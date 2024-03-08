#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

build_image() {
    DOCKERFILE_CONTENT=$(cat <<'EOF'
ARG DISTRIBUTION=debian

ARG RELEASE=stable

FROM $DISTRIBUTION:$RELEASE

# Required for first time sudo commands
RUN apt-get update && apt-get install -y sudo

EOF
)

    echo "Building Docker image: $IMAGE_NAME..."
    # Check if Dockerfile exists in the current directory
    if [ -f Dockerfile ]; then
        # Use the Dockerfile in the current directory
        docker build --no-cache -t "$IMAGE_NAME" .
    else
        # Use the inline Dockerfile content
        echo "$DOCKERFILE_CONTENT" | docker build --no-cache -t "$IMAGE_NAME" -
    fi
}

install_to_container() {
  if [ "$#" -ne 2 ]; then
      echo "Usage: ${FUNCNAME[1]} source destination"
      exit 1
  fi

  local source=$1
  local destination=${2:-"/usr/local/bin/bootstrap"}

    # Redirect stdout and stderr of the script to a log file using tee
    echo "$(date +'%r %d-%m-%Y') Logging to $DEVELOPMENT_LOG_FILE"
    exec > >(tee -a "$DEVELOPMENT_LOG_FILE") 2>&1

    # Check if the container does not exist
    if ! docker ps --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
        build_image
    fi

    # Start the container if it is not running
    if [ "$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)" = "true" ]; then
        echo "Container is already running: $CONTAINER_NAME"
    else
        docker run -d --name "$CONTAINER_NAME" "$IMAGE_NAME" tail -f /dev/null
    fi

    # Recreate the destination folder
    # docker exec -d option is not applicable for running background processes like rm -rf
    echo "Recreating destination directory $destination in Docker container: $CONTAINER_NAME..."
    if ! docker exec "$CONTAINER_NAME" /bin/bash -c "[ -d \"$destination\" ] && rm -rf \"$destination\""; then
        echo "Failed to remove directory $destination in container $CONTAINER_NAME" >&2
        exit 1
    fi

    if ! docker exec "$CONTAINER_NAME" /bin/bash -c "mkdir -p \"$destination\""; then
        echo "Failed to create directory $destination in container $CONTAINER_NAME" >&2
        exit 1
    fi

    # Copy files and subdirectories from the host to the container
    docker cp "$source/." "$CONTAINER_NAME":"$destination"

    # Run install.sh as sudo
    echo "Installing in Docker container: $CONTAINER_NAME..."
    docker exec -w "$destination" -it "$CONTAINER_NAME" /bin/bash -c "sudo $( [ $source = $DOTFILES_SOURCE ] && echo "-u $USERNAME" ) ./install.sh"

    # Connection instructions
    docker exec -w "$destination" -e CONTAINER_NAME="$CONTAINER_NAME" -it "$CONTAINER_NAME" /bin/bash -c '
      if [[ -f ".report" ]]; then
          source ".report"
          echo "To connect as the user in docker, run: \"docker exec -u $USERNAME -it -w /home/$USERNAME $CONTAINER_NAME $(grep "^$USERNAME:" /etc/passwd | cut -d: -f7)\""
      fi
    '
}

cleanup_container() {
    # Find and remove the container and associated image
    IMAGE_NAME=$(docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME" 2>/dev/null)

    if docker ps -a --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
        echo "Stopping and removing container: $CONTAINER_NAME"
        docker stop "$CONTAINER_NAME" && docker rm "$CONTAINER_NAME"
    else
        echo "Container $CONTAINER_NAME not found."
    fi

    if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "$IMAGE_NAME"; then
        echo "Removing image: $IMAGE_NAME"
        docker rmi "$IMAGE_NAME"
    else
        echo "Image $IMAGE_NAME not found."
    fi
}
