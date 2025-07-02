#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

NVIM_VERSION="${NVIMVERSION:-"nightly"}"

# Mac OS packages
install_mac_packages() {
    packages=(
      neovim
    )
    run_brew_command_as_target_user install "${packages[@]}"
    echo "Done!"
    exit 0
}

# Debian / Ubuntu packages
install_debian_packages(){
    # Ensure apt is in non-interactive to avoid prompts
    export DEBIAN_FRONTEND=noninteractive
    apt install -y --no-install-recommends ninja-build gettext cmake unzip curl build-essential
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
  echo "Current distro not supported for neovim installation"
  exit 0
fi

# Verify requested version is available
ADJUSTED_VERSION=$NVIM_VERSION

if [  "$NVIM_VERSION" != "stable" ] && [  "$NVIM_VERSION" != "nightly" ]; then
    ADJUSTED_VERSION="v$NVIM_VERSION"
fi

if [[ "$(nvim -v 2>/dev/null)" != *"${ADJUSTED_VERSION}"* ]]; then
  echo "Downloading nvim ${ADJUSTED_VERSION}..."
  set +e
  curl -sL https://github.com/neovim/neovim/archive/refs/tags/${ADJUSTED_VERSION}.tar.gz | tar -xzC /tmp 2>&1
  cd /tmp/neovim-${ADJUSTED_VERSION}
  make && make install
  cd -
  rm -rf /tmp/nvim-${ADJUSTED_VERSION}
else
    echo "(!) neovim is already installed with version ${ADJUSTED_VERSION}. Skipping."
fi

echo "Done!"
