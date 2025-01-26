#!/bin/bash

function theme_help() {
  cat <<EOF
Usage: env [OPTIONS]

Themes:
  Gotham

Options:
  -n, --name     Specify the theme name
  help           Show this help message
EOF
}

if [[ "$#" -lt 1 ]]; then
  theme_help
  exit 1
fi

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -n|--name)
      if [[ -n "$2" && ! "$2" =~ ^- ]]; then
        case "$2" in
          Gotham)
            set_theme "Gotham" "gotham"
            ;;
          *)
            echo "Error: Unknown theme '$2'. Available themes: Gotham."
            exit 1
            ;;
        esac
        shift 2
      else
        echo "Error: Missing value for --name"
        exit 1
      fi
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
