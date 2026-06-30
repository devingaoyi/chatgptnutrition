import { Router } from "express";
import { z } from "zod";
import { withTransaction } from "../db.js";
import { ApiError, asyncHandler } from "../http.js";

export const entitlementsRouter = Router();

const redeemCouponSchema = z.object({
  userId: z.string().uuid(),
  code: z.string().trim().min(1).max(64),
});

const consumeQuerySchema = z.object({
  userId: z.string().uuid(),
  queryInput: z.string().trim().min(1).max(512),
  evidenceClaimId: z.string().uuid().optional(),
  shareLinkId: z.string().uuid().optional(),
});

entitlementsRouter.post(
  "/coupons/redeem",
  asyncHandler(async (req, res) => {
    const body = redeemCouponSchema.parse(req.body);
    const couponCode = body.code.toUpperCase();

    const redemption = await withTransaction(async (client) => {
      const userResult = await client.query("select id from users where id = $1 and status = 'active'", [
        body.userId,
      ]);
      if (!userResult.rows[0]) {
        throw new ApiError(404, "user_not_found", "User was not found.");
      }

      const couponResult = await client.query(
        `
        select *
        from coupons
        where code = $1
          and status = 'active'
          and (starts_at is null or starts_at <= now())
          and (expires_at is null or expires_at > now())
        for update
        `,
        [couponCode],
      );
      const coupon = couponResult.rows[0];
      if (!coupon) {
        throw new ApiError(404, "coupon_not_found", "Coupon was not found or is inactive.");
      }
      if (coupon.coupon_type !== "query_credit") {
        throw new ApiError(400, "unsupported_coupon_type", "Only query credit coupons are supported now.");
      }

      const totalRedemptions = await client.query(
        "select count(*)::int as count from coupon_redemptions where coupon_id = $1",
        [coupon.id],
      );
      if (coupon.max_redemptions && totalRedemptions.rows[0].count >= coupon.max_redemptions) {
        throw new ApiError(409, "coupon_exhausted", "Coupon redemption limit has been reached.");
      }

      const userRedemptions = await client.query(
        "select count(*)::int as count from coupon_redemptions where coupon_id = $1 and user_id = $2",
        [coupon.id, body.userId],
      );
      if (userRedemptions.rows[0].count >= coupon.per_user_limit) {
        throw new ApiError(409, "coupon_already_redeemed", "User has already redeemed this coupon.");
      }

      const entitlementResult = await client.query(
        `
        insert into query_entitlements
          (user_id, total_count, used_count, source, source_ref_type, source_ref_id, expires_at)
        values
          ($1, $2, 0, 'coupon', 'coupon', $3, $4)
        returning *
        `,
        [body.userId, coupon.query_count, coupon.id, coupon.expires_at],
      );
      const entitlement = entitlementResult.rows[0];

      const redemptionResult = await client.query(
        `
        insert into coupon_redemptions
          (coupon_id, user_id, entitlement_id, snapshot_code)
        values ($1, $2, $3, $4)
        returning *
        `,
        [coupon.id, body.userId, entitlement.id, coupon.code],
      );

      return {
        coupon: {
          id: coupon.id,
          code: coupon.code,
          name: coupon.name,
        },
        entitlement,
        redemption: redemptionResult.rows[0],
      };
    });

    res.status(201).json(redemption);
  }),
);

entitlementsRouter.post(
  "/queries/consume",
  asyncHandler(async (req, res) => {
    const body = consumeQuerySchema.parse(req.body);

    const result = await withTransaction(async (client) => {
      const entitlementResult = await client.query(
        `
        select *
        from query_entitlements
        where user_id = $1
          and used_count < total_count
          and (expires_at is null or expires_at > now())
        order by expires_at nulls last, created_at
        limit 1
        for update
        `,
        [body.userId],
      );
      const entitlement = entitlementResult.rows[0];
      if (!entitlement) {
        throw new ApiError(402, "no_query_entitlement", "User has no remaining query entitlement.");
      }

      if (body.evidenceClaimId) {
        const claimResult = await client.query(
          "select id from evidence_claims where id = $1 and status in ('published', 'draft')",
          [body.evidenceClaimId],
        );
        if (!claimResult.rows[0]) {
          throw new ApiError(404, "claim_not_found", "Evidence claim was not found.");
        }
      }

      const updatedEntitlement = await client.query(
        `
        update query_entitlements
        set used_count = used_count + 1
        where id = $1
        returning *, total_count - used_count as remaining_count
        `,
        [entitlement.id],
      );

      const consumption = await client.query(
        `
        insert into query_consumptions
          (user_id, entitlement_id, evidence_claim_id, query_input, share_link_id)
        values ($1, $2, $3, $4, $5)
        returning *
        `,
        [
          body.userId,
          entitlement.id,
          body.evidenceClaimId ?? null,
          body.queryInput,
          body.shareLinkId ?? null,
        ],
      );

      return {
        entitlement: updatedEntitlement.rows[0],
        consumption: consumption.rows[0],
      };
    });

    res.status(201).json(result);
  }),
);
