#!/bin/bash
set -oue pipefail

dnf5 -y copr enable karlisk/ventoy
dnf5 -y install ventoy
dnf5 -y copr disable karlisk/ventoy
