#!/bin/bash
set -oue pipefail

dnf5 -y copr enable sunnyyang/corefreq
dnf5 -y install corefreq
dnf5 -y copr disable sunnyyang/corefreq
