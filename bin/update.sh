#!/bin/bash

set -e

update_repo() {
    local repo_dir=$1
    local repo_name=$2

    if [[ ! -d "$repo_dir/.git" ]]; then
        echo "$repo_name repository not found: $repo_dir"
        return
    fi

    if [[ -n $(git -C "$repo_dir" status --porcelain) ]]; then
        echo "$repo_name has local changes. Skipping update."
        return
    fi

    current_branch=$(git -C "$repo_dir" branch --show-current)
    if [[ "$current_branch" != "main" ]]; then
        echo "$repo_name is on $current_branch. Skipping update."
        return
    fi

    echo "Fetching $repo_name..."
    git -C "$repo_dir" fetch origin main

    local status=$(git -C "$repo_dir" status -uno | grep "Your branch is behind" || true)
    if [[ -n "$status" ]]; then
        echo "Updating $repo_name..."
        git -C "$repo_dir" pull origin main
    else
        echo "$repo_name is up to date."
    fi
}

update_repo "$ENVIRONMENT_DIR" "environment"
update_repo "$DOTFILES_DIR" "dotfiles"
update_repo "$APPEARANCE_DIR" "appearance"
