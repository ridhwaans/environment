#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

# Mac OS
install_mac_dependencies() {
  if ! command -v xcode-select &>/dev/null; then
    echo "Installing Command Line Tools..."
    xcode-select --install && xcodebuild -license accept
  fi

	if ! command -v brew &> /dev/null; then
		echo "Installing Homebrew..."
		yes '' | bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

  # Make sure we’re using the latest Homebrew
  run_brew_command_as_target_user update

  # Upgrade any already-installed formulae
  run_brew_command_as_target_user upgrade

  packages=(
      bash
      dockutil
      fontconfig
      fzf
      git
      grep
      gnu-sed
      jq
      fastfetch
      tig
      tree
  )
  run_brew_command_as_target_user install "${packages[@]}"

  # Remove outdated versions from the cellar
  run_brew_command_as_target_user cleanup
}

# Debian / Ubuntu
install_debian_dependencies() {
  # Ensure apt is in non-interactive to avoid prompts
  export DEBIAN_FRONTEND=noninteractive
  packages=(
    acl
    ca-certificates
    curl
    fontconfig
    fzf
    git
    jq
    locales
    sudo
    tig
    tree
    tzdata
    unzip
    vim
    wget
    zip
    zsh
  )

  # Install the list of packages
  apt update -y
  apt install -y --no-install-recommends "${packages[@]}"

  # Get to latest versions of all packages
  apt upgrade -y --no-install-recommends
  apt autoremove -y

  # fastfetch
  apt install -y --no-install-recommends cmake build-essential
  git clone https://github.com/fastfetch-cli/fastfetch /tmp/fastfetch
  mkdir -p /tmp/fastfetch/build
  cd /tmp/fastfetch/build
  cmake ..
  cmake --build . --target fastfetch
  cp fastfetch /usr/local/bin/

  # Fix for https://github.com/ohmyzsh/ohmyzsh/issues/4786
  if ! grep -o -E '^\s*en_US.UTF-8\s+UTF-8' /etc/locale.gen > /dev/null; then
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
  fi
}

# Install dependencies for appropriate OS
case "${ADJUSTED_ID}" in
    "mac")
        install_mac_dependencies
        ;;
    "debian")
        install_debian_dependencies
        ;;
esac

echo "Installing neovim..."
apt install -y --no-install-recommends ninja-build gettext cmake unzip curl build-essential
NVIM_VERSION="${NVIMVERSION:-"nightly"}"
ADJUSTED_NVIM_VERSION=$NVIM_VERSION
if [  "$NVIM_VERSION" != "stable" ] && [  "$NVIM_VERSION" != "nightly" ]; then
    ADJUSTED_NVIM_VERSION="v$NVIM_VERSION"
fi
curl -sL https://github.com/neovim/neovim/archive/refs/tags/${ADJUSTED_NVIM_VERSION}.tar.gz | tar -xzC /tmp 2>&1
cd /tmp/neovim-${ADJUSTED_NVIM_VERSION}
make && make install
cd -
rm -rf /tmp/neovim-${ADJUSTED_NVIM_VERSION}


echo "Installing zellij..."
case $(uname -m) in
  "x86_64"|"aarch64")
      arch=$(uname -m)
      ;;
  "arm64")
      arch="aarch64"
      ;;
  *)
      echo "Unsupported cpu arch: $(uname -m)"
      exit 1
      ;;
esac

case $(uname -s) in
  "Linux")
      sys="unknown-linux-musl"
      ;;
  "Darwin")
      sys="apple-darwin"
      ;;
  *)
      echo "Unsupported system: $(uname -s)"
      exit 1
      ;;
esac
curl -sL "https://github.com/zellij-org/zellij/releases/latest/download/zellij-$arch-$sys.tar.gz" | tar -xzC /usr/local/bin


echo "Installing system-wide plugin manager for shell..."
ZSHPLUG_ROOT="${ZSHPLUGROOT:-"/usr/local/share/zsh/bundle"}"
[ ! -d ${ZSHPLUG_ROOT} ] && git clone https://github.com/zplug/zplug ${ZSHPLUG_ROOT}
if [ "$ADJUSTED_ID" != "mac" ]; then
  # Create group
  if ! cat /etc/group | grep -e "^zplug:" > /dev/null 2>&1; then
      groupadd -r zplug
  fi
  usermod -a -G zplug ${USERNAME}
  mkdir -p $ZSHPLUG_ROOT/{cache,log,repos}

  chown -R "root:zplug" $(dirname $ZSHPLUG_ROOT)
  chmod -R 775 $(dirname $ZSHPLUG_ROOT)
fi

echo "Installing system-wide plugin manager for vim..."
VIMPLUG_ROOT="${VIMPLUGROOT:-"/usr/local/share/vim/bundle"}"
curl -fLo "${VIMPLUG_ROOT}/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
if [ "$ADJUSTED_ID" != "mac" ]; then
  # Create group
  if ! cat /etc/group | grep -e "^vimplug:" > /dev/null 2>&1; then
      groupadd -r vimplug
  fi
  usermod -a -G vimplug ${USERNAME}
  chown -R "root:vimplug" "$(dirname $VIMPLUG_ROOT)"
  chmod -R 775 "$(dirname $VIMPLUG_ROOT)"
fi

echo "Installing system-wide version manager..."
curl https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh

mkdir -p /etc/mise
touch /etc/mise/config.toml
export MISE_GLOBAL_CONFIG_FILE=/etc/mise/config.toml
export MISE_DATA_DIR=/usr/local/share/mise

if [ "$ADJUSTED_ID" != "mac" ]; then
  # Create group
  if ! cat /etc/group | grep -e "^mise:" > /dev/null 2>&1; then
      groupadd -r mise
  fi
  mkdir -p $MISE_DATA_DIR
  usermod -a -G mise ${USERNAME}
  chown -R "root:mise" $MISE_DATA_DIR
  chmod -R g+rwXs $MISE_DATA_DIR
fi

mise settings get global_config_file

mise use -g bun@latest
mise use -g node@24
mise use -g go@1.24
mise use -g java@openjdk-24
mise use -g python@3.13

install_mac_apps() {
  apps=(
      beekeeper-studio
      docker
      dockutil
      discord
      dropbox
      figma
      kap
      mounty
      notion
      postman
      steam
      visual-studio-code
  )

  if [ ! -d "/Applications/Google Chrome.app" ]; then
      apps+=(google-chrome)
  fi

  if [ ! -d "/Applications/Slack.app" ]; then
      apps+=(slack)
  fi

  if [ ! -d "/Applications/zoom.us.app" ]; then
      apps+=(zoom)
  fi

  run_brew_command_as_target_user install --cask "${apps[@]}"

  # Remove outdated versions from the cellar
  run_brew_command_as_target_user cleanup

	# Set Dock items
	OLDIFS=$IFS
	IFS=''

	apps=(
		'Google Chrome'
		'Visual Studio Code'
		'Beekeeper Studio'
		Postman
		Notion
		Slack
		Figma
		zoom.us
		Docker
		'System Settings'
	)

	dockutil --no-restart --remove all $HOME
	for app in "${apps[@]}"
	do
		echo "Keeping $app in Dock"
		dockutil --no-restart --add /Applications/$app.app $HOME
	done
	killall Dock

	# restore $IFS
	IFS=$OLDIFS
}

case "${ADJUSTED_ID}" in
    "mac")
        install_mac_apps
        ;;
esac

echo "Done!"
