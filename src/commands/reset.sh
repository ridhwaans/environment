#!/usr/bin/env bash

dotenv_reset_system() {
  sync_assets
  setup_configs
}

dotenv_reset_appearance() {
  load_font_manifest "$DEFAULT_FONT_NAME"
  set_font "$FONT_POSTSCRIPT_NAME" "$FONT_FILE" "$FONT_URL"
  set_theme "$DEFAULT_THEME_NAME"
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
