#!/usr/bin/env bash

if [ $(uname) = Darwin ]; then
  export ADJUSTED_ID="mac"
elif [ $(uname) = Linux ]; then

  if [ ! -f /etc/os-release ]; then
    echo "/etc/os-release file not found."
    exit 1
  fi

  # Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
  . /etc/os-release

  # Get an adjusted ID independent of distro variants
  if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
    export ADJUSTED_ID="debian"
  else
    echo "Linux distro ${ID} not supported."
    exit 1
  fi
fi

echo "Installation starting..."
source ~/.local/share/environment/src/install.sh
source ~/.local/share/environment/src/configs.sh
