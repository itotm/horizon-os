#!/bin/bash
set -ouex pipefail

QUADLET_DIR="$HOME/.config/containers/systemd"
QUADLET_FILE="$QUADLET_DIR/syncthing.container"

mkdir -p "$QUADLET_DIR"

cat > "$QUADLET_FILE" <<'EOF'
[Unit]
Description=Syncthing
After=network-online.target
Wants=network-online.target

[Service]
ExecStartPre=-mkdir -p %h/.config/syncthing
ExecStartPre=-mkdir -p %h/Sync
Restart=on-failure
TimeoutStartSec=900

[Container]
ContainerName=syncthing
Image=lscr.io/linuxserver/syncthing:latest
AutoUpdate=registry

Environment=PUID=1000
Environment=PGID=1000
Environment=UMASK=022
Environment=TZ=Europe/Rome

Volume=%h/.config/syncthing:/config:Z
Volume=%h/Sync:/data/Sync:Z

PublishPort=8384:8384
PublishPort=22000:22000/tcp
PublishPort=22000:22000/udp
PublishPort=21027:21027/udp

Network=slirp4netns:allow_host_loopback=true
SecurityLabelDisable=true

[Install]
WantedBy=default.target
EOF

echo "Quadlet file created successfully!"

echo "Reloading systemd..."
systemctl --user daemon-reload

echo "Syncthing has been enabled, reboot to activate it."
echo ""
echo "To check the status: systemctl --user status syncthing.service"
echo "Access the web UI at: http://localhost:8384"
echo "Your sync folders will be in: $HOME/Sync"
