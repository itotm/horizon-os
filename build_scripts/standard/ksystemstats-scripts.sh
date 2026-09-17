#!/bin/bash
set -oue pipefail

dnf5 -y install /ctx/rpms/ksystemstats-scripts/*.rpm
