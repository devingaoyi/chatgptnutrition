import { Router } from "express";
import { z } from "zod";
import { config } from "../config.js";
import { query } from "../db.js";
import { ApiError, asyncHandler } from "../http.js";

export const claimsRouter = Router();

const paramsSchema = z.object({
  id: z.string().uuid(),
});

claimsRouter.get(
  "/:id",
  asyncHandler(async (req, res) => {
    const { id } = paramsSchema.parse(req.params);
    const allowedStatuses = config.showDraftClaims ? ["published", "draft"] : ["published"];

    const claimResult = await query(
      `
      select
        ec.*,
        i.slug as ingredient_slug,
        i.name_cn as ingredient_name_cn,
        i.name_en as ingredient_name_en,
        h.slug as health_target_slug,
        h.name as health_target_name,
        h.compliant_name as health_target_compliant_name
      from evidence_claims ec
      join ingredients i on i.id = ec.ingredient_id
      join health_targets h on h.id = ec.health_target_id
      where ec.id = $1 and ec.status = any($2::claim_status[])
      `,
      [id, allowedStatuses],
    );
    const claim = claimResult.rows[0];
    if (!claim) {
      throw new ApiError(404, "claim_not_found", "Evidence claim was not found.");
    }

    const literatureResult = await query(
      `
      select
        l.id,
        l.title,
        l.year,
        l.journal,
        l.study_type,
        l.pmid,
        l.doi,
        l.url,
        ecl.evidence_role,
        ecl.weight,
        ecl.extracted_dose,
        ecl.extracted_duration,
        ecl.extracted_result,
        ecl.reviewer_note
      from evidence_claim_literatures ecl
      join literatures l on l.id = ecl.literature_id
      where ecl.evidence_claim_id = $1
      order by ecl.weight desc, l.year desc nulls last
      `,
      [id],
    );

    res.json({
      claim,
      literatures: literatureResult.rows,
      draftVisible: config.showDraftClaims,
    });
  }),
);
