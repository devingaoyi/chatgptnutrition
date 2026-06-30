# ChatGPT Nutrition Evidence

H5 nutrition evidence query backend prototype.

## Local Database

PostgreSQL 17 is expected locally.

Default development connection:

```text
postgresql://postgres:postgres@localhost:5432/chatgptnutrition_dev
```

Verify schema and seed data:

```powershell
npm run db:verify
```

## Install

```powershell
npm install
```

## Run API

```powershell
npm run dev
```

Default URL:

```text
http://localhost:3000
```

Open this URL directly for the H5 demo. It serves the static frontend from `public/` and calls the same API origin.

For a friend-facing demo, keep admin routes disabled:

```text
ENABLE_ADMIN_ROUTES=false
```

If you need local admin tools, start the API with:

```powershell
$env:ENABLE_ADMIN_ROUTES="true"
npm run dev
```

## Main Endpoints

- `GET /health`
- `GET /`
- `GET /api/search?q=褪黑素`
- `GET /api/reports/ingredients/:slug`
- `GET /api/reports/health-targets/:slug`
- `GET /api/evidence-claims/:id`
- `POST /api/users/dev`
- `POST /api/coupons/redeem`
- `POST /api/queries/consume`
- `GET /api/admin/evidence-claims?status=draft`
- `PATCH /api/admin/evidence-claims/:id/status`
- `POST /api/admin/literature/import-jsonl`

## Important Production Gaps

- Admin routes have no authentication and are disabled by default.
- Payment is not implemented; only coupon-based query credits exist.
- Current seed evidence claims are `draft` and must not be treated as reviewed medical conclusions.
- `SHOW_DRAFT_CLAIMS=true` is suitable only for development. Production should set it to `false`.

## Streamlit Demo

The Streamlit app is a read-only demo for sharing with friends. It uses static JSON exported from PostgreSQL.

Generate demo data:

```powershell
npm run export:streamlit
```

Run locally:

```powershell
pip install -r requirements.txt
streamlit run streamlit_app.py
```

Deploy on Streamlit Community Cloud:

1. Push this repository to GitHub.
2. Create a new Streamlit app from the GitHub repo.
3. Set the entry file to `streamlit_app.py`.
4. Confirm `requirements.txt` is detected.

No database password is needed for Streamlit Cloud because `data/demo_data.json` is static.
