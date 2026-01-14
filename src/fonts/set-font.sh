#!/usr/bin/env bash

set -e

conditional_sed() {
    # use gnu sed for no explicit backup in-place editing on mac
    if [ $(uname) = Darwin ]; then
        gsed "$@"
    else
        sed "$@"
    fi
}

set_font() {
  local postscript_name=$1
	local file=$2
  base_name="${file%.*}"
	local url=$3
  FONT_SIZE="11"

  echo "postscript_name=$postscript_name, file=$file, base_name=$base_name, url=$url, FONT_SIZE=$FONT_SIZE"

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
    conditional_sed -i "s/\"editor.fontFamily\": \".*\"/\"editor.fontFamily\": \"$base_name\"/g" "$VSCODE_USER_SETTINGS_DIR"/settings.json
    conditional_sed -i "s/\"terminal.integrated.fontFamily\": \".*\"/\"terminal.integrated.fontFamily\": \"$base_name\"/g" "$VSCODE_USER_SETTINGS_DIR"/settings.json
  fi

  # Windows Terminal
  if [ $(uname) = Linux ]; then
    if [ -n "$WSL_DISTRO_NAME" ]; then
      echo "(wsl)"

      WINDOWS_HOME=$(wslpath $(powershell.exe '$env:UserProfile') | sed -e 's/\r//g')
      # Expand glob safely using array and quotes
      shopt -s nullglob
      WINDOWS_TERMINAL_SETTINGS_DIR=("$WINDOWS_HOME"/AppData/Local/Packages/Microsoft.WindowsTerminal*/LocalState)

      if [ ${#WINDOWS_TERMINAL_SETTINGS_DIR[@]} -eq 0 ]; then
          echo "Settings directory not found"
          exit 1
      fi
      # Pick first match
      WINDOWS_TERMINAL_SETTINGS_DIR="${WINDOWS_TERMINAL_SETTINGS_DIR[0]}"
      SETTINGS_FILE=$WINDOWS_TERMINAL_SETTINGS_DIR/settings.json
      echo $SETTINGS_FILE

      # Run jq safely
      jq --arg base_name "$base_name" '.profiles.list |= map(if .source == "Windows.Terminal.Wsl" then .font.face = $base_name else . end)' \
      $SETTINGS_FILE \
      > temp.json && mv temp.json $SETTINGS_FILE
      echo "Updated Windows Terminal font to '$base_name' size $FONT_SIZE."
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
    set font name of defaultProfile to "$postscript_name"
    set font size of defaultProfile to $FONT_SIZE
end tell
EOD
  fi

}

export -f set_font
