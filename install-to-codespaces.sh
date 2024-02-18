#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

install_to_codespaces() {
    # Check if GitHub CLI is installed
    if ! command -v gh &> /dev/null; then
        echo "GitHub CLI (gh) is required but not installed. Please install it first."
        exit 1
    fi

    # Check if a URL is provided
    if [ $# -ne 1 ]; then
        echo "Usage: install_to_codespaces <decontainer_feature_url>"
        exit 1
    fi

    # Extract repository owner and name from the URL
    url=$1
    repo_owner=$(echo "$url" | cut -d'/' -f4)
    repo_name=$(echo "$url" | cut -d'/' -f5)

    # Check if the repository exists
    if gh repo view "$repo_owner/$repo_name" &> /dev/null; then
        echo "Repository already exists."

        # Clone the repository
        git clone "https://github.com/$repo_owner/$repo_name.git"
        cd "$repo_name" || exit 1

        # Check if devcontainer.json exists in the repository
        if [ -f ".devcontainer/devcontainer.json" ]; then
            # Check if devcontainer.json has the correct URL
            if ! grep -q "$url" .devcontainer/devcontainer.json; then
                echo "Rewriting devcontainer.json URL"
                jq ". += {\"decontainerFeatureUrl\": \"$url\"}" .devcontainer/devcontainer.json > tmp_devcontainer.json && mv tmp_devcontainer.json .devcontainer/devcontainer.json
                git add .devcontainer/devcontainer.json
                git commit -m "Update devcontainer.json with decontainer feature"
                git push origin main
            else
                echo "devcontainer.json already points to the correct URL"
            fi
        else
            echo "devcontainer.json not found in the repository"
        fi

        # Return to the original directory
        cd ..
    else
        # Create a new repository
        gh repo create "$repo_owner/$repo_name" --private

        # Create a codespace using the decontainer feature URL
        gh codespace create --name "$repo_name-codespace" --decontainer-feature-url "$url" "$repo_owner/$repo_name"
    fi
}