#!/usr/bin/env bash

set -e

APPEARANCE_DIR=${APPEARANCE_DIR:-$HOME/Source/appearance}
APPEARANCE_REPO_URL=${APPEARANCE_REPO_URL:-https://github.com/ridhwaans/appearance.git}

echo "Installing appearance..."

if [ ! -d "$APPEARANCE_DIR/.git" ]; then
    if [ -e "$APPEARANCE_DIR" ]; then
        echo "Appearance path exists but is not a git repository: $APPEARANCE_DIR"
        exit 1
    fi

    git clone -b main "$APPEARANCE_REPO_URL" "$APPEARANCE_DIR"
fi

if [ ! -x "$APPEARANCE_DIR/bin/appearance" ]; then
    echo "Appearance executable not found: $APPEARANCE_DIR/bin/appearance"
    exit 1
fi
