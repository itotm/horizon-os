#!/bin/bash
set -ouex pipefail

PACKAGE_NAME="nomachine_9.2.18_3_x86_64.tar.gz"
INSTALL_PATH="/var/opt/nomachine"

mkdir -p "$INSTALL_PATH"

cd /tmp
wget "https://download.nomachine.com/download/9.2/Linux/$PACKAGE_NAME"
tar xfz "$PACKAGE_NAME"
cd NX
NX_INSTALL_PREFIX="$INSTALL_PATH" ./nxserver --install

cd /tmp
rm -f "$PACKAGE_NAME"
rm -rf NX
