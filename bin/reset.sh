#!/bin/bash

set -e

reset_help() {
  cat <<EOF
Usage: dotenv reset [OPTIONS]

Repositories:
  environment
  dotfiles
  appearance

Behavior:
  Fetch origin/main and reset each repository to origin/main.
  Local changes in tracked files are discarded.

Options:
  help           Show this help message
EOF
}

if [[ "${1:-}" = "help" ]]; then
    reset_help
    exit 0
fi

reset_repo() {
    local repo_dir=$1
    local repo_name=$2

    if [[ ! -d "$repo_dir/.git" ]]; then
        echo "$repo_name repository not found: $repo_dir"
        return
    fi

    current_branch=$(git -C "$repo_dir" branch --show-current)
    if [[ "$current_branch" != "main" ]]; then
        echo "$repo_name switching to main..."
        git -C "$repo_dir" switch -f main
    fi

    echo "Fetching $repo_name..."
    git -C "$repo_dir" fetch origin main

    echo "Resetting $repo_name to origin/main..."
    git -C "$repo_dir" reset --hard origin/main
}

reset_repo "$ENVIRONMENT_DIR" "environment"
reset_repo "$DOTFILES_DIR" "dotfiles"
reset_repo "$APPEARANCE_DIR" "appearance"
