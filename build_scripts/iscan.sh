#!/bin/bash
set -ouex pipefail

dnf5 -y install iscan-firmware

./ctx/cleanup.sh
