FROM alpine AS ctx
COPY build_scripts /
RUN chmod +x ./*.sh

FROM quay.io/fedora/fedora-kinoite:43

ARG BUILD_NUMBER=1
ENV BUILD_NUMBER=${BUILD_NUMBER}

LABEL org.opencontainers.image.title="HorizonOS"
LABEL org.opencontainers.image.description="Custom Fedora Kinoite image"
LABEL org.opencontainers.image.source="https://github.com/itotm/horizon-os"

ARG INSTALL_FLATHUB=false
ARG INSTALL_GIMP=false
ARG INSTALL_KDEAPPS=false
ARG INSTALL_LIBREOFFICE=false
ARG INSTALL_NOMACHINE=false
ARG INSTALL_QEMU=false
ARG INSTALL_RPMFUSION=false
ARG INSTALL_SUNSHINE=false
ARG INSTALL_THUNDERBIRD=false
ARG INSTALL_VLC=false
ARG INSTALL_WINE=false

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/start.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/packages.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh INSTALL_FLATHUB /ctx/flathub.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh INSTALL_GIMP /ctx/gimp.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh INSTALL_KDEAPPS /ctx/kde-apps.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh INSTALL_LIBREOFFICE /ctx/libreoffice.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh INSTALL_NOMACHINE /ctx/nomachine.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh INSTALL_QEMU /ctx/qemu.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh INSTALL_RPMFUSION /ctx/rpmfusion.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh INSTALL_SUNSHINE /ctx/sunshine.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh INSTALL_THUNDERBIRD /ctx/thunderbird.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh INSTALL_VLC /ctx/vlc.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/runner.sh INSTALL_WINE /ctx/wine.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache --mount=type=cache,dst=/var/log --mount=type=tmpfs,dst=/tmp \
    /ctx/end.sh

RUN bootc container lint
