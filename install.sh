#!/usr/bin/env bash

SCRIPT_ROOT=$(dirname "${BASH_SOURCE[0]}")
export ENVIRONMENT_DIR=${ENVIRONMENT_DIR:-$(cd "$SCRIPT_ROOT" && pwd)}

source $ENVIRONMENT_DIR/system-check.sh

echo "Installation starting..."
source $ENVIRONMENT_DIR/src/install.sh "$@"
