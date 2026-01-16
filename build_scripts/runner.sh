#!/bin/sh
set -oue pipefail

FLAG_NAME="$1"
SCRIPT_TO_RUN="$2"

FLAG_VALUE=$(eval echo "\$$FLAG_NAME")

if [ "$FLAG_VALUE" = "true" ]; then
    if [ -d "$SCRIPT_TO_RUN" ]; then
        for script in "$SCRIPT_TO_RUN"/*; do
            if [ -f "$script" ] && [ -x "$script" ]; then
                echo "----------> Running $(basename "$script")"
                sh "$script"
            fi
        done
    else
        echo "----------> Running $(basename "$SCRIPT_TO_RUN")"
        sh "$SCRIPT_TO_RUN"
    fi
else
    exit 0
fi
