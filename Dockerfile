# syntax=docker/dockerfile:1

# Docker build arguments
ARG DOTNET_VERSION
ARG JELLYFIN_VERSION
ARG MEDIASDK_VERSION
ARG FFMPEG_VERSION

FROM mcr.microsoft.com/dotnet/sdk:$DOTNET_VERSION-alpine AS server

ARG DOTNET_CLI_TELEMETRY_OPTOUT=1

ADD https://github.com/jellyfin/jellyfin/archive/refs/tags/v$JELLYFIN_VERSION.tar.gz /tmp/jellyfin.tar.gz

WORKDIR /tmp/jellyfin

RUN set -ex; \
    tar xf /tmp/jellyfin.tar.gz --strip-components=1; \
    dotnet publish \
        Jellyfin.Server \
        --self-contained \
        --configuration Release \
        --runtime linux-musl-x64 \
        --output=/server \
        "-p:DebugSymbols=false" \
        "-p:DebugType=none" \
    ; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/* \
        ;

FROM node:lts-alpine AS web

ADD https://github.com/jellyfin/jellyfin-web/archive/refs/tags/v$JELLYFIN_VERSION.tar.gz /tmp/jellyfin-web.tar.gz

WORKDIR /tmp/jellyfin-web

RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
        alpine-sdk \
        autoconf \
        automake \
        g++ \
        gcc \
        gifsicle \
        libpng-dev \
        libtool \
        make \
        musl-dev \
        nasm \
        python3 \
    ; \
    tar xf ../jellyfin-web.tar.gz --strip-components=1; \
    npm ci --no-audit --unsafe-perm; \
    npm run build:production; \
    apk del --no-network .build-deps; \
    mv dist /web; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/* \
        ;

FROM alpine as ffmpeg

ARG FFMPEG_URL="https://repo.jellyfin.org/files/ffmpeg/linux/latest-${FFMPEG_VERSION:0:1}.x/amd64/jellyfin-ffmpeg_${FFMPEG_VERSION}_portable_linux64-gpl.tar.xz"

ADD $FFMPEG_URL /tmp/jellyfin-ffmpeg.tar.xz

WORKDIR /tmp

RUN set -ex; \
    tar -xvf jellyfin-ffmpeg.tar.xz -C jellyfin-ffmpeg; \
    mv jellyfin-ffmpeg /ffmpeg; \
    rm -rf \
        /var/tmp/* \
        /tmp/* \
        ;

FROM clion007/alpine

LABEL mantainer="Clion Nihe Email: clion007@126.com"

ARG BRANCH="edge"

# Default environment variables for the Jellyfin invocation
ENV JELLYFIN_LOG_DIR=/config/log \
    JELLYFIN_DATA_DIR=/config/data \
    JELLYFIN_CACHE_DIR=/config/cache \
    JELLYFIN_CONFIG_DIR=/config/config \
    JELLYFIN_WEB_DIR=/usr/share/jellyfin-web \
    XDG_CACHE_HOME=${JELLYFIN_CACHE_DIR}

# https://github.com/dlemstra/Magick.NET/issues/707#issuecomment-785351620
ENV MALLOC_TRIM_THRESHOLD_=131072

# add jellyfin and jellyfin-web files
COPY --from=server /server /usr/lib/jellyfin
COPY --from=web /web /usr/share/jellyfin-web
COPY --from=ffmpeg /ffmpeg /usr/lib/jellyfin-ffmpeg

# install packages
RUN set -eux; \
  #install build packages
  apk add --no-cache \
    --repository=http://dl-cdn.alpinelinux.org/alpine/$BRANCH/main \
    --repository=http://dl-cdn.alpinelinux.org/alpine/$BRANCH/testing \
    --repository=http://dl-cdn.alpinelinux.org/alpine/$BRANCH/community \
    opencl \
    gcompat \
    libintl \
    su-exec \
    icu-libs \
    icu-data-full \
    chromaprint-libs \
    intel-media-sdk \
    libva-intel-driver \
    intel-media-driver \
    font-noto-cjk-extra \
    ; \

  # set jellyfin process user and group
  mv /usr/lib/jellyfin/jellyfin /usr/bin/jellyfin; \
  chown jellyfin:jellyfin /usr/bin/jellyfin; \
  
  # make dir for config and data
  mkdir -p /config; \
  chmod 777 /config; \
  chown jellyfin:jellyfin /config;

# add local files
COPY --chmod=755 root/ /

# ports
EXPOSE 8096 8920 7359/udp 1900/udp

# entrypoint set in clion007/alpine base image
CMD ["--ffmpeg=/usr/lib/jellyfin-ffmpeg/ffmpeg"]
