#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

start_time=$(date +%s)

if [ $(uname) = Darwin ]; then
  export ADJUSTED_ID="mac"
elif [ $(uname) = Linux ]; then
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

# load defaults
source $(dirname $0)/modules/_config.sh
# load helper functions
source $(dirname $0)/modules/_helper.sh

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
)
total=${#modules[@]}
cur=1

for module in "${modules[@]}"; do
    $(which bash) $(dirname $0)/modules/$module "$@"
    exit_status=$?

    if [ $exit_status -eq 0 ]; then
        echo "($cur/$total) Module '$module' executed successfully."
    else
        echo "Error: ($cur/$total) Module '$module' failed to execute with status $exit_status."
        exit 1
    fi
    ((cur++))
done

end_time=$(date +%s)
elapsed=$(( end_time - start_time ))
echo "Install took $elapsed seconds."

echo "elapsed=$elapsed" > .report
echo "ADJUSTED_ID=$ADJUSTED_ID" >> .report
echo "TARGET_USERNAME=$USERNAME" >> .report
echo "TARGET_UID=$UID" >> .report
echo "TARGET_GID=$GID" >> .report

exit $?
