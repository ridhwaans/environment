#!/usr/bin/env bash

dotenv_install_environment() {
  source "$ENVIRONMENT_DIR/system-check.sh"
  source "$ENVIRONMENT_DIR/src/install.sh"
  run_environment_install
}

dotenv_show_install_help() {
  cat <<EOF
Usage: dotenv install [environment]

Install Targets:
  environment          Bootstrap packages, tools, configs, and default assets
EOF
}

dotenv_handle_install() {
  local target="${1:-environment}"

  case "$target" in
    environment)
      dotenv_install_environment
      ;;
    help)
      dotenv_show_install_help
      ;;
    *)
      echo "Error: Unknown install target '$target'."
      dotenv_show_install_help
      return 1
      ;;
  esac
}

export -f dotenv_install_environment
export -f dotenv_show_install_help
export -f dotenv_handle_install
