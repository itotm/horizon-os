# HorizonOS

![HorizonOS](./logo.png)

A custom bootc image built with Universal Blue template and based on Fedora Kinoite.

## Features

- [my](https://github.com/itotm) custom colors, icons, Plymouth theme, Plasma widgets
- [cli tools](./build_scripts/standard/1/packages-core.sh)
- media codecs from [RPM Fusion](https://rpmfusion.org/)
- [KDE apps](./build_scripts/standard/4/kde-apps.sh)
- [Apps](./sys_files/usr/libexec/horizon-install-flatpaks) from Flathub (removed Fedora flatpak repository)
- Cockpit, QEmu, Distrobox, VSCode, Syncthing and Tailscale preinstalled
- Italian locales and various dictionaries
- scheduled to update weekly
- designed to be modular (fork the repo to try!)

![build action](./build-action.png)

## Howto

- install [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/download)
- pin current version (optional - to go back easily)

```bash
sudo ostree admin pin 0
```

- install

```bash
sudo bootc switch ghcr.io/itotm/horizon-os:latest

# or one of these
sudo bootc switch docker.io/itotm/horizon-os:latest
sudo bootc switch quay.io/itotm/horizon-os:latest
```

- reboot and login (**note**: the system will finish installing apps and reboot automatically)

## AI disclaimer

Some scripts written and/or modified by Claude and Copilot.

---

[![Latest build](https://github.com/itotm/horizon-os/actions/workflows/build.yml/badge.svg)](https://github.com/itotm/horizon-os/actions/workflows/build.yml)
