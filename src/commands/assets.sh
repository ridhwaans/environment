#!/usr/bin/env bash

dotenv_assets_sync() {
  sync_assets
}

dotenv_show_assets_help() {
  cat <<EOF
Usage: dotenv assets [sync]

Asset Commands:
  sync                 Clone or update the external assets repo if configured
EOF
}

dotenv_handle_assets() {
  local subcommand="${1:-sync}"

  case "$subcommand" in
    sync)
      dotenv_assets_sync
      ;;
    help)
      dotenv_show_assets_help
      ;;
    *)
      echo "Error: Unknown assets command '$subcommand'."
      dotenv_show_assets_help
      return 1
      ;;
  esac
}

export -f dotenv_assets_sync
export -f dotenv_show_assets_help
export -f dotenv_handle_assets
