#!/usr/bin/env bash

set -e

SCRIPT_ROOT=$(dirname "${BASH_SOURCE[0]}")

echo "SCRIPT_ROOT: $SCRIPT_ROOT"

FONT_SIZE="11"

set_font() {
  local profile_font_name=$1
	local file=$2
	local url=$3
  # Extract the base name (without the extension)
  base_name="${file%.*}"
  echo $base_name

  # Install
	if ! $(fc-list | grep -i "$base_name" >/dev/null); then
    if [ $(uname) = Darwin ]; then
      echo "(mac)"

      curl -L $url --create-dirs -o /Library/Fonts/"$file"
      fc-cache -f -v
      fc-list | grep $file

    elif [ $(uname) = Linux ]; then
      if [ -n "$WSL_DISTRO_NAME" ]; then
        echo "(wsl)"

        curl -L $url --create-dirs -o /usr/share/fonts/"$file"
        fc-cache -f -v
        fc-list | grep $file

      elif [ -n "$CODESPACES" ]; then
		    echo "(github codespaces)"

      else
        echo "(native linux)"

      fi
    fi
	fi

  # VS Code
  if command -v code &>/dev/null; then
    if [ $(uname) = Darwin ]; then
        echo "(mac)"

        VSCODE_USER_SETTINGS_DIR=$HOME/Library/Application\ Support/Code/User

     elif [ $(uname) = Linux ]; then
      if [ -n "$WSL_DISTRO_NAME" ]; then
        echo "(wsl)"

        WINDOWS_HOME=$(wslpath $(powershell.exe '$env:UserProfile') | sed -e 's/\r//g')
        VSCODE_USER_SETTINGS_DIR=$WINDOWS_HOME/AppData/Roaming/Code/User

      elif [ -n "$CODESPACES" ]; then
		    echo "(github codespaces)"

      else
        echo "(native linux)"

        VSCODE_USER_SETTINGS_DIR=$HOME/.config/Code/User
      fi
    fi

    echo "$VSCODE_USER_SETTINGS_DIR"/settings.json
    # use GNU sed -i for in-place editing and no backup requirement
    gsed -i "s/\"editor.fontFamily\": \".*\"/\"editor.fontFamily\": \"$base_name\"/g" "$VSCODE_USER_SETTINGS_DIR"/settings.json
    gsed -i "s/\"terminal.integrated.fontFamily\": \".*\"/\"terminal.integrated.fontFamily\": \"$base_name\"/g" "$VSCODE_USER_SETTINGS_DIR"/settings.json
  fi

  # Windows Terminal
  if [ $(uname) = Linux ]; then
    if [ -n "$WSL_DISTRO_NAME" ]; then
      echo "(wsl)"

      WINDOWS_HOME=$(wslpath $(powershell.exe '$env:UserProfile') | sed -e 's/\r//g')
      WINDOWS_TERMINAL_SETTINGS_DIR=$WINDOWS_HOME/AppData/Local/Packages/Microsoft.WindowsTerminal*/LocalState

      jq --arg base_name "$base_name" '.profiles.list |= map(if .source == "Windows.Terminal.Wsl" then .font.face = $base_name else . end)' \
      "$WINDOWS_TERMINAL_SETTINGS_DIR"/settings.json \
      > temp.json && mv temp.json "$WINDOWS_TERMINAL_SETTINGS_DIR"/settings.json
    fi
  fi

  # Terminal.app
  if [ $(uname) = Darwin ]; then
    echo "(mac)"

osascript <<EOD
tell application "Terminal"
    -- Get the default profile
    set defaultProfile to default settings

    -- Change the font name and size of the default profile
    set font name of defaultProfile to "$profile_font_name"
    set font size of defaultProfile to $FONT_SIZE
end tell
EOD
  fi

}
