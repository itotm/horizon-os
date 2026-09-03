#!/bin/bash
set -oue pipefail

fc-cache -f

sed -i 's/^enabled=.*/enabled=0/' /etc/yum.repos.d/*.repo

echo "----------> Cleaning up dnf cache"
dnf5 -y autoremove
dnf5 -y clean all

echo "----------> Downloading GitHub assets"
./ctx/download-github.sh https://github.com/itotm/eleven-twilight/releases/download/v2.5/ElevenTwilight-2.5.tar.gz /usr/share/icons
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/releases/download/v1.0/ClearSimple.colors.tar.gz /usr/share/color-schemes
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/releases/download/v1.0/ClearSimple.tar.gz /usr/share/plasma/desktoptheme
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/releases/download/v1.0/colored-plasma-logo.tar.gz /usr/share/plasma/look-and-feel
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/releases/download/v1.0/breeze-cursors-light-plasma5.tar.gz /usr/share/icons
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/tree/main/Konsole /usr/share/konsole
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-wallpaper-potd-enhanced/releases/download/v1.6.0/com.plasma.wallpaper.potd-enhanced-1.6.0.tar.gz /usr/share/plasma/wallpapers
sleep 1
./ctx/download-github.sh https://github.com/itotm/kickoff-simplified/releases/download/v1.3.5/org.kde.plasma.kickoff-simplified-1.3.5.tar.gz /usr/share/plasma/plasmoids
sleep 1
./ctx/download-github.sh https://github.com/itotm/plymouth-themes/releases/download/v1.2/fedora-logo-spinner-1.2.tar.gz /usr/share/plymouth/themes

plymouth-set-default-theme fedora-logo-spinner

echo "----------> Regenerating initramfs"
KERNEL_VERSION=$(ls -1 /usr/lib/modules/ | head -n1)
echo "Kernel: ${KERNEL_VERSION}"
depmod -a "${KERNEL_VERSION}"
INITRAMFS_IMAGE="/usr/lib/modules/${KERNEL_VERSION}/initramfs.img"

# dracut mirrors the top-level directories into the initramfs. On ostree images
# /root is a symlink to /var/roothome, which only exists once tmpfiles has run
# on a booted system, so during the build the link dangles and dracut-install
# reports "ERROR: installing '/root'".
mkdir -p -m 0700 /var/roothome

# Fedora enables syslog logging, but a build container has no /dev/log socket,
# so dracut prints "No '/dev/log' or 'logger' included for syslog logging" and
# hides real errors behind it. The drop-in is removed right after the run so it
# never reaches the image.
DRACUT_QUIET_CONF="/etc/dracut.conf.d/99-horizon-build.conf"
mkdir -p /etc/dracut.conf.d
echo 'sysloglvl=0' > "${DRACUT_QUIET_CONF}"

echo "Starting initramfs regeneration for kernel version: ${KERNEL_VERSION}"
    dracut \
    --kver "${KERNEL_VERSION}" \
    --force \
    --add 'ostree' \
    --no-hostonly \
    --reproducible \
    "${INITRAMFS_IMAGE}"

rm -f "${DRACUT_QUIET_CONF}"

chmod 0600 "${INITRAMFS_IMAGE}"

cp -r /ctx/sys_files/* /

systemctl enable horizon-setup-system.service

cat > /etc/xdg/kcm-about-distrorc <<EOF
[General]
Variant=HorizonOS ${IMAGE_VERSION}
Website=https://github.com/itotm/horizon-os
EOF

sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"HorizonOS ${IMAGE_VERSION}\"/" /usr/lib/os-release

echo "${IMAGE_VERSION}" > /etc/horizon-version

echo "----------> Sqlite cleanup"
sqlite3 /usr/lib/sysimage/rpm/rpmdb.sqlite "PRAGMA wal_checkpoint(TRUNCATE); PRAGMA journal_mode=DELETE;"

echo "----------> Clearing /boot"
# bootc reads the kernel from /usr/lib/modules/<kver> and fills the real /boot
# at install time, so whatever the kernel-install hooks dropped here is dead
# weight that only trips the nonempty-boot lint.
if [ ! -f "/usr/lib/modules/${KERNEL_VERSION}/vmlinuz" ] && [ -f "/boot/vmlinuz-${KERNEL_VERSION}" ]; then
    cp "/boot/vmlinuz-${KERNEL_VERSION}" "/usr/lib/modules/${KERNEL_VERSION}/vmlinuz"
fi
if [ ! -f "/usr/lib/modules/${KERNEL_VERSION}/vmlinuz" ]; then
    echo "ERROR: no kernel at /usr/lib/modules/${KERNEL_VERSION}/vmlinuz, refusing to clear /boot" >&2
    exit 1
fi
find /boot -mindepth 1 -delete

echo "----------> Pruning build residue from /var"
# Only directories survive an update: /var comes from the image at install time
# only, and every later boot gets whatever the machine already has. Regular
# files left in /var are therefore stale by design, and these are pure build
# artifacts anyway (dnf's repo cache and its countme stamps, sepolgen's map
# used only by the audit2allow policy-authoring tool).
rm -rf /var/lib/dnf/repos
rm -f /var/lib/sepolgen/perm_map

echo "----------> Generating tmpfiles.d entries for /var"
# rpm-ostree does this conversion during compose; installing with dnf5 from a
# Containerfile does not, so directories packages expect under /var would be
# missing on every boot after the first. Only these two directories are read
# because they are the ones bootc itself considers when deciding whether a
# path is already declared.
{ cat /usr/lib/tmpfiles.d/*.conf /etc/tmpfiles.d/*.conf 2>/dev/null || true; } \
    | awk '$1 !~ /^#/ && NF >= 2 { print $2 }' \
    | sort -u > /tmp/tmpfiles-covered

# -xdev keeps the walk out of the /var/cache and /var/log build caches, whose
# content is mounted rather than part of the image; /var/run is skipped because
# it is a symlink to /run that systemd's own var.conf already declares.
find /var -xdev -mindepth 1 \
        \( -path /var/cache -o -path /var/log -o -path /var/run \) -prune -o \
        \( -type d -o -type l \) -print \
    | sort \
    | while read -r path; do
        grep -qxF "$path" /tmp/tmpfiles-covered && continue
        if [ -L "$path" ]; then
            printf 'L %s - - - - %s\n' "$path" "$(readlink "$path")"
        else
            printf 'd %s %s %s %s - -\n' \
                "$path" \
                "$(stat -c '%#a' "$path")" \
                "$(stat -c '%U' "$path")" \
                "$(stat -c '%G' "$path")"
        fi
    done > /usr/lib/tmpfiles.d/horizon-var.conf

echo "Generated $(wc -l < /usr/lib/tmpfiles.d/horizon-var.conf) entries:"
cat /usr/lib/tmpfiles.d/horizon-var.conf

echo "----------> Cleaning runtime-only directories"
# Package scriptlets (cockpit, dnf, ...) write into /run while the image is
# being built and that content lands in the layers. The buildah-managed mounts
# are skipped: they are not part of the layer and unlinking them fails.
for runtime_dir in /run /tmp; do
    find "${runtime_dir}" -mindepth 1 -maxdepth 1 \
        ! -name '.containerenv' ! -name 'secrets' \
        -exec rm -rf {} + 2>/dev/null || true
done

echo "----------> Final package count"
rpm -qa | wc -l

echo "----------> Final disk usage"
df -h
