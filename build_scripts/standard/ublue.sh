#!/bin/bash
set -oue pipefail

dnf5 -y copr enable ublue-os/akmods
dnf5 -y install zenpower3 nct6687d
dnf5 -y copr disable ublue-os/akmods
