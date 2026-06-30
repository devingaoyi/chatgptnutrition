import dotenv from "dotenv";

dotenv.config();

export const config = {
  port: Number(process.env.PORT ?? 3000),
  databaseUrl:
    process.env.DATABASE_URL ??
    "postgresql://postgres:postgres@localhost:5432/chatgptnutrition_dev",
  showDraftClaims: (process.env.SHOW_DRAFT_CLAIMS ?? "true").toLowerCase() === "true",
  enableAdminRoutes: (process.env.ENABLE_ADMIN_ROUTES ?? "false").toLowerCase() === "true",
  requestBodyLimit: process.env.REQUEST_BODY_LIMIT ?? "5mb",
};
