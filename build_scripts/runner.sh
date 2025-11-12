#!/bin/sh
set -ouex pipefail

FLAG_NAME="$1"
SCRIPT_TO_RUN="$2"

FLAG_VALUE=$(eval echo "\$$FLAG_NAME")

if [ "$FLAG_VALUE" = "true" ]; then
    echo "Flag '$FLAG_NAME' è true. Esecuzione di '$SCRIPT_TO_RUN'..."
    sh "$SCRIPT_TO_RUN"
else
    echo "Flag '$FLAG_NAME' è false. Salto di '$SCRIPT_TO_RUN'."
    exit 0
fi
