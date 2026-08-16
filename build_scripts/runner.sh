#!/bin/sh
set -oue pipefail

FLAG_NAME="$1"
SCRIPT_TO_RUN="$2"

FLAG_VALUE=$(eval echo "\$$FLAG_NAME")

if [ "$FLAG_VALUE" = "true" ]; then
    rpm -qa | wc -l

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

    for db in /var/lib/rpm/rpmdb.sqlite /usr/lib/sysimage/rpm/rpmdb.sqlite; do
        if [ -f "$db" ]; then
            echo "Found: $db"
            sqlite3 "$db" "PRAGMA integrity_check;" || echo "CORRUPT: $db"
        fi
    done
else
    exit 0
fi
