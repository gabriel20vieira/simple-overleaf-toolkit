#!/bin/bash

# Set working directory
cd "$(dirname "$0")"

echo "Starting Overleaf services..."

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

# Step 3: Verify MongoDB replica set is initialized
echo "Verifying MongoDB replica set status..."
if ! docker exec overleaf_mongo mongosh --quiet --eval "rs.status().ok" | grep -q "1"; then
    echo "Replica set not initialized. Initializing now..."
    docker exec overleaf_mongo mongosh --eval 'rs.initiate({ _id: "rs0", members: [{ _id: 0, host: "overleaf_mongo:27017" }] })'
else
    echo "MongoDB replica set is already initialized!"
fi

# Step 4: Start Sharelatex
echo "Starting Sharelatex service..."
docker compose -f docker/docker-compose.yml up -d sharelatex

echo "============================================"
echo "Overleaf is now running!"
echo "Access Overleaf at: http://localhost:8080/launchpad"
echo "============================================"