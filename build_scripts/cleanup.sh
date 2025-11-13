#!/bin/bash
set -ouex pipefail

dnf5 -y clean all
sed -i 's/^enabled=.*/enabled=0/' /etc/yum.repos.d/*.repo
