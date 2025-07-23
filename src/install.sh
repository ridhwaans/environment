#!/usr/bin/env bash

set -e

SCRIPT_ROOT=$(dirname "${BASH_SOURCE[0]}")

echo "SCRIPT_ROOT: $SCRIPT_ROOT"

modules=(
  common-utils.sh
  tools.sh
)
total=${#modules[@]}
cur=1

for module in "${modules[@]}"; do
    sudo bash -c "
        export USERNAME=$USERNAME
        export ADJUSTED_ID=$ADJUSTED_ID
        source $SCRIPT_ROOT/_helper.sh
        bash $SCRIPT_ROOT/install/$module"
    exit_status=$?

    if [ $exit_status -eq 0 ]; then
        echo "($cur/$total) Module '$module' completed successfully."
    else
        echo "Error: ($cur/$total) Module '$module' failed to complete with status $exit_status."
        exit 1
    fi
    ((cur++))
done
