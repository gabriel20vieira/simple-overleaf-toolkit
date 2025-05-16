#!/bin/bash

# Set working directory
cd "$(dirname "$0")"

echo "==================================================="
echo "CAUTION: This script will perform a complete cleanup"
echo "All containers, volumes, and images will be removed"
echo "ALL DATA WILL BE PERMANENTLY LOST"
echo "==================================================="
echo ""
read -p "Are you sure you want to continue? (y/N): " confirm

if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "Starting cleanup process..."

# Step 1: Stop all running containers
echo "Stopping all running containers..."
docker compose -f docker/docker-compose.yml stop

# Step 2: Remove all containers
echo "Removing all containers..."
docker compose -f docker/docker-compose.yml down

# Step 3: Remove all volumes
echo "Removing all volumes (THIS WILL DELETE ALL DATA)..."
docker compose -f docker/docker-compose.yml down -v

# Step 4: Remove all images used by Overleaf
echo "Removing Docker images..."
docker rmi sharelatex/sharelatex:latest mongo:6.0 redis:6.2

# Step 5: Remove data directories
echo "Removing data directories..."
rm -rf docker/data
echo "Data directories removed."

echo ""
echo "==================================================="
echo "Cleanup complete!"
echo "All Overleaf containers, volumes, and images have been removed."
echo "To reinstall Overleaf, run ./install.sh"
echo "==================================================="
