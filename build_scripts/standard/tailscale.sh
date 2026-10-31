#!/bin/bash
set -oue pipefail

dnf5 -y config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
dnf5 -y install tailscale

# avahi on tailscale0 conflicts with its own hostname at boot (apollo -> apollo-2)
sed -i '/^\[server\]/a deny-interfaces=tailscale0' /etc/avahi/avahi-daemon.conf
