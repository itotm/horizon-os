#!/bin/bash
set -oue pipefail

rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo > /dev/null

# openssl3-libs provides libssl.so.3: the extension signature verifier bundled
# with VS Code (vsce-sign, .NET) only knows OpenSSL <= 3 and aborts on Fedora 45
# (OpenSSL 4 ships only libssl.so.4), so every extension install fails verification.
dnf5 -y install code openssl3-libs

echo "----------> Adding the Open in VSCode service menu"
# Generated here rather than shipped in sys_files: KIO ignores TryExec in
# service menus, so the entry must only exist where VS Code is installed.
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
