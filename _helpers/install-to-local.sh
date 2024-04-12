#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

install_to_local() {
  if [ ! -z "${sources}" ]; then
    OLDIFS=$IFS
    IFS=","
        read -a sources <<< "$SOURCES"
        for source in "${sources[@]}"; do
          # For dotfiles, username is the original user who invoked sudo, not the username of the root user
          cd $source && sudo $( [ $source = $DOTFILES_SOURCE ] && echo "-u $USERNAME" ) ./install.sh
        done
    IFS=$OLDIFS
  fi
}
