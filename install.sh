#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export ENVIRONMENT_DIR="${ENVIRONMENT_DIR:-$SCRIPT_DIR}"

source "$ENVIRONMENT_DIR/system-check.sh"
echo "Installation starting..."
source "$ENVIRONMENT_DIR/src/install.sh"
run_environment_install
