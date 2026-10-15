#!/bin/bash
set -oue pipefail

# Epson Perfection V200 Photo (GT-F670): Image Scan! for Linux plus the
# proprietary gt-f670 plugin, taken from Epson's
# iscan-gt-f670-bundle-2.30.4.x64.rpm.tar.gz and downloaded at build time
# instead of being vendored: the plugin is under a non-free Epson EULA and is
# not ours to redistribute. The bundle is checked against a pinned sha256, so
# the build fails if Epson changes or removes it.
#
# The RPMs are installed with rpm rather than dnf so nothing gets resolved
# behind our back: the dependencies are listed here explicitly, and rpm aborts
# the build if one of them is missing. Their scriptlets are skipped as well and
# the configuration they would do is done below instead: they append sane-port
# to /etc/services and udev/hwdb rules for the scanner, both of which Fedora's
# setup and sane-backends already provide; they enable the backend by editing
# /etc/sane.d/dll.conf; they register the plugin in /var/lib/iscan/interpreter,
# which bootc would not carry across updates; and they symlink iscan into
# GIMP's plug-in directory, which is not wanted.
# --nodigest --nosignature: the packages are neither digested nor signed, and
# since Fedora 45 rpm refuses to install an unsigned package by default.

BUNDLE_URL="https://download2.ebz.epson.net/iscan/plugin/gt-f670/rpm/x64/iscan-gt-f670-bundle-2.30.4.x64.rpm.tar.gz"
BUNDLE_SHA256="664360a1517a74b4e22ae8227ac58e8031450dc8b56dea2d2d1a6dd157043547"
BUNDLE_DIR="/tmp/iscan-gt-f670-bundle-2.30.4.x64.rpm"

ISCAN_DEPS=(
    gtk2
    libtool-ltdl
    libusb1
    libxml2
    sane-backends
)
dnf5 -y install "${ISCAN_DEPS[@]}"

echo "----------> Downloading the Epson GT-F670 bundle"
curl --http1.1 --retry 3 --retry-delay 10 -fsSL -o "/tmp/iscan-bundle.tar.gz" "$BUNDLE_URL"
echo "${BUNDLE_SHA256}  /tmp/iscan-bundle.tar.gz" | sha256sum -c -
tar -xzf "/tmp/iscan-bundle.tar.gz" -C /tmp

rpm -ivh --noscripts --nodigest --nosignature \
    "${BUNDLE_DIR}/data/iscan-data-1.39.2-1.noarch.rpm" \
    "${BUNDLE_DIR}/core/iscan-2.30.4-2.x86_64.rpm" \
    "${BUNDLE_DIR}/plugins/iscan-plugin-gt-f670-2.1.3-1.x86_64.rpm"
rm -rf "/tmp/iscan-bundle.tar.gz" "$BUNDLE_DIR"

echo "----------> Enabling the epkowa SANE backend"
mkdir -p /etc/sane.d/dll.d
echo "epkowa" > /etc/sane.d/dll.d/epkowa

echo "----------> Registering the gt-f670 plugin"
# Same line the plugin's %post writes with iscan-registry, but declared in
# tmpfiles.d so that it is recreated on every boot: bootc only populates /var
# at install time, so a file written here would be missing after an update.
cat > /usr/lib/tmpfiles.d/iscan.conf <<'TMPFILES'
d  /var/lib/iscan             0755 root root - -
f+ /var/lib/iscan/interpreter 0644 root root - interpreter usb 0x04b8 0x012e /usr/lib64/iscan/libesint7A /usr/share/iscan/esfw7A.bin\n
TMPFILES
