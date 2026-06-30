#!/usr/bin/env python3
"""Convert a candidate JSONL artifact into an idempotent PostgreSQL import script."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


def sql_literal(value: Any) -> str:
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, (int, float)):
        return str(value)
    text = str(value)
    return "'" + text.replace("'", "''") + "'"


def jsonb_literal(value: Any) -> str:
    text = json.dumps(value if value is not None else {}, ensure_ascii=False)
    return sql_literal(text) + "::jsonb"


def load_records(path: Path) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    job: dict[str, Any] | None = None
    candidates: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8") as handle:
        for line in handle:
            if not line.strip():
                continue
            record = json.loads(line)
            if record.get("record_type") == "import_job":
                job = record
            elif record.get("record_type") == "candidate":
                candidates.append(record)
    if job is None:
        raise ValueError("JSONL file does not contain an import_job record")
    return job, candidates


def lit_match_condition(candidate: dict[str, Any]) -> str:
    clauses = []
    if candidate.get("pmid"):
        clauses.append(f"pmid = {sql_literal(candidate['pmid'])}")
    if candidate.get("doi"):
        clauses.append(f"lower(doi) = lower({sql_literal(candidate['doi'])})")
    if candidate.get("url"):
        clauses.append(f"url = {sql_literal(candidate['url'])}")
    if not clauses:
        clauses.append(f"title = {sql_literal(candidate.get('title'))}")
    return " OR ".join(clauses)


def emit_sql(job: dict[str, Any], candidates: list[dict[str, Any]]) -> str:
    query_summary = json.dumps(job.get("queries", {}), ensure_ascii=False)
    lines = [
        "BEGIN;",
        "DO $$",
        "DECLARE",
        "  v_job_id uuid;",
        "  v_literature_id uuid;",
        "  v_ingredient_id uuid;",
        "  v_health_target_id uuid;",
        "BEGIN",
        f"  SELECT id INTO v_ingredient_id FROM ingredients WHERE slug = {sql_literal(job.get('ingredient_slug'))};",
        f"  SELECT id INTO v_health_target_id FROM health_targets WHERE slug = {sql_literal(job.get('health_target_slug'))};",
        "  INSERT INTO literature_import_jobs (ingredient_id, health_target_id, source, query, status, result_count, finished_at)",
        (
            "  VALUES (v_ingredient_id, v_health_target_id, "
            f"{sql_literal('pipeline')}, {sql_literal(query_summary)}, 'succeeded', {len(candidates)}, now())"
        ),
        "  RETURNING id INTO v_job_id;",
    ]

    for candidate in candidates:
        lines.extend(
            [
                "",
                f"  SELECT id INTO v_literature_id FROM literatures WHERE {lit_match_condition(candidate)} LIMIT 1;",
                "  IF v_literature_id IS NULL THEN",
                "    INSERT INTO literatures (title, year, journal, study_type, pmid, doi, url, abstract, population, sample_size, intervention, comparator, outcomes, limitations, source)",
                "    VALUES ("
                + ", ".join(
                    [
                        sql_literal(candidate.get("title")),
                        sql_literal(candidate.get("year")),
                        sql_literal(candidate.get("journal")),
                        sql_literal(candidate.get("study_type") or "other"),
                        sql_literal(candidate.get("pmid")),
                        sql_literal(candidate.get("doi")),
                        sql_literal(candidate.get("url")),
                        sql_literal(candidate.get("abstract")),
                        sql_literal(candidate.get("population")),
                        sql_literal(candidate.get("sample_size")),
                        sql_literal(candidate.get("intervention")),
                        sql_literal(candidate.get("comparator")),
                        sql_literal(candidate.get("outcomes")),
                        sql_literal(candidate.get("limitations")),
                        sql_literal(candidate.get("source") or "pipeline"),
                    ]
                )
                + ")",
                "    RETURNING id INTO v_literature_id;",
                "  END IF;",
                "  INSERT INTO literature_import_results (import_job_id, literature_id, external_source, external_id, candidate_score, raw_payload)",
                "  VALUES ("
                + ", ".join(
                    [
                        "v_job_id",
                        "v_literature_id",
                        sql_literal(candidate.get("source")),
                        sql_literal(candidate.get("external_id")),
                        sql_literal(candidate.get("candidate_score") or 0),
                        jsonb_literal(candidate.get("raw_payload")),
                    ]
                )
                + ")",
                "  ON CONFLICT (import_job_id, external_source, external_id) DO NOTHING;",
            ]
        )

    lines.extend(["END $$;", "COMMIT;"])
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Convert candidate JSONL to PostgreSQL SQL.")
    parser.add_argument("jsonl", help="Path to candidate JSONL from fetch_candidates.py.")
    parser.add_argument("--output", help="Optional output SQL path. Defaults to stdout.")
    args = parser.parse_args()

    job, candidates = load_records(Path(args.jsonl))
    sql = emit_sql(job, candidates)
    if args.output:
        Path(args.output).write_text(sql, encoding="utf-8")
    else:
        sys.stdout.write(sql)
    return 0


if __name__ == "__main__":
    sys.exit(main())
