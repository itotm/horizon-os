#!/bin/bash
set -oue pipefail

dnf5 -y copr enable shdwchn10/zenpower3
dnf5 -y install zenpower3 zenmonitor3
dnf5 -y copr disable shdwchn10/zenpower3
