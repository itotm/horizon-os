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

echo "----------> Raising the open-file soft limit for VS Code windows"
# Chromium gives its renderers the soft RLIMIT_NOFILE VS Code was started
# with: 1024 under systemd. A window that receives many large IPC messages
# needs two descriptors per shared-memory buffer; once it runs out, buffers
# arrive truncated and the window crashes with SIGBUS ("code 135").
# Start VS Code with a soft limit of 65536 from the menu, the URL handler
# and the code command.
for f in /usr/share/applications/com.microsoft.VSCode.desktop /usr/share/applications/com.microsoft.VSCode.UrlHandler.desktop; do
    sed -i 's|^Exec=/usr/share/code/code |Exec=prlimit --nofile=65536: /usr/share/code/code |' "$f"
    if grep -q '^Exec=/usr/share/code/code' "$f"; then
        echo "$f still starts VS Code without prlimit" >&2
        exit 1
    fi
done
sed -i 's|^ELECTRON_RUN_AS_NODE=1 "\$ELECTRON" "\$CLI" "\$@"$|ulimit -Sn 65536 2>/dev/null\n&|' /usr/share/code/bin/code
if ! grep -q '^ulimit -Sn 65536' /usr/share/code/bin/code; then
    echo "/usr/share/code/bin/code no longer matches the expected launch line" >&2
    exit 1
fi

echo "----------> Keeping VS Code alive when one of its processes is OOM-killed"
# If the kernel OOM-kills one process inside VS Code (e.g. a runaway ESLint),
# keep the rest of VS Code and its Claude Code sessions alive
# (systemd default for scopes: OOMPolicy=stop).
mkdir -p "/usr/lib/systemd/user/app-com.microsoft.VSCode-.scope.d"
cat > "/usr/lib/systemd/user/app-com.microsoft.VSCode-.scope.d/50-oom-continue.conf" <<'CONF'
[Scope]
OOMPolicy=continue
CONF
