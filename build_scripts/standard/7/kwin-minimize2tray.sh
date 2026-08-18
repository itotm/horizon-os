#!/usr/bin/env bash
set -euo pipefail

dnf5 -y copr enable itotm/kwin-minimize2tray
dnf5 -y install kwin-minimize2tray
dnf5 -y copr disable itotm/kwin-minimize2tray
