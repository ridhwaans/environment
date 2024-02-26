#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

DISTRIBUTION="${DISTRIBUTION:-"debian"}"
RELEASE="${RELEASE:-"stable"}"
IMAGE_NAME="${IMAGE_NAME:-"base"}"
CONTAINER_NAME="${CONTAINER_NAME:-"instance"}"
CLIENT_DIR="${CLIENT_DIR:-"devcontainer-features/src/base"}"
WORKING_DIR="${WORKING_DIR:-"/usr/local/bin/bootstrap"}"
DEVELOPMENT_LOG_FILE="${DEVELOPMENT_LOG_FILE:-"log/development.log"}"

source $(dirname $0)/install-to-container.sh
source $(dirname $0)/install-to-codespaces.sh

# Create the log directory if it doesn't exist
mkdir -p "$(dirname "$DEVELOPMENT_LOG_FILE")"
chmod 777 "$(dirname "$DEVELOPMENT_LOG_FILE")"

# Check if the log file exists; if not, create an empty file
if [ ! -e "$DEVELOPMENT_LOG_FILE" ]; then
    touch "$DEVELOPMENT_LOG_FILE"
    chmod 777 "$DEVELOPMENT_LOG_FILE"
fi

install_to_local() {
    cd devcontainer-features/src/base && ./install.sh
}

docker_installation_menu() {
    containers=$(docker ps -a --format '{{.Names}}')
    if [ "$containers" ]; then
        echo "Existing Docker containers:"
        echo "$containers"
    fi

    echo ""
    images=$(docker images --format '{{.Repository}}:{{.Tag}}')
    if [ "$images" ]; then
        echo "Existing Docker images:"
        echo "$images"
    fi

    echo ""
    echo "Select Docker installation type:"
    echo "1. Install into Docker container"
    echo "2. Remove container by name (local)"
    echo "3. Go back to previous menu"
}

# Ask the user for installation type
echo "Select installation type:"
echo "1. Local (dockerless)"
echo "2. Docker (local)"
echo "3. Codespaces"
read -p "Enter your choice (1, 2, or 3): " choice

# Check the user's choice and proceed accordingly
case $choice in
    1)
        echo "Installing to local (dockerless)..."
        install_to_local
        ;;
    2)
        echo "Installing to docker (local)..."
        while true; do
            docker_installation_menu
            read -p "Enter your choice (1, 2 or 3): " docker_choice
            case $docker_choice in
                1)
                    read -p "Enter the name for the Docker container: " container_name
                    CONTAINER_NAME="$container_name"
                    install_to_container
                    break
                    ;;
                2)
                    read -p "Enter the name of the container to remove: " container_name
                    CONTAINER_NAME="$container_name"
                    cleanup_container
                    ;;
                3)
                    break  # Go back to previous menu
                    ;;
                *)
                    echo "Invalid choice. Please enter 1, 2, or 3."
                    ;;
            esac
        done
        ;;
    3)
        echo "Installing to codespaces..."
        install_to_codespaces
        ;;
    *)
        echo "Invalid choice. Try again."
        ;;
esac

echo "Done"
