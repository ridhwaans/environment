# ***********
# ** zplug **
# ***********

export LANG=en_US.UTF-8

export ZSHPLUG_ROOT="/usr/local/share/zsh/bundle"

source $ZSHPLUG_ROOT/init.zsh

export ZPLUG_HOME="$HOME/zsh/bundle"

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load --verbose

unset MISE_GLOBAL_CONFIG_FILE
unset MISE_DATA_DIR

eval "$(mise activate zsh)"
export MISE_GLOBAL_CONFIG_FILE=/etc/mise/config.toml
export MISE_DATA_DIR=/usr/local/share/mise


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
alias es="[ -f $HOME/Source/scripts.sh ] && $EDITOR $HOME/Source/scripts.sh"

alias weather="curl http://v2.wttr.in"

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

export ENVIRONMENT_DIR="$HOME/.local/share/environment"

export PATH="$PATH:$ENVIRONMENT_DIR/bin"

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
