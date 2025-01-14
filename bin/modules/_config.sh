# Export all variables and make them available to child processes & scripts invoked from within main script

export USERNAME="${USERNAME:-"automatic"}"
export USER_UID="${USERUID:-"automatic"}"
export USER_GID="${USERGID:-"automatic"}"
export UPDATE_RC="${UPDATERC:-"true"}"
export VIMPLUG_PATH="${VIMPLUGPATH:-"/usr/local/share/vim/bundle"}"
export ZSHPLUG_PATH="${ZSHPLUGPATH:-"/usr/local/share/zsh/bundle"}"

if [ "$ADJUSTED_ID" = "mac" ]; then
    export PYENV_PATH="${PYENVPATH:-"/opt/homebrew/opt/pyenv"}"
    export RBENV_PATH="${RBENVPATH:-"/opt/homebrew/opt/rbenv"}"
    export GO_DIR="${GODIR:-"/opt/homebrew/opt/go"}"
else
    export PYENV_PATH="${PYENVPATH:-"/usr/local/pyenv"}"
    export RBENV_PATH="${RBENVPATH:-"/usr/local/rbenv"}"
    export GO_DIR="${GODIR:-"/usr/local/go"}"
fi

export SDKMAN_PATH="${SDKMANPATH:-"/usr/local/sdkman"}"
export JAVA_VERSION="${JAVAVERSION:-"lts"}"
export INSTALL_GRADLE="${INSTALLGRADLE:-"false"}"
export GRADLE_VERSION="${GRADLEVERSION:-"latest"}"
export INSTALL_MAVEN="${INSTALLMAVEN:-"false"}"
export MAVEN_VERSION="${MAVENVERSION:-"latest"}"
export JAVA_ADDITIONAL_VERSIONS="${JAVAADDITIONALVERSIONS:-""}"

export PYTHON_VERSION="${PYTHONVERSION:-"latest"}"
export PYTHON_ADDITIONAL_VERSIONS="${PYTHONADDITIONALVERSIONS:-""}"

export RUBY_VERSION="${RUBYVERSION:-"latest"}"
export RUBY_ADDITIONAL_VERSIONS="${RUBYADDITIONALVERSIONS:-""}"

export NVM_PATH="${NVMPATH:-"/usr/local/nvm"}"
export NODE_VERSION="${NODEVERSION:-"latest"}"
export NODE_ADDITIONAL_VERSIONS="${NODEADDITIONALVERSIONS:-""}"
export BUN_PATH="${BUNPATH:-"/usr/local/bun"}"

export GO_PATH="${GOPATH:-"/go"}"
export GO_VERSION="${GOVERSION:-"latest"}"

export EXERCISM_VERSION="${EXERCISMVERSION:-"latest"}"
export TERRAFORM_VERSION="${TERRAFORMVERSION:-"latest"}"

export NEW_PASSWORD="${NEWPASSWORD:-"skip"}"
export SSHD_PORT="${SSHDPORT:-"2222"}"
export START_SSHD="${STARTSSHD:-"false"}"

export TMUX_VERSION="${TMUXVERSION:-"latest"}"
