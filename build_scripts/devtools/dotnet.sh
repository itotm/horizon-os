#!/bin/bash
set -ouex pipefail

rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[packages-microsoft-com-prod]\nname=Microsoft .NET Core SDK\nbaseurl=https://packages.microsoft.com/yumrepos/packages-microsoft-com-prod\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/dotnet-sdk.repo > /dev/null

dnf5 check-update
dnf5 -y install dotnet-sdk-8.0

./ctx/cleanup.sh
