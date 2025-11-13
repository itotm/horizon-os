#!/bin/bash
set -ouex pipefail

dnf5 -y clean all
dnf5 config-manager --set-disabled \*
