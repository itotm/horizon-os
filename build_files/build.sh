#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

SERVER_PACKAGES=(
    mc
    hunspell-it
    qemu
    cockpit
    cockpit-machines
    cockpit-podman
    distrobox
    fastfetch
    syncthing
    tailscale
)

dnf5 install -y "${SERVER_PACKAGES[@]}"

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
systemctl enable cockpit.socket

BUILD_DATE=$(date +'%Y%m%d')
cat > /etc/xdg/kcm-about-distrorc <<EOF
[General]
Variant=HorizonOS ${BUILD_DATE}
Website=https://github.com/itotm/horizon-os
END
EOF