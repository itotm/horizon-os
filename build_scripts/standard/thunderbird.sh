#!/bin/bash
set -oue pipefail

dnf5 -y install thunderbird

dnf5 config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:/Ximi1970:/Mozilla:/Add-ons/Fedora_43/home:Ximi1970:Mozilla:Add-ons.repo
dnf5 -y install systray-x
