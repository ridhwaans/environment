#!/bin/bash

source "$ENVIRONMENT_DIR/src/assets.sh"
source "$ENVIRONMENT_DIR/src/fonts/set-font.sh"

font_names() {
  local font
  local manifest

  for font in $(list_assets "fonts" | sort -u); do
    manifest=$(resolve_asset_manifest "fonts" "$font")
    unset FONT_NAME FONT_DISPLAY_NAME FONT_POSTSCRIPT_NAME FONT_FILE FONT_URL FONT_DIR
    source "$manifest"
    echo "$FONT_DISPLAY_NAME"
  done
}

current_vscode_settings_file() {
  if [ "$(uname)" = Darwin ]; then
    echo "$HOME/Library/Application Support/Code/User/settings.json"
    return 0
  fi

  if [ "$(uname)" = Linux ]; then
    if [ -n "$WSL_DISTRO_NAME" ]; then
      local windows_home
      windows_home=$(wslpath "$(powershell.exe '$env:UserProfile')" | sed -e 's/\r//g')
      echo "$windows_home/AppData/Roaming/Code/User/settings.json"
      return 0
    fi

    if [ -n "$CODESPACES" ]; then
      echo "$XDG_CONFIG_HOME/code/user/settings.json"
      return 0
    fi

    echo "$XDG_CONFIG_HOME/code/user/settings.json"
    return 0
  fi

  return 1
}

current_font_name() {
  local settings_file
  local configured_font
  local font
  local manifest
  local base_name

  settings_file=$(current_vscode_settings_file)
  if [ ! -f "$settings_file" ]; then
    echo "unknown"
    return 0
  fi

  configured_font=$(sed -n 's/.*"editor.fontFamily": "\([^"]*\)".*/\1/p' "$settings_file" | head -n 1)
  configured_font=$(printf '%s' "$configured_font" | sed "s/^'//; s/',.*$//; s/'$//")

  if [ -z "$configured_font" ]; then
    echo "unknown"
    return 0
  fi

  for font in $(list_assets "fonts" | sort -u); do
    manifest=$(resolve_asset_manifest "fonts" "$font")
    unset FONT_NAME FONT_DISPLAY_NAME FONT_POSTSCRIPT_NAME FONT_FILE FONT_URL FONT_DIR
    source "$manifest"
    base_name="${FONT_FILE%.*}"
    if [ "$configured_font" = "$base_name" ]; then
      echo "$FONT_DISPLAY_NAME"
      return 0
    fi
  done

  echo "$configured_font"
}

function font_help() {
  local fonts
  fonts=$(font_names)

  cat <<EOF
Usage: dotenv [OPTIONS]

Current:
  $(current_font_name)

Fonts:
$(printf '%s\n' "$fonts" | sed 's/^/  /')

Options:
  -n, --name     Specify the font name
  current        Show the current font
  help           Show this help message
EOF
}

font_main() {
  if [[ "$#" -lt 1 ]]; then
    current_font_name
    return 0
  fi

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -n|--name)
        if [[ -n "$2" && ! "$2" =~ ^- ]]; then
          load_font_manifest "$2"
          set_font "$FONT_POSTSCRIPT_NAME" "$FONT_FILE" "$FONT_URL"
          shift 2
        else
          echo "Error: Missing value for --name"
          return 1
        fi
        ;;
      current)
        current_font_name
        return 0
        ;;
      help)
        font_help
        return 0
        ;;
      -*|--*)
        echo "Unknown option: $1"
        return 1
        ;;
      *)
        echo "Unknown argument: $1"
        return 1
        ;;
    esac
  done
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  font_main "$@"
fi
