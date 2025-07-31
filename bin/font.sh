#!/bin/bash

function font_help() {
  cat <<EOF
Usage: dotenv [OPTIONS]

Fonts:
  Roboto Mono

Options:
  -n, --name     Specify the font name
  help           Show this help message
EOF
}

if [[ "$#" -lt 1 ]]; then
  font_help
  exit 1
fi

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -n|--name)
      if [[ -n "$2" && ! "$2" =~ ^- ]]; then
        case "$2" in
          "Roboto Mono")
            set_font "RobotoMonoForPowerline-Regular" "Roboto Mono for Powerline.ttf" "https://github.com/powerline/fonts/raw/master/RobotoMono/Roboto%20Mono%20for%20Powerline.ttf"
            ;;
          *)
            echo "Error: Unknown font '$2'. Available fonts: 'Roboto Mono'"
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
      font_help
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
