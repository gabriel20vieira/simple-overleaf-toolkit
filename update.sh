#!/bin/sh

# Set working directory
cd "$(dirname "$0")"

echo "==================================================="
echo "Updating Sharelatex with additional TeX packages"
echo "==================================================="

# Check if the sharelatex container is running
if ! docker ps | grep -q overleaf_sharelatex; then
    echo "ERROR: The Sharelatex container is not running."
    echo "Please start it first using ./run.sh"
    exit 1
fi

echo "Step 1: Installing TeX Live packages (this may take a while)..."

# Get current Sharelatex version
echo "Checking for Sharelatex version..."

# First check if config/version exists
if ! docker exec overleaf_sharelatex test -f config/version; then
    echo "config/version file does not exist. Creating it..."
    # Get the image tag/version
    IMAGE_VERSION=$(docker inspect --format='{{index .Config.Image}}' overleaf_sharelatex | cut -d: -f2)
    if [ "$IMAGE_VERSION" = "" ] || [ "$IMAGE_VERSION" = "latest" ]; then
        # If using 'latest' tag, use a default version
        DEFAULT_VERSION="latest"
        docker exec overleaf_sharelatex mkdir -p config
        docker exec overleaf_sharelatex sh -c "echo $DEFAULT_VERSION > config/version"
        CURRENT_VERSION="$DEFAULT_VERSION"
    else
        CURRENT_VERSION="$IMAGE_VERSION"
        docker exec overleaf_sharelatex mkdir -p config
        docker exec overleaf_sharelatex sh -c "echo $CURRENT_VERSION > config/version"
    fi
    echo "config/version file created with version: $CURRENT_VERSION"
else
    CURRENT_VERSION=$(docker exec overleaf_sharelatex cat config/version)
    if [ -z "$CURRENT_VERSION" ]; then
        echo "WARNING: config/version exists but is empty. Using 'latest' as version."
        CURRENT_VERSION="latest"
        docker exec overleaf_sharelatex sh -c "echo $CURRENT_VERSION > config/version"
    fi
fi

echo "Current Sharelatex version: $CURRENT_VERSION"

# Ask for packages to install
echo ""
echo "Options for package installation:"
echo "1) Install all TeX Live packages (scheme-full) - This will take a long time and use several GB of disk space"
echo "2) Install specific packages only"
echo "3) Update all already installed packages"
read -p "Enter your choice (1/2/3): " PACKAGE_CHOICE

if [ "$PACKAGE_CHOICE" = "1" ]; then
    echo "Updating tlmgr (TeX Live package manager) first..."
    docker exec overleaf_sharelatex tlmgr update --self
    if [ $? -ne 0 ]; then
        echo "Error updating tlmgr. Using alternative method..."
        docker exec overleaf_sharelatex sh -c "cd /tmp && wget https://mirror.ctan.org/systems/texlive/tlnet/update-tlmgr-latest.sh && sh update-tlmgr-latest.sh"
    fi
    
    echo "Installing all TeX Live packages (scheme-full). This will take a long time..."
    docker exec overleaf_sharelatex tlmgr install scheme-full
    NEW_TAG="$CURRENT_VERSION-with-texlive-full"
elif [ "$PACKAGE_CHOICE" = "3" ]; then
    echo "Updating tlmgr (TeX Live package manager) first..."
    docker exec overleaf_sharelatex tlmgr update --self
    if [ $? -ne 0 ]; then
        echo "Error updating tlmgr. Using alternative method..."
        docker exec overleaf_sharelatex sh -c "cd /tmp && wget https://mirror.ctan.org/systems/texlive/tlnet/update-tlmgr-latest.sh && sh update-tlmgr-latest.sh"
    fi
    
    echo "Updating all installed packages..."
    docker exec overleaf_sharelatex tlmgr update --all
    NEW_TAG="$CURRENT_VERSION-updated"
else
    echo "Enter the packages to install (space-separated, e.g., 'tikzlings tikzmarmots tikzducks'):"
    read -p "> " PACKAGES
    if [ -z "$PACKAGES" ]; then
        echo "No packages specified. Exiting."
        exit 1
    fi
    
    echo "Updating tlmgr (TeX Live package manager) first..."
    docker exec overleaf_sharelatex tlmgr update --self
    if [ $? -ne 0 ]; then
        echo "Error updating tlmgr. Using alternative method..."
        docker exec overleaf_sharelatex sh -c "cd /tmp && wget https://mirror.ctan.org/systems/texlive/tlnet/update-tlmgr-latest.sh && sh update-tlmgr-latest.sh"
    fi
    
    echo "Installing packages: $PACKAGES"
    docker exec overleaf_sharelatex tlmgr install $PACKAGES
    PACKAGE_LIST=$(echo $PACKAGES | tr ' ' '-')
    NEW_TAG="$CURRENT_VERSION-with-$PACKAGE_LIST"
fi

# Commit changes to a new image
echo ""
echo "Step 2: Saving changes to a new Docker image..."
docker commit overleaf_sharelatex "sharelatex/sharelatex:$NEW_TAG"
echo "New image created: sharelatex/sharelatex:$NEW_TAG"

# Save version information
echo "$NEW_TAG" > docker/sharelatex-version
echo "Version information saved to docker/sharelatex-version"

echo ""
echo "==================================================="
echo "Update complete!"
echo "The new image has been created: sharelatex/sharelatex:$NEW_TAG"
echo "To use this image in the future, update your docker-compose.yml file"
echo "to reference this image tag instead of 'latest'"
echo "==================================================="
