#!/usr/bin/env bash

list_font_names() {
  local font
  local manifest

  for font in $(list_assets "fonts" | sort -u); do
    manifest=$(resolve_asset_manifest "fonts" "$font")
    unset FONT_NAME FONT_DISPLAY_NAME FONT_POSTSCRIPT_NAME FONT_FILE FONT_URL FONT_DIR
    source "$manifest"
    echo "$FONT_DISPLAY_NAME"
  done
}

list_theme_names() {
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

list_preset_names() {
  list_assets "presets" | sort -u
}

current_font_name() {
  local settings_file
  local configured_font
  local font
  local manifest
  local base_name

  settings_file=$(current_vscode_settings_file) || settings_file=""
  if [ -z "$settings_file" ] || [ ! -f "$settings_file" ]; then
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

current_theme_name() {
  local zshrc_file="$XDG_CONFIG_HOME/zsh/.zshrc"
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

current_preset_name() {
  local current_theme
  local current_font
  local preset

  current_theme=$(current_theme_name)
  current_font=$(current_font_name)

  for preset in $(list_preset_names); do
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

apply_font() {
  local font_name="$1"

  load_font_manifest "$font_name"
  set_font "$FONT_POSTSCRIPT_NAME" "$FONT_FILE" "$FONT_URL"
}

dotenv_show_named_help() {
  local singular="$1"
  local plural="$2"
  local current_fn="$3"
  local list_fn="$4"
  local items

  items=$("$list_fn")

  cat <<EOF
Usage: dotenv $singular [OPTIONS]

Current:
  $("$current_fn")

$plural:
$(printf '%s\n' "$items" | sed 's/^/  /')

Options:
  -n, --name     Specify the $singular name
  current        Show the current $singular
  help           Show this help message
EOF
}

dotenv_handle_named_command() {
  local singular="$1"
  local plural="$2"
  local current_fn="$3"
  local list_fn="$4"
  local apply_fn="$5"
  shift 5

  if [[ "$#" -lt 1 ]]; then
    "$current_fn"
    return 0
  fi

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -n|--name)
        if [[ -n "${2:-}" && ! "$2" =~ ^- ]]; then
          "$apply_fn" "$2"
          shift 2
        else
          echo "Error: Missing value for --name"
          return 1
        fi
        ;;
      current)
        "$current_fn"
        return 0
        ;;
      help)
        dotenv_show_named_help "$singular" "$plural" "$current_fn" "$list_fn"
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

dotenv_handle_font() {
  dotenv_handle_named_command "font" "Fonts" current_font_name list_font_names apply_font "$@"
}

dotenv_handle_theme() {
  dotenv_handle_named_command "theme" "Themes" current_theme_name list_theme_names set_theme "$@"
}

dotenv_handle_preset() {
  dotenv_handle_named_command "preset" "Presets" current_preset_name list_preset_names apply_preset "$@"
}

export -f list_font_names
export -f list_theme_names
export -f list_preset_names
export -f current_font_name
export -f current_theme_name
export -f current_preset_name
export -f apply_font
export -f apply_preset
export -f dotenv_show_named_help
export -f dotenv_handle_named_command
export -f dotenv_handle_font
export -f dotenv_handle_theme
export -f dotenv_handle_preset
