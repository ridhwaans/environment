#!/usr/bin/env bash

set -e

SCRIPT_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Script directory: $SCRIPT_HOME"

THEME="gotham"

echo "For user ${USERNAME}"
echo "\$THEME is $THEME"

# Windows Terminal

if [ $(uname) = Darwin ]; then
	echo "(mac)"

elif [ $(uname) = Linux ]; then
	if [ -n "$WSL_DISTRO_NAME" ]; then
		echo "(wsl)"

    WINDOWS_HOME=$(wslpath $(powershell.exe '$env:UserProfile') | sed -e 's/\r//g')
    WINDOWS_TERMINAL_SETTINGS_DIR=$WINDOWS_HOME/AppData/Local/Packages/Microsoft.WindowsTerminal*/LocalState

    jq --argjson terminal "$(cat "$SCRIPT_HOME/$THEME/terminal.json")" \
   '.schemes = [ $terminal ]' \
   "$WINDOWS_TERMINAL_SETTINGS_DIR"/settings.json \
   > temp.json && mv temp.json "$WINDOWS_TERMINAL_SETTINGS_DIR"/settings.json

  elif [ -n "$CODESPACES" ]; then
		echo "(github codespaces)"

	else
		echo "(native linux)"

  fi
fi

# Terminal.app

PROFILE="Gotham"

if [ $(uname) = Darwin ]; then
	echo "(mac)"

osascript <<EOD
tell application "Terminal"
    local allOpenedWindows
    local initialOpenedWindows
    local windowID
    set themeName to "$THEME"

    (* Store the IDs of all the open terminal windows. *)
    set initialOpenedWindows to id of every window

    (* Open the custom theme so that it gets added to the list
       of available terminal themes (note: this will open two
       additional terminal windows). *)
    do shell script "open '$SCRIPT_HOME/$THEME/$PROFILE.terminal'"

    (* Wait a little bit to ensure that the custom theme is added. *)
    delay 1

    (* Set the custom theme as the default terminal theme. *)
    set default settings to settings set themeName

    (* Get the IDs of all the currently opened terminal windows. *)
    set allOpenedWindows to id of every window

    repeat with windowID in allOpenedWindows
        (* Close the additional windows that were opened in order
           to add the custom theme to the list of terminal themes. *)
        if initialOpenedWindows does not contain windowID then
            close (every window whose id is windowID)
        (* Change the theme for the initial opened terminal windows
           to remove the need to close them in order for the custom
           theme to be applied. *)
        else
            set current settings of tabs of (every window whose id is windowID) to settings set $PROFILE
        end if
    end repeat
end tell
EOD

fi

# VS Code

if [ $(uname) = Darwin ]; then
	echo "(mac)"

  VSCODE_SETTINGS_DIR=$HOME/Library/Application\ Support/Code/User

elif [ $(uname) = Linux ]; then
	if [ -n "$WSL_DISTRO_NAME" ]; then
		echo "(wsl)"

    WINDOWS_HOME=$(wslpath $(powershell.exe '$env:UserProfile') | sed -e 's/\r//g')
    VSCODE_SETTINGS_DIR=$WINDOWS_HOME/AppData/Roaming/Code/User

  elif [ -n "$CODESPACES" ]; then
		echo "(github codespaces)"

	else
		echo "(native linux)"

    VSCODE_SETTINGS_DIR=$HOME/.config/Code/User
  fi
fi

if command -v code &>/dev/null; then

  source $SCRIPT_HOME/$THEME/vscode.sh
  code --install-extension $VSCODE_ICON_EXTENSION >/dev/null
  code --install-extension $VSCODE_COLOR_EXTENSION >/dev/null
  sed -i "s/\"workbench.iconTheme\": \".*\"/\"workbench.iconTheme\": \"$VSCODE_ICON_THEME\"/g" "$VSCODE_SETTINGS_DIR"/settings.json
  sed -i "s/\"workbench.colorTheme\": \".*\"/\"workbench.colorTheme\": \"$VSCODE_COLOR_THEME\"/g" "$VSCODE_SETTINGS_DIR"/settings.json
fi

# Shell

sed -i '' "s/^THEME_NAME=.*/THEME_NAME=\"$THEME\"/" ~/.zshrc

# Tmux

sed -i '' "s/^set -g @theme_name .*/set -g @theme_name \"$THEME\"/" ~/.tmux.conf

# Prompt

# reload source agnoster theme in .zshrc
