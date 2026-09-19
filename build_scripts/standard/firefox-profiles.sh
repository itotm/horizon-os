#!/bin/bash
set -oue pipefail

# Firefox's selectable profiles (about:profilemanager) break on ostree systems
# where /home is a symlink to /var/home: the primary profile runs with the
# profile path derived from $HOME (/home/<user>/...), while secondary profiles
# are launched with "--profile <path>", which Firefox passes through realpath()
# (/var/home/<user>/...). The SelectableProfileService compares the two as
# strings, never finds the current profile in its database, and about:editprofile
# stays blank with the profile menu missing. Giving Firefox a canonical HOME
# makes both sides agree. The Fedora wrapper is a shell script, so the export
# goes there: .desktop files cannot expand variables and would not cover
# launches from a terminal or xdg-open anyway.
FIREFOX_WRAPPER="/usr/bin/firefox"
ANCHOR="^# Run the browser$"

if grep -q "HorizonOS: canonical HOME" "${FIREFOX_WRAPPER}"; then
    echo "Firefox wrapper already patched"
    exit 0
fi

if ! grep -q "${ANCHOR}" "${FIREFOX_WRAPPER}"; then
    echo "ERROR: anchor '${ANCHOR}' not found in ${FIREFOX_WRAPPER}, wrapper layout changed" >&2
    exit 1
fi

sed -i "/${ANCHOR}/i\\
# HorizonOS: canonical HOME so selectable profiles resolve to the same path\\
# whether opened from profiles.ini or with --profile (see /home -> /var/home).\\
if [ -n \"\$HOME\" ] && [ -d \"\$HOME\" ]; then\\
    HOME=\$(realpath \"\$HOME\") && export HOME\\
fi\\
" "${FIREFOX_WRAPPER}"

echo "Patched ${FIREFOX_WRAPPER}"
