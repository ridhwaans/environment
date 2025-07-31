#!/usr/bin/env bash

set -e

echo "ADJUSTED_ID: $ADJUSTED_ID"

SCRIPT_ROOT=$(dirname "${BASH_SOURCE[0]}")
echo "SCRIPT_ROOT: $SCRIPT_ROOT"
source $SCRIPT_ROOT/_helper.sh
export CONFIGS_DIR=$SCRIPT_ROOT/configs

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

for script in "$SCRIPT_ROOT/install/common-utils.sh" "$SCRIPT_ROOT/configs.sh"; do
  echo "Running $(basename "$script")..."
  bash "$script"
done
