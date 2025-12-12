#!/bin/bash
set -oue pipefail

flatpak list --app --columns=application | while read -r app; do
    if [ -n "$app" ]; then
        flatpak uninstall -y --delete-data "$app" 2>/dev/null || true
    fi
done

flatpak list --runtime --columns=application | while read -r runtime; do
    if [ -n "$runtime" ]; then
        flatpak mask --remove "$runtime" 2>/dev/null || true
    fi
done

flatpak list --runtime --columns=application | while read -r runtime; do
    if [ -n "$runtime" ]; then
        flatpak uninstall -y --delete-data "$runtime" 2>/dev/null || true
    fi
done

for remote in fedora fedora-testing; do
    if flatpak remotes | grep -q "^$remote"; then
        flatpak remote-delete "$remote" 2>/dev/null || true
    fi
done

flatpak uninstall -y --unused 2>/dev/null || true

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-modify --enable flathub
