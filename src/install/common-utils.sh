#!/usr/bin/env bash

set -e

# Mac OS
install_mac_dependencies() {
  if ! command -v xcode-select &>/dev/null; then
    echo "Installing Command Line Tools..."
    sudo xcode-select --install && sudo xcodebuild -license accept
  fi

  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    yes '' | bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  brew update
  brew upgrade
  brew install bash fontconfig git grep gnu-sed tree
  brew cleanup
}

# Debian / Ubuntu
install_debian_dependencies() {
  export DEBIAN_FRONTEND=noninteractive

  sudo apt update
  sudo apt upgrade -y --no-install-recommends
  sudo apt install -y --no-install-recommends acl ca-certificates curl fontconfig git sudo tree unzip vim wget zip zsh
  sudo apt autoremove -y

  # Fix for https://github.com/ohmyzsh/ohmyzsh/issues/4786
  sudo apt install -y --no-install-recommends locales tzdata
  if ! grep -o -E '^\s*en_US.UTF-8\s+UTF-8' /etc/locale.gen > /dev/null; then
    echo "en_US.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen
    sudo locale-gen
  fi
}

echo "Installing dependencies..."
case "${ADJUSTED_ID}" in
    "mac")
        install_mac_dependencies
        ;;
    "debian")
        install_debian_dependencies
        ;;
esac

echo "Installing neovim..."
if [ "$ADJUSTED_ID" = "debian" ]; then
  sudo apt install -y --no-install-recommends ninja-build gettext cmake unzip curl build-essential
elif [ "$ADJUSTED_ID" = "mac" ]; then
  brew install ninja cmake gettext curl
fi

NVIM_VERSION="${NVIMVERSION:-"nightly"}"
ADJUSTED_NVIM_VERSION=$NVIM_VERSION
if [  "$NVIM_VERSION" != "stable" ] && [  "$NVIM_VERSION" != "nightly" ]; then
    ADJUSTED_NVIM_VERSION="v$NVIM_VERSION"
fi
curl -sL https://github.com/neovim/neovim/archive/refs/tags/${ADJUSTED_NVIM_VERSION}.tar.gz | tar -xzC /tmp 2>&1
make -C /tmp/neovim-${ADJUSTED_NVIM_VERSION} && sudo make -C /tmp/neovim-${ADJUSTED_NVIM_VERSION} install
sudo rm -rf /tmp/neovim-${ADJUSTED_NVIM_VERSION}

echo "Installing zplug..."
[ ! -d "$XDG_DATA_HOME/zplug" ] && git clone https://github.com/zplug/zplug "$XDG_DATA_HOME/zplug"

echo "Installing vim-plug..."
curl -fLo "$XDG_DATA_HOME/vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

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
mkdir -p "$XDG_BIN_HOME"
curl -sL "https://github.com/zellij-org/zellij/releases/latest/download/zellij-$arch-$sys.tar.gz" | tar -xzC "$XDG_BIN_HOME"

echo "Installing mise..."
curl https://mise.run | MISE_INSTALL_PATH="$XDG_BIN_HOME/mise" sh

echo "Installing exercism..."
EXERCISM_VERSION="${EXERCISMVERSION:-"latest"}"
if command -v exercism &> /dev/null; then
    echo "exercism is installed. Version: $(exercism version)"
else
  find_version_from_git_tags EXERCISM_VERSION https://github.com/exercism/cli
  case $(uname -m) in
    "x86_64"|"aarch64")
        arch="x86_64"
        ;;
    "arm64")
        arch="arm64"
        ;;
    *)
        echo "Unsupported cpu arch: $(uname -m)"
        exit 1
        ;;
  esac

  case $(uname -s) in
    "Linux")
        sys="linux"
        ;;
    "Darwin")
        sys="darwin"
        ;;
    *)
        echo "Unsupported system: $(uname -s)"
        exit 1
        ;;
  esac
  exercism_filename="exercism-${EXERCISM_VERSION}-${sys}-${arch}.tar.gz"
  curl -L https://github.com/exercism/cli/releases/download/v${EXERCISM_VERSION}/${exercism_filename} --create-dirs -o /tmp/${exercism_filename}
  tar -xzvf /tmp/${exercism_filename} -C $XDG_BIN_HOME exercism
  sudo rm -rf /tmp/${exercism_filename}
fi

install_mac_apps() {
  brew install --cask beekeeper-studio brave-browser docker discord dropbox figma kap mounty notion postman steam visual-studio-code

  [ ! -d "/Applications/Slack.app" ] && brew install --cask slack
  [ ! -d "/Applications/zoom.us.app" ] && brew install --cask zoom

  brew cleanup
  brew install dockutil

  # Set Dock items
  OLDIFS=$IFS
  IFS=''

  apps=(
    "Terminal"
    "Visual Studio Code"
    "Brave Browser"
    "Notion"
    "Docker"
    "Beekeeper Studio"
    "Postman"
    "Slack"
    "Figma"
    "zoom.us"
    "System Settings"
  )

  # Remove all current Dock items
  dockutil --no-restart --remove all "$HOME"

  for app in "${apps[@]}"; do
    if [[ "$app" == "Terminal" ]]; then
      path="/Applications/Utilities/$app.app"
    elif [[ "$app" == "System Settings" ]]; then
      path="/System/Applications/$app.app"
    else
      path="/Applications/$app.app"
    fi

    dockutil --no-restart --add "$path" "$HOME"
  done

  # Restart the Dock to apply changes
  killall Dock

  # Restore IFS
  IFS=$OLDIFS
}

echo "Installing apps..."
case "${ADJUSTED_ID}" in
    "mac")
        install_mac_apps
        ;;
esac

echo "Done!"
