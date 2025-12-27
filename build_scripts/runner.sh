#!/bin/sh
set -ouex pipefail

FLAG_NAME="$1"
SCRIPT_TO_RUN="$2"

FLAG_VALUE=$(eval echo "\$$FLAG_NAME")

if [ "$FLAG_VALUE" = "true" ]; then
    if [ -d "$SCRIPT_TO_RUN" ]; then
        for script in "$SCRIPT_TO_RUN"/*; do
            [ -f "$script" ] && [ -x "$script" ] && sh "$script"
        done
    else
        sh "$SCRIPT_TO_RUN"
    fi
else
    exit 0
fi
