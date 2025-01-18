#!/bin/bash

# Display help for theme management
function theme_help() {
  echo "Usage: $(basename "$0") [OPTIONS]"
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
    set_theme "Gotham" "gotham"
    echo "Theme set to: $1"
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
