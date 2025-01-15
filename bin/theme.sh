#!/bin/bash

# Display help for theme management
function theme_help() {
  echo "Usage: $0 [THEME]"
  echo "Themes:"
  echo "  Gotham"
  echo "  help   Show this help message"
}

# Theme management logic
if [[ "$#" -lt 1 ]]; then
  theme_help
  exit 1
fi

case "$1" in
 Gotham)
    echo "Theme set to: $1"
    set_theme "Gotham" "gotham"
    ;;
  help)
    theme_help
    exit 0
    ;;
  *)
    echo "Error: Unknown theme '$1'. Available themes: Gotham."
    exit 1
    ;;
esac
