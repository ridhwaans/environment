#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

export SDKMAN_DIR="${SDKMAN_PATH}"

# Comma-separated list of java versions to be installed
# alongside JAVA_VERSION, but not set as default.
ADDITIONAL_VERSIONS="${JAVA_ADDITIONAL_VERSIONS:-""}"

# Use SDKMAN to install something using a partial version match
sdk_install() {
    local install_type=$1
    local requested_version=$2
    local prefix=$3
    local suffix="${4:-"\\s*"}"
    local full_version_check=${5:-".*-[a-z]+"}
    local set_as_default=${6:-"true"}
    if [ "${requested_version}" = "none" ]; then return; fi
    # Blank will install latest stable version SDKMAN has
    if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "lts" ] || [ "${requested_version}" = "default" ]; then
         requested_version=""
    elif echo "${requested_version}" | grep -oE "${full_version_check}" > /dev/null 2>&1; then
        echo "${requested_version}"
    else
        local regex="${prefix}\\K[0-9]+\\.?[0-9]*\\.?[0-9]*${suffix}"
        local version_list=$(su ${USERNAME} -c ". \${SDKMAN_DIR}/bin/sdkman-init.sh && sdk list ${install_type} 2>&1 | grep -oP \"${regex}\" | tr -d ' ' | sort -rV")
        if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ]; then
            requested_version="$(echo "${version_list}" | head -n 1)"
        else
            set +e
            requested_version="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|-|$)")"
            set -e
        fi
        if [ -z "${requested_version}" ] || ! echo "${version_list}" | grep "^${requested_version//./\\.}$" > /dev/null 2>&1; then
            echo -e "Version ${requested_version} not found. Available versions:\n${version_list}" >&2
            exit 1
        fi
    fi
    if [ "${set_as_default}" = "true" ]; then
        JAVA_VERSION=${requested_version}
    fi

    su ${USERNAME} -c "umask 0002 && . ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install ${install_type} ${requested_version} && sdk flush archives && sdk flush temp"
}


if [ "$ADJUSTED_ID" != "mac" ]; then
    # Install sdkman if not installed
    if [ ! -d "${SDKMAN_DIR}" ]; then
        # Create sdkman group, dir, and set sticky bit
        if ! cat /etc/group | grep -e "^sdkman:" > /dev/null 2>&1; then
            groupadd -r sdkman
        fi
        usermod -a -G sdkman ${USERNAME}
        umask 0002
        # Install SDKMAN
        curl -sSL "https://get.sdkman.io?rcupdate=false" | bash
        chown -R "root:sdkman" ${SDKMAN_DIR}
        chmod -R g+rws "${SDKMAN_DIR}"
    fi
else
    # Install SDKMAN
    curl -sSL "https://get.sdkman.io?rcupdate=false" | bash
    chown -R $USERNAME ${SDKMAN_DIR}
fi

sdkman_rc_snippet=$(cat <<EOF
export SDKMAN_DIR="$SDKMAN_DIR"

[[ -s "\$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "\$SDKMAN_DIR/bin/sdkman-init.sh"
EOF
)

if [ "${UPDATE_RC}" = "true" ]; then
    updaterc "zsh" "${sdkman_rc_snippet}"
    updaterc "bash" "${sdkman_rc_snippet}"
fi

sdk_install java ${JAVA_VERSION} "\\s*" "(\\.[a-z0-9]+)*-${JDK_DISTRO}\\s*" ".*-[a-z]+$" "true"

# Additional Java versions to be installed but not be set as default.
if [ ! -z "${ADDITIONAL_VERSIONS}" ]; then
    OLDIFS=$IFS
    IFS=","
        read -a additional_versions <<< "$ADDITIONAL_VERSIONS"
        for version in "${additional_versions[@]}"; do
            sdk_install java ${version} "\\s*" "(\\.[a-z0-9]+)*-${JDK_DISTRO}\\s*" ".*-[a-z]+$" "false"
        done
    IFS=$OLDIFS
fi

# Install Gradle
if [[ "${INSTALL_GRADLE}" = "true" ]] && ! gradle --version > /dev/null; then
    sdk_install gradle ${GRADLE_VERSION}
fi

# Install Maven
if [[ "${INSTALL_MAVEN}" = "true" ]] && ! mvn --version > /dev/null; then
    sdk_install maven ${MAVEN_VERSION}
fi

echo "Done!"
