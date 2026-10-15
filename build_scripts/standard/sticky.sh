#!/usr/bin/env bash
set -euo pipefail

# without weak deps: xapps recommends inxi, which pulls in perl, ipmitool and freeipmi
dnf5 -y install --setopt=install_weak_deps=False /ctx/rpms/sticky/*.rpm
