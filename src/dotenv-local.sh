#!/bin/bash

source "$ENVIRONMENT_DIR/src/runtime.sh"
source "$ENVIRONMENT_DIR/src/defaults.sh"
source "$ENVIRONMENT_DIR/src/assets.sh"
source "$ENVIRONMENT_DIR/src/configs.sh"
source "$ENVIRONMENT_DIR/src/fonts/set-font.sh"
source "$ENVIRONMENT_DIR/src/themes/set-theme.sh"
source "$ENVIRONMENT_DIR/src/commands/version.sh"
source "$ENVIRONMENT_DIR/src/commands/install.sh"
source "$ENVIRONMENT_DIR/src/commands/update.sh"
source "$ENVIRONMENT_DIR/src/commands/assets.sh"
source "$ENVIRONMENT_DIR/src/commands/reset.sh"
source "$ENVIRONMENT_DIR/src/commands/help.sh"

dotenv_dispatch_local() {
  local command

  if [[ "$#" -lt 1 ]]; then
    dotenv_show_banner
    dotenv_show_help
    return 1
  fi

  command="$1"
  shift

  case "$command" in
    install)
      dotenv_handle_install "$@"
      ;;
    update)
      dotenv_handle_update "$@"
      ;;
    reset)
      dotenv_handle_reset "$@"
      ;;
    assets)
      dotenv_handle_assets "$@"
      ;;
    font)
      "$ENVIRONMENT_DIR/bin/font.sh" "$@"
      ;;
    theme)
      "$ENVIRONMENT_DIR/bin/theme.sh" "$@"
      ;;
    version)
      dotenv_version
      ;;
    help)
      dotenv_show_help
      ;;
    *)
      echo "Error: Unknown command '$command'."
      dotenv_show_help
      return 1
      ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  dotenv_dispatch_local "$@"
fi
