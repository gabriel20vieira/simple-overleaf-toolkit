#!/bin/bash

# Set working directory
cd "$(dirname "$0")"

echo "Opening shell in the Sharelatex container..."

# Check if the sharelatex container is running
if ! docker ps | grep -q overleaf_sharelatex; then
    echo "ERROR: The Sharelatex container is not running."
    echo "Please start it first using ./run.sh"
    exit 1
fi

# Open an interactive shell in the sharelatex container
docker exec -it overleaf_sharelatex /bin/bash

echo "Exited from Sharelatex container shell."
