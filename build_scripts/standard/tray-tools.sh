#!/usr/bin/env bash
# HorizonOS build step: build & install tail-tray and/or kwin-minimize2tray
# from source (no COPR). Common deps are factored out, cleanup runs once.
#
# Sources:
#   https://github.com/SneWs/tail-tray
#   https://github.com/luisbocanegra/kwin-minimize2tray
set -euo pipefail

# ---------------------------------------------------------------------------
# Toggles: which components to build
# ---------------------------------------------------------------------------
BUILD_TAIL_TRAY="${BUILD_TAIL_TRAY:-1}"
BUILD_KWIN_MINIMIZE2TRAY="${BUILD_KWIN_MINIMIZE2TRAY:-1}"

# tail-tray specific options
KNOTIFICATIONS_ENABLED="${KNOTIFICATIONS_ENABLED:-ON}"
DAVFS_ENABLED="${DAVFS_ENABLED:-ON}"

WORK_DIR="/tmp/horizonos-src-build"
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"

# ---------------------------------------------------------------------------
# Dependencies
# ---------------------------------------------------------------------------
# Common to both (base toolchain)
COMMON_DEPS=(gcc-c++ cmake)

# tail-tray specific
TAIL_TRAY_DEPS=(
    clang
    qt6-qtbase-devel qt6-qttools-devel qt6-qtbase-private-devel
    extra-cmake-modules kf6-knotifications-devel
    davfs2
)

# kwin-minimize2tray specific
KWIN_M2T_DEPS=(
    extra-cmake-modules
    qt6-qtbase-devel qt6-qtdeclarative-devel
    kf6-kpackage-devel kf6-kwindowsystem-devel
    kf6-kconfig-devel kf6-kcoreaddons-devel
)

BUILD_DEPS=("${COMMON_DEPS[@]}")
[[ "${BUILD_TAIL_TRAY}" == "1" ]] && BUILD_DEPS+=("${TAIL_TRAY_DEPS[@]}")
[[ "${BUILD_KWIN_MINIMIZE2TRAY}" == "1" ]] && BUILD_DEPS+=("${KWIN_M2T_DEPS[@]}")

# Dedup while preserving order
mapfile -t BUILD_DEPS < <(printf '%s\n' "${BUILD_DEPS[@]}" | awk '!seen[$0]++')

if [[ "${BUILD_TAIL_TRAY}" != "1" && "${BUILD_KWIN_MINIMIZE2TRAY}" != "1" ]]; then
    echo "==> No component enabled (BUILD_TAIL_TRAY=0 and BUILD_KWIN_MINIMIZE2TRAY=0), exiting."
    exit 0
fi

echo "==> installing build dependencies: ${BUILD_DEPS[*]}"
dnf5 -y install "${BUILD_DEPS[@]}"

# ---------------------------------------------------------------------------
# Helper: resolve the latest release tag, fall back to a given branch
# ---------------------------------------------------------------------------
latest_tag() {
    local repo="$1" fallback_branch="$2" tag
    # Don't use curl -f / let it abort here: repos with no GitHub releases
    # return 404 on this endpoint, which must fall back to the branch
    # instead of killing the whole script under set -e.
    tag="$(curl -sSL "https://api.github.com/repos/${repo}/releases/latest" \
        | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name":\s*"([^"]+)".*/\1/' || true)"
    [[ -z "${tag}" ]] && tag="${fallback_branch}"
    echo "${tag}"
}

# ---------------------------------------------------------------------------
# tail-tray
# ---------------------------------------------------------------------------
build_tail_tray() {
    local repo="SneWs/tail-tray"
    local src="${WORK_DIR}/tail-tray"
    local tag
    tag="$(latest_tag "${repo}" "master")"
    echo "==> [tail-tray] building tag: ${tag}"

    git clone --depth 1 --branch "${tag}" "https://github.com/${repo}.git" "${src}"

    cmake -B "${src}/build" -S "${src}" \
        -DKNOTIFICATIONS_ENABLED="${KNOTIFICATIONS_ENABLED}" \
        -DDAVFS_ENABLED="${DAVFS_ENABLED}" \
        -DCMAKE_BUILD_TYPE=Release

    cmake --build "${src}/build" --config Release -- -j"$(nproc)"
    cmake --install "${src}/build"

    echo "==> [tail-tray] installed: $(command -v tail-tray || echo /usr/local/bin/tail-tray)"
}

# ---------------------------------------------------------------------------
# kwin-minimize2tray
# ---------------------------------------------------------------------------
build_kwin_minimize2tray() {
    local repo="luisbocanegra/kwin-minimize2tray"
    local src="${WORK_DIR}/kwin-minimize2tray"
    local tag
    tag="$(latest_tag "${repo}" "main")"
    echo "==> [kwin-minimize2tray] building tag: ${tag}"

    git clone --depth 1 --branch "${tag}" "https://github.com/${repo}.git" "${src}"

    cmake -B "${src}/build" -S "${src}" \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_PLUGIN=ON \
        -DINSTALL_SCRIPT=ON

    cmake --build "${src}/build" --config Release -- -j"$(nproc)"
    cmake --install "${src}/build"

    cat <<'EOF'
==> [kwin-minimize2tray] installed system-wide. The KWin Script still needs
    to be ENABLED per-user (kwinrc config, no system-wide default exists):
      kwriteconfig6 --file kwinrc --group Plugins --key minimize2trayEnabled true
      qdbus org.kde.KWin /KWin reconfigure
    Check the exact "Plugin Id" in the repo's package/metadata.json after the build.
EOF
}

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------
[[ "${BUILD_TAIL_TRAY}" == "1" ]] && build_tail_tray
[[ "${BUILD_KWIN_MINIMIZE2TRAY}" == "1" ]] && build_kwin_minimize2tray

# ---------------------------------------------------------------------------
# Single final cleanup
# ---------------------------------------------------------------------------
echo "==> removing build-only dependencies (keep runtime libs)"
DEVEL_DEPS=()
for d in "${BUILD_DEPS[@]}"; do
    [[ "${d}" == "git" ]] && continue   # often needed by other steps, don't force-remove
    DEVEL_DEPS+=("${d}")
done
dnf5 -y remove "${DEVEL_DEPS[@]}" || true

echo "==> cleaning up source/build tree and dnf cache"
rm -rf "${WORK_DIR}"

echo "==> done."