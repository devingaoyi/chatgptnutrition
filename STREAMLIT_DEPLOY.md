# Streamlit Sharing Deployment

This is the recommended temporary sharing path for friends.

## What Gets Shared

The Streamlit app is read-only. It uses:

- `streamlit_app.py`
- `requirements.txt`
- `data/demo_data.json`

It does not need:

- PostgreSQL
- Node.js server
- database password
- admin routes
- payment or coupon logic

## Before Pushing to GitHub

Regenerate the static demo data whenever the local database changes:

```powershell
npm run export:streamlit
```

Run local checks:

```powershell
python -m py_compile streamlit_app.py
python -m streamlit run streamlit_app.py
```

Open:

```text
http://localhost:8501
```

## GitHub

Create a public GitHub repository and push the project.

At minimum, Streamlit Cloud needs these files in the repo root:

```text
streamlit_app.py
requirements.txt
data/demo_data.json
```

The rest of the repository can stay public. It is not required by Streamlit, but it preserves the full development history.

## Streamlit Community Cloud

1. Go to Streamlit Community Cloud.
2. Create a new app.
3. Select the GitHub repository.
4. Branch: `main`.
5. Main file path: `streamlit_app.py`.
6. Open **Advanced settings** and keep Python at the default supported version, preferably Python 3.12.
7. Deploy.

No secrets are required for the current read-only demo.

Do not rely on `runtime.txt` to set the Python version on Streamlit Community Cloud. Streamlit's current deployment documentation states that Python version is selected from the **Advanced settings** modal during deployment.

## Important Demo Disclaimer

Keep this wording visible in the app:

```text
当前为只读体验版。草稿结论用于产品验证，正式发布前需要完成人工文献复核。
```

Do not describe the Streamlit demo as a finished medical, nutrition, or commercial product.
