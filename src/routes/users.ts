import { Router } from "express";
import { z } from "zod";
import { query } from "../db.js";
import { asyncHandler } from "../http.js";

export const usersRouter = Router();

const createUserSchema = z.object({
  nickname: z.string().trim().min(1).max(128).optional(),
});

usersRouter.post(
  "/dev",
  asyncHandler(async (req, res) => {
    const body = createUserSchema.parse(req.body);
    const result = await query(
      `
      insert into users (nickname, role, status)
      values ($1, 'consumer', 'active')
      returning id, nickname, role, status, created_at
      `,
      [body.nickname ?? "dev-user"],
    );

    res.status(201).json({ user: result.rows[0] });
  }),
);

usersRouter.get(
  "/:id/entitlements",
  asyncHandler(async (req, res) => {
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    const result = await query(
      `
      select
        id,
        total_count,
        used_count,
        total_count - used_count as remaining_count,
        source,
        expires_at,
        created_at
      from query_entitlements
      where user_id = $1
      order by created_at desc
      `,
      [id],
    );

    res.json({
      entitlements: result.rows,
      totalRemaining: result.rows.reduce(
        (sum, row) => sum + Number(row.remaining_count ?? 0),
        0,
      ),
    });
  }),
);
