# Overleaf Local Installation

This is a local instance of Overleaf (formerly ShareLaTeX) running via Docker Compose.

## Usage

### Starting Overleaf

To start the Overleaf installation:

```bash
# Linux/Mac/WSL
bash install.sh
```

### Accessing Overleaf

Once running, Overleaf is available at:

http://localhost:8080/launchpad

### Stopping Overleaf

To stop all containers:

```bash
# Linux/Mac/WSL
bash stop.sh
```

### Full Cleanup

To completely remove all containers, volumes, and data:

```bash
# Linux/Mac/WSL
bash cleanup.sh
```

Note: This will delete all your Overleaf data!

### Data Storage

All data is stored in Docker volumes, which are backed by the `docker/data` directory.

-   `docker/data/sharelatex` - Document data
-   `docker/data/mongo` - MongoDB data
-   `docker/data/redis` - Redis data

## Components

This Overleaf installation consists of:

1. ShareLaTeX/Overleaf - The main web application
2. MongoDB - Database for storing user and project information
3. Redis - Used for session management and caching

## Troubleshooting

If you encounter issues:

1. Check the container logs:

    ```bash
    docker compose -f docker/docker-compose.yml logs
    ```

2. Try restarting the containers:

    ```bash
    docker compose -f docker/docker-compose.yml restart
    ```

3. For persistent data issues, you might need to clean up and start fresh:
    ```bash
    bash cleanup.sh
    bash install.sh
    ```
