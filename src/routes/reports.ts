import { Router } from "express";
import { z } from "zod";
import { config } from "../config.js";
import { query } from "../db.js";
import { ApiError, asyncHandler } from "../http.js";

export const reportsRouter = Router();

const slugSchema = z.object({
  slug: z.string().trim().min(1).max(128),
});

function visibleClaimCondition(alias = "ec") {
  return config.showDraftClaims
    ? `${alias}.status in ('published', 'draft')`
    : `${alias}.status = 'published'`;
}

const claimSelect = `
  ec.id,
  ec.title,
  ec.population,
  ec.outcome_metric,
  ec.evidence_strength,
  ec.feasibility,
  ec.safety_risk,
  ec.public_conclusion,
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
  ec.reviewed_at,
  ec.next_review_at,
  i.slug as ingredient_slug,
  i.name_cn as ingredient_name_cn,
  i.name_en as ingredient_name_en,
  h.slug as health_target_slug,
  h.name as health_target_name,
  h.compliant_name as health_target_compliant_name
`;

reportsRouter.get(
  "/ingredients/:slug",
  asyncHandler(async (req, res) => {
    const { slug } = slugSchema.parse(req.params);
    const ingredientResult = await query(
      `
      select id, slug, name_cn, name_en, category, common_forms, summary, safety_note, status
      from ingredients
      where slug = $1 and status = 'active'
      `,
      [slug],
    );
    const ingredient = ingredientResult.rows[0];
    if (!ingredient) {
      throw new ApiError(404, "ingredient_not_found", "Ingredient was not found.");
    }

    const claims = await query(
      `
      select ${claimSelect}
      from evidence_claims ec
      join ingredients i on i.id = ec.ingredient_id
      join health_targets h on h.id = ec.health_target_id
      where ec.ingredient_id = $1 and ${visibleClaimCondition("ec")}
      order by
        case ec.evidence_strength
          when 'high' then 1
          when 'medium' then 2
          when 'low' then 3
          else 4
        end,
        h.name
      `,
      [ingredient.id],
    );

    res.json({
      ingredient,
      claims: claims.rows,
      draftVisible: config.showDraftClaims,
    });
  }),
);

reportsRouter.get(
  "/health-targets/:slug",
  asyncHandler(async (req, res) => {
    const { slug } = slugSchema.parse(req.params);
    const targetResult = await query(
      `
      select id, slug, name, compliant_name, description, risk_level, status
      from health_targets
      where slug = $1 and status = 'active'
      `,
      [slug],
    );
    const healthTarget = targetResult.rows[0];
    if (!healthTarget) {
      throw new ApiError(404, "health_target_not_found", "Health target was not found.");
    }

    const claims = await query(
      `
      select ${claimSelect}
      from evidence_claims ec
      join ingredients i on i.id = ec.ingredient_id
      join health_targets h on h.id = ec.health_target_id
      where ec.health_target_id = $1 and ${visibleClaimCondition("ec")}
      order by
        case ec.evidence_strength
          when 'high' then 1
          when 'medium' then 2
          when 'low' then 3
          else 4
        end,
        i.name_cn
      `,
      [healthTarget.id],
    );

    res.json({
      healthTarget,
      claims: claims.rows,
      draftVisible: config.showDraftClaims,
    });
  }),
);
