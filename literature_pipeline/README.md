# Literature Pipeline

This pipeline collects candidate evidence from open APIs. It does not publish evidence claims.

## Sources

- PubMed via NCBI E-utilities: ESearch for PMID discovery and EFetch XML for citation metadata.
- Europe PMC Articles REST API: search endpoint for metadata and open-access/full-text indexed records.
- ClinicalTrials.gov Data API v2: studies endpoint for registered clinical trials.

## Basic Run

```powershell
python literature_pipeline/fetch_candidates.py `
  --ingredient "melatonin" `
  --target "sleep" `
  --ingredient-slug melatonin `
  --target-slug sleep `
  --ingredient-terms "褪黑素,melatonin" `
  --target-terms "sleep,insomnia,circadian" `
  --max-results 10 `
  --email "your-contact@example.com"
```

The output is a JSONL file under `literature_pipeline/output/`.

Convert a reviewed or triage-ready JSONL artifact into an import SQL file:

```powershell
python literature_pipeline/jsonl_to_sql.py `
  literature_pipeline/output/20260630T000000Z-melatonin-sleep.jsonl `
  --output literature_pipeline/output/melatonin-sleep-import.sql
```

## Review Rules

1. Treat every output row as `unreviewed`.
2. Exclude animal-only, in-vitro-only, irrelevant population, irrelevant endpoint, and product-marketing materials unless they are being kept as mechanism-only background.
3. Prioritize systematic reviews, meta-analyses, randomized controlled trials, clinical guidelines, and official fact sheets.
4. Extract PICO manually or with expert-assisted tooling, then store the reviewed extraction in `literature_extractions`.
5. Only after expert review should a record be linked to `evidence_claim_literatures`.

## Database Mapping

- `record_type = import_job` maps to `literature_import_jobs`.
- `record_type = candidate` maps to `literatures` plus `literature_import_results`.
- Reviewers then create `literature_extractions`.
- Accepted extractions can support or challenge `evidence_claims` through `evidence_claim_literatures`.

## Important Limitation

Candidate score is a triage signal, not evidence strength. Evidence strength must be decided from reviewed PICO, risk of bias, directness, consistency, effect size, and safety context.
