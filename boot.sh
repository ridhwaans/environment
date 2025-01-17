#!/usr/bin/env bash

ENVIRONMENT_PATH="${ENVIRONMENT_PATH:-"$HOME/.local/share"}"

rm -rf $ENVIRONMENT_PATH/environment
git clone https://github.com/ridhwaans/environment.git $ENVIRONMENT_PATH/environment

source $ENVIRONMENT_PATH/environment/install.sh
