#!/bin/bash
set -oue pipefail

# Hydrascale runs one tailscaled per tailnet, each in its own network
# namespace, so the host joins several tailnets at once. It is not packaged
# in Fedora: install the latest release binary of the itotm/hydrascale fork
# (upstream Crank-Git/Hydrascale plus a peers view, light theme, console
# password and host_ipv6). tailscaled itself comes from
# standard/tailscale.sh. The lite image (no ENABLE_EXTENDED) keeps the system
# tailscaled instead: see horizon-configure-services.
# The latest tag is read from the redirect of releases/latest rather than from
# api.github.com, whose anonymous rate limit is shared by all the runners.
HYDRASCALE_TAG=$(curl --http1.1 -fsSLI -o /dev/null -w '%{url_effective}' \
  "https://github.com/itotm/hydrascale/releases/latest")
HYDRASCALE_TAG="${HYDRASCALE_TAG##*/}"
HYDRASCALE_VERSION="${HYDRASCALE_TAG#v}"
HYDRASCALE_URL="https://github.com/itotm/hydrascale/releases/download/${HYDRASCALE_TAG}"
HYDRASCALE_TGZ="hydrascale_${HYDRASCALE_VERSION}_linux_amd64.tar.gz"
echo "----------> Installing Hydrascale ${HYDRASCALE_VERSION}"

mkdir -p /tmp/hydrascale
curl --http1.1 --retry 3 --retry-delay 10 -fsSL -o "/tmp/hydrascale/${HYDRASCALE_TGZ}" "${HYDRASCALE_URL}/${HYDRASCALE_TGZ}"
curl --http1.1 --retry 3 --retry-delay 10 -fsSL -o "/tmp/hydrascale/checksums.txt" "${HYDRASCALE_URL}/checksums.txt"
(cd /tmp/hydrascale && grep " ${HYDRASCALE_TGZ}\$" checksums.txt | sha256sum --check)

tar -xzf "/tmp/hydrascale/${HYDRASCALE_TGZ}" -C /tmp/hydrascale hydrascale LICENSE
install -m 0755 /tmp/hydrascale/hydrascale /usr/bin/hydrascale
install -D -m 0644 /tmp/hydrascale/LICENSE /usr/share/licenses/hydrascale/LICENSE
rm -rf /tmp/hydrascale

# Same unit as upstream contrib/hydrascale.service, with the binary in
# /usr/bin. The daemon starts only once /etc/hydrascale/config.yaml exists.
# No systemd sandboxing: the daemon needs iptables, /run/netns and mount
# propagation to the host. horizon-lan-direct.service (sys_files) adds the
# routing rule that keeps the LAN off the routes of the daemon.
cat > /usr/lib/systemd/system/hydrascale.service <<'UNIT'
[Unit]
Description=Hydrascale - Multi-Tailnet Manager
After=network-online.target
Wants=network-online.target horizon-lan-direct.service
ConditionPathExists=/etc/hydrascale/config.yaml

[Service]
Type=simple
ExecStart=/usr/bin/hydrascale serve --config /etc/hydrascale/config.yaml
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5s
WorkingDirectory=/var/lib/hydrascale
StandardOutput=journal
StandardError=journal
SyslogIdentifier=hydrascale

[Install]
WantedBy=multi-user.target
UNIT

cat > /usr/lib/tmpfiles.d/hydrascale.conf <<'TMPFILES'
d /var/lib/hydrascale 0750 root root - -
d /var/lib/hydrascale/state 0750 root root - -
d /var/log/hydrascale 0750 root root - -
TMPFILES

# The traffic of each namespace reaches the internet through the host.
cat > /usr/lib/sysctl.d/90-hydrascale.conf <<'SYSCTL'
net.ipv4.ip_forward = 1
SYSCTL
