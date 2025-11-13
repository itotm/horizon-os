#!/bin/bash
set -ouex pipefail

dnf5 -y install libreoffice

./ctx/cleanup.sh
