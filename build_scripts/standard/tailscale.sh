#!/bin/bash
set -ouex pipefail

dnf5 -y install tailscale

systemctl enable tailscaled

./ctx/cleanup.sh
