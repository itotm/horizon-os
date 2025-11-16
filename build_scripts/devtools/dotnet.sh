#!/bin/bash
set -ouex pipefail

dnf5 -y install dotnet-sdk-10.0

./ctx/cleanup.sh
