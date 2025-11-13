#!/bin/bash
set -ouex pipefail

dnf5 -y install qemu-kvm
dnf5 -y install cockpit-machines
