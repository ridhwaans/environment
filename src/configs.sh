#!/usr/bin/env bash

set -e

SCRIPT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_ROOT/runtime.sh"

remove_dest() {
  dest="$1"
  if [ -L "$dest" ] || [ -f "$dest" ]; then
    rm -f "$dest"
  elif [ -d "$dest" ]; then
    rm -rf "$dest"
  fi
}

copy_path() {
  src="$1"
  dest="$2"

  remove_dest "$dest"
  mkdir -p "$(dirname "$dest")"

  if [ -d "$src" ]; then
    cp -r "$src" "$dest"
  else
    cp "$src" "$dest"
  fi
}

setup_ide() {
  echo "(1/7) Setting up IDE..."
  if command -v code &>/dev/null; then
    code --extensions-dir "$XDG_DATA_HOME/code/extensions"

    while IFS= read -r extension || [ -n "$extension" ]; do
        code --install-extension "$extension"
    done < "$CONFIGS_DIR/code/extensions/extensions"
    code --install-extension PKief.material-icon-theme
  fi

  if [ "$(uname)" = Darwin ]; then
    echo "(mac)"

    VSCODE_USER_SETTINGS_DIR=$HOME/Library/Application\ Support/Code/User
    copy_path "$CONFIGS_DIR/code/user/settings.json" "$VSCODE_USER_SETTINGS_DIR/settings.json"

  elif [ "$(uname)" = Linux ]; then
    if [ -n "$WSL_DISTRO_NAME" ]; then
      echo "(wsl)"

      WINDOWS_HOME=$(wslpath "$(powershell.exe '$env:UserProfile')" | sed -e 's/\r//g')
      VSCODE_USER_SETTINGS_DIR=$WINDOWS_HOME/AppData/Roaming/Code/User

      # https://github.com/microsoft/vscode/issues/1022
      # https://github.com/microsoft/vscode/issues/166680
      copy_path "$CONFIGS_DIR/code/user/settings.json" "$VSCODE_USER_SETTINGS_DIR/settings.json"

    elif [ -n "$CODESPACES" ]; then
      echo "(github codespaces)"
    else
      echo "(native linux)"

      copy_path "$CONFIGS_DIR/code/user/settings.json" "$XDG_CONFIG_HOME/code/user/settings.json"
    fi
  fi
}

setup_terminal_emulator() {
  echo "(2/7) Setting up terminal emulator..."
  if [ "$(uname)" = Darwin ]; then
    echo "(mac)"

  elif [ "$(uname)" = Linux ]; then
    if [ -n "$WSL_DISTRO_NAME" ]; then
      echo "(wsl)"

      WINDOWS_HOME=$(wslpath "$(powershell.exe '$env:UserProfile')" | sed -e 's/\r//g')
      TERMINAL_USER_SETTINGS_DIR="$WINDOWS_HOME/AppData/Local/Packages"/Microsoft.WindowsTerminal*/LocalState

      copy_path "$CONFIGS_DIR/windowsterminal/settings.json" "$TERMINAL_USER_SETTINGS_DIR/settings.json"

    elif [ -n "$CODESPACES" ]; then
      echo "(github codespaces)"
    else
      echo "(native linux)"
    fi
  fi
}

setup_home_files() {
  echo "(3/7) Setting up home files & permissions..."

  for entry in "$CONFIGS_DIR"/*; do
    name=$(basename "$entry")

    case "$name" in
      code|windowsterminal) continue ;;
    esac

    dest="$XDG_CONFIG_HOME/$name"
    copy_path "$entry" "$dest"
  done

  if [ -z "$CODESPACES" ] && [ -d "$HOME/.ssh/" ]; then
      find "$HOME/.ssh/" -type f -exec chmod 600 {} \;
      find "$HOME/.ssh/" -type d -exec chmod 700 {} \;
      find "$HOME/.ssh/" -type f -name "*.pub" -exec chmod 644 {} \;
  fi

  echo 'export ZDOTDIR=$HOME/.config/zsh' > "$HOME/.zshenv"
}

setup_source_directory() {
  echo "(4/7) Setting up Source directory..."
  # https://gist.github.com/ridhwaans/08f2fc5e9b3614a3154cef749a43a568
  mkdir -p "$HOME/Source" && curl -sfSL "https://gist.githubusercontent.com/ridhwaans/08f2fc5e9b3614a3154cef749a43a568/raw/scripts.sh" -o "$HOME/Source/scripts.sh" && chmod +x "$HOME/Source/scripts.sh"
}

setup_cli_links() {
  echo "(5/7) Setting up dotenv CLI..."
  mkdir -p "$XDG_BIN_HOME"
  ln -sf "$ENVIRONMENT_DIR/bin/dotenv" "$XDG_BIN_HOME/dotenv"
}

setup_mise_config() {
  local mise_config_dir

  mise_config_dir="$CONFIGS_DIR/mise"
  if [ ! -d "$mise_config_dir" ]; then
    return 0
  fi

  copy_path "$mise_config_dir" "$XDG_CONFIG_HOME/mise"
}

setup_mise_runtime() {
  local mise_bin
  local install_log
  local install_status
  local script_cmd

  echo "(6/7) Setting up mise runtime..."

  if [ -x "$XDG_BIN_HOME/mise" ]; then
    mise_bin="$XDG_BIN_HOME/mise"
  elif command -v mise &>/dev/null; then
    mise_bin="$(command -v mise)"
  else
    return 0
  fi

  if [ -f "$XDG_CONFIG_HOME/mise/config.toml" ]; then
    "$mise_bin" trust "$XDG_CONFIG_HOME/mise/config.toml"
  fi

  install_log=$(mktemp)

  set +e
  if [ -t 1 ] && command -v script >/dev/null 2>&1; then
    script_cmd=$(printf 'cd %q || exit 1\n%q install\n' "$HOME" "$mise_bin")
    if [ "$(uname)" = "Linux" ]; then
      script -qefc "$script_cmd" "$install_log"
      install_status=$?
    else
      script -q "$install_log" /bin/bash -lc "$script_cmd"
      install_status=$?
    fi
  else
    (
      cd "$HOME" || exit 1
      "$mise_bin" install
    ) 2>&1 | tee "$install_log"
    install_status=${PIPESTATUS[0]}
  fi
  set -e

  if [ "$install_status" -ne 0 ]; then
    if grep -qi "rate limit exceeded" "$install_log"; then
      echo "mise install hit GitHub API rate limits; skipping runtime install for this run."
      rm -f "$install_log"
      return 0
    fi

    rm -f "$install_log"
    return "$install_status"
  fi

  rm -f "$install_log"
}

sync_editor_plugins() {
  echo "(7/7) Syncing editor plugins..."
  vim -u "$XDG_CONFIG_HOME/vim/vimrc" +silent! +PlugInstall +PlugClean +qall
  nvim --headless "+Lazy! sync" +qa
}

setup_baseline_configs() {
  setup_cli_links
  setup_mise_config
  setup_mise_runtime
}

setup_dotfiles() {
  setup_ide
  setup_terminal_emulator
  setup_home_files
  setup_source_directory
  sync_editor_plugins
}

setup_configs() {
  setup_baseline_configs
  setup_dotfiles

  echo "Done!"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  setup_configs
fi
