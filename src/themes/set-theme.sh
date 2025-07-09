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

set_theme() {
  local profile_theme_name=$1
  local theme=$2

  # Windows Terminal
  if [ $(uname) = Darwin ]; then
    echo "(mac)"

  elif [ $(uname) = Linux ]; then
    if [ -n "$WSL_DISTRO_NAME" ]; then
      echo "(wsl)"

      WINDOWS_HOME=$(wslpath $(powershell.exe '$env:UserProfile') | sed -e 's/\r//g')
      WINDOWS_TERMINAL_SETTINGS_DIR=$WINDOWS_HOME/AppData/Local/Packages/Microsoft.WindowsTerminal*/LocalState

      # in script, echo expands glob, but ls -d does not
      SETTINGS_FILE=$(echo $WINDOWS_TERMINAL_SETTINGS_DIR)/settings.json
      echo $SETTINGS_FILE

      echo $ENVIRONMENT_DIR/src/themes/$theme/terminal.json
      jq --slurpfile theme "$ENVIRONMENT_DIR/src/themes/$theme/terminal.json" \
      '.schemes = [$theme]' \
      $SETTINGS_FILE \
      > temp.json && mv temp.json $SETTINGS_FILE

    elif [ -n "$CODESPACES" ]; then
      echo "(github codespaces)"

    else
      echo "(native linux)"

    fi
  fi

  # Terminal.app
  if [ $(uname) = Darwin ]; then
	echo "(mac)"

osascript <<EOD
tell application "Terminal"
    local allOpenedWindows
    local initialOpenedWindows
    local windowID
    set themeName to "$theme"
    set themeFilePath to "$ENVIRONMENT_DIR/src/themes/$theme/$profile_theme_name.terminal"

    (* Store the IDs of all the open terminal windows *)
    set initialOpenedWindows to id of every window

    (* Check if the theme already exists in the list of Terminal settings *)
    if not (exists settings set themeName) then
        (* Open the custom theme so that it gets added to the list of available terminal themes *)
        do shell script "open '" & themeFilePath & "'"

        (* Wait a little bit to ensure that the custom theme is added *)
        delay 1
    end if

    (* Set the custom theme as the default terminal theme *)
    set default settings to settings set themeName

    (* Get the IDs of all the currently opened terminal windows *)
    set allOpenedWindows to id of every window

    repeat with windowID in allOpenedWindows
        (* Close the additional windows that were opened in order
           to add the custom theme to the list of terminal themes *)
        if initialOpenedWindows does not contain windowID then
            close (every window whose id is windowID)
        else
            (* Change the theme for the initial opened terminal windows
               to remove the need to close them in order for the custom
               theme to be applied *)
            set current settings of tabs of (every window whose id is windowID) to settings set themeName
        end if
    end repeat
end tell
EOD

  fi

  # VS Code
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

  if command -v code &>/dev/null; then

    source $ENVIRONMENT_DIR/src/themes/$theme/vscode.sh
    code --install-extension $VSCODE_ICON_EXTENSION >/dev/null
    code --install-extension $VSCODE_COLOR_EXTENSION >/dev/null
    sed -i "s/\"workbench.iconTheme\": \".*\"/\"workbench.iconTheme\": \"$VSCODE_ICON_THEME\"/g" "$VSCODE_USER_SETTINGS_DIR"/settings.json
    sed -i "s/\"workbench.colorTheme\": \".*\"/\"workbench.colorTheme\": \"$VSCODE_COLOR_THEME\"/g" "$VSCODE_USER_SETTINGS_DIR"/settings.json
  fi

  # Shell

  conditional_sed -i "s/^THEME_NAME=.*/THEME_NAME=\"$theme\"/" $HOME/.zshrc

  # Prompt

  conditional_sed -i "s/^PROMPT_THEME=.*/PROMPT_THEME="agnoster"/" $HOME/.zshrc

  # Tmux

  conditional_sed -i "s/^set -g @theme_name .*/set -g @theme_name \"$theme\"/" $HOME/.tmux.conf

  # Vim

  source $ENVIRONMENT_DIR/src/themes/$theme/vim.sh

  conditional_sed -i "s|^let g:vim_plug_colorscheme = \".*\"|let g:vim_plug_colorscheme = \"$VIMPLUG_COLORSCHEME\"|" $HOME/.vimrc

  conditional_sed -i "s|^let g:colorscheme = \".*\"|let g:colorscheme = \"$VIM_COLORSCHEME\"|" $HOME/.vimrc

  vim +silent! +PlugInstall +PlugClean +qall

  # Neovim
  NEOVIM_USER_PLUGINS_DIR=$HOME/.config/nvim/lua/plugins
  mkdir -p $NEOVIM_USER_PLUGINS_DIR && cp -f $ENVIRONMENT_DIR/src/themes/$theme/neovim.lua $NEOVIM_USER_PLUGINS_DIR/theme.lua
}

export -f set_theme
export -f conditional_sed
