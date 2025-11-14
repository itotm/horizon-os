#!/bin/bash
set -ouex pipefail

dnf5 -y install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf5 -y install \
    rpmfusion-free-release-tainted \
    rpmfusion-nonfree-release-tainted

dnf5 -y swap ffmpeg-free ffmpeg --allowerasing

RPMFUSION_PACKAGES=(
    intel-media-driver
    libdvdcss
    gstreamer1-plugin-libav
    gstreamer1-plugins-bad-free-extras
    gstreamer1-plugins-bad-freeworld
    gstreamer1-plugins-ugly
    gstreamer1-vaapi
)
dnf5 -y install "${RPMFUSION_PACKAGES[@]}"

./ctx/cleanup.sh
