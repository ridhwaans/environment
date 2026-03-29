#!/usr/bin/env bash

current_windows_home() {
  wslpath "$(powershell.exe '$env:UserProfile')" | sed -e 's/\r//g'
}

current_vscode_settings_file() {
  if [ "$(uname)" = "Darwin" ]; then
    printf '%s\n' "$HOME/Library/Application Support/Code/User/settings.json"
    return 0
  fi

  if [ "$(uname)" = "Linux" ]; then
    if [ -n "${WSL_DISTRO_NAME:-}" ]; then
      printf '%s\n' "$(current_windows_home)/AppData/Roaming/Code/User/settings.json"
      return 0
    fi

    printf '%s\n' "$XDG_CONFIG_HOME/code/user/settings.json"
    return 0
  fi

  return 1
}

current_windows_terminal_settings_file() {
  local windows_home
  local terminal_dirs

  if [ -z "${WSL_DISTRO_NAME:-}" ]; then
    return 1
  fi

  windows_home=$(current_windows_home)
  shopt -s nullglob
  terminal_dirs=("$windows_home"/AppData/Local/Packages/Microsoft.WindowsTerminal*/LocalState)
  shopt -u nullglob

  if [ ${#terminal_dirs[@]} -eq 0 ]; then
    return 1
  fi

  printf '%s\n' "${terminal_dirs[0]}/settings.json"
}

export -f current_windows_home
export -f current_vscode_settings_file
export -f current_windows_terminal_settings_file
