#!/bin/bash
set -oue pipefail

dnf5 -y copr enable rok/vdhcoapp
dnf5 -y install vdhcoapp
dnf5 -y copr disable rok/vdhcoapp

vdhcoapp install

./ctx/cleanup.sh
