#!/bin/bash
set -oue pipefail

dnf5 -y install vlc

echo "----------> Letting KIO open smb:// files for VLC"
# vlc.desktop always lists smb in X-KDE-Protocols, even without
# vlc-plugin-samba. Without it, Dolphin mounts the share through kio-fuse and
# hands VLC a local path, using the password KIO already keeps in KWallet.
# (VLC's own smb access cannot read back the passwords it saves in KWallet.)
sed -i -E '/^X-KDE-Protocols=/{s/(=|,)smb(,|$)/\1\2/;s/,$//;s/=,/=/;s/,,/,/}' /usr/share/applications/vlc.desktop
if grep -E '^X-KDE-Protocols=.*(=|,)smb(,|$)' /usr/share/applications/vlc.desktop; then
    echo "smb is still listed in vlc.desktop" >&2
    exit 1
fi
