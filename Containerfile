ARG FEDORA_VERSION=44
ARG ENABLE_COMMON=true
ARG ENABLE_STANDARD=true
ARG ENABLE_VIRTTOOLS=true
ARG ENABLE_DEVTOOLS=true
ARG ENABLE_EXPERIMENTAL=false
ARG DISABLE_REPOS=true

FROM alpine AS ctx
COPY build_scripts /
RUN find . -name "*.sh" -exec chmod +x {} \;
COPY sys_files sys_files
RUN chmod +x ./sys_files/usr/libexec/horizon-*

FROM quay.io/fedora/fedora-kinoite:${FEDORA_VERSION}

ARG IMAGE_VERSION=20251125
ENV IMAGE_VERSION=${IMAGE_VERSION}
ARG BUILD_NUMBER=1
ENV BUILD_NUMBER=${BUILD_NUMBER}
ENV FEDORA_VERSION=${FEDORA_VERSION}
ENV DISABLE_REPOS=${DISABLE_REPOS}

ARG ENABLE_COMMON
ARG ENABLE_STANDARD
ARG ENABLE_VIRTTOOLS
ARG ENABLE_DEVTOOLS
ARG ENABLE_EXPERIMENTAL
ARG DISABLE_REPOS

LABEL org.opencontainers.image.title="HorizonOS"
LABEL org.opencontainers.image.description="Custom Fedora Kinoite image"
LABEL org.opencontainers.image.source="https://github.com/itotm/horizon-os"

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_STANDARD /ctx/standard/1

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_STANDARD /ctx/standard/2

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_STANDARD /ctx/standard/3

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_STANDARD /ctx/standard/4

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_STANDARD /ctx/standard/5

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_STANDARD /ctx/standard/6

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_STANDARD /ctx/standard/7

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_VIRTTOOLS /ctx/virttools/1

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_VIRTTOOLS /ctx/virttools/2

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_DEVTOOLS /ctx/devtools/1

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_DEVTOOLS /ctx/devtools/2

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_EXPERIMENTAL /ctx/experimental

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh ENABLE_COMMON /ctx/common.sh

RUN bootc container lint
