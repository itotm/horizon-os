#!/bin/bash
set -oue pipefail

mkdir -p /usr/lib/bootc/kargs.d

cat > /usr/lib/bootc/kargs.d/00-custom.toml <<EOF
kargs = ["amdgpu.sg_display=0", "amdgpu.dcdebugmask=0x10"]
EOF
