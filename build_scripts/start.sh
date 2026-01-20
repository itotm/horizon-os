#!/bin/bash
set -oue pipefail

echo 'max_parallel_downloads=10' >> /etc/dnf/dnf.conf
