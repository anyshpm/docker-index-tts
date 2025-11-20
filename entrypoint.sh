#!/bin/sh
set -e

# Navigate to the application directory
cd /app/index-tts

# Activate the virtual environment
. .venv/bin/activate

# Run the application
exec uv run webui.py --host 0.0.0.0 --port 7860 "$@"
