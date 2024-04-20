# syntax=docker/dockerfile:1
FROM alpine

# set version label
LABEL maintainer="Clion Nieh <76857061@qq.com>"

# install packages
RUN set -eux; \
  #install build packages
  apk add --no-cache \
  openrc \
  ffmpeg \
  jellyfin \
  jellyfin-web \
  mesa-va-gallium \
  font-noto-cjk-extra; \

  # set jellyfin start when container run
  rc-update add jellyfin default; \
  \
  # Make dir for config and data
  mkdir -p /config; \
  chown jellyfin:jellyfin /config

# add local files
COPY  --chmod=755 root/ /

# set entrypoint
ENTRYPOINT ["/init"]

# ports and volumes
EXPOSE 8096 8920
VOLUME /config

CMD ["default"]
