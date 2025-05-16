#!/bin/sh

# Set working directory
cd "$(dirname "$0")"

echo "==================================================="
echo "Checking TeX Live packages in the Overleaf container"
echo "==================================================="

# Check if the sharelatex container is running
if ! docker ps | grep -q overleaf_sharelatex; then
    echo "ERROR: The Sharelatex container is not running."
    echo "Please start it first using ./run.sh"
    exit 1
fi

echo "Available options:"
echo "1) List all installed packages"
echo "2) Check if specific package is installed"
echo "3) Get information about a specific package"
read -p "Enter your choice (1/2/3): " CHECK_CHOICE

if [ "$CHECK_CHOICE" = "1" ]; then
    echo "Listing all installed packages (this may take a while)..."
    docker exec overleaf_sharelatex tlmgr list --only-installed
elif [ "$CHECK_CHOICE" = "2" ]; then
    echo "Enter the package name to check:"
    read -p "> " PACKAGE_NAME
    if [ -z "$PACKAGE_NAME" ]; then
        echo "No package specified. Exiting."
        exit 1
    fi
    echo "Checking if $PACKAGE_NAME is installed..."
    docker exec overleaf_sharelatex tlmgr info "$PACKAGE_NAME"
elif [ "$CHECK_CHOICE" = "3" ]; then
    echo "Enter the package name to get info about:"
    read -p "> " PACKAGE_NAME
    if [ -z "$PACKAGE_NAME" ]; then
        echo "No package specified. Exiting."
        exit 1
    fi
    echo "Getting information about $PACKAGE_NAME..."
    docker exec overleaf_sharelatex tlmgr info "$PACKAGE_NAME" --list
else
    echo "Invalid choice. Exiting."
    exit 1
fi

echo "==================================================="
echo "Check complete!"
echo "==================================================="
