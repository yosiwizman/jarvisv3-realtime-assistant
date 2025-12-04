# 🤖 JarvisV3 - AI Voice Assistant

A powerful, Streamlit-based AI assistant featuring both text chat and realtime voice conversation capabilities powered by OpenAI's latest models.

![Python Version](https://img.shields.io/badge/python-3.11%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/status-active-success)

---

## ✨ Features

### 💬 Text Chat
- Interactive text-based conversations with Jarvis
- Full chat history maintained throughout your session
- Markdown formatting support for rich responses
- Context-aware conversations with date/time inclusion

### 🎙️ Realtime Audio Chat
- Voice-to-voice conversations using OpenAI's Realtime API
- Real-time audio streaming with WebSocket
- Automatic microphone muting during AI speech
- Voice Activity Detection (VAD) support
- Multiple voice options (alloy, ash, ballad, coral, echo, sage, shimmer, verse)

### ⚙️ Settings Management
- Configure OpenAI API key directly in the UI
- Select between GPT-4o and GPT-4o-mini realtime models
- Customize system prompt/instructions
- Enable/disable function calling capabilities
- Toggle VAD, date/time inclusion, and other features
- All settings persist to `.env` file

### 🔧 Function Calling (Optional)
- Execute OS commands through natural language
- System integration capabilities
- Controlled via settings (disabled by default for security)

---

## 📋 Prerequisites

Before you begin, ensure you have:

- **Python 3.11 or higher** installed ([Download here](https://www.python.org/downloads/))
- **OpenAI API Key** ([Get one here](https://platform.openai.com/api-keys))
- **Windows 10/11** (PowerShell 5.1+)
- **Internet connection** (for OpenAI API access)

### Optional
- **Docker Desktop** (if you want to run in a container)
- **Git** (if you want to clone from GitHub)

---

## 🚀 Quick Start (Easiest Method)

### Method 1: One-Click Startup (Recommended for Non-Technical Users)

1. **Download or clone this project** to your computer

2. **Double-click `run-jarvis.ps1`** in the project folder
   - If Windows blocks the script, right-click → Properties → Unblock → OK
   - The script will automatically:
     - Check Python installation
     - Create a virtual environment
     - Install all dependencies
     - Launch Jarvis in your browser

3. **On first run**, the script will:
   - Ask if you want to create a `.env` file
   - Say "yes" and it will open the file in Notepad
   - Add your OpenAI API key where indicated
   - Run the script again

4. **Jarvis will open** at `http://localhost:8501`

That's it! 🎉

---

## 📝 Detailed Setup Instructions

### Step 1: Clone or Download

```powershell
# If you have Git installed
git clone <your-repo-url>
cd JarvisV3

# Or download and extract the ZIP file, then navigate to the folder
```

### Step 2: Create Environment File

```powershell
# Copy the example environment file
copy .env.example .env

# Edit .env in your favorite text editor
notepad .env
```

Add your OpenAI API key:
```env
OPENAI_API_KEY=sk-proj-your-actual-api-key-here
```

### Step 3: Set Up Python Environment (Manual)

```powershell
# Create virtual environment
python -m venv venv

# Activate it
.\venv\Scripts\Activate.ps1

# Upgrade pip
python -m pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt
```

### Step 4: Run Jarvis (Manual)

```powershell
# Make sure virtual environment is activated
streamlit run app.py
```

Jarvis will open in your default browser at `http://localhost:8501`

### Stopping Jarvis (panic button)

If Jarvis ever gets stuck or your browser cannot connect, you can run `stop-jarvis.ps1` from the project folder to cleanly stop the Streamlit server.
If you created the optional **Stop Jarvis V3** desktop shortcut, double-clicking it does the same thing.

---

## 🐳 Docker Setup (Alternative)

### Prerequisites
- Docker Desktop installed and running

### Build and Run

```powershell
# Build the Docker image
docker build -t jarvisv3 .

# Run the container
docker run -p 8501:8501 --env-file .env jarvisv3

# Or use docker-compose
docker-compose up
```

Access Jarvis at `http://localhost:8501`

## Docker: Local Test (Railway/Render Simulation)

If you want to quickly simulate how JarvisV3 will run on platforms like Railway or Render, you can use:

- `test-jarvis-docker.ps1` (PowerShell)
- The optional **Test Jarvis V3 Docker** desktop shortcut

This script:
- Builds the Docker image from this repo
- Runs it on `http://localhost:8585` with `PORT=8501` inside the container
- Checks that the UI is reachable
- Stops and removes the test container when finished

This is only a local verification tool; real cloud deploys will still pass secrets (like `OPENAI_API_KEY`) via environment variables configured on the provider (Railway/Render), not via git.

---

## 📖 Usage Guide

### Text Chat Tab
1. Navigate to the "Chat" tab
2. Type your message in the input box at the bottom
3. Press Enter to send
4. Jarvis will respond with text

### Realtime Audio Tab
1. Navigate to the "Realtime" tab
2. Click "Start Realtime Audio Chat"
3. Grant microphone permissions when prompted
4. Speak naturally - Jarvis will listen and respond with voice
5. Click "Stop Realtime Audio Chat" when done

### Settings Tab
1. Navigate to the "Settings" tab
2. Configure your preferences:
   - **API Key**: Your OpenAI API key
   - **Model**: Choose between gpt-4o-mini (faster, cheaper) or gpt-4o (more capable)
   - **Voice**: Select AI voice personality
   - **Initial Prompt**: Customize Jarvis's behavior
   - **Function Calling**: Enable system command execution (use with caution)
   - **VAD**: Voice Activity Detection for better audio handling
   - **Date/Time**: Include contextual information in messages
3. Click "Save Settings" to persist changes

---

## ⚙️ Configuration

### Environment Variables

All configuration is managed through the `.env` file:

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `OPENAI_API_KEY` | Your OpenAI API key | - | ✅ Yes |
| `OPENAI_MODEL` | Model to use | `gpt-4o-mini-realtime-preview-2024-12-17` | No |
| `VOICE` | Voice for audio responses | `echo` | No |
| `VAD` | Enable Voice Activity Detection | `True` | No |
| `DEVICE` | Device type for commands | `windows` | No |
| `FUNCTION_CALLING` | Enable OS command execution | `False` | No |
| `INCLUDE_DATE` | Include date in context | `True` | No |
| `INCLUDE_TIME` | Include time in context | `True` | No |
| `INITIAL_PROMPT` | System prompt/instructions | Default assistant behavior | No |

### Voice Options

Choose from 8 different AI voices:
- **alloy**: Neutral and balanced
- **ash**: Clear and articulate
- **ballad**: Warm and expressive
- **coral**: Friendly and engaging
- **echo**: Resonant and confident (default)
- **sage**: Wise and thoughtful
- **shimmer**: Bright and energetic
- **verse**: Smooth and melodic

---

## 🛠️ Troubleshooting

### "Python is not installed or not in PATH"
- Install Python 3.11+ from [python.org](https://www.python.org/downloads/)
- During installation, check "Add Python to PATH"
- Restart PowerShell after installation

### "PyAudio failed to install"
On Windows, PyAudio requires additional setup:
```powershell
# Option 1: Use pre-built wheel
pip install pipwin
pipwin install pyaudio

# Option 2: Download wheel from unofficial binaries
# Visit: https://www.lfd.uci.edu/~gohlke/pythonlibs/#pyaudio
# Download the appropriate .whl file and install:
pip install PyAudio-0.2.14-cp311-cp311-win_amd64.whl
```

### "Cannot load PyAudio" at runtime
- Ensure you have Microsoft Visual C++ Redistributable installed
- Download from: [Microsoft Support](https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads)

### Microphone not working
- Check Windows microphone permissions: Settings → Privacy → Microphone
- Ensure your browser has microphone access
- Try restarting the Streamlit app

### "API key is invalid"
- Verify your API key in the `.env` file
- Check that you have credits on your OpenAI account
- Ensure there are no extra spaces or quotes around the key

### Port 8501 already in use
```powershell
# Find and kill process using port 8501
netstat -ano | findstr :8501
taskkill /PID <process-id> /F

# Or use a different port
streamlit run app.py --server.port 8502
```

---

## 🔒 Security & Privacy

### API Key Safety
- **Never** commit your `.env` file to version control
- **Never** share your OpenAI API key publicly
- The `.gitignore` file automatically excludes `.env`

### Function Calling
- Function calling is **disabled by default** for security
- When enabled, Jarvis can execute OS commands
- Only enable if you understand the implications
- Use with trusted models and contexts only

### Data Privacy
- All conversations are processed through OpenAI's API
- Chat history is stored in your browser session only
- No data is saved to disk (except settings in `.env`)
- Review OpenAI's [Privacy Policy](https://openai.com/policies/privacy-policy)

---

## 📁 Project Structure

```
JarvisV3/
├── assets/              # Images and static files
│   ├── full.png         # Chat avatar
│   ├── Header.png       # App header logo
│   └── [other images]
├── venv/                # Python virtual environment (git ignored)
├── .env                 # Your configuration (git ignored)
├── .env.example         # Environment template
├── .gitignore           # Git ignore rules
├── app.py               # Main Streamlit application
├── s2s.py               # JarvisClient (WebSocket/Realtime logic)
├── requirements.txt     # Python dependencies
├── run-jarvis.ps1       # PowerShell startup script
├── Dockerfile           # Docker container definition
├── docker-compose.yml   # Docker Compose configuration
├── README.md            # This file
└── PROJECT_PLAN.md      # Technical cleanup plan
```

---

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 📄 License

This project is licensed under the MIT License. See `LICENSE` file for details.

---

## 🙏 Acknowledgments

- **OpenAI** for the Realtime API and GPT models
- **Streamlit** for the amazing web framework
- **PyAudio** for audio streaming capabilities

---

## 📞 Support

Having issues? Here's how to get help:

1. **Check this README** - Most common issues are covered
2. **Check PROJECT_PLAN.md** - Technical details and architecture
3. **Check .env.example** - Configuration reference
4. **Open an Issue** - Describe your problem in detail

---

## 🚧 Known Limitations

- **Windows Only**: PowerShell script designed for Windows (Mac/Linux users use manual setup)
- **PyAudio on Windows**: May require additional setup (see Troubleshooting)
- **Realtime API**: Requires stable internet connection
- **Browser Compatibility**: Best experience with Chrome/Edge (Chromium-based)
- **API Costs**: OpenAI charges per token/audio second - monitor your usage

---

## 🚀 Deployment Options

JarvisV3 is a Python/Streamlit application. Vercel is optimized for Node/Next.js, so the simplest deployment paths today are container-based platforms. You have two straightforward options:

- Docker on a container host: Fly.io, Railway, Render, Google Cloud Run, Azure Container Apps, AWS App Runner, or a VPS.
- Traditional VM/server: Install Docker and run `docker-compose up -d`.

Notes for later:
- If you want a Vercel-hosted frontend, we can add a small Next.js UI on Vercel that talks to this Streamlit backend running on a container platform. No rewrite needed now.
- For single-container deploys, this repo already includes `Dockerfile` and `docker-compose.yml`.

## Deployment (Railway & Render)

This project is ready to run as a single Docker container. Platforms like **Railway** and **Render** will automatically provide a `PORT` environment variable; the Docker image uses:

See `JARVIS_CLOUD_ENV_VARS.md` for the full list of environment variables to configure for local `.env` and cloud providers (Railway/Render).

```bash
streamlit run app.py --server.port=${PORT:-8501} --server.address=0.0.0.0
```

so it will listen on the port the platform expects (falling back to `8501` when running locally).

### A) Railway (Docker deploy)

1. Sign in to [Railway](https://railway.app/) and create a new project.
2. Choose **Deploy from GitHub** and connect your GitHub account.
3. Select the repo: `yosiwizman/jarvisv3-realtime-assistant`.
4. When asked how to deploy, choose **Dockerfile** (Railway will detect the `Dockerfile` in the repo root).
5. In the Railway project settings, open the **Variables / Environment** section and add:
   - `OPENAI_API_KEY` → set this to your real OpenAI API key.
6. Leave the `PORT` variable to whatever Railway sets automatically (do **not** hardcode it). The container command already uses `${PORT:-8501}`.
7. Click **Deploy**. Railway will build the Docker image and start the service.
8. Once deployment is successful, open the Railway-provided URL to access Jarvis in your browser.

Notes:
- You **do not** need a `railway.json` file for this simple Docker-based deploy.
- Never commit `.env` or your API key; keep them in Railway's dashboard only.

### B) Render (Docker deploy)

1. Sign in to [Render](https://render.com/).
2. Click **New** → **Web Service**.
3. Choose **Build and deploy from a Git repository** and connect your GitHub account.
4. Select the `jarvisv3-realtime-assistant` repo and the `main` branch.
5. For **Runtime**, choose **Docker** (Render will detect the `Dockerfile` in the root).
6. In the **Environment** / **Env Vars** section, add:
   - `OPENAI_API_KEY` → set this to your real OpenAI API key.
7. Leave the `PORT` setting alone; Render will inject `PORT` automatically. The Dockerfile's start command already respects `${PORT:-8501}`.
8. Click **Create Web Service** and wait for the build and deploy to finish.
9. Open the URL Render provides to use Jarvis in your browser.

Notes:
- You do **not** need a custom `render.yaml` for this basic Docker deployment.
- `.env` remains local-only; in the cloud you configure env vars in Render's dashboard.

## 🗺️ Roadmap

Future enhancements planned:
- [ ] Web search integration
- [ ] Document Q&A capabilities
- [ ] Multiple conversation threads
- [ ] Conversation export/import
- [ ] Custom wake word support
- [ ] Mobile-responsive UI improvements

---

## 📚 Additional Resources

- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Streamlit Documentation](https://docs.streamlit.io/)
- [Python Documentation](https://docs.python.org/3/)

---

**Made with ❤️ for seamless AI assistance**
