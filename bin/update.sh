#!/bin/bash

# Function to clean the main branch if dirty (unstaged changes)
clean_branch() {
    # Check if the main branch is dirty
    if [[ -n $(git -C "$ENVIRONMENT_DIR" status --porcelain) ]]; then
        echo "The main branch is dirty. Cleaning up..."
        git -C "$ENVIRONMENT_DIR" reset --hard  # Clean the working directory
    else
        echo "The main branch is clean."
    fi
}

# Function to check if the current branch has unpulled commits
check_unpulled_commits() {
    local status=$(git -C "$ENVIRONMENT_DIR" status -uno | grep "Your branch is behind")
    if [[ -n "$status" ]]; then
        echo "There are unpulled commits. Pulling latest changes..."
        return 0  # Indicate unpulled commits exist
    else
        echo "No unpulled commits."
        return 1  # No unpulled commits
    fi
}

# Function to update the repository
update_repo() {
    # Ensure the repo path exists
    if [[ ! -d "$ENVIRONMENT_DIR" ]]; then
        echo "The specified repository path does not exist."
        exit 1
    fi

    # Check if we are on the main branch
    current_branch=$(git -C "$ENVIRONMENT_DIR" branch --show-current)
    if [[ "$current_branch" != "main" ]]; then
        echo "Switching to the main branch..."
        git -C "$ENVIRONMENT_DIR" checkout main
    fi

    # Clean the main branch if it's dirty
    clean_branch

    # Check for unpulled commits and pull if necessary
    check_unpulled_commits
    if [[ $? -eq 0 ]]; then
        git -C "$ENVIRONMENT_DIR" pull origin main
    fi

    echo "Repository is up to date!"
}

# Call the update function
update_repo
