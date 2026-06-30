import cors from "cors";
import express from "express";
import path from "node:path";
import { config } from "./config.js";
import { errorHandler } from "./http.js";
import { adminRouter } from "./routes/admin.js";
import { claimsRouter } from "./routes/claims.js";
import { entitlementsRouter } from "./routes/entitlements.js";
import { reportsRouter } from "./routes/reports.js";
import { searchRouter } from "./routes/search.js";
import { usersRouter } from "./routes/users.js";

export function createApp() {
  const app = express();

  app.use(cors());
  app.use(express.json({ limit: config.requestBodyLimit }));
  app.use(express.static(path.join(process.cwd(), "public")));

  app.get("/health", (_req, res) => {
    res.json({ status: "ok" });
  });

  app.use("/api/search", searchRouter);
  app.use("/api/reports", reportsRouter);
  app.use("/api/evidence-claims", claimsRouter);
  app.use("/api/users", usersRouter);
  app.use("/api", entitlementsRouter);
  if (config.enableAdminRoutes) {
    app.use("/api/admin", adminRouter);
  }

  app.get("*", (req, res, next) => {
    if (req.path.startsWith("/api")) {
      return next();
    }
    return res.sendFile(path.join(process.cwd(), "public", "index.html"));
  });

  app.use(errorHandler);

  return app;
}
