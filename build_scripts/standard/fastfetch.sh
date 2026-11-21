#!/bin/bash
set -oue pipefail

# System-wide fastfetch defaults: the HorizonOS emblem instead of the Fedora
# logo, keys in the ring's blue and the title in the sun's orange. The logo is
# a pre-rendered half-block picture with 24-bit colours (file-raw), so it needs
# no image library and also shows over SSH. A ~/.config/fastfetch/config.jsonc
# replaces this file entirely. The module list is the stock one: a config
# without "modules" would print the logo alone.
echo "----------> Writing the fastfetch configuration"
mkdir -p /etc/xdg/fastfetch
cat > /etc/xdg/fastfetch/config.jsonc <<'JSONC'
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "type": "file-raw",
        "source": "/usr/share/horizon-os/fastfetch-logo.ansi",
        "width": 46,
        "height": 19,
        "padding": { "top": 1, "right": 3 }
    },
    "display": {
        "color": {
            "keys": "38;2;6;151;215",
            "title": "38;2;245;152;35"
        }
    },
    "modules": [
        "title",
        "separator",
        "os",
        "host",
        "kernel",
        "uptime",
        "packages",
        "shell",
        "display",
        "de",
        "wm",
        "wmtheme",
        "theme",
        "icons",
        "font",
        "cursor",
        "terminal",
        "terminalfont",
        "cpu",
        "gpu",
        "memory",
        "swap",
        "disk",
        "localip",
        "battery",
        "poweradapter",
        "locale",
        "break",
        "colors"
    ]
}
JSONC
