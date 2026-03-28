#!/usr/bin/env bash

set -e

SCRIPT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_ROOT/runtime.sh"
source "$SCRIPT_ROOT/assets.sh"

run_environment_install() {
  echo "ADJUSTED_ID: $ADJUSTED_ID"
  echo "SCRIPT_ROOT: $SCRIPT_ROOT"

  sync_assets

  for script in "$SCRIPT_ROOT/install/common-utils.sh" "$SCRIPT_ROOT/configs.sh"; do
    echo "Running $(basename "$script")..."
    bash "$script"
  done
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run_environment_install
fi
