#!/bin/bash
set -ouex pipefail

#flatpak uninstall --system --all --delete-data -y || true
#flatpak pin --system --remove-all || true
#flatpak uninstall --system --unused -y || true
#flatpak remote-delete --system fedora --force || true
#flatpak remote-delete --system fedora-testing --force || true

flatpak remote-add --system flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-modify --system --enable flathub
