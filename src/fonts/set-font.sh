#!/usr/bin/env bash

set -e

source "$ENVIRONMENT_DIR/src/platform.sh"

set_font() {
  local postscript_name="$1"
  local file="$2"
  local url="$3"
  local base_name="${file%.*}"
  local font_size="11"
  local vscode_settings_file
  local settings_file

  echo "postscript_name=$postscript_name, file=$file, base_name=$base_name, url=$url, FONT_SIZE=$font_size"

  # Install
  if ! fc-list | grep -i "$base_name" >/dev/null; then
    if [ "$(uname)" = "Darwin" ]; then
      echo "(mac)"

      curl -L "$url" --create-dirs -o /Library/Fonts/"$file"
      fc-cache -f -v
      fc-list | grep "$file"

    elif [ "$(uname)" = "Linux" ]; then
      if [ -n "${WSL_DISTRO_NAME:-}" ]; then
        echo "(wsl)"

        curl -L "$url" --create-dirs -o /usr/share/fonts/"$file"
        fc-cache -f -v
        fc-list | grep "$file"

      elif [ -n "${CODESPACES:-}" ]; then
        echo "(github codespaces)"

      else
        echo "(native linux)"

      fi
    fi
	fi

  # VS Code
  if command -v code &>/dev/null; then
    vscode_settings_file=$(current_vscode_settings_file) || vscode_settings_file=""
    if [ -n "$vscode_settings_file" ] && [ -f "$vscode_settings_file" ]; then
      echo "$vscode_settings_file"
      conditional_sed -i "s/\"editor.fontFamily\": \".*\"/\"editor.fontFamily\": \"$base_name\"/g" "$vscode_settings_file"
      conditional_sed -i "s/\"terminal.integrated.fontFamily\": \".*\"/\"terminal.integrated.fontFamily\": \"$base_name\"/g" "$vscode_settings_file"
    fi
  fi

  # Windows Terminal
  if [ "$(uname)" = "Linux" ]; then
    if [ -n "${WSL_DISTRO_NAME:-}" ]; then
      echo "(wsl)"

      settings_file=$(current_windows_terminal_settings_file) || settings_file=""
      if [ -z "$settings_file" ]; then
        echo "Settings directory not found"
        return 1
      fi
      echo "$settings_file"

      jq --arg base_name "$base_name" '.profiles.list |= map(if .source == "Windows.Terminal.Wsl" then .font.face = $base_name else . end)' \
      "$settings_file" \
      > temp.json && mv temp.json "$settings_file"
      echo "Updated Windows Terminal font to '$base_name' size $font_size."
    fi
  fi

  # Terminal.app
  if [ "$(uname)" = "Darwin" ]; then
    echo "(mac)"

osascript <<EOD
tell application "Terminal"
    -- Get the default profile
    set defaultProfile to default settings

    -- Change the font name and size of the default profile
    set font name of defaultProfile to "$postscript_name"
    set font size of defaultProfile to $font_size
end tell
EOD
  fi

}

export -f set_font
