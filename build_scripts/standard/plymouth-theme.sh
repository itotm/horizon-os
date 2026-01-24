#!/bin/bash
set -oue pipefail

./ctx/download-github.sh https://github.com/itotm/plymouth-themes/releases/download/v1.0/fedora-logo.tar.gz /usr/share/plymouth/themes

#plymouth-set-default-theme fedora-logo
