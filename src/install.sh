#!/usr/bin/env bash

set -e

SCRIPT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_ROOT/runtime.sh"
source "$SCRIPT_ROOT/assets.sh"
source "$SCRIPT_ROOT/platform.sh"
source "$SCRIPT_ROOT/fonts/set-font.sh"
source "$SCRIPT_ROOT/themes/set-theme.sh"
source "$SCRIPT_ROOT/commands/appearance.sh"

run_environment_baseline_install() {
  echo "ADJUSTED_ID: $ADJUSTED_ID"
  echo "SCRIPT_ROOT: $SCRIPT_ROOT"

  source "$SCRIPT_ROOT/install/common-utils.sh"
  source "$SCRIPT_ROOT/configs.sh"

  echo "Running common-utils.sh..."
  run_common_utils_install
  echo "Running baseline config setup..."
  setup_baseline_configs
  persist_environment_install_state
}

run_environment_dotfiles_install() {
  echo "ADJUSTED_ID: $ADJUSTED_ID"
  echo "SCRIPT_ROOT: $SCRIPT_ROOT"

  source "$SCRIPT_ROOT/configs.sh"

  sync_assets
  echo "Running dotfiles setup..."
  setup_dotfiles
  echo "Applying default preset..."
  apply_preset "$DEFAULT_PRESET_NAME"
  persist_environment_install_state
}

run_environment_install() {
  run_environment_baseline_install
  run_environment_dotfiles_install
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run_environment_install
fi
