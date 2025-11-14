#!/bin/bash
set -ouex pipefail

dnf5 -y install syncthing

./ctx/cleanup.sh
