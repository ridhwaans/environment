#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

USERNAME="${USERNAME:-"automatic"}"
USER_UID="${USERUID:-"automatic"}"
USER_GID="${USERGID:-"automatic"}"

# If in automatic mode, determine if a user already exists, if not use vscode
# Set existing user as USERNAME. Requires ADJUSTED_ID
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

if [ "$ADJUSTED_ID" = "mac" ]; then
  dseditgroup -o edit -a $USERNAME -t user wheel
else
  # Create or update a non-root user to match UID/GID.
  if id -u ${USERNAME} > /dev/null 2>&1; then
      # User exists, update if needed
      if [ "${USER_GID}" != "automatic" ] && [ "$USER_GID" != "$(id -g $USERNAME)" ]; then
          group_name="$(id -gn $USERNAME)"
          groupmod --gid $USER_GID ${group_name}
          usermod --gid $USER_GID $USERNAME
      fi
      if [ "${USER_UID}" != "automatic" ] && [ "$USER_UID" != "$(id -u $USERNAME)" ]; then
          usermod --uid $USER_UID $USERNAME
      fi
  else
      # Create group
      # Determine if GID provided, if not use vscode
      if [ "${USER_GID}" = "automatic" ]; then
          groupadd $USERNAME
      else
          groupadd --gid $USER_GID $USERNAME
      fi
      # Create user
      # Determine if UID provided, if not use vscode
      if [ "${USER_UID}" = "automatic" ]; then
          useradd -s /bin/bash --gid $USERNAME -m $USERNAME
      else
          useradd -s /bin/bash --uid $USER_UID --gid $USERNAME -m $USERNAME
      fi
  fi
fi

# Add sudo support for non-root user
if [ "${USERNAME}" != "root" ]; then
  # Ensure /etc/sudoers.d exists
  [ -d /etc/sudoers.d ] || mkdir -p /etc/sudoers.d
  # Add the user to sudoers with no password requirement
  echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
  chmod 0440 /etc/sudoers.d/$USERNAME
fi

# Set default shell & verify
chsh -s /bin/zsh ${USERNAME}
if [ "$ADJUSTED_ID" = "mac" ]; then
  dscl . -read /Users/${USERNAME} UserShell
else
  getent passwd $USERNAME | awk -F: '{ print $7 }'
fi

echo "confirming username, uid, gid, shell"
cat /etc/passwd

echo "elapsed=$elapsed" > /tmp/.environment
echo "ADJUSTED_ID=$ADJUSTED_ID" >> /tmp/.environment
echo "TARGET_USERNAME=$USERNAME" >> /tmp/.environment
echo "TARGET_UID=$USER_UID" >> /tmp/.environment
echo "TARGET_GID=$USER_GID" >> /tmp/.environment

cat /tmp/.environment
