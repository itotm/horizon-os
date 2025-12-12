#!/bin/bash
set -oue pipefail

URL="https://www.hamrick.com/files/iscan-gt-f670-bundle-2.30.4.x64.rpm.tar.gz"
ARCHIVE="iscan-gt-f670-bundle-2.30.4.x64.rpm.tar.gz"
DIR="iscan-gt-f670-bundle-2.30.4.x64.rpm"

curl -LO "$URL"
tar xzf "$ARCHIVE"

find "$DIR" -type f -name '*.rpm' > /tmp/epson-v200-rpms.txt

dnf5 -y install --nogpgcheck $(cat /tmp/epson-v200-rpms.txt)

rm -f /tmp/epson-v200-rpms.txt
rm -rf "$ARCHIVE" "$DIR"
