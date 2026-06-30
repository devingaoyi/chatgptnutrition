# Database

This directory contains the first PostgreSQL database draft for the nutrition evidence H5 product.

Apply in order:

```sql
\i database/schema.sql
\i database/seed.sql
```

If a database was already created from an earlier schema, apply:

```sql
\i database/migrations/001_literature_pipeline.sql
```

On Windows with PostgreSQL 17 installed, run the verification script:

```powershell
powershell -ExecutionPolicy Bypass -File database/verify_database.ps1
```

Important constraints:

- `evidence_claims` is the core table. A claim is scoped to ingredient, health target, population, dose, duration, and outcome.
- Seeded claims are marked as `draft`. They are product-scope placeholders and must not be treated as reviewed medical conclusions.
- Product records are only an input layer. Product labels should map back to ingredient dose and then to evidence claims.
- China mainland display wording should use `health_targets.compliant_name`, `health_target_aliases.display_rewrite`, and `evidence_claims.compliance_note`.
- The seed includes the 10 consumer-facing health directions plus 2 supporting nutrition directions: nutrient deficiency/status and maternal nutrition. This avoids incorrectly mapping iron, folic acid, and vitamin B12 into broad immune claims.
- `literature_import_results` and `literature_extractions` keep candidate screening and PICO extraction separate from published evidence claims.
