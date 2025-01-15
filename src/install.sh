#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

SCRIPT_ROOT=$(dirname "${BASH_SOURCE[0]}")

echo "Script directory: $SCRIPT_ROOT"

USERNAME="${USERNAME:-"automatic"}"
USER_UID="${USERUID:-"automatic"}"
USER_GID="${USERGID:-"automatic"}"
UPDATE_RC="${UPDATERC:-"true"}"

if [ $(uname) = Darwin ]; then
  export ADJUSTED_ID="mac"
elif [ $(uname) = Linux ]; then

  if [ ! -f /etc/os-release ]; then
    echo "/etc/os-release file not found."
    exit 1
  fi

  # Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
  . /etc/os-release

  # Get an adjusted ID independent of distro variants
  if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
    export ADJUSTED_ID="debian"
  else
    echo "Linux distro ${ID} not supported."
    exit 1
  fi
fi

# load helper functions
source $SCRIPT_ROOT/_helper.sh

# If in automatic mode, determine if a user already exists, if not use vscode
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
  USERNAME=""
  if [ "$ADJUSTED_ID" = "mac" ]; then
    FIRST_USER=$(dscl . -list /Users UniqueID | awk -v val=501 '$2 == val {print $1}')
  else
    FIRST_USER="$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)"
  fi
  if id -u ${FIRST_USER} > /dev/null 2>&1; then
    USERNAME=${FIRST_USER}
  fi
  if [ "${USERNAME}" = "" ]; then
    USERNAME=vscode
  fi
elif [ "${USERNAME}" = "none" ]; then
  USERNAME=root
  USER_UID=0
  USER_GID=0
fi

modules=(
  common-utils.sh
  tmux.sh
  java.sh
  python.sh
  ruby.sh
  node.sh
  go.sh
  tools.sh
  sshd.sh
  apps.sh
)
total=${#modules[@]}
cur=1

for module in "${modules[@]}"; do
    source /modules/$module "$@"
    exit_status=$?

    if [ $exit_status -eq 0 ]; then
        echo "($cur/$total) Module '$module' executed successfully."
    else
        echo "Error: ($cur/$total) Module '$module' failed to execute with status $exit_status."
        exit 1
    fi
    ((cur++))
done

echo "elapsed=$elapsed" > .report
echo "ADJUSTED_ID=$ADJUSTED_ID" >> .report
echo "TARGET_USERNAME=$USERNAME" >> .report
echo "TARGET_UID=$UID" >> .report
echo "TARGET_GID=$GID" >> .report

exit $?
