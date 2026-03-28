#!/usr/bin/env bash

source "$ENVIRONMENT_DIR/src/runtime.sh"
source "$ENVIRONMENT_DIR/src/defaults.sh"

export ENVIRONMENT_ASSETS_REPO_URL="${ENVIRONMENT_ASSETS_REPO_URL:-https://github.com/ridhwaans/assets.git}"
export ENVIRONMENT_ASSETS_REPO_REF="${ENVIRONMENT_ASSETS_REPO_REF:-main}"
export ENVIRONMENT_ASSETS_DIR="${ENVIRONMENT_ASSETS_DIR:-$XDG_DATA_HOME/environment-assets}"
export ENVIRONMENT_LOCAL_ASSETS_DIR="${ENVIRONMENT_LOCAL_ASSETS_DIR:-$HOME/Source/assets}"

resolve_asset_root() {
  if [ -d "$ENVIRONMENT_ASSETS_DIR" ]; then
    echo "$ENVIRONMENT_ASSETS_DIR"
  else
    echo "$ENVIRONMENT_LOCAL_ASSETS_DIR"
  fi
}

resolve_asset_manifest() {
  local asset_type="$1"
  local asset_name="$2"
  local root

  root=$(resolve_asset_root)
  if [ -f "$root/$asset_type/$asset_name/manifest.sh" ]; then
    echo "$root/$asset_type/$asset_name/manifest.sh"
    return 0
  fi

  if [ "$root" != "$ENVIRONMENT_LOCAL_ASSETS_DIR" ] && [ -f "$ENVIRONMENT_LOCAL_ASSETS_DIR/$asset_type/$asset_name/manifest.sh" ]; then
    echo "$ENVIRONMENT_LOCAL_ASSETS_DIR/$asset_type/$asset_name/manifest.sh"
    return 0
  fi

  return 1
}

list_assets() {
  local asset_type="$1"
  local root
  local local_root

  root=$(resolve_asset_root)
  find "$root/$asset_type" -mindepth 2 -maxdepth 2 -type f -name manifest.sh 2>/dev/null | sed 's#/manifest\.sh$##' | xargs -n 1 basename 2>/dev/null

  local_root="$ENVIRONMENT_LOCAL_ASSETS_DIR/$asset_type"
  if [ "$root" != "$ENVIRONMENT_LOCAL_ASSETS_DIR" ] && [ -d "$local_root" ]; then
    find "$local_root" -mindepth 2 -maxdepth 2 -type f -name manifest.sh 2>/dev/null | sed 's#/manifest\.sh$##' | xargs -n 1 basename 2>/dev/null
  fi
}

sync_assets() {
  if [ -z "$ENVIRONMENT_ASSETS_REPO_URL" ]; then
    return 0
  fi

  mkdir -p "$(dirname "$ENVIRONMENT_ASSETS_DIR")"

  if [ ! -d "$ENVIRONMENT_ASSETS_DIR/.git" ]; then
    git clone --branch "$ENVIRONMENT_ASSETS_REPO_REF" "$ENVIRONMENT_ASSETS_REPO_URL" "$ENVIRONMENT_ASSETS_DIR"
    return 0
  fi

  git -C "$ENVIRONMENT_ASSETS_DIR" fetch origin "$ENVIRONMENT_ASSETS_REPO_REF"
  git -C "$ENVIRONMENT_ASSETS_DIR" checkout "$ENVIRONMENT_ASSETS_REPO_REF"
  git -C "$ENVIRONMENT_ASSETS_DIR" pull --ff-only origin "$ENVIRONMENT_ASSETS_REPO_REF"
}

load_font_manifest() {
  local font_name="$1"
  local manifest

  manifest=$(resolve_asset_manifest "fonts" "$font_name")
  if [ -z "$manifest" ]; then
    local candidate
    for candidate in $(list_assets "fonts" | sort -u); do
      manifest=$(resolve_asset_manifest "fonts" "$candidate")
      unset FONT_NAME FONT_DISPLAY_NAME FONT_POSTSCRIPT_NAME FONT_FILE FONT_URL FONT_DIR
      source "$manifest"
      if [ "$FONT_DISPLAY_NAME" = "$font_name" ]; then
        break
      fi
      manifest=""
    done
  fi

  if [ -z "$manifest" ]; then
    echo "Error: Unknown font '$font_name'." >&2
    return 1
  fi

  unset FONT_NAME FONT_DISPLAY_NAME FONT_POSTSCRIPT_NAME FONT_FILE FONT_URL FONT_DIR
  source "$manifest"
}

load_theme_manifest() {
  local theme_name="$1"
  local manifest

  manifest=$(resolve_asset_manifest "themes" "$theme_name") || {
    echo "Error: Unknown theme '$theme_name'." >&2
    return 1
  }

  unset THEME_NAME PROMPT_THEME VIMPLUG_COLORSCHEME VIM_COLORSCHEME NVIM_COLORSCHEME \
    VSCODE_ICON_EXTENSION VSCODE_ICON_THEME VSCODE_COLOR_EXTENSION VSCODE_COLOR_THEME \
    WT_FILENAME TERM_FILENAME NVIM_FILENAME THEME_DIR
  source "$manifest"
}

load_preset_manifest() {
  local preset_name="$1"
  local manifest

  manifest=$(resolve_asset_manifest "presets" "$preset_name") || {
    echo "Error: Unknown preset '$preset_name'." >&2
    return 1
  }

  unset PRESET_NAME THEME_NAME FONT_NAME
  source "$manifest"
}

export -f resolve_asset_root
export -f resolve_asset_manifest
export -f list_assets
export -f sync_assets
export -f load_font_manifest
export -f load_theme_manifest
export -f load_preset_manifest
