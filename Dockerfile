# syntax=docker/dockerfile:1
FROM clion007/alpine

LABEL mantainer="Clion Nihe Email: clion007@126.com"

ARG BRANCH=edge
ENV JELLYFIN_LOG_DIR=/config/log \
    JELLYFIN_DATA_DIR=/config/data \
    JELLYFIN_CACHE_DIR=/config/cache \
    JELLYFIN_CONFIG_DIR=/config/config \
    JELLYFIN_WEB_DIR=/usr/share/webapps/jellyfin-web \
    XDG_CACHE_HOME=${JELLYFIN_CACHE_DIR}

# install packages
RUN set -eux; \
  #install build packages
  apk add --no-cache \
    --repository=http://dl-cdn.alpinelinux.org/alpine/$BRANCH/main \
    --repository=http://dl-cdn.alpinelinux.org/alpine/$BRANCH/community \
  opencl \
  su-exec \
  jellyfin \
  jellyfin-web \
  intel-media-sdk \
  libva-intel-driver \
  intel-media-driver \
  font-noto-cjk-extra; \

  # set jellyfin process user and group
  chown jellyfin:jellyfin /usr/bin/jellyfin; \
  
  # make dir for config and data
  mkdir -p /config; \
  chown jellyfin:jellyfin /config;

# add local files
COPY --chmod=755 root/ /

# ports
EXPOSE 8096 8920 7359/udp 1900/udp

# entrypoint /init set in clion007/alpine base image
CMD ["--ffmpeg=/usr/bin/ffmpeg"]
