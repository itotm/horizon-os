# HorizonOS

![HorizonOS](./logo.png)

A custom image based on Fedora Kinoite 43 and built with Universal Blue template.

**WARNING:** not (yet) ready, builds are unstable and experimental. Use at your own risk.

## Features

- a bunch of [cli tools](./build_scripts/standard/packages.sh)
- media codecs from [RPM Fusion](https://rpmfusion.org/)
- selected [KDE apps](./build_scripts/standard/kde-apps.sh)
- Cockpit, Tailscale, Sunshine, Thunderbird, VLC preinstalled
- dev tools: QEmu, dotnet, VSCode
- Flathub with selected [packages](./sys_files/usr/bin/horizon-install-flatpaks.sh)
- Syncthing as Quadlet
- my custom colors and icons
- scheduled to update weekly
- designed to be modular (fork the repo to try!)

![build action](./build-action.png)

## Howto

- install standard [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/download)
- upgrade

```bash
sudo rpm-ostree upgrade
```

- reboot
- pin current version (optional - to go back easily to standard Kinoite)

```bash
sudo ostree admin pin 0
```

- install

```bash
sudo bootc switch ghcr.io/itotm/horizon-os:latest
```

- reboot (**note**: after the first reboot, wait until Flatpak apps finish installing)

## Post install

- enable syncthing

```bash
horizon-enable-syncthing.sh
```

## TODO

Better post-install and post-update automation.

## AI disclaimer

Some scripts written and/or modified by Claude and Copilot.

---

[![Build container image](https://github.com/itotm/horizon-os/actions/workflows/build.yml/badge.svg)](https://github.com/itotm/horizon-os/actions/workflows/build.yml)

[![Build disk images](https://github.com/itotm/horizon-os/actions/workflows/build-disk.yml/badge.svg)](https://github.com/itotm/horizon-os/actions/workflows/build-disk.yml)