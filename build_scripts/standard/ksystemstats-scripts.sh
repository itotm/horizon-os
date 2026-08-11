#!/bin/bash
set -oue pipefail

dnf5 -y copr enable itotm/ksystemstats-scripts
dnf5 -y install ksystemstats-scripts
dnf5 -y copr disable itotm/ksystemstats-scripts
