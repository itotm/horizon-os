#!/bin/bash
set -oue pipefail

dnf5 -y copr enable bieszczaders/kernel-cachyos
dnf5 -y install kernel-cachyos kernel-cachyos-devel-matched
dnf5 -y copr disable bieszczaders/kernel-cachyos
