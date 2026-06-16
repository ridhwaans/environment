#!/usr/bin/env bash

ENVIRONMENT_DIR="${ENVIRONMENT_DIR:-"$HOME/Source/environment"}"
export ENVIRONMENT_START_SECONDS=${ENVIRONMENT_START_SECONDS:-$(date +%s)}

rm -rf "$ENVIRONMENT_DIR"
git clone -b main https://github.com/ridhwaans/environment.git "$ENVIRONMENT_DIR"

source $ENVIRONMENT_DIR/install.sh "$@"
