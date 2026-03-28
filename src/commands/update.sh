#!/usr/bin/env bash

dotenv_update_branch() {
  if [ -n "${ENVIRONMENT_BRANCH:-}" ]; then
    printf '%s\n' "$ENVIRONMENT_BRANCH"
    return 0
  fi

  git -C "$ENVIRONMENT_DIR" branch --show-current
}

dotenv_update_clean_branch() {
  if [[ -n $(git -C "$ENVIRONMENT_DIR" status --porcelain) ]]; then
    echo "The current branch is dirty. Cleaning up..."
    git -C "$ENVIRONMENT_DIR" reset --hard
  else
    echo "The current branch is clean."
  fi
}

dotenv_update_check_unpulled_commits() {
  local branch="$1"
  local status

  echo "Fetching the latest changes from the remote repository..."
  git -C "$ENVIRONMENT_DIR" fetch origin "$branch"

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
  local target_branch

  if [[ ! -d "$ENVIRONMENT_DIR" ]]; then
    echo "The specified repository path does not exist."
    return 1
  fi

  target_branch=$(dotenv_update_branch)
  current_branch=$(git -C "$ENVIRONMENT_DIR" branch --show-current)
  if [[ -z "$target_branch" ]]; then
    echo "Unable to determine which branch to update."
    return 1
  fi

  if [[ "$current_branch" != "$target_branch" ]]; then
    echo "Switching to the $target_branch branch..."
    git -C "$ENVIRONMENT_DIR" checkout "$target_branch"
  fi

  dotenv_update_clean_branch

  if dotenv_update_check_unpulled_commits "$target_branch"; then
    git -C "$ENVIRONMENT_DIR" pull origin "$target_branch"
  fi

  export ENVIRONMENT_BRANCH="$target_branch"
  persist_environment_install_state

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
export -f dotenv_update_branch
export -f dotenv_update_environment
export -f dotenv_show_update_help
export -f dotenv_handle_update
