#!/usr/bin/env bash

dotenv_install_environment() {
  source "$ENVIRONMENT_DIR/system-check.sh"
  source "$ENVIRONMENT_DIR/src/install.sh"
  run_environment_install
}

dotenv_install_baseline() {
  source "$ENVIRONMENT_DIR/system-check.sh"
  source "$ENVIRONMENT_DIR/src/install.sh"
  run_environment_baseline_install
}

dotenv_install_dotfiles() {
  source "$ENVIRONMENT_DIR/system-check.sh"
  source "$ENVIRONMENT_DIR/src/install.sh"
  run_environment_dotfiles_install
}

dotenv_show_install_help() {
  cat <<EOF
Usage: dotenv install [environment|baseline|dotfiles]

Install Targets:
  environment          Install the full machine setup: baseline + dotfiles + default preset
  baseline             Install packages, core tools, runtimes, and the dotenv CLI
  dotfiles             Apply configs, plugin sync, assets, and the default preset
EOF
}

dotenv_handle_install() {
  local target="${1:-environment}"

  case "$target" in
    environment)
      dotenv_install_environment
      ;;
    baseline)
      dotenv_install_baseline
      ;;
    dotfiles)
      dotenv_install_dotfiles
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
export -f dotenv_install_baseline
export -f dotenv_install_dotfiles
export -f dotenv_show_install_help
export -f dotenv_handle_install
