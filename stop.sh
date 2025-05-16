#!/bin/bash

# Set working directory
cd "$(dirname "$0")"

echo "Stopping Overleaf services..."

# Step 1: Stop all services in reverse order
echo "Stopping all Overleaf services..."
docker compose -f docker/docker-compose.yml stop

echo "============================================"
echo "All Overleaf services have been stopped."
echo "To start services again, run ./run.sh"
echo "============================================"

# Optional: Uncomment the following lines if you want to completely remove containers as well
# echo "Removing containers (data will be preserved)..."
# docker compose -f docker/docker-compose.yml down
# echo "Containers removed."