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
  jellyfin-web \; \
  \
  # Make dir for config and data
  mkdir -p /config; \
  \
  # Add user for php process
  adduser -u 1000 -D -S -G jellyfin jellyfin; \
  \
  chown jellyfin:jellyfin /config; \
  \
  # guarantee correct ffmpeg for jellyfin web client player
  
  \
  # configure jellyfin
  sed -i "s#;error_log = log/php7/error.log.*#error_log = /config/log/php/php73/error.log#g" \
    /etc/php7/php-fpm.conf; \
  sed -i "s#user = nobody.*#user = www-data#g" \
    /etc/php7/php-fpm.d/www.conf; \
  sed -i "s#group = nobody.*#group = www-data#g" \
    /etc/php7/php-fpm.d/www.conf; \
  sed -i "s#listen = 127.0.0.1:9000.*#listen = 0.0.0.0:9000#g" \
    /etc/php7/php-fpm.d/www.conf

# add local files
COPY  --chmod=755 root/ /usr/local/bin

# set entrypoint
ENTRYPOINT ["init"]

# ports and volumes
EXPOSE 9000
VOLUME /config

CMD ["-F"]
