FROM ubuntu:jammy

# Define build arguments for proxies
ARG http_proxy
ARG https_proxy
ARG TARGETARCH

# Set environment variables
ENV http_proxy=$http_proxy
ENV https_proxy=$https_proxy
ENV PATH="$PATH:/root/.local/bin"

# Install system dependencies and CUDA Compiler in a single layer for efficiency
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    git \
    git-lfs \
    python3-pip \
    ca-certificates && \
    case "${TARGETARCH}" in \
    "amd64") CUDA_ARCH="x86_64" ;; \
    "arm64") CUDA_ARCH="sbsa" ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/${CUDA_ARCH}/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    apt-get update && \
    apt-get -y install cuda-compiler-12-8 && \
    #apt-get -y install cuda-libraries-12-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* cuda-keyring_1.1-1_all.deb && \
    git lfs install

WORKDIR /app/

# Clone the repository
ARG CACHEBUST=1
RUN git clone https://github.com/index-tts/index-tts.git

WORKDIR /app/index-tts

# Install python dependencies and tools in a single layer
RUN pip install -U uv && \
    uv tool install "huggingface-hub[cli,hf_xet]" && \
    uv tool install "modelscope" && \
    uv sync --extra webui #--all-extras

WORKDIR /app/index-tts

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose the port
EXPOSE 7860

# Command to run the application
ENTRYPOINT ["/entrypoint.sh"]
