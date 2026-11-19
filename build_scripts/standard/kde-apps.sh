#!/bin/bash
set -oue pipefail

KDE_PACKAGES=(
    elisa-player
    gwenview
    isoimagewriter
    kamoso
    kate
    kcalc
    kcolorchooser
    kdiff3
    kdotool
    kmahjongg
    kmines
    kid3
    kolourpaint
    koko
    kompare
    kommit
    kpat
    krename
    krusader
    ksystemlog
    okular
    skanlite
    skanpage
)
dnf5 -y install "${KDE_PACKAGES[@]}"

echo "----------> Making Elisa the default for every audio type it plays"
# plasma-desktop's kde-mimeapps.list already maps most audio to Elisa but
# misses a few types Elisa handles (Opus in Ogg went to MediaInfo).
list=/usr/share/applications/kde-mimeapps.list
if [ "$(grep -c '^\[' "$list")" -ne 1 ] || ! grep -qx '\[Default Applications\]' "$list"; then
    echo "$list no longer has just [Default Applications]" >&2
    exit 1
fi
[ -z "$(tail -c1 "$list")" ] || echo >> "$list"
for mime in $(sed -n 's/^MimeType=//p' /usr/share/applications/org.kde.elisa.desktop | tr ';' '\n' | grep .); do
    cut -d= -f1 "$list" | grep -qxF "$mime" || echo "$mime=org.kde.elisa.desktop;" >> "$list"
done
grep -qx 'audio/x-opus+ogg=org.kde.elisa.desktop;' "$list"
