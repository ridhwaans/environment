#!/usr/bin/env bash

set -e

source "$ENVIRONMENT_DIR/src/assets.sh"
source "$ENVIRONMENT_DIR/src/platform.sh"

set_theme() {
  local theme="$1"
  load_theme_manifest "$theme"
  apply_theme "$theme"
}

apply_theme() {
  local theme="$1"
  local vscode_settings_file
  local windows_terminal_settings_file

  # Windows Terminal
  echo "Applying theme: $theme"

  if [ "$(uname)" = "Darwin" ]; then
    echo "(mac)"

  elif [ "$(uname)" = "Linux" ]; then
    if [ -n "${WSL_DISTRO_NAME:-}" ]; then
      echo "(wsl)"

      windows_terminal_settings_file=$(current_windows_terminal_settings_file) || windows_terminal_settings_file=""
      if [ -z "$windows_terminal_settings_file" ]; then
        echo "Settings directory not found"
        return 1
      fi
      echo "$windows_terminal_settings_file"

      echo "$THEME_DIR/$WT_FILENAME"
      jq --slurpfile theme "$THEME_DIR/$WT_FILENAME" \
      '.schemes = [$theme[0]]' \
      "$windows_terminal_settings_file" \
      > temp.json && mv temp.json "$windows_terminal_settings_file"
      echo "Updated Windows Terminal colorScheme to '$theme'."

    elif [ -n "${CODESPACES:-}" ]; then
      echo "(github codespaces)"

    else
      echo "(native linux)"

    fi
  fi

  # Terminal.app
  if [ "$(uname)" = "Darwin" ]; then
    echo "(mac)"

osascript <<EOD
tell application "Terminal"
    local allOpenedWindows
    local initialOpenedWindows
    local windowID
    set themeName to "$theme"
    set themeFilePath to "$THEME_DIR/$TERM_FILENAME"

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

  if command -v code &>/dev/null; then
    vscode_settings_file=$(current_vscode_settings_file) || vscode_settings_file=""

    code --install-extension $VSCODE_ICON_EXTENSION >/dev/null
    code --install-extension $VSCODE_COLOR_EXTENSION >/dev/null
    if [ -n "$vscode_settings_file" ] && [ -f "$vscode_settings_file" ]; then
      conditional_sed -i "s/\"workbench.iconTheme\": \".*\"/\"workbench.iconTheme\": \"$VSCODE_ICON_THEME\"/g" "$vscode_settings_file"
      conditional_sed -i "s/\"workbench.colorTheme\": \".*\"/\"workbench.colorTheme\": \"$VSCODE_COLOR_THEME\"/g" "$vscode_settings_file"
    fi
  fi

  # Shell

  conditional_sed -i "s/^THEME_NAME=.*/THEME_NAME=\"$theme\"/" "$XDG_CONFIG_HOME/zsh/.zshrc"

  # Prompt

  conditional_sed -i "s/^PROMPT_THEME=.*/PROMPT_THEME=\"$PROMPT_THEME\"/" "$XDG_CONFIG_HOME/zsh/.zshrc"

  # vim

  conditional_sed -i "s|^let g:vim_plug_colorscheme = \".*\"|let g:vim_plug_colorscheme = \"$VIMPLUG_COLORSCHEME\"|" "$XDG_CONFIG_HOME/vim/vimrc"

  conditional_sed -i "s|^let g:colorscheme = \".*\"|let g:colorscheme = \"$VIM_COLORSCHEME\"|" "$XDG_CONFIG_HOME/vim/vimrc"

  vim -u "$XDG_CONFIG_HOME/vim/vimrc" +silent! +PlugInstall +PlugClean +qall

  # nvim

  NVIM_USER_PLUGINS_DIR=$XDG_CONFIG_HOME/nvim/lua/plugins
  mkdir -p "$NVIM_USER_PLUGINS_DIR" && cp -f "$THEME_DIR/$NVIM_FILENAME" "$NVIM_USER_PLUGINS_DIR/colorscheme.lua"

  nvim --headless +"colorscheme $NVIM_COLORSCHEME" +qa
}

export -f set_theme
export -f apply_theme
