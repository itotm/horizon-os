#!/bin/bash
set -oue pipefail

dnf5 -y install vlc

./ctx/cleanup.sh
