# ========================================
# JarvisV3 Docker Container
# ========================================
# This Dockerfile creates a production-ready container for JarvisV3

FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies required for PyAudio and other packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    # PyAudio dependencies
    portaudio19-dev \
    python3-pyaudio \
    # Build tools
    gcc \
    g++ \
    make \
    # Useful utilities
    curl \
    # Clean up
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copy requirements first for better Docker layer caching
COPY requirements.txt .

# Upgrade pip and install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY app.py .
COPY s2s.py .
COPY assets/ ./assets/

# Create .streamlit directory for configuration
RUN mkdir -p .streamlit

# Create Streamlit config to disable file watcher and set server settings
RUN echo "[server]\n\
headless = true\n\
port = 8501\n\
address = 0.0.0.0\n\
enableCORS = false\n\
enableXsrfProtection = true\n\
\n\
[browser]\n\
gatherUsageStats = false\n\
\n\
[theme]\n\
base = \"dark\"\n" > .streamlit/config.toml

# Expose Streamlit default port (container listens on $PORT, defaults to 8501)
EXPOSE 8501

# Health check to ensure app is running on the same port the platform provides
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8501}/_stcore/health || exit 1

# Run the application (honors PORT env var used by Railway/Render)
CMD ["sh", "-c", "streamlit run app.py --server.port=${PORT:-8501} --server.address=0.0.0.0"]
