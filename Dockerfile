# syntax=docker/dockerfile:1

# Docker build arguments
ARG DOTNET_VERSION

# build jellyfin server
FROM mcr.microsoft.com/dotnet/sdk:$DOTNET_VERSION-alpine AS server

ARG JELLYFIN_VERSION
ARG DOTNET_CLI_TELEMETRY_OPTOUT=1

WORKDIR /tmp/jellyfin

ADD https://github.com/jellyfin/jellyfin/archive/refs/tags/v$JELLYFIN_VERSION.tar.gz /tmp/jellyfin.tar.gz

RUN set -ex; \
    tar xf ../jellyfin.tar.gz --strip-components=1; \
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

# build jellyfin-web client
FROM node:lts-alpine AS web

ARG JELLYFIN_VERSION

ENV JELLYFIN_VERSION=${JELLYFIN_VERSION}

WORKDIR /tmp/jellyfin-web

ADD https://github.com/jellyfin/jellyfin-web/archive/refs/tags/v$JELLYFIN_VERSION.tar.gz /tmp/jellyfin-web.tar.gz

RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
      autoconf \
      g++ \
      make \
      libpng-dev \
      gifsicle \
      alpine-sdk \
      automake \
      libtool \
      gcc \
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

# build jellyfin-ffmpeg
FROM alpine as ffmpeg

ARG MEDIASDK_VERSION
ARG FFMPEG_VERSION
ARG FFMPEG_PREFIX=/usr/lib/jellyfin-ffmpeg

ADD https://github.com/Intel-Media-SDK/MediaSDK/archive/refs/tags/v$MEDIASDK_VERSION.tar.gz /tmp/intel-mediasdk.tar.gz
ADD https://github.com/jellyfin/jellyfin-ffmpeg/archive/refs/tags/v$FFMPEG_VERSION.tar.gz /tmp/jellyfin-ffmpeg.tar.gz

RUN set -ex; \
    apk add --no-cache --upgrade \
        autoconf \
        automake \
        alpine-sdk \
        bash \
        ca-certificates \
        cmake \
        coreutils \
        cunit-dev \
        curl \
        dos2unix \
        g++ \
        gcc \
        libtool \
        musl \
        nasm \
        python3 \
        tzdata \
        unzip \
        yasm \
        cunit-dev \
        dav1d-dev \
        fdk-aac-dev \
        ffmpeg-libs \
        ffmpeg-dev \
        fontconfig-dev \
        freetype-dev \
        fribidi-dev \
        lame-dev \
        libass-dev \
        libbluray-dev \
        libdrm-dev \
        libogg-dev \
        libpng-dev \
        libtheora-dev \
        libvorbis-dev \
        libvpx-dev \
        libwebp-dev \
        mesa-dev \
        openssl-dev \
        opus-dev \
        util-linux-dev \
        x264-dev \
        x265-dev \
        intel-media-driver-dev \
        libva-dev \
        libva-intel-driver \
    ; 

WORKDIR /tmp/intel-mediasdk

RUN set -ex; \
    tar xf ../mediasdk.tar.gz --strip-components=1; \
    mkdir build; \
    cd build; \
    cmake \
        -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DENABLE_X11=OFF \
        -DBUILD_SAMPLES=OFF \
        -DBUILD_TUTORIALS=OFF \
        ../; \
    make -j $(nproc); \
    make -j $(nproc) install;

WORKDIR /tmp/jellyfin-ffmpeg

RUN set -ex; \
    tar xf ../jellyfin-ffmpeg.tar.gz --strip-components=1; \
    cat debian/patches/*.patch | patch -p1;
    ./configure \
      --prefix=$FFMPEG_PREFIX \
      --target-os=linux \
      --extra-version=Jellyfin \
      --cc=musl-gcc \
      --cxx=musl-g++ \
      --ar=musl-ar \
      --ranlib=musl-ranlib \
      --disable-asm \
      --disable-doc \
      --disable-ffplay \
      --disable-librtmp \
      --disable-libxcb \
      --disable-sdl2 \
      --disable-shared \
      --disable-xlib \
      --enable-chromaprint \
      --enable-gmp \
      --enable-gpl \
      --enable-libass \
      --enable-libbluray \
      --enable-libdav1d \
      --enable-libdrm \
      --enable-libfontconfig \
      --enable-libfreetype \
      --enable-libfribidi \
      --enable-libmfx \
      --enable-libmp3lame \
      --enable-libopenmpt \
      --enable-libopus \
      --enable-libplacebo \
      --enable-libshaderc \
      --enable-libtheora \
      --enable-libvorbis \
      --enable-libvpl \
      --enable-libvpx \
      --enable-libwebp \
      --enable-libx264 \
      --enable-libx265 \
      --enable-libzimg \
      --enable-opencl \
      --enable-openssl \
      --enable-pic \
      --enable-pthreads \
      --enable-static \
      --enable-vaapi \
      --enable-version3 \
      --enable-vulkan \
    ; \
    make -j $(nproc) install /ffmpeg; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/* \
    ;

# Build the final combined image
FROM clion007/alpine

LABEL mantainer="Clion Nihe Email: clion007@126.com"

ARG BRANCH="edge"
ARG JELLYFIN_PATH=/usr/lib/jellyfin
ARG JELLYFIN_WEB_PATH=/usr/share/jellyfin-web
ARG JELLYFIN_FFMPEG_PATH=/usr/lib/jellyfin-ffmpeg

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
COPY --from=server /server $JELLYFIN_PATH
COPY --from=web /web $JELLYFIN_WEB_PATH
COPY --from=ffmpeg /ffmpeg $JELLYFIN_FFMPEG_PATH

# install packages
RUN set -ex; \
  apk add --no-cache \
    --repository=http://dl-cdn.alpinelinux.org/alpine/$BRANCH/main \
    --repository=http://dl-cdn.alpinelinux.org/alpine/$BRANCH/testing \
    --repository=http://dl-cdn.alpinelinux.org/alpine/$BRANCH/community \
    su-exec \
    icu-libs \
    # jellyfin-ffmpeg \
    libva-intel-driver \
    intel-media-driver \
    font-noto-cjk-extra \
  ; \
  apk add --no-cache --virtual .user-deps \
    shadow \
  ; \
  \
  # set jellyfin process user and group
  groupadd -g 101 jellyfin; \
  useradd -u 100 -s /bin/nologin -M -g 101 jellyfin; \
  ln -s /usr/lib/jellyfin/jellyfin /usr/bin/jellyfin; \
  chown jellyfin:jellyfin /usr/bin/jellyfin; \
  \
  # make dir for config and data
  mkdir -p /config; \
  chmod 777 /config; \
  chown jellyfin:jellyfin /config; \
  \
  apk del --no-network .user-deps; \
  rm -rf \
      /var/cache/apk/* \
      /var/tmp/* \
      /tmp/* \
      ;

# add local files
COPY --chmod=755 root/ /

# ports
EXPOSE 8096 8920 7359/udp 1900/udp

# entrypoint set in clion007/alpine base image
CMD ["--ffmpeg=/usr/lib/jellyfin-ffmpeg/ffmpeg"]
