#!/bin/bash
set -oue pipefail

# Usage: install-opt <package-name>
# Installs the given package, moves /opt contents to /var/opt, then restores /opt

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <package-name>"
    exit 1
fi

PACKAGE_NAME="$1"

mv /opt /opt_
mkdir /opt

dnf5 -y install "$PACKAGE_NAME"

mkdir -p /var/opt
mv /opt/* /var/opt/
mv /opt_ /opt
