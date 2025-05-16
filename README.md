# Simple Overleaf Toolkit

A streamlined toolkit for running Overleaf Community Edition locally via Docker Compose.

## Quick Start

### Installation

```bash
# First-time installation
bash install.sh

# After installation, install additional TeX packages (recommended)
bash update.sh
```

For detailed installation instructions, see [INSTALL.md](INSTALL.md).

### Accessing Overleaf

Once running, Overleaf is available at:

http://localhost:8080/launchpad

### Daily Usage

```bash
# Start existing installation
bash run.sh

# Stop all services
bash stop.sh
```

## Toolkit Scripts

| Script              | Description                                                  |
| ------------------- | ------------------------------------------------------------ |
| `install.sh`        | First-time installation of Overleaf                          |
| `run.sh`            | Start all services in the correct order                      |
| `stop.sh`           | Stop all services                                            |
| `shell.sh`          | Open a shell in the Sharelatex container                     |
| `update.sh`         | Install/update TeX packages (recommended after installation) |
| `check-packages.sh` | Verify installed TeX packages                                |
| `cleanup.sh`        | Remove all containers, volumes, and data                     |

## Data Storage

All data is stored in Docker volumes, which are backed by the `docker/data` directory:

-   `docker/data/sharelatex` - Document data
-   `docker/data/mongo` - MongoDB data
-   `docker/data/redis` - Redis data

## System Components

This Overleaf installation consists of:

1. **ShareLaTeX/Overleaf** - The main web application
2. **MongoDB** - Database for storing user and project information
3. **Redis** - Used for session management and caching

## Basic Troubleshooting

If you encounter issues:

1. Check container logs:

    ```bash
    docker compose -f docker/docker-compose.yml logs
    ```

2. Restart services:

    ```bash
    docker compose -f docker/docker-compose.yml restart
    ```

3. For persistent issues, reset the installation:
    ```bash
    bash cleanup.sh   # Warning: Deletes all data!
    bash install.sh
    ```

For more detailed troubleshooting and configuration options, refer to [INSTALL.md](INSTALL.md).

## License

This toolkit is available under the MIT License. See [LICENSE](LICENSE) file for details.

## Additional Resources

-   [Overleaf Community Edition](https://github.com/overleaf/overleaf)
-   [Docker Documentation](https://docs.docker.com/)
-   [TeX Live Documentation](https://www.tug.org/texlive/doc.html)
