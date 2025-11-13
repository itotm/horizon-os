#!/bin/bash
set -ouex pipefail

dnf5 -y copr enable lizardbyte/beta
dnf5 -y install Sunshine || echo "Warning: Sunshine installation failed"
dnf5 -y copr disable lizardbyte/beta

./ctx/cleanup.sh
