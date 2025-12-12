#!/bin/bash
set -oue pipefail

URL="https://www.hamrick.com/files/iscan-gt-f670-bundle-2.30.4.x64.rpm.tar.gz"
ARCHIVE="iscan-gt-f670-bundle-2.30.4.x64.rpm.tar.gz"
DIR="iscan-gt-f670-bundle-2.30.4.x64.rpm"

curl -LO "$URL"
tar xzf "$ARCHIVE"

rpm --nosignature --nodigest -i $(find "$DIR" -type f -name '*.rpm')

rm -rf "$ARCHIVE" "$DIR"
