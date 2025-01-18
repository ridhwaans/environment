#!/bin/bash

clean_branch() {
    if [[ -n $(git -C "$ENVIRONMENT_DIR" status --porcelain) ]]; then
        echo "The main branch is dirty. Cleaning up..."
        git -C "$ENVIRONMENT_DIR" reset --hard  # Clean the working directory
    else
        echo "The main branch is clean."
    fi
}

check_unpulled_commits() {
    echo "Fetching the latest changes from the remote repository..."
    git -C "$ENVIRONMENT_DIR" fetch origin main  # Get up-to-date remote state

    local status=$(git -C "$ENVIRONMENT_DIR" status -uno | grep "Your branch is behind")
    if [[ -n "$status" ]]; then
        echo "There are unpulled commits. Pulling latest changes..."
        return 0
    else
        echo "No unpulled commits."
        return 1
    fi
}

update_repo() {
    if [[ ! -d "$ENVIRONMENT_DIR" ]]; then
        echo "The specified repository path does not exist."
        exit 1
    fi

    current_branch=$(git -C "$ENVIRONMENT_DIR" branch --show-current)
    if [[ "$current_branch" != "main" ]]; then
        echo "Switching to the main branch..."
        git -C "$ENVIRONMENT_DIR" checkout main
    fi

    clean_branch

    check_unpulled_commits
    if [[ $? -eq 0 ]]; then
        git -C "$ENVIRONMENT_DIR" pull origin main
    fi

    echo "Repository is up to date!"
}

update_repo
