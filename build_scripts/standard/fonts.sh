#!/bin/bash
set -oue pipefail

FONT_PACKAGES=(
    abattis-cantarell-fonts
    adobe-source-sans-pro-fonts
    adobe-source-serif-pro-fonts
    adwaita-sans-fonts
    alerque-libertinus-fonts
    cascadia-code-fonts
    cascadia-mono-fonts
    fira-code-fonts
    fontawesome-fonts-all
    google-carlito-fonts
    google-crosextra-caladea-fonts
    google-roboto-fonts
    intel-one-mono-fonts
    jetbrains-mono-fonts
    lato-fonts
    liberation-fonts-all
    open-sans-fonts
    rsms-inter-fonts
    stix-fonts
)
dnf5 -y install "${FONT_PACKAGES[@]}"

TERRA_FONT_PACKAGES=(
    cleartype-fonts
    ms-core-fonts
    ms-core-tahoma-fonts
)
dnf5 -y install \
    --nogpgcheck \
    --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
    "${TERRA_FONT_PACKAGES[@]}"

# Selawik: Microsoft's open-source, metric-compatible stand-in for Segoe UI.
# The release zip also carries eot/svg/woff web copies; only the TTFs are kept.
curl -fsSL --retry 3 -o /tmp/selawik.zip \
    https://github.com/microsoft/Selawik/releases/download/1.01/Selawik_Release.zip
unzip -j /tmp/selawik.zip '*.ttf' -d /usr/share/fonts/selawik

# Documents and web pages asking for Segoe UI get Selawik. binding="same"
# makes it a metric alias, like Liberation for Arial in 30-metric-aliases.conf;
# Windows ships the lighter and semibold cuts as separate families, and so does
# Selawik, so each one is mapped to its counterpart.
cat > /usr/share/fontconfig/conf.avail/30-selawik-segoe-ui.conf <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <alias binding="same">
    <family>Segoe UI</family>
    <accept><family>Selawik</family></accept>
  </alias>
  <alias binding="same">
    <family>Segoe UI Light</family>
    <accept><family>Selawik Light</family></accept>
  </alias>
  <alias binding="same">
    <family>Segoe UI Semilight</family>
    <accept><family>Selawik Semilight</family></accept>
  </alias>
  <alias binding="same">
    <family>Segoe UI Semibold</family>
    <accept><family>Selawik Semibold</family></accept>
  </alias>
</fontconfig>
EOF
ln -s /usr/share/fontconfig/conf.avail/30-selawik-segoe-ui.conf /etc/fonts/conf.d/

# Latin Modern straight from GUST: Fedora's texlive-lm ships the same 72 OTF
# files but pulls in texlive-base, luatex and Perl (~87 MiB instead of ~7 MiB).
curl -fsSL --retry 3 -o /tmp/latin-modern.zip \
    https://www.gust.org.pl/projects/e-foundry/latin-modern/download/lm2.004otf.zip
unzip -j /tmp/latin-modern.zip '*.otf' -d /usr/share/fonts/latin-modern
