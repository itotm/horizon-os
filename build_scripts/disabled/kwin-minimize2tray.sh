#!/usr/bin/env bash
# HorizonOS build step: build & install kwin-minimize2tray from source (no COPR).
#
# Source: https://github.com/luisbocanegra/kwin-minimize2tray
set -euo pipefail

WORK_DIR="/tmp/horizonos-src-build"
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"

# ---------------------------------------------------------------------------
# Dependencies
# ---------------------------------------------------------------------------
BUILD_DEPS=(
    git gcc-c++ cmake
    extra-cmake-modules
    qt6-qtbase-devel qt6-qtdeclarative-devel
    kf6-kpackage-devel kf6-kwindowsystem-devel
    kf6-kconfig-devel kf6-kcoreaddons-devel
    kf6-kstatusnotifieritem-devel kf6-kservice-devel
)

echo "==> installing build dependencies: ${BUILD_DEPS[*]}"
dnf5 -y install "${BUILD_DEPS[@]}"

# ---------------------------------------------------------------------------
# Resolve latest release tag, fall back to a given branch
# ---------------------------------------------------------------------------
latest_tag() {
    local repo="$1" fallback_branch="$2" tag
    tag="$(curl -sSL "https://api.github.com/repos/${repo}/releases/latest" \
        | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name":\s*"([^"]+)".*/\1/' || true)"
    [[ -z "${tag}" ]] && tag="${fallback_branch}"
    echo "${tag}"
}

# ---------------------------------------------------------------------------
# Build kwin-minimize2tray
# ---------------------------------------------------------------------------
REPO="luisbocanegra/kwin-minimize2tray"
SRC="${WORK_DIR}/kwin-minimize2tray"

TAG="$(latest_tag "${REPO}" "main")"
echo "==> [kwin-minimize2tray] building tag: ${TAG}"

git clone --depth 1 --branch "${TAG}" "https://github.com/${REPO}.git" "${SRC}"

cmake -B "${SRC}/build" -S "${SRC}" \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_PLUGIN=ON \
    -DINSTALL_SCRIPT=ON

cmake --build "${SRC}/build" --config Release -- -j"$(nproc)"
cmake --install "${SRC}/build"

cat <<'EOF'
==> [kwin-minimize2tray] installed system-wide. The KWin Script still needs
    to be ENABLED per-user (kwinrc config, no system-wide default exists):
      kwriteconfig6 --file kwinrc --group Plugins --key minimize2trayEnabled true
      qdbus org.kde.KWin /KWin reconfigure
    Check the exact "Plugin Id" in the repo's package/metadata.json after the build.
EOF

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------
echo "==> removing build-only dependencies (keep runtime libs)"
DEVEL_DEPS=()
for d in "${BUILD_DEPS[@]}"; do
    [[ "${d}" == "git" ]] && continue
    DEVEL_DEPS+=("${d}")
done
dnf5 -y remove "${DEVEL_DEPS[@]}" || true

echo "==> cleaning up source/build tree and dnf cache"
rm -rf "${WORK_DIR}"
dnf5 -y clean all

echo "==> done."
