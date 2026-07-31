#!/usr/bin/env bash
set -euo pipefail

dnf -y copr enable itotm/kwin-minimize2tray
dnf5 -y install kwin-minimize2tray
