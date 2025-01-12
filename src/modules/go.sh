#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

if [ "$ADJUSTED_ID" = "mac" ]; then
    packages=(
      go
    )
    run_brew_command_as_target_user install "${packages[@]}"
else
  # Verify requested version is available, convert latest
  find_version_from_git_tags GO_VERSION "https://go.googlesource.com/go" "tags/go" "." "true"

  # Create golang group to the user's UID or GID to change while still allowing access to nvm
  if ! cat /etc/group | grep -e "^golang:" > /dev/null 2>&1; then
      groupadd -r golang
  fi
  usermod -a -G golang ${USERNAME}
  mkdir -p "${GO_DIR}"

  if [[ "${GO_VERSION}" != "none" ]] && [[ "$(go version 2>/dev/null)" != *"${GO_VERSION}"* ]]; then
    echo "Downloading Go ${GO_VERSION}..."
      set +e
      curl -fsSL -o /tmp/go.tar.gz "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz"
      tar -xzf /tmp/go.tar.gz -C "${GO_DIR}" --strip-components=1
      rm -rf /tmp/go.tar.gz
  else
      echo "(!) Go is already installed with version ${GO_VERSION}. Skipping."
  fi

  chown -R "root:golang" "${GO_DIR}"
  chmod -R g+rws "${GO_DIR}"
fi

go_rc_snippet=$(cat << EOF
export GO_DIR="${GO_DIR}"
export PATH="\$GO_DIR/bin:\$PATH"
EOF
)

if [ "${UPDATE_RC}" = "true" ]; then
  updaterc "zsh" "${go_rc_snippet}"
  updaterc "bash" "${go_rc_snippet}"
fi

echo "Done!"
