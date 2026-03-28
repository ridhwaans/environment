#!/usr/bin/env bash

dotenv_reset_system() {
  sync_assets
  setup_configs
}

dotenv_reset_appearance() {
  local preset_theme_name
  local preset_font_name

  load_preset_manifest "$DEFAULT_PRESET_NAME"
  preset_theme_name="$THEME_NAME"
  preset_font_name="$FONT_NAME"

  if [ -z "$preset_theme_name" ] || [ -z "$preset_font_name" ]; then
    echo "Error: Preset '$DEFAULT_PRESET_NAME' must define THEME_NAME and FONT_NAME." >&2
    return 1
  fi

  load_font_manifest "$preset_font_name"
  set_font "$FONT_POSTSCRIPT_NAME" "$FONT_FILE" "$FONT_URL"
  set_theme "$preset_theme_name"
}

dotenv_reset_all() {
  dotenv_reset_system
  dotenv_reset_appearance
}

dotenv_show_reset_help() {
  cat <<EOF
Usage: dotenv reset [system|appearance|all]

Reset Targets:
  system               Recopy managed configs and rerun plugin/config sync
  appearance           Reapply default font and theme
  all                  Run both system and appearance reset
EOF
}

dotenv_handle_reset() {
  local target="${1:-all}"

  case "$target" in
    system)
      dotenv_reset_system
      ;;
    appearance)
      dotenv_reset_appearance
      ;;
    all)
      dotenv_reset_all
      ;;
    help)
      dotenv_show_reset_help
      ;;
    *)
      echo "Error: Unknown reset target '$target'."
      dotenv_show_reset_help
      return 1
      ;;
  esac
}

export -f dotenv_reset_system
export -f dotenv_reset_appearance
export -f dotenv_reset_all
export -f dotenv_show_reset_help
export -f dotenv_handle_reset
