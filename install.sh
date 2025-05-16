#!/bin/bash

# Set working directory
cd "$(dirname "$0")"

echo "Starting Overleaf installation process..."

# Create data directories for Docker volumes
echo "Creating data directories for Docker volumes..."
mkdir -p docker/data
mkdir -p docker/data/sharelatex
mkdir -p docker/data/mongo
mkdir -p docker/data/redis
# Ensure data directories have proper permissions
if [ "$(uname)" = "Linux" ]; then
    # Set permissions for Linux
    echo "Setting proper permissions on data directories..."
    chmod -R 777 docker/data
    # Clean up any hanging volume files - ignore errors if volumes don't exist
    docker volume rm overleaf_mongo overleaf_redis overleaf_overleaf_data 2>/dev/null || true
fi
echo "Data directories created successfully."

# Step 1: Start Redis
echo "Starting Redis service..."
docker compose -f docker/docker-compose.yml up -d redis

# Wait for Redis to be ready
echo "Waiting for Redis to be ready..."
until docker exec overleaf_redis redis-cli ping | grep -q "PONG"; do
    echo "Redis not ready yet. Waiting..."
    sleep 1
done
echo "Redis is now ready!"

# Step 2: Start MongoDB
echo "Starting MongoDB service..."
docker compose -f docker/docker-compose.yml up -d mongo

# Wait for MongoDB to be ready
echo "Waiting for MongoDB to be ready..."
until docker exec overleaf_mongo mongosh --quiet --eval "db.runCommand('ping').ok" | grep -q "1"; do
    echo "MongoDB not ready yet. Waiting..."
    sleep 1
done
echo "MongoDB is now ready!"

# Step 3: Initialize MongoDB replica set
echo "Initializing MongoDB replica set..."
docker exec overleaf_mongo mongosh --eval 'rs.initiate({ _id: "rs0", members: [{ _id: 0, host: "overleaf_mongo:27017" }] })'

# Step 4: Verify replica set status
echo "Verifying MongoDB replica set status..."
docker exec overleaf_mongo mongosh --eval "rs.status()"

# Step 5: Start Sharelatex
echo "Starting Sharelatex service..."
docker compose -f docker/docker-compose.yml up -d sharelatex

# Step 6: Wait for Sharelatex to be ready
echo "Waiting for Sharelatex to be ready..."
sleep 10  # Give Sharelatex some time to start up

# Step 7: Create config/version file if it doesn't exist
echo "Checking for config/version file..."
if ! docker exec overleaf_sharelatex test -f config/version; then
    echo "config/version file does not exist. Creating it..."
    # Get the image tag/version
    IMAGE_VERSION=$(docker inspect --format='{{index .Config.Image}}' overleaf_sharelatex | cut -d: -f2)
    if [ "$IMAGE_VERSION" == "" ] || [ "$IMAGE_VERSION" == "latest" ]; then
        # If using 'latest' tag, use a default version or try to get actual version
        echo "Using default version 'latest'"
        DEFAULT_VERSION="latest"
        docker exec overleaf_sharelatex mkdir -p config
        docker exec overleaf_sharelatex bash -c "echo $DEFAULT_VERSION > config/version"
    else
        echo "Using image version: $IMAGE_VERSION"
        docker exec overleaf_sharelatex mkdir -p config
        docker exec overleaf_sharelatex bash -c "echo $IMAGE_VERSION > config/version"
    fi
    echo "config/version file created."
fi

echo "============================================"
echo "Installation complete!"
echo "Overleaf will be available at: http://localhost:8080/launchpad"
echo "It may take a few moments for the service to be fully ready."
echo "============================================"