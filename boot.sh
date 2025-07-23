#!/usr/bin/env bash

ENVIRONMENT_DIR="${ENVIRONMENT_DIR:-"$HOME/.local/share/environment"}"

rm -rf $ENVIRONMENT_DIR
git clone -b test https://github.com/ridhwaans/environment.git $ENVIRONMENT_DIR
-
source $ENVIRONMENT_DIR/install.sh
