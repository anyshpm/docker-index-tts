# Build stage
FROM ubuntu:jammy

# Define build arguments for proxies
ARG http_proxy
ARG https_proxy

# Set environment variables from build arguments
ENV http_proxy=$http_proxy
ENV https_proxy=$https_proxy
ENV PATH="$PATH:/root/.local/bin"

# Install system dependencies for building
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    git \
    git-lfs \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && git lfs install
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    apt-get update && \
    apt-get -y install cuda-compiler-12-8

WORKDIR /app/

# Clone the repository
ARG CACHEBUST=1
RUN git clone https://github.com/index-tts/index-tts.git

WORKDIR /app/index-tts

# Install python dependencies
RUN pip install -U uv && \
    uv sync --all-extras

# Download models
RUN uv tool install "huggingface-hub[cli,hf_xet]" && \
    hf download IndexTeam/IndexTTS-2 --local-dir=checkpoints && \
    uv run tools/gpu_check.py
    

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose the port
EXPOSE 7860

# Command to run the application
ENTRYPOINT ["/entrypoint.sh"]
