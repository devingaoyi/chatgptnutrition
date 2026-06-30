#!/usr/bin/env python3
"""
Fetch candidate nutrition evidence from open literature APIs.

This script writes reviewable JSONL artifacts instead of publishing records
directly. A later backend job can insert accepted candidates into literatures,
literature_import_jobs, and literature_import_results.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any


USER_AGENT = "chatgptnutrition-literature-pipeline/0.1"
NCBI_BASE = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils"
EUROPE_PMC_SEARCH = "https://www.ebi.ac.uk/europepmc/webservices/rest/search"
CLINICALTRIALS_STUDIES = "https://clinicaltrials.gov/api/v2/studies"


@dataclass
class Candidate:
    source: str
    external_id: str
    title: str
    year: int | None = None
    journal: str | None = None
    study_type: str = "other"
    pmid: str | None = None
    doi: str | None = None
    url: str | None = None
    abstract: str | None = None
    population: str | None = None
    sample_size: int | None = None
    intervention: str | None = None
    comparator: str | None = None
    outcomes: str | None = None
    limitations: str | None = None
    candidate_score: float = 0
    raw_payload: dict[str, Any] = field(default_factory=dict)


def request_json(url: str, params: dict[str, Any], timeout: int = 30) -> Any:
    query = urllib.parse.urlencode({k: v for k, v in params.items() if v is not None})
    req = urllib.request.Request(
        f"{url}?{query}",
        headers={"User-Agent": USER_AGENT, "Accept": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=timeout) as response:
        return json.loads(response.read().decode("utf-8"))


def request_xml(url: str, params: dict[str, Any], timeout: int = 30) -> ET.Element:
    query = urllib.parse.urlencode({k: v for k, v in params.items() if v is not None})
    req = urllib.request.Request(
        f"{url}?{query}",
        headers={"User-Agent": USER_AGENT, "Accept": "application/xml"},
    )
    with urllib.request.urlopen(req, timeout=timeout) as response:
        return ET.fromstring(response.read())


def text_or_none(node: ET.Element | None) -> str | None:
    if node is None:
        return None
    text = "".join(node.itertext()).strip()
    return re.sub(r"\s+", " ", text) if text else None


def first_int(value: str | None) -> int | None:
    if not value:
        return None
    match = re.search(r"(19|20)\d{2}", value)
    return int(match.group(0)) if match else None


def classify_study_type(text: str) -> str:
    lowered = text.lower()
    if "meta-analysis" in lowered or "meta analysis" in lowered:
        return "meta_analysis"
    if "systematic review" in lowered:
        return "systematic_review"
    if "randomized controlled trial" in lowered or "randomised controlled trial" in lowered:
        return "rct"
    if "randomized" in lowered or "randomised" in lowered or "placebo-controlled" in lowered:
        return "rct"
    if "guideline" in lowered or "consensus" in lowered or "position stand" in lowered:
        return "guideline"
    if "cohort" in lowered or "case-control" in lowered or "cross-sectional" in lowered:
        return "observational"
    if "trial" in lowered and "registry" in lowered:
        return "clinical_trial_registry"
    if "animal" in lowered or "in vitro" in lowered or "mechanism" in lowered:
        return "mechanism"
    return "other"


def score_candidate(candidate: Candidate, ingredient_terms: list[str], target_terms: list[str]) -> float:
    score_by_type = {
        "meta_analysis": 90,
        "systematic_review": 85,
        "guideline": 80,
        "rct": 75,
        "clinical_trial_registry": 55,
        "observational": 45,
        "official_fact_sheet": 45,
        "mechanism": 15,
        "other": 25,
    }
    text = " ".join([candidate.title or "", candidate.abstract or "", candidate.outcomes or ""]).lower()
    score = score_by_type.get(candidate.study_type, 25)
    if any(term.lower() in text for term in ingredient_terms):
        score += 8
    if any(term.lower() in text for term in target_terms):
        score += 8
    if candidate.abstract:
        score += 2
    if candidate.year and candidate.year >= dt.datetime.now().year - 5:
        score += 3
    return min(score, 100)


def fetch_pubmed(
    query: str,
    retmax: int,
    email: str | None,
    api_key: str | None,
    ingredient_terms: list[str],
    target_terms: list[str],
) -> list[Candidate]:
    search_data = request_json(
        f"{NCBI_BASE}/esearch.fcgi",
        {
            "db": "pubmed",
            "term": query,
            "retmode": "json",
            "retmax": retmax,
            "sort": "relevance",
            "tool": "chatgptnutrition",
            "email": email,
            "api_key": api_key,
        },
    )
    ids = search_data.get("esearchresult", {}).get("idlist", [])
    if not ids:
        return []

    time.sleep(0.34)
    root = request_xml(
        f"{NCBI_BASE}/efetch.fcgi",
        {
            "db": "pubmed",
            "id": ",".join(ids),
            "retmode": "xml",
            "tool": "chatgptnutrition",
            "email": email,
            "api_key": api_key,
        },
    )

    candidates: list[Candidate] = []
    for article in root.findall(".//PubmedArticle"):
        medline = article.find("MedlineCitation")
        article_node = medline.find("Article") if medline is not None else None
        if medline is None or article_node is None:
            continue

        pmid = text_or_none(medline.find("PMID"))
        title = text_or_none(article_node.find("ArticleTitle")) or "Untitled PubMed record"
        abstract_parts = []
        for part in article_node.findall("Abstract/AbstractText"):
            part_text = text_or_none(part)
            if part_text:
                abstract_parts.append(part_text)
        abstract = " ".join(abstract_parts) if abstract_parts else None
        journal = (
            text_or_none(article_node.find("Journal/Title"))
            or text_or_none(article_node.find("Journal/ISOAbbreviation"))
        )
        year = (
            first_int(text_or_none(article_node.find("Journal/JournalIssue/PubDate/Year")))
            or first_int(text_or_none(article_node.find("Journal/JournalIssue/PubDate/MedlineDate")))
        )
        pub_types = [
            text_or_none(item) or ""
            for item in article_node.findall("PublicationTypeList/PublicationType")
        ]
        doi = None
        for article_id in article.findall(".//ArticleIdList/ArticleId"):
            if article_id.attrib.get("IdType") == "doi":
                doi = text_or_none(article_id)
                break
        classifier_text = " ".join([title, abstract or "", " ".join(pub_types)])
        candidate = Candidate(
            source="PubMed",
            external_id=pmid or title,
            title=title,
            year=year,
            journal=journal,
            study_type=classify_study_type(classifier_text),
            pmid=pmid,
            doi=doi,
            url=f"https://pubmed.ncbi.nlm.nih.gov/{pmid}/" if pmid else None,
            abstract=abstract,
            raw_payload={"pmid": pmid, "publication_types": pub_types},
        )
        candidate.candidate_score = score_candidate(candidate, ingredient_terms, target_terms)
        candidates.append(candidate)
    return candidates


def fetch_europe_pmc(
    query: str,
    page_size: int,
    ingredient_terms: list[str],
    target_terms: list[str],
) -> list[Candidate]:
    data = request_json(
        EUROPE_PMC_SEARCH,
        {"query": query, "format": "json", "pageSize": page_size, "sort": "relevance"},
    )
    results = data.get("resultList", {}).get("result", [])
    candidates: list[Candidate] = []
    for item in results:
        title = item.get("title") or "Untitled Europe PMC record"
        pub_type = item.get("pubType") or item.get("pubTypeList") or ""
        abstract = item.get("abstractText")
        source = item.get("source") or "EuropePMC"
        external_id = item.get("id") or item.get("pmid") or item.get("doi") or title
        pmid = item.get("pmid") or (external_id if source == "MED" and str(external_id).isdigit() else None)
        doi = item.get("doi")
        candidate = Candidate(
            source="EuropePMC",
            external_id=str(external_id),
            title=title,
            year=first_int(item.get("pubYear")),
            journal=item.get("journalTitle"),
            study_type=classify_study_type(" ".join([title, abstract or "", str(pub_type)])),
            pmid=pmid,
            doi=doi,
            url=f"https://europepmc.org/article/{source}/{external_id}",
            abstract=abstract,
            raw_payload=item,
        )
        candidate.candidate_score = score_candidate(candidate, ingredient_terms, target_terms)
        candidates.append(candidate)
    return candidates


def fetch_clinical_trials(
    query: str,
    page_size: int,
    ingredient_terms: list[str],
    target_terms: list[str],
) -> list[Candidate]:
    data = request_json(
        CLINICALTRIALS_STUDIES,
        {"query.term": query, "pageSize": page_size, "format": "json"},
    )
    candidates: list[Candidate] = []
    for study in data.get("studies", []):
        protocol = study.get("protocolSection", {})
        identification = protocol.get("identificationModule", {})
        status = protocol.get("statusModule", {})
        description = protocol.get("descriptionModule", {})
        eligibility = protocol.get("eligibilityModule", {})
        interventions_module = protocol.get("armsInterventionsModule", {})
        outcomes_module = protocol.get("outcomesModule", {})

        nct_id = identification.get("nctId")
        title = identification.get("briefTitle") or identification.get("officialTitle") or nct_id
        interventions = interventions_module.get("interventions", []) or []
        intervention_text = "; ".join(
            filter(None, [item.get("name") for item in interventions if isinstance(item, dict)])
        )
        primary_outcomes = outcomes_module.get("primaryOutcomes", []) or []
        outcome_text = "; ".join(
            filter(None, [item.get("measure") for item in primary_outcomes if isinstance(item, dict)])
        )
        year = first_int(
            json.dumps(
                [
                    status.get("startDateStruct"),
                    status.get("completionDateStruct"),
                    status.get("lastUpdatePostDateStruct"),
                ],
                ensure_ascii=False,
            )
        )
        candidate = Candidate(
            source="ClinicalTrials.gov",
            external_id=nct_id or title or "unknown",
            title=title or "Untitled clinical trial",
            year=year,
            study_type="clinical_trial_registry",
            url=f"https://clinicaltrials.gov/study/{nct_id}" if nct_id else None,
            abstract=description.get("briefSummary"),
            population=eligibility.get("eligibilityCriteria"),
            intervention=intervention_text or None,
            outcomes=outcome_text or None,
            raw_payload=study,
        )
        candidate.candidate_score = score_candidate(candidate, ingredient_terms, target_terms)
        candidates.append(candidate)
    return candidates


def candidate_key(candidate: Candidate) -> str:
    if candidate.pmid:
        return f"pmid:{candidate.pmid}"
    if candidate.doi:
        return f"doi:{candidate.doi.lower()}"
    return f"{candidate.source}:{candidate.external_id}".lower()


def dedupe(candidates: list[Candidate]) -> list[Candidate]:
    seen: set[str] = set()
    deduped: list[Candidate] = []
    for candidate in sorted(candidates, key=lambda item: item.candidate_score, reverse=True):
        key = candidate_key(candidate)
        if key in seen:
            continue
        seen.add(key)
        deduped.append(candidate)
    return deduped


def build_queries(ingredient: str, target: str, extra_terms: str | None) -> dict[str, str]:
    base = f'("{ingredient}") AND ("{target}")'
    if extra_terms:
        base = f"{base} AND ({extra_terms})"
    return {
        "pubmed": f'{base} AND (meta-analysis[Publication Type] OR systematic review[Title/Abstract] OR randomized controlled trial[Publication Type] OR randomized[Title/Abstract])',
        "europepmc": f'{base} AND (SRC:MED OR SRC:PMC)',
        "clinicaltrials": f"{ingredient} {target}",
    }


def write_jsonl(path: Path, records: list[dict[str, Any]]) -> None:
    with path.open("w", encoding="utf-8") as handle:
        for record in records:
            handle.write(json.dumps(record, ensure_ascii=False, sort_keys=True) + "\n")


def parse_terms(raw: str) -> list[str]:
    return [item.strip() for item in raw.split(",") if item.strip()]


def main() -> int:
    parser = argparse.ArgumentParser(description="Fetch candidate nutrition evidence.")
    parser.add_argument("--ingredient", required=True, help="Primary ingredient search term.")
    parser.add_argument("--target", required=True, help="Primary health target search term.")
    parser.add_argument("--ingredient-slug", help="Ingredient slug from ingredients.slug.")
    parser.add_argument("--target-slug", help="Health target slug from health_targets.slug.")
    parser.add_argument("--ingredient-terms", default="", help="Comma-separated ingredient aliases for scoring.")
    parser.add_argument("--target-terms", default="", help="Comma-separated target aliases for scoring.")
    parser.add_argument("--extra-terms", help="Additional query constraints.")
    parser.add_argument("--sources", default="pubmed,europepmc,clinicaltrials")
    parser.add_argument("--max-results", type=int, default=25)
    parser.add_argument("--email", help="NCBI contact email. Recommended by NCBI.")
    parser.add_argument("--ncbi-api-key", help="Optional NCBI API key.")
    parser.add_argument("--output-dir", default="literature_pipeline/output")
    args = parser.parse_args()

    source_names = {item.strip().lower() for item in args.sources.split(",") if item.strip()}
    ingredient_terms = [args.ingredient] + parse_terms(args.ingredient_terms)
    target_terms = [args.target] + parse_terms(args.target_terms)
    queries = build_queries(args.ingredient, args.target, args.extra_terms)

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    timestamp = dt.datetime.now(dt.UTC).strftime("%Y%m%dT%H%M%SZ")
    slug_part = "-".join(filter(None, [args.ingredient_slug, args.target_slug])) or "manual-query"
    output_path = output_dir / f"{timestamp}-{slug_part}.jsonl"

    all_candidates: list[Candidate] = []
    errors: list[dict[str, str]] = []

    for source in ("pubmed", "europepmc", "clinicaltrials"):
        if source not in source_names:
            continue
        try:
            if source == "pubmed":
                all_candidates.extend(
                    fetch_pubmed(
                        queries[source],
                        args.max_results,
                        args.email,
                        args.ncbi_api_key,
                        ingredient_terms,
                        target_terms,
                    )
                )
            elif source == "europepmc":
                all_candidates.extend(
                    fetch_europe_pmc(
                        queries[source],
                        args.max_results,
                        ingredient_terms,
                        target_terms,
                    )
                )
            elif source == "clinicaltrials":
                all_candidates.extend(
                    fetch_clinical_trials(
                        queries[source],
                        min(args.max_results, 100),
                        ingredient_terms,
                        target_terms,
                    )
                )
        except (urllib.error.URLError, TimeoutError, ET.ParseError, json.JSONDecodeError) as exc:
            errors.append({"source": source, "error": str(exc)})

    candidates = dedupe(all_candidates)
    job = {
        "record_type": "import_job",
        "created_at": timestamp,
        "ingredient_slug": args.ingredient_slug,
        "health_target_slug": args.target_slug,
        "ingredient": args.ingredient,
        "target": args.target,
        "queries": queries,
        "sources": sorted(source_names),
        "result_count": len(candidates),
        "errors": errors,
    }
    records = [job] + [
        {
            "record_type": "candidate",
            "ingredient_slug": args.ingredient_slug,
            "health_target_slug": args.target_slug,
            **asdict(candidate),
        }
        for candidate in candidates
    ]
    write_jsonl(output_path, records)

    print(json.dumps({"output": str(output_path), "candidates": len(candidates), "errors": errors}, ensure_ascii=False))
    return 0 if not errors else 2


if __name__ == "__main__":
    sys.exit(main())
