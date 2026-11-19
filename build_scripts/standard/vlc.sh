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

echo "----------> Making VLC the default video player"
# plasma-desktop's kde-mimeapps.list makes Haruna the default for video, but
# Haruna is not installed, so KDE opened videos with whatever else claimed
# them (HandBrake, MediaInfo). Point those entries to VLC and add the video
# types VLC handles that the list does not mention.
list=/usr/share/applications/kde-mimeapps.list
if [ "$(grep -c '^\[' "$list")" -ne 1 ] || ! grep -qx '\[Default Applications\]' "$list"; then
    echo "$list no longer has just [Default Applications]" >&2
    exit 1
fi
sed -i -E 's/=org\.kde\.haruna\.desktop;?$/=vlc.desktop;/' "$list"
[ -z "$(tail -c1 "$list")" ] || echo >> "$list"
for mime in $(sed -n 's/^MimeType=//p' /usr/share/applications/vlc.desktop | tr ';' '\n' | grep '^video/'); do
    cut -d= -f1 "$list" | grep -qxF "$mime" || echo "$mime=vlc.desktop;" >> "$list"
done
if grep -q haruna "$list"; then
    echo "Haruna is still listed in $list" >&2
    exit 1
fi
