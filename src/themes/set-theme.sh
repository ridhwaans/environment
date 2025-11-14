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
  theme=$1
  case "$theme" in
    gotham)
      # nvim
      NVIM_FILENAME="colorscheme.lua"
      NVIM_COLORSCHEME="neogotham"

      # Windows Terminal
      WT_FILENAME="terminal.json"

      # Terminal.app
      TERM_FILENAME="Gotham.terminal"

      # vim
      VIMPLUG_COLORSCHEME="whatyouhide/vim-gotham"
      VIM_COLORSCHEME="gotham256"

      # VS Code
      VSCODE_ICON_EXTENSION="PKief.material-icon-theme"
      VSCODE_ICON_THEME="material-icon-theme"

      VSCODE_COLOR_EXTENSION="alireza94.theme-gotham"
      VSCODE_COLOR_THEME="Gotham"

      apply_theme
      ;;
    *)
      echo "Error: Unknown theme '$theme'."
      exit 1
      ;;
  esac
}

apply_theme() {
  echo "Applying theme: $theme"

  # Windows Terminal
  if [ $(uname) = Darwin ]; then
    echo "(mac)"

  elif [ $(uname) = Linux ]; then
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

      echo $ENVIRONMENT_DIR/src/themes/$theme/$WT_FILENAME
      jq --slurpfile theme "$ENVIRONMENT_DIR/src/themes/$theme/$WT_FILENAME" \
      '.schemes = [$theme[0]]' \
      $SETTINGS_FILE \
      > temp.json && mv temp.json $SETTINGS_FILE
      echo "Updated Windows Terminal colorScheme to '$theme'."

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
    set themeFilePath to "$ENVIRONMENT_DIR/src/themes/$theme/$TERM_FILENAME"

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

    code --install-extension $VSCODE_ICON_EXTENSION >/dev/null
    conditional_sed -i "s/\"workbench.iconTheme\": \".*\"/\"workbench.iconTheme\": \"$VSCODE_ICON_THEME\"/g" "$VSCODE_USER_SETTINGS_DIR"/settings.json

    code --install-extension $VSCODE_COLOR_EXTENSION >/dev/null
    conditional_sed -i "s/\"workbench.colorTheme\": \".*\"/\"workbench.colorTheme\": \"$VSCODE_COLOR_THEME\"/g" "$VSCODE_USER_SETTINGS_DIR"/settings.json
  fi

  # Shell

  conditional_sed -i "s/^THEME_NAME=.*/THEME_NAME=\"$theme\"/" $XDG_CONFIG_HOME/zsh/.zshrc

  # Prompt

  conditional_sed -i "s/^PROMPT_THEME=.*/PROMPT_THEME="agnoster"/" $XDG_CONFIG_HOME/zsh/.zshrc

  # vim

  conditional_sed -i "s|^let g:vim_plug_colorscheme = \".*\"|let g:vim_plug_colorscheme = \"$VIMPLUG_COLORSCHEME\"|" $XDG_CONFIG_HOME/vim/vimrc

  conditional_sed -i "s|^let g:colorscheme = \".*\"|let g:colorscheme = \"$VIM_COLORSCHEME\"|" $XDG_CONFIG_HOME/vim/vimrc

  vim -u "$XDG_CONFIG_HOME/vim/vimrc" +silent! +PlugInstall +PlugClean +qall

  # nvim

  NVIM_USER_PLUGINS_DIR=$XDG_CONFIG_HOME/nvim/lua/plugins
  mkdir -p $NVIM_USER_PLUGINS_DIR && cp -f $ENVIRONMENT_DIR/src/themes/$theme/colorscheme.lua $NVIM_USER_PLUGINS_DIR/colorscheme.lua

  nvim --headless +"colorscheme $NVIM_COLORSCHEME" +qa
}

export -f set_theme
export -f apply_theme
export -f conditional_sed
