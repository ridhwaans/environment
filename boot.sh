#!/usr/bin/env bash

export ENVIRONMENT_DIR="${ENVIRONMENT_DIR:-"$HOME/Source/environment"}"
export ENVIRONMENT_BRANCH="${ENVIRONMENT_BRANCH:-main}"

rm -rf "$ENVIRONMENT_DIR"
git clone -b "$ENVIRONMENT_BRANCH" https://github.com/ridhwaans/environment.git "$ENVIRONMENT_DIR"

source "$ENVIRONMENT_DIR/install.sh"
