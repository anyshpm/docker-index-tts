# Build stage
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04

# Define build arguments for proxies
ARG http_proxy
ARG https_proxy

# Set environment variables from build arguments
ENV http_proxy=$http_proxy
ENV https_proxy=$https_proxy

# Install system dependencies for building
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    git \
    git-lfs \
    python3-pip \
    python3-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && git lfs install

WORKDIR /app/

# Clone the repository
ARG CACHEBUST=1
RUN git clone https://github.com/index-tts/index-tts.git

WORKDIR /app/index-tts

# Install python dependencies
RUN python3 -m venv .venv --copies && \
    . .venv/bin/activate && \
    pip install -U uv && \
    uv sync --all-extras

# Download models
RUN . .venv/bin/activate && \
    uv tool install "modelscope" && \
    modelscope download --model IndexTeam/IndexTTS-2 --local_dir checkpoints && \
    uv run tools/gpu_check.py

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose the port
EXPOSE 7860

# Command to run the application
ENTRYPOINT ["/entrypoint.sh"]
