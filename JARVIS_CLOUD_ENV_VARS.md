# JarvisV3 Cloud Environment Variables Checklist

This file lists all of the environment variables that JarvisV3 uses.
It is meant for the project owner, not for developers.

Use it when you:
- Set up your local `.env` file, or
- Configure environment variables on cloud providers such as Railway or Render.

**Important:**
- Never commit your real `.env` file or API keys to GitHub.
- Keep secrets only on your own machine or in your cloud provider’s dashboard.

---

## 1. Environment variables (summary)

JarvisV3 reads the following environment variables:

- `OPENAI_API_KEY`  
- `OPENAI_MODEL`  
- `VOICE`  
- `VAD`  
- `DEVICE`  
- `INCLUDE_DATE`  
- `INCLUDE_TIME`  
- `FUNCTION_CALLING`  
- `INITIAL_PROMPT`  
- `PORT` (cloud/platform-managed, not set in `.env`)

---

## 2. Details for each variable

Below, each variable lists:
- Whether it is required
- Where it is used in the project
- What it controls in plain language
- An example local `.env` value
- How to handle it in cloud dashboards (Railway / Render)

### 2.1 `OPENAI_API_KEY`

- **Required?**  
  Yes. Jarvis cannot start without this.

- **Used in**  
  - `app.py` (Streamlit app settings)  
  - `s2s.py` (JarvisClient – the realtime connection to OpenAI)

- **Purpose**  
  Your personal OpenAI API key. This is what allows Jarvis to talk to OpenAI’s servers.

- **Example local `.env` value**  
  ```env
  OPENAI_API_KEY="sk-your-openai-key-here"
  ```

- **Cloud notes (Railway / Render)**  
  - Do **not** upload `.env` to the cloud.  
  - In the cloud dashboard, add a variable named `OPENAI_API_KEY` and paste your real key as the value.  
  - Jarvis will read it automatically inside the container.

---

### 2.2 `OPENAI_MODEL`

- **Required?**  
  No. If you do not set it, Jarvis uses a default model.

- **Used in**  
  - `app.py` (remembered in settings and written back to `.env`)  
  - `s2s.py` (controls which OpenAI realtime model is used)

- **Purpose**  
  Tells Jarvis which OpenAI model to use for chat and realtime audio.

- **Behavior if missing**  
  Falls back to `gpt-4o-mini-realtime-preview-2024-12-17`.

- **Example local `.env` value**  
  ```env
  OPENAI_MODEL="gpt-4o-mini-realtime-preview-2024-12-17"
  ```

- **Cloud notes**  
  - Optional to set in Railway/Render.  
  - If you are happy with the default model, you can leave it unset.  
  - To change it, add `OPENAI_MODEL` with one of the supported values (for example `gpt-4o-mini-realtime-preview-2024-12-17` or `gpt-4o-realtime-preview-2024-12-17`).

---

### 2.3 `VOICE`

- **Required?**  
  No. If you do not set it, Jarvis uses a default voice.

- **Used in**  
  - `app.py` (settings UI and `.env` saving)  
  - `s2s.py` (controls which AI voice is used for audio responses)

- **Purpose**  
  Chooses Jarvis’s speaking voice for realtime audio (for example: `alloy`, `ash`, `ballad`, `coral`, `echo`, `sage`, `shimmer`, `verse`).

- **Behavior if missing**  
  Falls back to `echo`.

- **Example local `.env` value**  
  ```env
  VOICE="echo"
  ```

- **Cloud notes**  
  - Optional in Railway/Render.  
  - You can set `VOICE` if you want a specific voice globally.  
  - If you leave it unset, Jarvis will use the default.

---

### 2.4 `VAD`

- **Required?**  
  No.

- **Used in**  
  - `app.py` (stored in settings; controls behavior flags passed into JarvisClient)

- **Purpose**  
  Stands for **Voice Activity Detection**. Turns automatic speech detection on or off for realtime audio.

- **Behavior if missing**  
  Treated as `True` by default.

- **Example local `.env` value**  
  ```env
  VAD="True"
  ```

- **Cloud notes**  
  - Optional in Railway/Render.  
  - Set `VAD` to `True` or `False` if you want to force a behavior for all users.  
  - If you leave it unset, Jarvis behaves as if `VAD` is `True`.

---

### 2.5 `DEVICE`

- **Required?**  
  No.

- **Used in**  
  - `app.py` (settings UI and `.env` saving)  
  - `s2s.py` (used when describing what device OS commands run on)

- **Purpose**  
  A short label for the type of computer Jarvis is running on (for example: `windows`, `mac`, or `linux`). This is only used in text descriptions when Jarvis is allowed to run OS commands.

- **Behavior if missing**  
  - The main app defaults to `windows`.  
  - The realtime client falls back to `unknown`.

- **Example local `.env` value**  
  ```env
  DEVICE="windows"
  ```

- **Cloud notes**  
  - Optional.  
  - For cloud deploys you can leave it as the default, or set it to something like `linux` if you want the wording to match the server environment.

---

### 2.6 `INCLUDE_DATE`

- **Required?**  
  No.

- **Used in**  
  - `app.py` (settings UI and `.env` saving)  
  - `s2s.py` (controls whether the current date is added to messages)

- **Purpose**  
  When `True`, Jarvis adds the current date into the message it sends to the AI. This can help the model stay aware of “today’s” date.

- **Behavior if missing**  
  Treated as `True` by default.

- **Example local `.env` value**  
  ```env
  INCLUDE_DATE="True"
  ```

- **Cloud notes**  
  - Optional.  
  - Set to `False` if you do not want date information included in messages.

---

### 2.7 `INCLUDE_TIME`

- **Required?**  
  No.

- **Used in**  
  - `app.py` (settings UI and `.env` saving)  
  - `s2s.py` (controls whether the current time is added to messages)

- **Purpose**  
  When `True`, Jarvis adds the current time into the message it sends to the AI.

- **Behavior if missing**  
  Treated as `True` by default.

- **Example local `.env` value**  
  ```env
  INCLUDE_TIME="True"
  ```

- **Cloud notes**  
  - Optional.  
  - Set to `False` if you do not want time information included in messages.

---

### 2.8 `FUNCTION_CALLING`

- **Required?**  
  No.

- **Used in**  
  - `app.py` (settings UI and `.env` saving)  
  - `s2s.py` (decides whether Jarvis exposes the ability to run OS commands)

- **Purpose**  
  Controls whether Jarvis is allowed to execute OS commands on your machine through natural language requests.

- **Behavior if missing**  
  Treated as `False` by default (function calling off).

- **Example local `.env` value**  
  ```env
  FUNCTION_CALLING="False"
  ```

- **Cloud notes**  
  - Optional, but sensitive.  
  - For most cloud deployments you will want this **off** for safety.  
  - Only set `FUNCTION_CALLING="True"` if you fully understand the security implications.

---

### 2.9 `INITIAL_PROMPT`

- **Required?**  
  No.

- **Used in**  
  - `app.py` (settings UI and `.env` saving)  
  - `s2s.py` (used as the system instructions for Jarvis)

- **Purpose**  
  Lets you customize Jarvis’s personality and default behavior in a single text field.

- **Behavior if missing**  
  Falls back to a built-in default prompt inside the app.

- **Example local `.env` value**  
  ```env
  INITIAL_PROMPT="You are Jarvis, a helpful AI assistant. Be concise and friendly."
  ```

- **Cloud notes**  
  - Optional.  
  - You can set a project-wide behavior by defining `INITIAL_PROMPT` in your cloud env vars.  
  - If you leave it unset, the app’s built-in behavior is used.

---

### 2.10 `PORT` (cloud/platform variable)

- **Required?**  
  - **Locally (.env):** No – you normally do **not** set this.  
  - **In the cloud:** The platform (Railway, Render, etc.) automatically sets `PORT` for the container.

- **Used in**  
  - `Dockerfile` (Streamlit start command and health check):  
    - `streamlit run app.py --server.port=${PORT:-8501} --server.address=0.0.0.0`  
    - Healthcheck at `http://localhost:${PORT:-8501}/_stcore/health`

- **Purpose**  
  Tells the container which port number to listen on. Cloud platforms inject this value so they can route traffic correctly.

- **Behavior if missing**  
  Defaults to `8501`, which is what you normally use on your own machine.

- **Example local `.env` value**  
  Normally **not needed**. If you do set it for testing, you could use:  
  ```env
  PORT="8501"
  ```

- **Cloud notes**  
  - You usually do **not** touch this in the cloud UI.  
  - Railway and Render set `PORT` automatically. Jarvis already honors it inside the Docker container.

---

## 3. Example local `.env` file (placeholders only)

Below is a sample `.env` file. All values are **fake** and for illustration only.

```env
# Required
OPENAI_API_KEY="sk-your-openai-key-here"

# Optional but recommended
OPENAI_MODEL="gpt-4o-mini-realtime-preview-2024-12-17"
VOICE="echo"
VAD="True"
DEVICE="windows"
INCLUDE_DATE="True"
INCLUDE_TIME="True"
FUNCTION_CALLING="False"
INITIAL_PROMPT="You are Jarvis, a helpful AI assistant. Be concise and friendly."
```

Remember:
- Keep this `.env` file **local only**.  
- Do not email it, upload it, or commit it to Git.

---

## 4. Cloud provider setup notes

### 4.1 Railway

1. Deploy this repo to Railway using the Dockerfile (as described in `README.md`).
2. In the Railway project, open the **Variables / Environment** section.
3. Add the variables you want from this checklist:
   - At minimum: `OPENAI_API_KEY`.
   - Optionally: `OPENAI_MODEL`, `VOICE`, `VAD`, `DEVICE`, `INCLUDE_DATE`, `INCLUDE_TIME`, `FUNCTION_CALLING`, `INITIAL_PROMPT`.
4. Do **not** set `PORT` – Railway manages this automatically.
5. Redeploy if needed. Railway will rebuild/restart the container using your new variables.

### 4.2 Render

1. Deploy this repo to Render as a Docker-based **Web Service**.
2. In the service **Environment / Env Vars** section, add:
   - At minimum: `OPENAI_API_KEY`.
   - Optionally: the other variables listed in this file.
3. Leave `PORT` alone – Render will inject it automatically. The container already uses `${PORT:-8501}`.
4. Save your changes and allow Render to restart the service.

---

## 5. Optional helper: `print-jarvis-env.ps1`

If you run the optional `print-jarvis-env.ps1` script from the project folder, it will:

- Look for a `.env` file in the JarvisV3 project root.
- Check which of the known Jarvis variables from this document are present.
- Print **only the variable names**, never their values.

Example output:

```text
Jarvis env variables currently defined in .env:
- OPENAI_API_KEY
- OPENAI_MODEL
- VOICE
```

You can use this as a quick safety check before committing changes or sharing your screen.
