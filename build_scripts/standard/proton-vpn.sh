#!/bin/bash
set -oue pipefail

dnf5 -y install https://repo.protonvpn.com/fedora-$(rpm -E %fedora)-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.3-1.noarch.rpm
dnf5 -y install proton-vpn-cli
