# clion/jellyfin
Jellyfin is a Free Software Media System that puts you in control of managing and streaming your media. It is an alternative to the proprietary Emby and Plex, to provide media from a dedicated server to end-user devices via multiple apps. Jellyfin is descended from Emby's 3.5.2 release and ported to the .NET Core framework to enable full cross-platform support. There are no strings attached, no premium licenses or features, and no hidden agendas: just a team who want to build something better and work together to achieve it.

This clion/jellyfin docker image supply you a better choice for the jellyfin container than offical image. It is builded base on latest alpine, with smaller size and fix the ffmpg decode, hardware drivers and chinese shown in garbled problems et,al. This image will auto check and update when there is new version of jellyfin exist.

## Application Setup
* Webui can be found at http://\<your-ip\>:8096
* More information can be found on the official documentation.

## Hardware Acceleration
Many desktop applications need access to a GPU to function properly and even some Desktop Environments have compositor effects that will not function without a GPU. However this is not a hard requirement and all base images will function without a video device mounted into the container.

For Intel/ATI/AMD to leverage hardware acceleration you will need to mount /dev/dri video device inside of the container.
```
--device=/dev/dri:/dev/dri
```
I will automatically ensure the jellyfin user inside of the container has the proper permissions to access this device.

## Usage
To help you get started creating a container from this image you can use the docker cli.

### Docker cli
```
docker run -d \
  --name=Jellyfin \
  -e 'UMASK'='022' \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Shanghai \
  -e JELLYFIN_PublishedServerUrl=192.168.0.5 `#optional` \
  -p 8096:8096 \
  -p 8920:8920 `#optional` \
  -p 7359:7359/udp `#optional` \
  -p 1900:1900/udp `#optional` \
  -v /path/to/config:/config \
  -v /path/to/media:/media \
  --restart unless-stopped \
  registry.cn-chengdu.aliyuncs.com/clion/jellyfin
```
## Parameters
Containers are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate <external>:<internal> respectively. For example, -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080 outside the container.

* ```-p 8096``` Http webUI.
* ```-p 8920``` Optional - Https webUI (you need to set up your own certificate).
* ```-p 7359/udp``` Optional - Allows clients to discover Jellyfin on the local network.
* ```-p 1900/udp``` Optional - Service discovery used by DNLA and clients.
* ```-e PUID=1000``` for UserID - see below for explanation.
* ```-e PUID=1000``` for GroupID - see below for explanation.
* ```-e TZ=Asia/Shanghai``` specify a timezone to use in your local area.
* ```-e JELLYFIN_PublishedServerUrl=192.168.0.5``` Set the autodiscovery response domain or IP address.
* ```-v /config``` Jellyfin data storage location. This can grow very large, 50gb+ is likely for a large collection.
* ```-v /media``` Media goes here. Add as many as needed e.g. /media/movies, /media/tv, etc.

## Umask for running applications
For all of my images I provide the ability to override the default umask settings for services started within the containers using the optional -e UMASK=022 setting. Keep in mind umask is not chmod it subtracts from permissions based on it's value it does not add.

## User / Group Identifiers
When using volumes (-v flags), permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user PUID and group PGID.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.
