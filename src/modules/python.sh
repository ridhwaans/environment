#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

export PYENV_ROOT="${PYENV_PATH}"

# Comma-separated list of python versions to be installed
# alongside PYTHON_VERSION, but not set as default.
ADDITIONAL_VERSIONS="${PYTHON_ADDITIONAL_VERSIONS:-""}"

# Mac OS packages
install_mac_packages() {
    packages=(
		pyenv
		pyenv-virtualenv
	)
	run_brew_command_as_target_user install "${packages[@]}"
}

# Debian / Ubuntu packages
install_debian_packages(){
    # Ensure apt is in non-interactive to avoid prompts
    export DEBIAN_FRONTEND=noninteractive

    # General requirements
    # https://stackoverflow.com/a/71347968/3577482
    # https://stackoverflow.com/questions/50757647/e-gnupg-gnupg2-and-gnupg1-do-not-seem-to-be-installed-but-one-of-them-is-requ
    # https://github.com/pyenv/pyenv/issues/677
    apt install -y --no-install-recommends libssl-dev libffi-dev libncurses5-dev zlib1g zlib1g-dev libreadline-dev libbz2-dev libsqlite3-dev make gcc liblzma-dev gnupg patch
}

# Install packages for appropriate OS
case "${ADJUSTED_ID}" in
    "debian")
        install_debian_packages
        ;;
    "mac")
        install_mac_packages
        ;;
esac

if [ "$ADJUSTED_ID" != "mac" ]; then
    # Create pyenv group to the user's UID or GID to change while still allowing access to pyenv
    if ! cat /etc/group | grep -e "^pyenv:" > /dev/null 2>&1; then
        groupadd -r pyenv
    fi
    usermod -a -G pyenv ${USERNAME}

    umask 0002
    [ ! -d ${PYENV_ROOT} ] && git clone https://github.com/pyenv/pyenv.git ${PYENV_ROOT}
    chown -R "root:pyenv" ${PYENV_ROOT}
    chmod -R g+rws "${PYENV_ROOT}"
    [ ! -d "${PYENV_ROOT}/plugins/pyenv-virtualenv" ] && git clone https://github.com/pyenv/pyenv-virtualenv.git ${PYENV_ROOT}/plugins/pyenv-virtualenv
fi

pyenv_rc_snippet=$(cat <<EOF
export PYENV_ROOT="$PYENV_ROOT"

[[ -d \$PYENV_ROOT/bin ]] && export PATH="\$PYENV_ROOT/bin:\$PATH"

eval "\$(pyenv init -)"

eval "\$(pyenv virtualenv-init -)"
EOF
)

if [ "${UPDATE_RC}" = "true" ]; then
    updaterc "zsh" "${pyenv_rc_snippet}"
    updaterc "bash" "${pyenv_rc_snippet}"
fi

if [ "${PYTHON_VERSION}" != "" ]; then
     # Find version using soft match
    find_version_from_git_tags PYTHON_VERSION "https://github.com/python/cpython"
    su ${USERNAME} -c "export PYENV_ROOT=${PYENV_ROOT}; export PATH=$PYENV_ROOT/bin:\$PATH; pyenv install ${PYTHON_VERSION} && pyenv global ${PYTHON_VERSION}"
fi

# Additional python versions to be installed but not be set as default.
if [ ! -z "${ADDITIONAL_VERSIONS}" ]; then
    OLDIFS=$IFS
    IFS=","
        read -a additional_versions <<< "$ADDITIONAL_VERSIONS"
        for version in "${additional_versions[@]}"; do
            su ${USERNAME} -c "export PYENV_ROOT=${PYENV_ROOT}; export PATH=$PYENV_ROOT/bin:\$PATH; pyenv install ${version}"
        done
    IFS=$OLDIFS
fi

echo "Done!"
