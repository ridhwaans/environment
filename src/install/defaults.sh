#!/usr/bin/env bash

set -e

defaults_help() {
  cat <<EOF
Usage: dotenv defaults [OPTIONS]

Defaults:
  Apply defaults from dotfiles/appearance/profile.env.

Options:
  --appearance-defaults       Apply appearance defaults
  --no-appearance-defaults    Skip appearance defaults
  help                        Show this help message
EOF
}

for arg in "$@"; do
  case "$arg" in
    help)
      defaults_help
      exit 0
      ;;
    --appearance-defaults)
      export INSTALL_APPEARANCE_DEFAULTS=true
      ;;
    --no-appearance-defaults)
      export INSTALL_APPEARANCE_DEFAULTS=false
      ;;
    *)
      echo "Unknown defaults option: $arg"
      exit 1
      ;;
  esac
done

echo "Installing defaults..."

case "$INSTALL_APPEARANCE_DEFAULTS" in
    true|1|yes)
        ;;
    *)
        echo "Skipping appearance defaults."
        exit 0
        ;;
esac

"$APPEARANCE_DIR/install.sh"
