#!/usr/bin/env bash

dotenv_update_clean_branch() {
  if [[ -n $(git -C "$ENVIRONMENT_DIR" status --porcelain) ]]; then
    echo "The main branch is dirty. Cleaning up..."
    git -C "$ENVIRONMENT_DIR" reset --hard
  else
    echo "The main branch is clean."
  fi
}

dotenv_update_check_unpulled_commits() {
  local status

  echo "Fetching the latest changes from the remote repository..."
  git -C "$ENVIRONMENT_DIR" fetch origin main

  status=$(git -C "$ENVIRONMENT_DIR" status -uno | grep "Your branch is behind")
  if [[ -n "$status" ]]; then
    echo "There are unpulled commits. Pulling latest changes..."
    return 0
  fi

  echo "No unpulled commits."
  return 1
}

dotenv_update_environment() {
  local current_branch

  if [[ ! -d "$ENVIRONMENT_DIR" ]]; then
    echo "The specified repository path does not exist."
    return 1
  fi

  current_branch=$(git -C "$ENVIRONMENT_DIR" branch --show-current)
  if [[ "$current_branch" != "main" ]]; then
    echo "Switching to the main branch..."
    git -C "$ENVIRONMENT_DIR" checkout main
  fi

  dotenv_update_clean_branch

  if dotenv_update_check_unpulled_commits; then
    git -C "$ENVIRONMENT_DIR" pull origin main
  fi

  echo "Repository is up to date!"
}

dotenv_show_update_help() {
  cat <<EOF
Usage: dotenv update [environment]

Update Targets:
  environment          Pull the latest changes for the environment repo
EOF
}

dotenv_handle_update() {
  local target="${1:-environment}"

  case "$target" in
    environment)
      dotenv_update_environment
      ;;
    help)
      dotenv_show_update_help
      ;;
    *)
      echo "Error: Unknown update target '$target'."
      dotenv_show_update_help
      return 1
      ;;
  esac
}

export -f dotenv_update_clean_branch
export -f dotenv_update_check_unpulled_commits
export -f dotenv_update_environment
export -f dotenv_show_update_help
export -f dotenv_handle_update
