#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

build_image() {
    DOCKERFILE_DEBIAN_STABLE=$(cat <<'EOF'
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
        echo "$DOCKERFILE_DEBIAN_STABLE" | docker build --no-cache -t "$IMAGE_NAME" -
    fi
}

install_to_container() {
  # Check if source is provided
  if [ $# -lt 1 ]; then
      echo "Usage: install_to_container <source> [<destination> (optional)]"
      exit 1
  fi

  local source=$1
  local destination=${2:-"/usr/local/bin/bootstrap"}

    # Redirect stdout and stderr of the script to a log file using tee
    echo "$(date +'%r %d-%m-%Y') Logging to $DEVELOPMENT_LOG_FILE"
    exec > >(tee -a "$DEVELOPMENT_LOG_FILE") 2>&1

    # Build the image if it does not exist locally
    if ! docker image inspect "$IMAGE_NAME" 2>/dev/null; then
        echo "Image '$IMAGE_NAME' does not exist locally."
        build_image
    fi

    # Check if the container with the specified name exists
    if docker ps -a --filter "name=$CONTAINER_NAME" --format "{{.Names}}" | grep -q "$CONTAINER_NAME"; then
        # Get the image name associated with the container
        CONTAINER_IMAGE_NAME=$(docker inspect -f '{{.Config.Image}}' "$CONTAINER_NAME")

        # Check if the image name matches the specified image name
        if [ "$CONTAINER_IMAGE_NAME" = "$IMAGE_NAME" ]; then
            echo "Container with name '$CONTAINER_NAME' and image '$IMAGE_NAME' exists."
             # Start the container in detached mode if it is not running
            if [ "$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)" = "true" ]; then
                echo "Container is already running: $CONTAINER_NAME"
            else
                docker start "$CONTAINER_NAME"
            fi
        else
            echo "Container with name '$CONTAINER_NAME' exists, but it is using a different image: $CONTAINER_IMAGE"
        fi
    else
        # Create and start the container in detached mode if it does not exist
        echo "Container with name '$CONTAINER_NAME' does not exist."
        docker run -d --name "$CONTAINER_NAME" "$IMAGE_NAME" tail -f /dev/null
    fi

    docker exec "$CONTAINER_NAME" /bin/bash -c "[ -d $destination ]" && {
    # If exit status is 0 (directory exists), recreate the destination directory
    # If exit status is 1, just continue the script
    # docker exec -d option is not applicable for running background processes like rm -rf
    docker exec "$CONTAINER_NAME" /bin/bash -c "rm -rf $destination && mkdir -p $destination"
    } || true

    # Copy files and subdirectories from the host to the container
    docker cp "$source/." "$CONTAINER_NAME":"$destination"

    # Run install.sh as sudo
    echo "Installing in Docker container: $CONTAINER_NAME..."
    docker exec -w "$destination" -it "$CONTAINER_NAME" /bin/bash -c "sudo $( [ $source = $DOTFILES_SOURCE ] && echo "-u $USERNAME" ) ./install.sh"

    # Connection instructions
    docker exec -w "$destination" -e CONTAINER_NAME="$CONTAINER_NAME" -it "$CONTAINER_NAME" /bin/bash -c '
      if [[ -f ".report" ]]; then
          source ".report"
          echo "To connect as this user in docker, run: \"docker exec -u $USERNAME -it -w /home/$USERNAME $CONTAINER_NAME $(grep "^$USERNAME:" /etc/passwd | cut -d: -f7)\""
      fi
    '
}

cleanup_container() {
    # Find and remove the container and associated image
    if docker ps -a --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
        echo "Stopping and removing container: $CONTAINER_NAME"
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1 && docker rm "$CONTAINER_NAME" >/dev/null 2>&1
    else
        echo "Container $CONTAINER_NAME not found."
    fi

    CONTAINER_IMAGE_NAME=$(docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME" 2>/dev/null) || true
    if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "$CONTAINER_IMAGE_NAME"; then
        echo "Removing image: $CONTAINER_IMAGE_NAME"
        docker rmi "$CONTAINER_IMAGE_NAME" >/dev/null 2>&1
    else
        echo "Image $CONTAINER_IMAGE_NAME not found."
    fi
}
