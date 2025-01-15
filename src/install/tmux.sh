#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

TMUX_VERSION="${TMUXVERSION:-"latest"}"
TPM_PATH="${TPMPATH:-"/usr/local/share/tmux/bundle"}"

# Mac OS packages
install_mac_packages() {
    packages=(
      tmux
    )
    run_brew_command_as_target_user install "${packages[@]}"
}

# Debian / Ubuntu packages
install_debian_packages(){
    # Ensure apt is in non-interactive to avoid prompts
    export DEBIAN_FRONTEND=noninteractive
    apt install -y --no-install-recommends gcc make libevent-dev ncurses-dev bison
}

# Install packages for appropriate OS
case "${ADJUSTED_ID}" in
    "debian")
        install_debian_packages
        ;;
    "mac")
        install_mac_packages
        ;;
esac

if [ "$ADJUSTED_ID" != "debian" ]; then
  echo "Current distro not supported for sshd installation"
  exit 0
fi

# Verify requested version is available, convert latest
if [  "$TMUX_VERSION" = "latest" ]; then
  # Get the version from the latest release
  TMUX_VERSION=$(curl -s "https://api.github.com/repos/tmux/tmux/releases/latest" | conditional_grep -oP '"tag_name": "\K(.*)(?=")')
fi

if [[ "$(tmux -V 2>/dev/null)" != *"${TMUX_VERSION}"* ]]; then
  echo "Downloading tmux ${TMUX_VERSION}..."
  set +e
  curl -sL https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz | tar -xzC /tmp 2>&1
  cd /tmp/tmux-${TMUX_VERSION}
  ./configure
  make && make install
  cd -
  rm -rf /tmp/tmux-${TMUX_VERSION}
else
    echo "(!) tmux is already installed with version ${TMUX_VERSION}. Skipping."
fi

echo "Installing system-wide plugin manager for tmux..."
[ ! -d ${TPM_PATH} ] && git clone https://github.com/tmux-plugins/tpm ${TPM_PATH}
if [ "$ADJUSTED_ID" != "mac" ]; then
  # Create group
  if ! cat /etc/group | grep -e "^tpm:" > /dev/null 2>&1; then
      groupadd -r tpm
  fi
  usermod -a -G tpm ${USERNAME}
  chown -R "root:tpm" "$(dirname $TPM_PATH)"
  chmod -R 775 "$(dirname $TPM_PATH)"
fi

echo "Done!"
