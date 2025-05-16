# Simple Overleaf Toolkit - Installation and Usage Guide

This document provides instructions for installing and running Overleaf Community Edition using Docker with the Simple Overleaf Toolkit.

## System Requirements

-   Docker and Docker Compose installed
-   Bash shell (on Windows, you can use WSL, Git Bash, or other Bash-compatible shell)
-   At least 4GB of RAM for Docker
-   Approximately 10GB of disk space for the Docker images and volumes

## Automated Scripts Overview

Several bash scripts are provided to simplify Overleaf management:

-   **install.sh**: First-time setup of Overleaf with Redis, MongoDB and Sharelatex
-   **run.sh**: Start all Overleaf services in the correct order with readiness checks
-   **stop.sh**: Stop all Overleaf services
-   **shell.sh**: Open an interactive shell in the Sharelatex container
-   **update.sh**: Install additional TeX packages and save the updated container
-   **check-packages.sh**: Verify installed TeX packages
-   **cleanup.sh**: Complete removal of all containers, volumes, and images (CAUTION: deletes all data)

If you're on Windows, run these scripts using:

```powershell
bash script.sh
```

## Installation Process

### First-time Installation

Run the installation script to set up Overleaf:

```powershell
bash install.sh
```

This script performs the following actions:

1. Creates data directories for Docker volumes
2. Starts Redis and waits for it to be ready
3. Starts MongoDB and waits for it to be ready
4. Initializes the MongoDB replica set
5. Starts the Sharelatex service
6. Creates necessary configuration files

After installation completes, Overleaf will be available at: http://localhost:8080/launchpad

### Day-to-day Usage

To start Overleaf after installation or shutdown:

```powershell
bash run.sh
```

The run script:

1. Starts Redis and waits for it to be ready
2. Starts MongoDB and waits for it to be ready
3. Verifies MongoDB replica set is initialized (and initializes it if needed)
4. Starts the Sharelatex service

To stop Overleaf when not in use:

```powershell
bash stop.sh
```

### Docker Compose Structure

The toolkit uses a structured Docker Compose setup:

-   `docker/docker-compose.yml`: Main compose file that includes the individual services
-   `docker/services/sharelatex.yml`: Sharelatex service configuration
-   `docker/services/mongo.yml`: MongoDB service configuration
-   `docker/services/redis.yml`: Redis service configuration

## Advanced Management

### Working with the Sharelatex Container

Access the Sharelatex container's shell for administration:

```powershell
bash shell.sh
```

This gives you direct access to the container's command line for running TeX commands, managing files, or troubleshooting.

### Installing Additional TeX Packages

To install additional TeX packages:

```powershell
bash update.sh
```

This script allows you to:

1. Install additional TeX Live packages
2. Run tlmgr to update packages
3. Save the updated container as a new image
4. Create a versioned backup of your customized Overleaf container

### Verifying Installed Packages

To check what TeX packages are installed:

```powershell
bash check-packages.sh
```

### Complete System Cleanup

For complete removal of all Overleaf components (WARNING: deletes all data):

```powershell
bash cleanup.sh
```

This will remove all Overleaf containers, volumes, and images.

## Manual Management

If you prefer to run commands manually instead of using the provided scripts:

### Starting Services Manually

```bash
# Start all services
docker compose -f docker/docker-compose.yml up -d
```

### Managing MongoDB Replica Set

```bash
# Initialize MongoDB replica set
docker exec overleaf_mongo mongosh --eval 'rs.initiate({ _id: "rs0", members: [{ _id: 0, host: "overleaf_mongo:27017" }] })'

# Check MongoDB replica set status
docker exec overleaf_mongo mongosh --eval "rs.status()"
```

### Shell Access and Package Management

```bash
# Access the container shell
docker exec -it overleaf_sharelatex /bin/bash

# Inside the container, install TeX packages
tlmgr install <package-name>
```

## Configuration Options

The Sharelatex service can be customized through environment variables in `docker/services/sharelatex.yml`:

-   `OVERLEAF_APP_NAME`: The name displayed in the UI
-   `EMAIL_CONFIRMATION_DISABLED`: Set to "true" to disable email confirmation
-   `ENABLE_CONVERSIONS`: Set to "true" to enable thumbnail generation

Additional email and site configuration options are available but commented out by default.

## Troubleshooting

If you encounter issues:

1. Ensure Docker is running with sufficient resources
2. Check service status with `docker ps` and `docker logs overleaf_sharelatex`
3. Restart services with `bash stop.sh` followed by `bash run.sh`
4. For data corruption issues, you may need to run `bash cleanup.sh` and reinstall

## Further Resources

-   [Overleaf Community Edition Documentation](https://github.com/overleaf/overleaf)
-   [Docker Documentation](https://docs.docker.com/)
-   [TeX Live Documentation](https://www.tug.org/texlive/doc.html)

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
