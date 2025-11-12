#!/bin/bash
set -ouex pipefail

# wine needs /opt writable
rm /opt && mkdir /opt

dnf5 -y config-manager addrepo --from-repofile=https://dl.winehq.org/wine-builds/fedora/43/winehq.repo
dnf5 -y install winehq-staging
