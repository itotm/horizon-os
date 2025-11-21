#!/bin/bash
set -ouex pipefail

flatpak list --app --columns=application | while read -r app; do
    if [ -n "$app" ]; then
        flatpak uninstall -y "$app" 2>/dev/null || true
    fi
done

flatpak list --runtime --columns=application | while read -r runtime; do
    if [ -n "$runtime" ]; then
        flatpak mask --remove "$runtime" 2>/dev/null || true
    fi
done

flatpak list --runtime --columns=application | while read -r runtime; do
    if [ -n "$runtime" ]; then
        flatpak uninstall -y "$runtime" 2>/dev/null || true
    fi
done

for remote in fedora fedora-testing; do
    if flatpak remotes | grep -q "^$remote"; then
        flatpak remote-delete "$remote" 2>/dev/null || true
    fi
done

flatpak uninstall --unused -y 2>/dev/null || true

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-modify --enable flathub

FLATPAK_PACKAGES=(
    com.calibre_ebook.calibre
    com.github.PintaProject.Pinta
    com.github.tchx84.Flatseal
    com.ranfdev.DistroShelf
    com.usebottles.bottles
    fr.handbrake.ghb
    io.github.flattool.Warehouse
    net.cozic.joplin_desktop
    net.lutris.Lutris
    net.mediaarea.MediaInfo
    net.nokyan.Resources
    no.mifi.losslesscut
    org.audacityteam.Audacity
    org.avidemux.Avidemux
    org.bunkus.mkvtoolnix-gui
    org.deskflow.deskflow
    org.fkoehler.KTailctl
    org.gimp.GIMP
    org.inkscape.Inkscape
    org.kde.kgeography
    org.kde.kid3
    org.kde.kmahjongg
    org.kde.kmines
    org.kde.kpat
    org.kde.marble
    org.libreoffice.LibreOffice
    org.qbittorrent.qBittorrent
    org.virt_manager.virt-manager
)

for package in "${FLATPAK_PACKAGES[@]}"; do
    flatpak install -y "$package"
done