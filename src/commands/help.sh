#!/usr/bin/env bash

dotenv_show_help() {
  cat <<EOF
Usage: $(basename "$0") [COMMAND] [OPTIONS]

Commands:
  install              Install environment-managed dependencies and configs
  update               Get the newest changes for the environment repo
  reset                Reset system, appearance, or both
  assets               Manage external theme/font assets
  font                 Font management (use 'font help' for details)
  theme                Theme management (use 'theme help' for details)
  version              Show the installed dotenv version
  help                 Show this help message
EOF
}

export -f dotenv_show_help
