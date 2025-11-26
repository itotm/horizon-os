#!/bin/bash
set -oue pipefail

dnf5 -y install gimp

./ctx/cleanup.sh
