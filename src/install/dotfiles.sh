#!/usr/bin/env bash

set -e

DOTFILES_DIR=${DOTFILES_DIR:-$HOME/Source/dotfiles}
DOTFILES_REPO_URL=${DOTFILES_REPO_URL:-https://github.com/ridhwaans/dotfiles.git}

echo "Installing dotfiles..."

if [ ! -d "$DOTFILES_DIR/.git" ]; then
    if [ -e "$DOTFILES_DIR" ]; then
        echo "Dotfiles path exists but is not a git repository: $DOTFILES_DIR"
        exit 1
    fi

    git clone -b main "$DOTFILES_REPO_URL" "$DOTFILES_DIR"
fi

if command -v mise &>/dev/null && [ -f "$DOTFILES_DIR/mise/config.toml" ]; then
    mise trust -q "$DOTFILES_DIR/mise/config.toml"
fi
