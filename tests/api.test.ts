import { afterAll, describe, expect, it } from "vitest";
import request from "supertest";
import type { Express } from "express";
import type pg from "pg";

process.env.ENABLE_ADMIN_ROUTES = "true";

const { createApp } = await import("../src/app.js");
const { pool } = await import("../src/db.js");
const app: Express = createApp();
const dbPool: pg.Pool = pool;

afterAll(async () => {
  await dbPool.end();
});

describe("nutrition evidence API", () => {
  it("responds to health checks", async () => {
    const response = await request(app).get("/health").expect(200);
    expect(response.body.status).toBe("ok");
  });

  it("serves the H5 entry page", async () => {
    const response = await request(app).get("/").expect(200);
    expect(response.text).toContain("营养品证据查询");
  });

  it("searches ingredients and health targets", async () => {
    const response = await request(app).get("/api/search").query({ q: "褪黑素" }).expect(200);
    expect(response.body.ingredients.length).toBeGreaterThan(0);
    expect(response.body.ingredients[0].slug).toBe("melatonin");
  });

  it("returns ingredient report claims", async () => {
    const response = await request(app).get("/api/reports/ingredients/melatonin").expect(200);
    expect(response.body.ingredient.slug).toBe("melatonin");
    expect(response.body.claims.length).toBeGreaterThan(0);
    expect(response.body.claims[0]).toHaveProperty("evidence_strength");
  });

  it("returns linked professional literature for the melatonin demo claim", async () => {
    const reportResponse = await request(app).get("/api/reports/ingredients/melatonin").expect(200);
    const claim = reportResponse.body.claims.find(
      (item: { title: string }) => item.title === "褪黑素与入睡时间",
    );
    expect(claim).toBeTruthy();

    const claimResponse = await request(app).get(`/api/evidence-claims/${claim.id}`).expect(200);
    expect(claimResponse.body.literatures.length).toBeGreaterThanOrEqual(2);
  });

  it("redeems a coupon and consumes one query entitlement", async () => {
    const userResponse = await request(app)
      .post("/api/users/dev")
      .send({ nickname: `test-user-${Date.now()}` })
      .expect(201);
    const userId = userResponse.body.user.id as string;

    const redeemResponse = await request(app)
      .post("/api/coupons/redeem")
      .send({ userId, code: "WELCOME3" })
      .expect(201);
    expect(Number(redeemResponse.body.entitlement.total_count)).toBe(3);

    const reportResponse = await request(app).get("/api/reports/ingredients/melatonin").expect(200);
    const evidenceClaimId = reportResponse.body.claims[0].id as string;

    const consumeResponse = await request(app)
      .post("/api/queries/consume")
      .send({ userId, evidenceClaimId, queryInput: "褪黑素" })
      .expect(201);
    expect(Number(consumeResponse.body.entitlement.remaining_count)).toBe(2);
  });

  it("imports candidate literature JSONL into review tables", async () => {
    const externalId = `TEST-${Date.now()}`;
    const jsonl = [
      {
        record_type: "import_job",
        ingredient_slug: "melatonin",
        health_target_slug: "sleep",
        queries: { test: "melatonin sleep" },
      },
      {
        record_type: "candidate",
        source: "TestSource",
        external_id: externalId,
        title: `Test melatonin sleep candidate ${externalId}`,
        year: 2026,
        study_type: "rct",
        candidate_score: 75,
        raw_payload: { externalId },
      },
    ]
      .map((record) => JSON.stringify(record))
      .join("\n");

    const response = await request(app)
      .post("/api/admin/literature/import-jsonl")
      .send({ jsonl })
      .expect(201);

    expect(response.body.importedCount).toBe(1);
    expect(response.body.job.result_count).toBe(1);
  });
});
