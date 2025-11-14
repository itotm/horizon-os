#!/bin/bash
set -ouex pipefail

dnf5 -y install vlc
./ctx/cleanup.sh
