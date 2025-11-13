#!/bin/bash
set -ouex pipefail

dnf5 -y install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf5 -y install \
    rpmfusion-free-release-tainted \
    rpmfusion-nonfree-release-tainted

dnf -y groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
dnf -y groupupdate sound-and-video

dnf5 -y swap ffmpeg-free ffmpeg --allowerasing

RPMFUSION_PACKAGES=(
    intel-media-driver
    libdvdcss
)
dnf5 -y install "${RPMFUSION_PACKAGES[@]}"
