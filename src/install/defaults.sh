#!/usr/bin/env bash

set -e

APPEARANCE_PROFILE=$DOTFILES_DIR/appearance/profile.env

for arg in "$@"; do
  case "$arg" in
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

if [ -f "$APPEARANCE_PROFILE" ]; then
    set -a
    source "$APPEARANCE_PROFILE"
    set +a
fi

"$APPEARANCE_DIR/install.sh"
