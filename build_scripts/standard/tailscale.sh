#!/bin/bash
set -oue pipefail

dnf5 -y install tailscale

./ctx/cleanup.sh
