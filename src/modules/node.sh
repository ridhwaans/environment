#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

export NVM_DIR="${NVM_PATH}"

# Comma-separated list of node versions to be installed
# alongside NODE_VERSION, but not set as default.
ADDITIONAL_VERSIONS="${NODE_ADDITIONAL_VERSIONS:-""}"

if [ "$ADJUSTED_ID" != "mac" ]; then
    # Create nvm group to the user's UID or GID to change while still allowing access to nvm
    if ! cat /etc/group | grep -e "^nvm:" > /dev/null 2>&1; then
        groupadd -r nvm
    fi
    usermod -a -G nvm ${USERNAME}

    umask 0002
    [ ! -d ${NVM_DIR} ] && git clone https://github.com/nvm-sh/nvm.git ${NVM_DIR}
    chown -R "root:nvm" "${NVM_DIR}"
    chmod -R g+rws "${NVM_DIR}"
else
    [ ! -d ${NVM_DIR} ] && git clone https://github.com/nvm-sh/nvm.git ${NVM_DIR}
    chown -R $USERNAME ${NVM_DIR}
fi

# Adjust node version if required
if [ "${NODE_VERSION}" = "none" ]; then
    NODE_VERSION=
elif [ "${NODE_VERSION}" = "lts" ]; then
    NODE_VERSION="lts/*"
elif [ "${NODE_VERSION}" = "latest" ]; then
    NODE_VERSION="node"
fi

nvm_rc_snippet=$(cat <<EOF
export NVM_DIR="${NVM_DIR}"
[ -s "\$NVM_DIR/nvm.sh" ] && . "\$NVM_DIR/nvm.sh"
EOF
)

if [ "${UPDATE_RC}" = "true" ]; then
    updaterc "zsh" "${nvm_rc_snippet}"
    updaterc "bash" "${nvm_rc_snippet}"
fi

if [ "${NODE_VERSION}" != "" ]; then
    su ${USERNAME} -c "umask 0002 && . ${NVM_DIR}/nvm.sh && nvm install '${NODE_VERSION}' && nvm alias default '${NODE_VERSION}'"
fi

# Additional node versions to be installed but not be set as default.
if [ ! -z "${ADDITIONAL_VERSIONS}" ]; then
    OLDIFS=$IFS
    IFS=","
        read -a additional_versions <<< "$ADDITIONAL_VERSIONS"
        for version in "${additional_versions[@]}"; do
            su ${USERNAME} -c "umask 0002 && . ${NVM_DIR}/nvm.sh && nvm install ${version}"
        done

        if [ "${NODE_VERSION}" != "" ]; then
          su ${USERNAME} -c "umask 0002 && . ${NVM_DIR}/nvm.sh && nvm use default"
        fi
    IFS=$OLDIFS
fi


nvm_rc_snippet=$(cat <<EOF
export NVM_DIR="${NVM_DIR}"
[ -s "\$NVM_DIR/nvm.sh" ] && . "\$NVM_DIR/nvm.sh"
EOF
)

export BUN_INSTALL="${BUN_PATH}"

# Install bun if not installed
if [ ! -d "${BUN_INSTALL}" ]; then
    # Create bun group, dir, and set sticky bit
    if ! cat /etc/group | grep -e "^bun:" > /dev/null 2>&1; then
        groupadd -r bun
    fi
    usermod -a -G bun ${USERNAME}
    umask 0002
    # Install bun
    curl -fsSL https://bun.sh/install | bash
    chown -R "root:bun" ${BUN_INSTALL}
    chmod -R g+rws "${BUN_INSTALL}"
fi

bun_rc_snippet=$(cat <<EOF
export BUN_INSTALL="${BUN_INSTALL}"
export PATH="\$BUN_INSTALL/bin:\$PATH"
EOF
)

if [ "${UPDATE_RC}" = "true" ]; then
  updaterc "zsh" "${bun_rc_snippet}"
  updaterc "bash" "${bun_rc_snippet}"
fi

echo "Done!"
