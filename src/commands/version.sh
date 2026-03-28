#!/usr/bin/env bash

dotenv_version() {
  if [ -f "$ENVIRONMENT_DIR/VERSION" ]; then
    tr -d '\n' < "$ENVIRONMENT_DIR/VERSION"
    return 0
  fi

  echo "0.0.0-dev"
}

dotenv_show_banner() {
  local version
  version=$(dotenv_version)
  awk -v version="$version" 'NR == 5 { print $0 "  v" version; next } { print }' "$ENVIRONMENT_DIR/bin/banner.txt"
}

export -f dotenv_version
export -f dotenv_show_banner
