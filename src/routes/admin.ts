import { Router } from "express";
import { z } from "zod";
import { query, withTransaction } from "../db.js";
import { ApiError, asyncHandler } from "../http.js";

export const adminRouter = Router();

const claimStatusSchema = z.enum(["draft", "pending_review", "published", "needs_review", "withdrawn"]);

adminRouter.get(
  "/evidence-claims",
  asyncHandler(async (req, res) => {
    const status = claimStatusSchema.optional().parse(req.query.status);
    const result = await query(
      `
      select
        ec.id,
        ec.title,
        ec.evidence_strength,
        ec.feasibility,
        ec.safety_risk,
        ec.status,
        ec.version,
        ec.updated_at,
        i.slug as ingredient_slug,
        i.name_cn as ingredient_name_cn,
        h.slug as health_target_slug,
        h.name as health_target_name
      from evidence_claims ec
      join ingredients i on i.id = ec.ingredient_id
      join health_targets h on h.id = ec.health_target_id
      where ($1::claim_status is null or ec.status = $1::claim_status)
      order by ec.updated_at desc
      limit 100
      `,
      [status ?? null],
    );

    res.json({ claims: result.rows });
  }),
);

adminRouter.patch(
  "/evidence-claims/:id/status",
  asyncHandler(async (req, res) => {
    const params = z.object({ id: z.string().uuid() }).parse(req.params);
    const body = z
      .object({
        status: claimStatusSchema,
        reviewerId: z.string().uuid().optional(),
      })
      .parse(req.body);

    const result = await query(
      `
      update evidence_claims
      set
        status = $2,
        reviewed_by = case when $2 = 'published' then $3 else reviewed_by end,
        reviewed_at = case when $2 = 'published' then now() else reviewed_at end,
        version = version + 1
      where id = $1
      returning *
      `,
      [params.id, body.status, body.reviewerId ?? null],
    );

    if (!result.rows[0]) {
      throw new ApiError(404, "claim_not_found", "Evidence claim was not found.");
    }

    res.json({ claim: result.rows[0] });
  }),
);

adminRouter.get(
  "/literature/import-jobs",
  asyncHandler(async (_req, res) => {
    const result = await query(
      `
      select
        lij.id,
        lij.source,
        lij.query,
        lij.status,
        lij.result_count,
        lij.error_message,
        lij.created_at,
        i.slug as ingredient_slug,
        i.name_cn as ingredient_name_cn,
        h.slug as health_target_slug,
        h.name as health_target_name
      from literature_import_jobs lij
      left join ingredients i on i.id = lij.ingredient_id
      left join health_targets h on h.id = lij.health_target_id
      order by lij.created_at desc
      limit 100
      `,
    );

    res.json({ jobs: result.rows });
  }),
);

adminRouter.post(
  "/literature/import-jsonl",
  asyncHandler(async (req, res) => {
    const body = z.object({ jsonl: z.string().min(1) }).parse(req.body);
    const records = body.jsonl
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter(Boolean)
      .map((line) => JSON.parse(line) as Record<string, unknown>);

    const jobRecord = records.find((record) => record.record_type === "import_job");
    const candidates = records.filter((record) => record.record_type === "candidate");
    if (!jobRecord) {
      throw new ApiError(400, "import_job_missing", "JSONL payload does not contain an import_job record.");
    }

    const imported = await withTransaction(async (client) => {
      const ingredientResult = await client.query(
        "select id from ingredients where slug = $1",
        [jobRecord.ingredient_slug ?? null],
      );
      const targetResult = await client.query(
        "select id from health_targets where slug = $1",
        [jobRecord.health_target_slug ?? null],
      );

      const importJob = await client.query(
        `
        insert into literature_import_jobs
          (ingredient_id, health_target_id, source, query, status, result_count, finished_at)
        values ($1, $2, 'api_jsonl', $3, 'succeeded', $4, now())
        returning *
        `,
        [
          ingredientResult.rows[0]?.id ?? null,
          targetResult.rows[0]?.id ?? null,
          JSON.stringify(jobRecord.queries ?? {}),
          candidates.length,
        ],
      );
      const job = importJob.rows[0];

      let importedCount = 0;
      for (const candidate of candidates) {
        const existing = await client.query(
          `
          select id
          from literatures
          where
            ($1::varchar is not null and pmid = $1)
            or ($2::varchar is not null and lower(doi) = lower($2))
            or ($3::text is not null and url = $3)
          limit 1
          `,
          [candidate.pmid ?? null, candidate.doi ?? null, candidate.url ?? null],
        );

        let literatureId = existing.rows[0]?.id as string | undefined;
        if (!literatureId) {
          const inserted = await client.query(
            `
            insert into literatures
              (title, year, journal, study_type, pmid, doi, url, abstract, population, sample_size, intervention, comparator, outcomes, limitations, source)
            values
              ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
            returning id
            `,
            [
              candidate.title ?? "Untitled literature record",
              candidate.year ?? null,
              candidate.journal ?? null,
              candidate.study_type ?? "other",
              candidate.pmid ?? null,
              candidate.doi ?? null,
              candidate.url ?? null,
              candidate.abstract ?? null,
              candidate.population ?? null,
              candidate.sample_size ?? null,
              candidate.intervention ?? null,
              candidate.comparator ?? null,
              candidate.outcomes ?? null,
              candidate.limitations ?? null,
              candidate.source ?? "api_jsonl",
            ],
          );
          literatureId = inserted.rows[0].id;
        }

        await client.query(
          `
          insert into literature_import_results
            (import_job_id, literature_id, external_source, external_id, candidate_score, raw_payload)
          values ($1, $2, $3, $4, $5, $6::jsonb)
          on conflict (import_job_id, external_source, external_id) do nothing
          `,
          [
            job.id,
            literatureId,
            candidate.source ?? "unknown",
            candidate.external_id ?? candidate.pmid ?? candidate.doi ?? candidate.title ?? "unknown",
            candidate.candidate_score ?? 0,
            JSON.stringify(candidate.raw_payload ?? {}),
          ],
        );
        importedCount += 1;
      }

      return { job, importedCount };
    });

    res.status(201).json(imported);
  }),
);
