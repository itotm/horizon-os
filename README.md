# HorizonOS

![HorizonOS](./logo.png)

A custom bootc image built with Universal Blue template and based on Fedora Kinoite.

## Features

- [my](https://github.com/itotm) custom colors, icons, Plymouth theme, Plasma widgets
- [cli tools](./build_scripts/standard/1.packages.sh)
- media codecs from [RPM Fusion](https://rpmfusion.org/)
- [KDE apps](./build_scripts/standard/kde-apps.sh)
- [Apps](./sys_files/usr/libexec/horizon-install-flatpaks) from Flathub (removed Fedora flatpak repository)
- Cockpit, QEmu, Distrobox, VSCode, Syncthing and Tailscale preinstalled
- Italian locales and various dictionaries
- [Epson Perfection V200 Photo](./build_scripts/standard/epson-v200.sh) scanner driver (Image Scan! for Linux)
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

## Image signing

Every published image is signed with [cosign](https://github.com/sigstore/cosign); the public key is [horizon-os.pub](./sys_files/etc/pki/containers/horizon-os.pub). To check a tag before installing it:

```bash
cosign verify --key sys_files/etc/pki/containers/horizon-os.pub ghcr.io/itotm/horizon-os:latest
```

The image ships that key together with a [policy.json](./sys_files/etc/containers/policy.json) that only accepts signed `horizon-os` images from the three registries above (and accepts anything else, so Distrobox, Toolbox and Podman keep working). The stock Kinoite you install from has neither, so the very first `bootc switch` cannot be verified. From the first boot of HorizonOS on, the policy applies to every pull on the system, `bootc upgrade` included; to additionally make bootc refuse to run without such a policy, switch once more from inside HorizonOS:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/itotm/horizon-os:latest
```

## AI disclaimer

Some scripts written and/or modified by Claude and Copilot.

---

[![Latest build](https://github.com/itotm/horizon-os/actions/workflows/build.yml/badge.svg)](https://github.com/itotm/horizon-os/actions/workflows/build.yml)
