#!/bin/bash
set -oue pipefail

REMOVE_IBUS=(
    anthy-unicode
    cldr-emoji-annotation
    cldr-emoji-annotation-dtd
    ibus
    ibus-anthy
    ibus-anthy-python
    ibus-chewing
    ibus-gtk2
    ibus-hangul
    ibus-libpinyin
    ibus-m17n
    ibus-panel
    ibus-setup
    ibus-typing-booster
    libchewing
    libhangul
    libpinyin
    libpinyin-data
    m17n-db
    m17n-lib
    python3-ibus
    unicode-ucd
)

REMOVE_FIRMWARE=(
    alsa-sof-firmware
    atheros-firmware
    brcmfmac-firmware
    cirrus-audio-firmware
    intel-audio-firmware
    intel-vsc-firmware
    iwlegacy-firmware
    iwlwifi-dvm-firmware
    iwlwifi-mld-firmware
    iwlwifi-mvm-firmware
    libertas-firmware
    nvidia-gpu-firmware
    nxpwireless-firmware
    qcom-wwan-firmware
    thermald
    tiwilink-firmware
)

# Intel VA-API: intel-media-driver (RPM Fusion, Broadwell+) is installed by
# 2.rpmfusion.sh and stays. Only the legacy Media SDK goes: ffmpeg uses libvpl for QSV.
REMOVE_INTEL_VAAPI=(
    intel-mediasdk
)

REMOVE_MARIADB=(
    akonadi-server
    akonadi-server-mysql
    mariadb
    mariadb-backup
    mariadb-cracklib-password-check
    mariadb-errmsg
    mariadb-gssapi-server
    mariadb-server
    mysql-selinux
)

REMOVE_AWS=(
    python3-boto3
    python3-botocore
    python3-s3transfer
)

REMOVE_PRINTERS=(
    braille-printer-app
    dymo-cups-drivers
    gutenprint
    gutenprint-cups
    gutenprint-libs
    hplip
    hplip-common
    hplip-libs
    libsane-hpaio
    ptouch-driver
    splix
)

REMOVE_GUEST_TOOLS=(
    open-vm-tools
    open-vm-tools-desktop
    #qemu-guest-agent
    #spice-vdagent
    #spice-webdavd
    virtualbox-guest-additions
)

REMOVE_FIREFOX_LANGPACKS=(
    firefox-langpacks
)

dnf5 -y remove \
    "${REMOVE_IBUS[@]}" \
    "${REMOVE_FIRMWARE[@]}" \
    "${REMOVE_INTEL_VAAPI[@]}" \
    "${REMOVE_MARIADB[@]}" \
    "${REMOVE_AWS[@]}" \
    "${REMOVE_PRINTERS[@]}" \
    "${REMOVE_GUEST_TOOLS[@]}" \
    "${REMOVE_FIREFOX_LANGPACKS[@]}"

# Locales: keep only en and it. Install the individual langpacks first (they
# coexist with glibc-all-langpacks), then remove the full package. Do not use
# "swap": in one build it downgraded glibc to an older version from updates-archive.
dnf5 -y install glibc-langpack-en glibc-langpack-it
dnf5 -y remove glibc-all-langpacks
