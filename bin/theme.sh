#!/bin/bash

source "$ENVIRONMENT_DIR/src/assets.sh"
source "$ENVIRONMENT_DIR/src/themes/set-theme.sh"

theme_names() {
  local theme
  local manifest

  for theme in $(list_assets "themes" | sort -u); do
    manifest=$(resolve_asset_manifest "themes" "$theme")
    unset THEME_NAME PROMPT_THEME VIMPLUG_COLORSCHEME VIM_COLORSCHEME NVIM_COLORSCHEME \
      VSCODE_ICON_EXTENSION VSCODE_ICON_THEME VSCODE_COLOR_EXTENSION VSCODE_COLOR_THEME \
      WT_FILENAME TERM_FILENAME NVIM_FILENAME THEME_DIR
    source "$manifest"
    echo "$THEME_NAME"
  done
}

current_theme_name() {
  local zshrc_file="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.zshrc"
  local configured_theme

  if [ ! -f "$zshrc_file" ]; then
    echo "unknown"
    return 0
  fi

  configured_theme=$(sed -n 's/^THEME_NAME="\{0,1\}\([^"]*\)"\{0,1\}$/\1/p' "$zshrc_file" | head -n 1)
  if [ -z "$configured_theme" ]; then
    echo "unknown"
    return 0
  fi

  echo "$configured_theme"
}

function theme_help() {
  local themes
  themes=$(theme_names)

  cat <<EOF
Usage: dotenv [OPTIONS]

Current:
  $(current_theme_name)

Themes:
$(printf '%s\n' "$themes" | sed 's/^/  /')

Options:
  -n, --name     Specify the theme name
  current        Show the current theme
  help           Show this help message
EOF
}

if [[ "$#" -lt 1 ]]; then
  current_theme_name
  exit 0
fi

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -n|--name)
      if [[ -n "$2" && ! "$2" =~ ^- ]]; then
        set_theme "$2"
        shift 2
      else
        echo "Error: Missing value for --name"
        exit 1
      fi
      ;;
    current)
      current_theme_name
      exit 0
      ;;
    help)
      theme_help
      exit 0
      ;;
    -*|--*)
      echo "Unknown option: $1"
      exit 1
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done
