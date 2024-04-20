# clion/jellyfin
Jellyfin is a Free Software Media System that puts you in control of managing and streaming your media. It is an alternative to the proprietary Emby and Plex, to provide media from a dedicated server to end-user devices via multiple apps. Jellyfin is descended from Emby's 3.5.2 release and ported to the .NET Core framework to enable full cross-platform support. There are no strings attached, no premium licenses or features, and no hidden agendas: just a team who want to build something better and work together to achieve it.

This clion/jellyfin docker image supply you a better choice for the jellyfin container than offical image. It is builded base on latest alpine, with smaller size and fix the ffmpg decode, hardware drivers and chinese shown in garbled problems et,al.

## Application Setup
* Webui can be found at http://<your-ip>:8096
* More information can be found on the official documentation.

## Hardware Acceleration
Many desktop applications need access to a GPU to function properly and even some Desktop Environments have compositor effects that will not function without a GPU. However this is not a hard requirement and all base images will function without a video device mounted into the container.

For Intel/ATI/AMD to leverage hardware acceleration you will need to mount /dev/dri video device inside of the container.
```
--device=/dev/dri:/dev/dri
```
