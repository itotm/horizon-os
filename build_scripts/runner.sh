#!/bin/sh
set -oue pipefail

FLAG_NAME="$1"
SCRIPT_TO_RUN="$2"

FLAG_VALUE=$(eval echo "\$$FLAG_NAME")

if [ "$FLAG_VALUE" = "true" ]; then
    sh "$SCRIPT_TO_RUN"
else
    exit 0
fi
