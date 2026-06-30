import { Router } from "express";
import { z } from "zod";
import { query } from "../db.js";
import { asyncHandler } from "../http.js";

export const searchRouter = Router();

const searchQuerySchema = z.object({
  q: z.string().trim().min(1).max(128),
});

searchRouter.get(
  "/",
  asyncHandler(async (req, res) => {
    const { q } = searchQuerySchema.parse(req.query);
    const like = `%${q.toLowerCase()}%`;

    const [ingredients, healthTargets, products] = await Promise.all([
      query(
        `
        with matches as (
          select i.id, i.slug, i.name_cn, i.name_en, i.category, i.status,
                 i.name_cn as matched_term, 'ingredient' as match_source, 100 as priority
          from ingredients i
          where i.status = 'active'
            and (lower(i.name_cn) like $1 or lower(coalesce(i.name_en, '')) like $1)
          union all
          select i.id, i.slug, i.name_cn, i.name_en, i.category, i.status,
                 ia.alias as matched_term, 'alias' as match_source, ia.priority
          from ingredient_aliases ia
          join ingredients i on i.id = ia.ingredient_id
          where i.status = 'active' and lower(ia.alias) like $1
        )
        select distinct on (id) id, slug, name_cn, name_en, category, matched_term, match_source
        from matches
        order by id, priority desc, matched_term
        limit 10
        `,
        [like],
      ),
      query(
        `
        with matches as (
          select h.id, h.slug, h.name, h.compliant_name, h.risk_level, h.status,
                 h.name as matched_term, 'health_target' as match_source, false as is_sensitive
          from health_targets h
          where h.status = 'active'
            and (lower(h.name) like $1 or lower(h.compliant_name) like $1)
          union all
          select h.id, h.slug, h.name, h.compliant_name, h.risk_level, h.status,
                 ha.alias as matched_term, 'alias' as match_source, ha.is_sensitive
          from health_target_aliases ha
          join health_targets h on h.id = ha.health_target_id
          where h.status = 'active'
            and ha.blocked_term = false
            and lower(ha.alias) like $1
        )
        select distinct on (id) id, slug, name, compliant_name, risk_level, matched_term, match_source, is_sensitive
        from matches
        order by id, is_sensitive desc, matched_term
        limit 10
        `,
        [like],
      ),
      query(
        `
        select id, brand, name, normalized_name, product_type, label_verified, status
        from products
        where status <> 'hidden'
          and (lower(name) like $1 or lower(coalesce(brand, '')) like $1 or lower(normalized_name) like $1)
        order by label_verified desc, name
        limit 10
        `,
        [like],
      ),
    ]);

    res.json({
      query: q,
      ingredients: ingredients.rows,
      healthTargets: healthTargets.rows,
      products: products.rows,
    });
  }),
);
