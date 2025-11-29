# HorizonOS

![HorizonOS](./logo.png)

A custom image based on Fedora Kinoite 43 and built with Universal Blue template.

**WARNING:** not (yet) ready, builds are unstable and experimental. Use at your own risk.

## Features

- a bunch of [cli tools](./build_scripts/standard/packages.sh)
- media codecs from [RPM Fusion](https://rpmfusion.org/)
- selected [KDE apps](./build_scripts/standard/kde-apps.sh)
- Flathub with selected [packages](./sys_files/usr/bin/horizon-install-flatpaks.sh)
- Cockpit, Tailscale, Sunshine preinstalled
- Syncthing as Quadlet
- optional tools: QEmu, dotnet, VSCode
- [my](https://github.com/itotm/plasma-colors) custom colors and icons
- image built daily, system scheduled to update weekly
- designed to be modular (fork the repo to try!)

![build action](./build-action.png)

## Howto

- install standard [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/download)
- pin current version (optional - to go back easily)

```bash
sudo ostree admin pin 0
```

- install

```bash
sudo bootc switch ghcr.io/itotm/horizon-os:latest
```

- reboot and login (**note**: the system will finish installing apps and reboot automatically)

## AI disclaimer

Some scripts written and/or modified by Claude and Copilot.

---

[![Build container image](https://github.com/itotm/horizon-os/actions/workflows/build.yml/badge.svg)](https://github.com/itotm/horizon-os/actions/workflows/build.yml)
