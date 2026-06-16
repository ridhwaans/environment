#!/usr/bin/env bash

SCRIPT_ROOT=$(dirname "${BASH_SOURCE[0]}")
export ENVIRONMENT_DIR=${ENVIRONMENT_DIR:-$(cd "$SCRIPT_ROOT" && pwd)}
export ENVIRONMENT_START_SECONDS=${ENVIRONMENT_START_SECONDS:-$(date +%s)}

source $ENVIRONMENT_DIR/system-check.sh

echo "Installation starting..."
source $ENVIRONMENT_DIR/src/install.sh "$@"

elapsed=$(($(date +%s) - ENVIRONMENT_START_SECONDS))
if [ -f /tmp/.environment ]; then
    if grep -q '^elapsed=' /tmp/.environment; then
        conditional_sed -i "s/^elapsed=.*/elapsed=$elapsed/" /tmp/.environment
    else
        echo "elapsed=$elapsed" >> /tmp/.environment
    fi
    cat /tmp/.environment
else
    echo "ENVIRONMENT_START_SECONDS=$ENVIRONMENT_START_SECONDS" > /tmp/.environment
    echo "elapsed=$elapsed" >> /tmp/.environment
    echo "ADJUSTED_ID=$ADJUSTED_ID" >> /tmp/.environment
    cat /tmp/.environment
fi
