#!/usr/bin/env bash

source $ENVIRONMENT_DIR/system-check.sh

USERNAME=$(whoami)
echo "Installation starting..."
source $ENVIRONMENT_DIR/src/install.sh
source $ENVIRONMENT_DIR/src/configs.sh
