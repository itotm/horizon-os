#!/bin/bash
set -oue pipefail

dnf5 -y install tailscale

systemctl enable tailscaled

./ctx/cleanup.sh
