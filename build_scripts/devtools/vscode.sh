#!/bin/bash
set -oue pipefail

rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo > /dev/null

dnf5 -y install code

echo "----------> Adding the Open in VSCode service menu"
mkdir -p /usr/share/kio/servicemenus
cat > /usr/share/kio/servicemenus/open-in-vscode.desktop <<'DESKTOP'
[Desktop Entry]
Name = Open in VSCode
Type=Service
ServiceTypes=KonqPopupMenu/Plugin
MimeType=all/all
X-KDE-Priority=TopLevel
Actions=openInVSCode

[Desktop Action openInVSCode]
Name=Open in VSCode
Icon=vscode
Exec=code %u
DESKTOP

echo "----------> Keeping VS Code alive when one of its processes is OOM-killed"
# If the kernel OOM-kills one process inside VS Code (e.g. a runaway ESLint),
# keep the rest of VS Code and its Claude Code sessions alive
# (systemd default for scopes: OOMPolicy=stop).
mkdir -p "/usr/lib/systemd/user/app-com.microsoft.VSCode-.scope.d"
cat > "/usr/lib/systemd/user/app-com.microsoft.VSCode-.scope.d/50-oom-continue.conf" <<'CONF'
[Scope]
OOMPolicy=continue
CONF
