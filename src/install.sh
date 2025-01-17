#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

SCRIPT_ROOT=$(dirname "${BASH_SOURCE[0]}")

echo "Script directory: $SCRIPT_ROOT"

# load helper functions
source $SCRIPT_ROOT/_helper.sh

modules=(
  common-utils.sh
  tmux.sh
  java.sh
  python.sh
  ruby.sh
  node.sh
  go.sh
  tools.sh
  sshd.sh
  apps.sh
)
total=${#modules[@]}
cur=1

for module in "${modules[@]}"; do
    sudo bash -c "
      export ADJUSTED_ID=$ADJUSTED_ID
      export USERNAME=$USERNAME
      source $SCRIPT_ROOT/_helper.sh
      sudo . $SCRIPT_ROOT/install/$module"

    exit_status=$?

    if [ $exit_status -eq 0 ]; then
        echo "($cur/$total) Module '$module' executed successfully."
    else
        echo "Error: ($cur/$total) Module '$module' failed to execute with status $exit_status."
        exit 1
    fi
    ((cur++))
done
