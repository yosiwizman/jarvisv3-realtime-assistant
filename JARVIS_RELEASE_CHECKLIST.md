# JarvisV3 Release & QA Checklist

This is a quick, human-friendly checklist to verify JarvisV3 is healthy before tagging or publishing a new release.
It does **not** change how the app works – it only reminds you which existing scripts and checks to run.
Remember: your `.env` file and all secret values must stay on your machine or in your cloud provider, never in git.

---

## 1. Environment variables

- Make sure a `.env` file exists in the JarvisV3 project folder.
- In PowerShell, from the project folder, run:
  - `./print-jarvis-env.ps1`
- Confirm that the script lists the expected **variable names** (for example: `OPENAI_API_KEY`, `OPENAI_MODEL`, etc.). It will **not** show their values.
- Cross-check the names against `JARVIS_CLOUD_ENV_VARS.md` to confirm nothing important is missing.
- If anything looks wrong, fix your `.env` file before continuing.

See `JARVIS_CLOUD_ENV_VARS.md` for full details about each environment variable and example values.

---

## 2. Local desktop start & stop

Use this section to confirm the normal Windows desktop flow is healthy.

- Use **one** of these ways to start Jarvis:
  - Double-click the **"Jarvis V3"** desktop shortcut, **or**
  - In PowerShell, run: `./run-jarvis.ps1`
- Wait for Jarvis to open in your browser at:
  - `http://localhost:8501`
- In the browser:
  - Make sure the UI loads.
  - Ask Jarvis a simple test question and confirm you get a reasonable answer.
- To stop Jarvis:
  - Double-click the **"Stop Jarvis V3"** desktop shortcut, **or**
  - In PowerShell, run: `./stop-jarvis.ps1`
- After stopping, confirm:
  - Refreshing `http://localhost:8501` no longer shows the app (or cannot connect).

If the app does not start or stop cleanly, fix that before creating or updating a release.

---

## 3. Docker local test (cloud simulation)

This step simulates how JarvisV3 will run on container platforms like Railway or Render.

- From the JarvisV3 project folder in PowerShell, run:
  - `./test-jarvis-docker.ps1`
- Watch the output and confirm that it reports something like:
  - `JarvisV3 Docker test: UI reachable at http://localhost:8585 (StatusCode=200)`
- Confirm that the script also reports that the test container was cleaned up.

Notes:
- This uses Docker and the `PORT` environment variable the same way Railway/Render do.
- Your real secrets (such as `OPENAI_API_KEY`) still come from environment variables, not from git.
- Cloud platforms will inject `PORT` automatically; you do not need to hardcode it.

If this Docker test fails, investigate before releasing.

---

## 4. Git & tag checks

Before tagging or publishing a release, check the git state.

In PowerShell, from the project folder:

1. **Working tree clean**
   - Run: `git status -sb`
   - It should show a clean working tree (no unexpected modified or untracked files).

2. **Recent history looks correct**
   - Run: `git log -3 --oneline`
   - Quickly scan the last few commits and confirm they match the changes you expect.

3. **v1.0.0 tag still points to the original stable commit**
   - Run: `git tag -n1 v1.0.0`
   - Confirm it still shows:
     - `JarvisV3 v1.0.0 - local desktop launcher + Docker + realtime assistant`
     - (This tag should remain on the earlier stable commit `390699a`.)

4. **Creating a new release (future)**
   - When you are ready for a new version, follow the same pattern:
     - Make sure all checks above pass.
     - Create a new annotated tag (for example `v1.1.0`).
     - Push the tag and create a GitHub release with notes.

---

## 5. Safety notes

- Never commit `.env` or any secret values (API keys, tokens, passwords) to git.
- No desktop shortcut files (`.lnk`) should be tracked in git.
- If anything during QA looks wrong:
  - Run `./stop-jarvis.ps1` to stop the local app.
  - Fix the issue (scripts, config, or Docker) **before** creating or updating a release.
- When in doubt, re-run this checklist from the top to confirm everything is still healthy.
