#!/bin/bash

set -oue pipefail

dnf5 -y copr enable lizardbyte/stable
if dnf5 -y install Sunshine; then
	dnf5 -y copr disable lizardbyte/stable
else
	dnf5 -y copr disable lizardbyte/stable
	dnf5 -y copr enable lizardbyte/beta
	dnf5 -y install Sunshine
	dnf5 -y copr disable lizardbyte/beta
fi
