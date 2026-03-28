#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT_BRANCH="${ENVIRONMENT_BRANCH:-test}"

docker run -w /root -it --rm debian bash -c '
  apt update -y &&
  apt install -y --no-install-recommends ca-certificates curl git sudo zsh &&
  curl -fsSL https://raw.githubusercontent.com/ridhwaans/environment/refs/heads/'"$ENVIRONMENT_BRANCH"'/user.sh | bash &&
  TARGET_USERNAME=$(grep "^TARGET_USERNAME=" /tmp/.environment | cut -d"=" -f2-) &&
  sudo -u "$TARGET_USERNAME" bash -c "export ENVIRONMENT_BRANCH='"$ENVIRONMENT_BRANCH"'; curl -fsSL https://raw.githubusercontent.com/ridhwaans/environment/refs/heads/'"$ENVIRONMENT_BRANCH"'/boot.sh | bash" &&
  exec sudo -u "$TARGET_USERNAME" env \
    HOME="/home/$TARGET_USERNAME" \
    ZDOTDIR="/home/$TARGET_USERNAME/.config/zsh" \
    bash -c "cd \$HOME && exec zsh -l"
'
