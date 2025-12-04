# Deployment Notes (JarvisV3 Realtime Assistant)

This is a short, practical checklist for deploying this app to container platforms like **Railway** or **Render**.

---

## 1. Prerequisites

- A **GitHub** account with this repo already pushed:
  - `https://github.com/yosiwizman/jarvisv3-realtime-assistant`
- A **Railway** or **Render** account (either works).
- Docker is *optional* locally (only needed if you want to test builds on your own machine).

---

## 2. Environment Variables

In the cloud dashboards (Railway or Render), you **must** set:

- `OPENAI_API_KEY` – your real OpenAI API key.

Notes:
- Do **not** commit `.env` to Git.
- Keep your `.env` file for local development only.
- In production, set all secrets (like `OPENAI_API_KEY`) through the platform's **Environment Variables** UI.

---

## 3. Container Start Command (for reference)

The Docker image runs Streamlit with this command:

```bash
streamlit run app.py --server.port=${PORT:-8501} --server.address=0.0.0.0
```

- Cloud platforms (Railway, Render, etc.) automatically provide `PORT`.
- When running locally with `docker run`, if you don't set `PORT`, it defaults to `8501`.

---

## 4. Very Short How-To

- **On Railway**
  1. Create a new project → deploy from GitHub → pick this repo.
  2. Let Railway detect and use the `Dockerfile` in the root.
  3. Add `OPENAI_API_KEY` in the Variables section.
  4. Deploy and open the URL Railway gives you.

- **On Render**
  1. New → Web Service → from GitHub → pick this repo.
  2. Use the Docker runtime with the root `Dockerfile`.
  3. Add `OPENAI_API_KEY` in the Environment section.
  4. Deploy and open the URL Render gives you.

That's it – this repo is now container-ready, and you can deploy with just a few clicks from your cloud dashboard.