#!/bin/bash
set -oue pipefail

URL="https://www.hamrick.com/files/iscan-gt-f670-bundle-2.30.4.x64.rpm.tar.gz"
ARCHIVE="iscan-gt-f670-bundle-2.30.4.x64.rpm.tar.gz"
DIR="iscan-gt-f670-bundle-2.30.4.x64.rpm"

curl -LO "$URL"
tar xzf "$ARCHIVE"

rpm --nosignature --nodigest -i $(find "$DIR" -type f -name 'iscan-data-*.noarch.rpm' | sort)
rpm --nosignature --nodigest -i $(find "$DIR" -type f -name 'iscan-*.x86_64.rpm' ! -name 'iscan-plugin-gt-f670-*.x86_64.rpm' | sort)
rpm --nosignature --nodigest -i $(find "$DIR" -type f -name 'iscan-plugin-gt-f670-*.x86_64.rpm' | sort)

rm -rf "$ARCHIVE" "$DIR"
