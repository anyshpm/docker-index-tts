#!/bin/sh
set -e

export PATH="$PATH:/root/.local/bin"

# Navigate to the application directory
cd /app/index-tts

# Check if models exist, if not download them
if [ ! -d "checkpoints/IndexTTS-2" ]; then
    echo "Models not found in checkpoints directory. Downloading..."
    # Create checkpoints directory if it doesn't exist
    mkdir -p checkpoints
    hf download IndexTeam/IndexTTS-2 --local-dir=checkpoints
else
    echo "Models found in checkpoints directory. Skipping download."
fi

# Check GPU
if [ -f "tools/gpu_check.py" ]; then
    uv run tools/gpu_check.py
else
    echo "GPU check script not found, skipping GPU check."
fi

# Run the application
# If no args or first arg starts with -, prepend the default command
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
    exec uv run webui.py --host 0.0.0.0 --port 7860 "$@"
fi

# Otherwise execute the custom command
exec "$@"
