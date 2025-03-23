# ***********
# ** zplug **
# ***********

export LANG=en_US.UTF-8

export ZPLUG_ROOT="/usr/local/share/zsh/bundle"

source $ZPLUG_ROOT/init.zsh

export ZPLUG_HOME="$HOME/zsh/bundle"

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load --verbose

# **********************
# ** Helper functions **
# **********************

if [ -f "$HOME/Source/scripts.sh" ]; then
    echo "Sourcing bash-compatible helper functions in zsh..."

    # Trap to capture errors
    error_message=""
    trap 'error_message="Error: $BASH_COMMAND failed at line $LINENO"' ERR

    if emulate bash -c "source $HOME/Source/scripts.sh"; then
        echo "Source successful"
    else
        echo "An error occurred. Source skipped"
        echo "$error_message"
    fi

    # Reset the trap to avoid affecting subsequent commands
    trap - ERR
fi

function tmux_attach_or_switch_last() {
  # If inside a tmux session
  if [[ -n $TMUX ]]; then
    # Switch to the previous tmux session if it exists
    tmux switch-client -p || echo "No previous tmux session found."
  else
    # Outside of tmux, shorthand attach to the last tmux session
    tmux attach
  fi
}

function tmux_default_sessions() {
  # Don't use ~ since it may not work with -d or tmux commands.
  local directories=(
    "$HOME"
    "$HOME/Source/environment/devcontainer-features"
    "$HOME/Source/environment/dotfiles"
    "$HOME/Source/practice-vault"
    "$HOME/Source/cv"
    "$HOME/Source/test"
  )

  # Filter out directories that do not exist.
  directories=($(for dir in "${directories[@]}"; do
      [[ -d "$dir" ]] && echo "$dir"
  done))

  # Create a session for each directory, but only if it doesn't already exist
  # or if it exists but points to a different working directory.
  for directory in "${directories[@]}"; do
    local session_name
    session_name=$(basename "$directory")
    
    # Check if the session exists
    if tmux has-session -t "$session_name" 2>/dev/null; then
      # Get the current working directory of the first pane of the session.
      local existing_dir
      existing_dir=$(tmux display-message -p -t "${session_name}:0.0" "#{pane_current_path}")
      
      if [ "$existing_dir" = "$directory" ]; then
        # The session already exists and points to the same directory.
        continue
      else
        # The session exists but its working directory is different.
        # Here you can choose to warn, rename, or take another action.
        # For now, we'll just skip creating a duplicate.
        continue
      fi
    fi

    tmux new-session -d -s "$session_name" -c "$directory"
  done

  # dont use [-1] because bash doesnt reliably negative index like zsh
  local last_directory="${directories[@]: -1}"
  local last_session
  last_session=$(basename "$last_directory")

  # If inside tmux, switch to the last session; if outside, attach to it.
  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$last_session"
  else
    tmux attach-session -t "$last_session"
  fi
}

function tmux_session_selector() {
    if [[ $# -eq 1 ]]; then
        local selected=$1
    else
        local selected=$(find ~/Source -mindepth 1 -maxdepth 1 -type d | fzf)
    fi

    if [[ -z $selected ]]; then
        return 0
    fi

    local selected_name=$(basename "$selected" | tr . _)
    local tmux_running=$(pgrep tmux)

    if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
        tmux new-session -s $selected_name -c $selected
        return 0
    fi

    if ! tmux has-session -t=$selected_name 2> /dev/null; then
        tmux new-session -ds $selected_name -c $selected
    fi

    tmux switch-client -t $selected_name
}

if [ $(uname) = Darwin ]; then
  # Command + Shift + . (period) shows hidden files in Finder
  function showHiddenFiles() {
    defaults write com.apple.finder AppleShowAllFiles YES
    killall Finder /System/Library/CoreServices/Finder.app
  }

  function hideHiddenFiles() {
    defaults write com.apple.finder AppleShowAllFiles NO
    killall Finder /System/Library/CoreServices/Finder.app
  }

  function sleepoff() {
    sudo pmset -a disablesleep 1
  }

  function sleepon() {
    sudo pmset -a disablesleep 0
  }

  showHiddenFiles
fi

# ***************************
# ** Aliases and home vars **
# ***************************

export HISTFILE="$HOME/.zsh_history"
export EDITOR="/usr/bin/vim"
export SUDO_EDITOR="$EDITOR"

alias cds="cd $HOME/Source"
alias evi="$EDITOR $HOME/.vimrc"
alias ezsh="$EDITOR $HOME/.zshrc"
alias et="$EDITOR $HOME/.tmux.conf"
alias es="[ -f $HOME/Source/scripts.sh ] && $EDITOR $HOME/Source/scripts.sh"

alias weather="curl http://v2.wttr.in"

# tmux
alias tn='tmux new-session -s'
alias tls='tmux list-sessions'
alias tksv='tmux kill-server'
alias tkss='tmux kill-session -t'
alias tds='tmux_default_sessions'
alias tl='tmux_attach_or_switch_last'
alias tss='tmux_session_selector'

if [ $(uname) = Darwin ]; then
  defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist Bluetooth -int 18
  defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist Sound -int 18
  defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist Display -int 18

  defaults write com.apple.finder ShowPathbar -bool true
  # Do not display prompt when quitting iTerm
  defaults write com.googlecode.iterm2 PromptOnQuit -bool false
  # Stop `Music.app` from opening
  launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist

  export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/usr/local/mysql/lib

  eval $(/opt/homebrew/bin/brew shellenv)
fi

if [ -n "$WSL_DISTRO_NAME" ]; then
  export WINDOWS_USER=$(powershell.exe '$env:UserName')
  # Also removes the ^M, carriage return character from DOS
  export WINDOWS_HOME=$(wslpath $(powershell.exe '$env:UserProfile') | sed -e 's/\r//g')

  alias cdw='cd $WINDOWS_HOME'

  ln -sf $HOME $WINDOWS_HOME/$(basename $HOME)

  export PATH=$PATH:/mnt/c/Program\ Files/Docker/Docker/resources/bin
fi

if [ -n "$CODESPACES" ]; then
fi

export PATH="$PATH:$HOME/bin"

export PATH="$PATH:$HOME/.local/bin"

# ***********************
# ** Language managers **
# ***********************

export SDKMAN_DIR="/usr/local/sdkman"

[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

if [ $(uname) = Linux ]; then
  export PYENV_ROOT="/usr/local/pyenv"

  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

  export RBENV_ROOT="/usr/local/rbenv"

  [[ -d $RBENV_ROOT/bin ]] && export PATH="$RBENV_ROOT/bin:$PATH"
fi

eval "$(pyenv init -)"

eval "$(pyenv virtualenv-init -)"

eval "$(rbenv init -)"

export NVM_DIR="/usr/local/nvm"

[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

export BUN_INSTALL="/usr/local/bun"

export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="/usr/local/go/bin:$PATH"

export ENVIRONMENT_DIR="$HOME/.local/share/environment"

export PATH="$ENVIRONMENT_DIR/bin:$PATH"

THEME_DIR="$ENVIRONMENT_DIR/src/themes"

# *****************
# ** Shell theme **
# *****************

THEME_NAME="gotham"

THEME_FILE="$THEME_DIR/$THEME_NAME/theme.sh"

[[ -s $THEME_FILE ]] && source $THEME_FILE

# ******************
# ** Prompt theme **
# ******************

PROMPT_THEME="agnoster"

PROMPT_THEME_FILE="$THEME_DIR/$PROMPT_THEME/$PROMPT_THEME.zsh-theme"

[[ -s $PROMPT_THEME_FILE ]] && source $PROMPT_THEME_FILE


setopt promptsubst # enable command substitution in prompt (for shell prompt theme)
setopt APPEND_HISTORY # append to Zsh history instead of overwriting
setopt HIST_IGNORE_DUPS # prevent duplicate commands in Zsh history
setopt HIST_IGNORE_SPACE # prevent commands starting with whitespace in Zsh history

bindkey '^R' history-incremental-search-backward # enable reverse-i-search in tmux

# start or attach to tmux default sessions
tds
