#!/bin/bash

source "$ENVIRONMENT_DIR/src/assets.sh"
source "$ENVIRONMENT_DIR/bin/theme.sh"
source "$ENVIRONMENT_DIR/bin/font.sh"

preset_names() {
  list_assets "presets" | sort -u
}

current_preset_name() {
  local current_theme
  local current_font
  local preset

  current_theme=$(current_theme_name)
  current_font=$(current_font_name)

  for preset in $(preset_names); do
    load_preset_manifest "$preset"
    load_font_manifest "$FONT_NAME"
    if [ "$THEME_NAME" = "$current_theme" ] && [ "$FONT_DISPLAY_NAME" = "$current_font" ]; then
      echo "$PRESET_NAME"
      return 0
    fi
  done

  echo "custom"
}

apply_preset() {
  local preset_name="$1"
  local preset_theme_name
  local preset_font_name

  load_preset_manifest "$preset_name"
  preset_theme_name="$THEME_NAME"
  preset_font_name="$FONT_NAME"

  if [ -z "$preset_theme_name" ] || [ -z "$preset_font_name" ]; then
    echo "Error: Preset '$preset_name' must define THEME_NAME and FONT_NAME." >&2
    return 1
  fi

  load_font_manifest "$preset_font_name"
  set_font "$FONT_POSTSCRIPT_NAME" "$FONT_FILE" "$FONT_URL"
  set_theme "$preset_theme_name"
}

preset_help() {
  local presets
  presets=$(preset_names)

  cat <<EOF
Usage: dotenv [OPTIONS]

Current:
  $(current_preset_name)

Presets:
$(printf '%s\n' "$presets" | sed 's/^/  /')

Options:
  -n, --name     Specify the preset name
  current        Show the current preset
  help           Show this help message
EOF
}

preset_main() {
  if [[ "$#" -lt 1 ]]; then
    current_preset_name
    return 0
  fi

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -n|--name)
        if [[ -n "$2" && ! "$2" =~ ^- ]]; then
          apply_preset "$2"
          shift 2
        else
          echo "Error: Missing value for --name"
          return 1
        fi
        ;;
      current)
        current_preset_name
        return 0
        ;;
      help)
        preset_help
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
  preset_main "$@"
fi
