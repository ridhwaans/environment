#!/usr/bin/env bash

set -e

readonly DOTFILES_SOURCE="dotfiles"
readonly BASE_ENV_SOURCE="devcontainer-features/src/base"
SOURCES="${SOURCES:-""}"

DISTRIBUTION="${DISTRIBUTION:-"debian"}"
RELEASE="${RELEASE:-"stable"}"
IMAGE_NAME="${IMAGE_NAME:-"base"}"
CONTAINER_NAME="${CONTAINER_NAME:-"instance"}"

DEVELOPMENT_LOG_FILE="${DEVELOPMENT_LOG_FILE:-"log/development.log"}"

source $(dirname $0)/_helpers/install-to-local.sh
source $(dirname $0)/_helpers/install-to-container.sh
source $(dirname $0)/_helpers/install-to-codespaces.sh

# Create the log directory if it doesn't exist
mkdir -p "$(dirname "$DEVELOPMENT_LOG_FILE")"
chmod 777 "$(dirname "$DEVELOPMENT_LOG_FILE")"

# Clear the log file if it exists; if not, create an empty file
if [ -e "$DEVELOPMENT_LOG_FILE" ]; then
   > "$DEVELOPMENT_LOG_FILE"
else
  touch "$DEVELOPMENT_LOG_FILE"
  chmod 777 "$DEVELOPMENT_LOG_FILE"
fi

install_what_menu(){
  echo "Select what to install:"
  echo "1) Install base environment only"
  echo "2) Install dotfiles only"
  echo "3) Install both"
}

install_what(){
  while true; do
    install_what_menu
    read -p "Enter your choice (1, 2, or 3): " choice

    case $choice in
      1)
          SOURCES=$BASE_ENV_SOURCE
          install_where
          break
          ;;
      2)
          SOURCES=$DOTFILES_SOURCE
          install_where
          break
          ;;
      3)
          SOURCES="$BASE_ENV_PATH, $DOTFILES_PATH"
          install_where
          break
          ;;
      *)
          echo "Invalid choice. Try again."
          ;;
    esac
  done
}


docker_install_menu() {
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
    echo "1. Install into container"
    echo "2. Remove container by name"
    echo "3. Go back to previous menu"
}

docker_install() {
  while true; do
  docker_install_menu
  read -p "Enter your choice (1, 2 or 3): " docker_choice
  case $docker_choice in
    1)
        read -p "Enter the name for the Docker container: " container_name
        CONTAINER_NAME="$container_name"
        if [ ! -z "${SOURCES}" ]; then
          OLDIFS=$IFS
          IFS=","
              read -a sources <<< "$SOURCES"
              for source in "${sources[@]}"; do
                install_to_container $source
              done
          IFS=$OLDIFS
        fi
        break
        ;;
    2)
        read -p "Enter the name of the container to remove: " container_name
        CONTAINER_NAME="$container_name"
        cleanup_container
        ;;
    3)
        break # Go back to previous menu
        ;;
    *)
        echo "Invalid choice. Try again."
        ;;
  esac
  done
}

install_where_menu(){
  echo "Select installation type:"
  echo "1. Local (dockerless)"
  echo "2. Docker (local)"
  echo "3. Codespaces"
}

install_where(){
  while true; do
  install_where_menu
  read -p "Enter your choice (1, 2, or 3): " choice

  case $choice in
      1)
          echo "Installing to local (dockerless)..."
          install_to_local
          break
          ;;
      2)
          echo "Installing to docker (local)..."
          docker_install
          break
          ;;
      3)
          echo "Installing to codespaces..."
          install_to_codespaces
          break
          ;;
      *)
          echo "Invalid choice. Try again."
          ;;
  esac
  done
}

install_what
