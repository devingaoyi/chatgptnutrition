import fs from "node:fs/promises";
import path from "node:path";
import pg from "pg";

const databaseUrl =
  process.env.DATABASE_URL ??
  "postgresql://postgres:postgres@localhost:5432/chatgptnutrition_dev";

const outputPath = process.argv[2] ?? "data/demo_data.json";

const pool = new pg.Pool({ connectionString: databaseUrl });

function byId(rows) {
  return new Map(rows.map((row) => [row.id, row]));
}

async function main() {
  const [
    ingredientsResult,
    ingredientAliasesResult,
    healthTargetsResult,
    healthTargetAliasesResult,
    claimsResult,
    literatureLinksResult,
  ] = await Promise.all([
    pool.query(`
      select id::text, slug, name_cn, name_en, category, common_forms, summary, safety_note
      from ingredients
      where status = 'active'
      order by name_cn
    `),
    pool.query(`
      select ingredient_id::text, alias, language, priority
      from ingredient_aliases
      order by priority desc, alias
    `),
    pool.query(`
      select id::text, slug, name, compliant_name, description, risk_level
      from health_targets
      where status = 'active'
      order by name
    `),
    pool.query(`
      select health_target_id::text, alias, display_rewrite, is_sensitive, blocked_term
      from health_target_aliases
      where blocked_term = false
      order by alias
    `),
    pool.query(`
      select
        ec.id::text,
        ec.ingredient_id::text,
        ec.health_target_id::text,
        ec.title,
        ec.population,
        ec.outcome_metric,
        ec.evidence_strength,
        ec.feasibility,
        ec.safety_risk,
        ec.public_conclusion,
        ec.professional_conclusion,
        ec.dose_min,
        ec.dose_max,
        ec.dose_unit,
        ec.dose_note,
        ec.duration_min,
        ec.duration_max,
        ec.duration_unit,
        ec.effect_size_summary,
        ec.applicability,
        ec.cautions,
        ec.common_misunderstanding,
        ec.compliance_note,
        ec.status,
        ec.version,
        i.slug as ingredient_slug,
        i.name_cn as ingredient_name_cn,
        i.name_en as ingredient_name_en,
        i.category as ingredient_category,
        h.slug as health_target_slug,
        h.name as health_target_name,
        h.compliant_name as health_target_compliant_name
      from evidence_claims ec
      join ingredients i on i.id = ec.ingredient_id
      join health_targets h on h.id = ec.health_target_id
      where ec.status in ('draft', 'published')
      order by i.name_cn, h.name, ec.title
    `),
    pool.query(`
      select
        ecl.evidence_claim_id::text,
        ecl.evidence_role,
        ecl.weight,
        ecl.extracted_dose,
        ecl.extracted_duration,
        ecl.extracted_result,
        ecl.reviewer_note,
        l.id::text,
        l.title,
        l.year,
        l.journal,
        l.study_type,
        l.pmid,
        l.doi,
        l.url,
        l.abstract,
        l.population,
        l.intervention,
        l.outcomes,
        l.limitations
      from evidence_claim_literatures ecl
      join literatures l on l.id = ecl.literature_id
      order by ecl.weight desc, l.year desc nulls last
    `),
  ]);

  const ingredients = ingredientsResult.rows;
  const healthTargets = healthTargetsResult.rows;
  const claims = claimsResult.rows.map((claim) => ({ ...claim, literatures: [] }));
  const claimMap = byId(claims);

  for (const ingredient of ingredients) {
    ingredient.aliases = ingredientAliasesResult.rows
      .filter((alias) => alias.ingredient_id === ingredient.id)
      .map(({ alias, language, priority }) => ({ alias, language, priority }));
  }

  for (const target of healthTargets) {
    target.aliases = healthTargetAliasesResult.rows
      .filter((alias) => alias.health_target_id === target.id)
      .map(({ alias, display_rewrite, is_sensitive }) => ({
        alias,
        display_rewrite,
        is_sensitive,
      }));
  }

  for (const link of literatureLinksResult.rows) {
    const claim = claimMap.get(link.evidence_claim_id);
    if (!claim) {
      continue;
    }
    claim.literatures.push({
      id: link.id,
      title: link.title,
      year: link.year,
      journal: link.journal,
      study_type: link.study_type,
      pmid: link.pmid,
      doi: link.doi,
      url: link.url,
      abstract: link.abstract,
      population: link.population,
      intervention: link.intervention,
      outcomes: link.outcomes,
      limitations: link.limitations,
      evidence_role: link.evidence_role,
      weight: link.weight,
      extracted_dose: link.extracted_dose,
      extracted_duration: link.extracted_duration,
      extracted_result: link.extracted_result,
      reviewer_note: link.reviewer_note,
    });
  }

  const data = {
    metadata: {
      generated_at: new Date().toISOString(),
      source: "chatgptnutrition_dev",
      note: "Read-only Streamlit demo data. Draft claims require expert review before publication.",
    },
    ingredients,
    health_targets: healthTargets,
    claims,
  };

  await fs.mkdir(path.dirname(outputPath), { recursive: true });
  await fs.writeFile(outputPath, JSON.stringify(data, null, 2), "utf8");
  await pool.end();

  console.log(`Exported ${ingredients.length} ingredients, ${healthTargets.length} health targets, ${claims.length} claims to ${outputPath}`);
}

main().catch(async (error) => {
  await pool.end().catch(() => undefined);
  console.error(error);
  process.exit(1);
});
