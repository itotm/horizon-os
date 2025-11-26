#!/bin/bash
set -oue pipefail

dnf5 -y install thunderbird

./ctx/cleanup.sh
