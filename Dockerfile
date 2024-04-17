# syntax=docker/dockerfile:1

FROM alpine

# set version label
LABEL maintainer="Clion Nieh <76857061@qq.com>"

# environment settings
# ENV BRANCH v3.12 

# install packages
RUN set -eux; \
  #install build packages
  apk add --no-cache \
  ffmpeg \
  jellyfin \
  jellyfin-web \
  jellyfin-openrc \
  mesa-va-gallium \
  font-noto-cjk-extra; \
  \
  # Make dir for config and data
  mkdir -p /config; \
  \
  # Add user for php process
  #adduser -u 1000 -D -S -G jellyfin jellyfin; \
  #\
  chown jellyfin:jellyfin /config; \
  \
  # configure jellyfin
  sed -i "s#\/var\/log#\/config\/log#g" \
    /etc/conf.d/jellyfin; \
  sed -i "s#\/var\/lib\/jellyfin#\/config\/data#g" \
    /etc/conf.d/jellyfin; \
  sed -i "s#--nowebclient##g" \
    /etc/conf.d/jellyfin

# add local files
#COPY  --chmod=755 root/ /usr/local/bin

# set entrypoint
ENTRYPOINT ["/etc/init.d/jellyfin"]

# ports and volumes
EXPOSE 8096 8920
VOLUME /config

CMD ["--ffmpeg=/usr/bin/ffmpeg"]
