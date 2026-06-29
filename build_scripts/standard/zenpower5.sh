#!/bin/bash
# build_scripts/zenpower5.sh
# Builds and installs the zenpower5 kernel module into the HorizonOS bootc image.
# Source: https://github.com/mattkeenan/zenpower5
#
# Steps:
#  1. Install build tools (kernel-devel, gcc, make)
#  2. Clone zenpower5 source at a pinned commit/branch
#  3. Build the module for every kernel version found in /usr/lib/modules/
#  4. Install the .ko in the correct location and run depmod
#  5. Blacklist k10temp (required: it uses the same PCI device as zenpower)
#  6. Enable automatic module loading at boot
#  7. Remove build tools to keep the image clean

set -oue pipefail

# ── Pinned version/commit ─────────────────────────────────────────────────────
# Update ZENPOWER5_REF to a specific commit SHA for reproducible builds.
# Leaving it as "master" always pulls the latest commit (not reproducible).
ZENPOWER5_REF="master"
ZENPOWER5_REPO="https://github.com/mattkeenan/zenpower5.git"
BUILD_DIR="/tmp/zenpower5-build"

# ── 1. Build dependencies ─────────────────────────────────────────────────────
echo ">>> Installing build dependencies..."
dnf5 -y install \
    kernel-devel \
    gcc \
    gcc-c++ \
    make \
    git

# ── 2. Clone source ───────────────────────────────────────────────────────────
echo ">>> Cloning zenpower5 (ref: ${ZENPOWER5_REF})..."
mkdir -p "${BUILD_DIR}"
git clone --depth=1 --branch "${ZENPOWER5_REF}" "${ZENPOWER5_REPO}" "${BUILD_DIR}/zenpower5" \
    || git clone --depth=1 "${ZENPOWER5_REPO}" "${BUILD_DIR}/zenpower5"

cd "${BUILD_DIR}/zenpower5"
ZENPOWER5_COMMIT=$(git rev-parse --short HEAD)
echo ">>> Actual commit: ${ZENPOWER5_COMMIT}"

# ── 3 & 4. Build and install for every kernel present ────────────────────────
# bootc/ostree builds can have more than one kernel under /usr/lib/modules/.
# The loop ensures the module is compiled for all of them.
BUILT_COUNT=0

for KERNEL_VERSION in $(ls -1 /usr/lib/modules/); do
    KERNEL_BUILD_DIR="/usr/lib/modules/${KERNEL_VERSION}/build"

    if [ ! -d "${KERNEL_BUILD_DIR}" ]; then
        echo ">>> Skipping ${KERNEL_VERSION}: build directory not found (kernel-devel missing?)"
        continue
    fi

    echo ">>> Building for kernel ${KERNEL_VERSION}..."

    # Clean any leftover build artifacts
    make -C "${BUILD_DIR}/zenpower5" clean 2>/dev/null || true

    # Build against the installed kernel tree
    make -C "${KERNEL_BUILD_DIR}" M="${BUILD_DIR}/zenpower5" modules

    # Destination matches the path declared in upstream dkms.conf
    DEST_DIR="/usr/lib/modules/${KERNEL_VERSION}/kernel/drivers/hwmon/zenpower"
    mkdir -p "${DEST_DIR}"

    # Compress and install all produced .ko files.
    # We compress the source .ko first, verify integrity, then install —
    # this avoids the corrupted .ko.xz that results from compressing in-place
    # after copying (xz -f with 2>/dev/null was hiding failures).
    for KO_FILE in "${BUILD_DIR}/zenpower5"/*.ko; do
        [ -f "${KO_FILE}" ] || continue

        echo ">>> Compressing ${KO_FILE}..."
        xz -f -k "${KO_FILE}"          # -k keeps the original .ko as fallback
        XZ_FILE="${KO_FILE}.xz"

        # Verify the compressed file is valid before installing
        if xz --test "${XZ_FILE}"; then
            echo ">>> Installing ${XZ_FILE} -> ${DEST_DIR}/"
            install -m 644 "${XZ_FILE}" "${DEST_DIR}/"
        else
            echo "WARNING: xz integrity check failed for ${XZ_FILE}, installing uncompressed .ko"
            install -m 644 "${KO_FILE}" "${DEST_DIR}/"
        fi
    done

    echo ">>> Running depmod for ${KERNEL_VERSION}..."
    depmod -a "${KERNEL_VERSION}"

    BUILT_COUNT=$((BUILT_COUNT + 1))
done

if [ "${BUILT_COUNT}" -eq 0 ]; then
    echo "ERROR: no kernel was built. Make sure kernel-devel is installed."
    exit 1
fi

echo ">>> Module built for ${BUILT_COUNT} kernel(s)."

# ── 5. Blacklist k10temp ──────────────────────────────────────────────────────
# zenpower uses the same PCI device as k10temp; they cannot coexist.
echo ">>> Blacklisting k10temp..."
mkdir -p /etc/modprobe.d
cat > /etc/modprobe.d/zenpower5.conf << 'EOF'
# zenpower5 uses the same PCI device as the built-in k10temp driver.
# k10temp must be disabled for zenpower5 to work.
blacklist k10temp
EOF

# ── 6. Enable automatic loading at boot ──────────────────────────────────────
echo ">>> Enabling automatic loading of zenpower at boot..."
mkdir -p /etc/modules-load.d
echo "zenpower" > /etc/modules-load.d/zenpower5.conf

# ── 7. Cleanup ────────────────────────────────────────────────────────────────
echo ">>> Removing build directory..."
cd /
rm -rf "${BUILD_DIR}"

echo ">>> Removing build dependencies..."
dnf5 -y remove \
    kernel-devel \
    gcc \
    gcc-c++ \
    make \
    git \
    || true   # do not fail if some packages were already present before this script

echo ""
echo ">>> zenpower5 installed successfully (commit: ${ZENPOWER5_COMMIT})"
echo "    - Module:    /usr/lib/modules/<kernel>/kernel/drivers/hwmon/zenpower/"
echo "    - Blacklist: /etc/modprobe.d/zenpower5.conf  (k10temp blacklisted)"
echo "    - Autoload:  /etc/modules-load.d/zenpower5.conf"
echo ""
echo "    After booting, run 'sensors' (lm-sensors) to verify the output."
