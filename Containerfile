ARG FEDORA_VERSION=latest

ARG ENABLE_COMMON=false
ARG ENABLE_STANDARD=false
ARG ENABLE_EXTENDED=false
ARG ENABLE_DEVTOOLS=false
ARG ENABLE_EXPERIMENTAL=false
ARG ENABLE_TESTING=false
ARG DISABLE_REPOS=true

FROM alpine AS ctx
COPY build_scripts /
RUN chmod +x ./*.sh

FROM quay.io/fedora/fedora-kinoite:${FEDORA_VERSION}

ARG BUILD_NUMBER=1
ENV BUILD_NUMBER=${BUILD_NUMBER}
ENV DISABLE_REPOS=${DISABLE_REPOS}

ARG ENABLE_COMMON
ARG ENABLE_STANDARD
ARG ENABLE_EXTENDED
ARG ENABLE_DEVTOOLS
ARG ENABLE_EXPERIMENTAL
ARG ENABLE_TESTING
ARG DISABLE_REPOS

LABEL org.opencontainers.image.title="HorizonOS"
LABEL org.opencontainers.image.description="Custom Fedora Kinoite image"
LABEL org.opencontainers.image.source="https://github.com/itotm/horizon-os"

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_STANDARD /ctx/standard/packages.sh
RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_STANDARD /ctx/standard/cockpit.sh
RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_STANDARD /ctx/standard/syncthing.sh
RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_STANDARD /ctx/standard/tailscale.sh
RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_STANDARD /ctx/standard/kde-apps.sh
RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_STANDARD /ctx/standard/rpmfusion.sh
RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_STANDARD /ctx/standard/thunderbird.sh
RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_STANDARD /ctx/standard/vlc.sh
RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_STANDARD /ctx/standard/sunshine.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_EXTENDED /ctx/extended/gimp.sh
RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_EXTENDED /ctx/extended/libreoffice.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_EXPERIMENTAL /ctx/experimental/nomachine.sh
RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_EXPERIMENTAL /ctx/experimental/wine.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_DEVTOOLS /ctx/devtools/qemu.sh
RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_DEVTOOLS /ctx/devtools/dotnet.sh
RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_DEVTOOLS /ctx/devtools/vscode.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_COMMON /ctx/common.sh

RUN bootc container lint
