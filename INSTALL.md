# Overleaf Installation and Usage Guide

This document provides instructions for installing and running Overleaf Community Edition using Docker.

## Automated Scripts

Several bash scripts are provided to simplify management:

-   **install.sh**: First-time setup of Overleaf with Redis, MongoDB and Sharelatex
-   **run.sh**: Start all Overleaf services in the correct order with readiness checks
-   **stop.sh**: Stop all Overleaf services
-   **shell.sh**: Open an interactive shell in the Sharelatex container
-   **update.sh**: Install additional TeX packages and save the updated container as a new image
-   **cleanup.sh**: Complete removal of all containers, volumes, and images (CAUTION: deletes all data)

If you're on Windows, run these using:

```powershell
bash script.sh
```

## Using the Scripts

### Installation

Run the installation script to set up Overleaf:

```powershell
bash install.sh
```

This script:

-   Starts Redis and MongoDB with readiness checks
-   Initializes the MongoDB replica set
-   Starts the Sharelatex service
-   Creates necessary configuration files

### Day-to-day Usage

Start Overleaf after installation or shutdown:

```powershell
bash run.sh
```

Stop Overleaf when not in use:

```powershell
bash stop.sh
```

### Advanced Management

Access the Sharelatex container's shell for administration:

```powershell
bash shell.sh
```

Install additional TeX packages:

```powershell
bash update.sh
```

Complete removal (WARNING: deletes all data):

```powershell
bash cleanup.sh
```

## Manual Installation

If you prefer to run commands manually:

### Installation

```bash
# Start all services
docker compose -f docker/docker-compose.yml up -d

# Initialize MongoDB replica set
docker exec overleaf_mongo mongosh --eval 'rs.initiate({ _id: "rs0", members: [{ _id: 0, host: "overleaf_mongo:27017" }] })'
```

### Verify Installation

```bash
# Check MongoDB replica set status
docker exec overleaf_mongo mongosh --eval "rs.status()"
```

### Installing TeX Packages

Access the container shell:

```bash
docker exec -it overleaf_sharelatex /bin/bash
```

Install packages:

```bash
# Check tlmgr version
tlmgr --version

# Install full TeX Live scheme (will take a long time)
tlmgr install scheme-full

# Or install specific packages
tlmgr install tikzlings tikzmarmots tikzducks
```

Save changes to a new image:

```bash
# Get current version
VERSION=$(cat config/version)

# Commit container to new image
docker commit overleaf_sharelatex sharelatex/sharelatex:$VERSION-with-texlive-full
docker commit sharelatex sharelatex/sharelatex:$VERSION-with-texlive-full
```

## Accessing Overleaf

Once running, access Overleaf at:
[http://localhost:8080/launchpad](http://localhost:8080/launchpad)
