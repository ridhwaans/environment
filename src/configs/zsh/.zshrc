export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

export PATH="$XDG_BIN_HOME:$PATH"

export ENVIRONMENT_DIR="$HOME/Source/environment"
ln -sf $ENVIRONMENT_DIR/bin/dotenv "$XDG_BIN_HOME/dotenv"

mise install

eval "$(mise activate zsh)"

export VIMINIT="source $XDG_CONFIG_HOME/vim/vimrc"

# ***********
# ** zplug **
# ***********

export ZPLUG_HOME="$XDG_DATA_HOME/zplug"

source $ZPLUG_HOME/init.zsh

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

export LANG=en_US.UTF-8
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export EDITOR="/usr/local/bin/nvim"
export SUDO_EDITOR="$EDITOR -u NORC"

alias cds="cd $HOME/Source"
alias evi="$EDITOR $XDG_CONFIG_HOME/vim/vimrc"
alias ezsh="$EDITOR $XDG_CONFIG_HOME/zsh/.zshrc"
alias es="[ -f $HOME/Source/scripts.sh ] && $EDITOR $HOME/Source/scripts.sh"

alias weather="curl http://v2.wttr.in"

if [ $(uname) = Darwin ]; then
  defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist Bluetooth -int 18
  defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist Sound -int 18
  defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist Display -int 18

  defaults write com.apple.finder ShowPathbar -bool true
  # Don't display prompt when quitting iTerm
  defaults write com.googlecode.iterm2 PromptOnQuit -bool false
  # Don't open `Music.app`
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

  export PATH=/mnt/c/Program\ Files/Docker/Docker/resources/bin:$PATH
fi

if [ -n "$CODESPACES" ]; then
fi

# *****************
# ** Shell theme **
# *****************

THEME_NAME="gotham"

THEME_FILE="$ENVIRONMENT_DIR/src/themes/$THEME_NAME/theme.sh"

[[ -s $THEME_FILE ]] && source $THEME_FILE

# ******************
# ** Prompt theme **
# ******************

PROMPT_THEME="agnoster"

PROMPT_THEME_FILE="$ENVIRONMENT_DIR/src/themes/$PROMPT_THEME/$PROMPT_THEME.zsh-theme"

[[ -s $PROMPT_THEME_FILE ]] && source $PROMPT_THEME_FILE

setopt PROMPT_SUBST # enable command substitution in prompt (for shell prompt theme)

# *************
# ** History **
# *************

export HISTFILE="$XDG_STATE_HOME/zsh/history"

export HISTSIZE=50000
export SAVEHIST=10000
setopt INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_REDUCE_BLANKS EXTENDED_HISTORY
