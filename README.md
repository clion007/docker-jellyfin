# Clion/Jellyfin
[![Docker Pulls](https://img.shields.io/docker/pulls/clion007/jellyfin.svg)](https://hub.docker.com/r/clion007/jellyfin)
[![Docker Stars](https://img.shields.io/docker/stars/clion007/jellyfin.svg)](https://hub.docker.com/r/clion007/jellyfin)
[![GitHub Stars](https://img.shields.io/github/stars/clion007/docker-jellyfin.svg)](https://github.com/clion007/docker-jellyfin)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/clion007/docker-jellyfin.svg)](https://github.com/clion007/docker-jellyfin/commits/main)
[![Build Status](https://img.shields.io/github/actions/workflow/status/clion007/docker-jellyfin/build.yml?branch=main)](https://github.com/clion007/docker-jellyfin/actions)
[![Image Size](https://img.shields.io/docker/image-size/clion007/jellyfin/latest)](https://hub.docker.com/r/clion007/jellyfin)
[![Jellyfin Version](https://img.shields.io/badge/jellyfin-10.8.13-blue)](https://github.com/jellyfin/jellyfin/releases)
[![FFmpeg Version](https://img.shields.io/badge/ffmpeg-6.0-orange)](https://github.com/jellyfin/jellyfin-ffmpeg/releases)

<div align="center">
  <img src="https://jellyfin.org/images/logo.png" alt="Jellyfin Logo" width="200"/>
  <br>
  <strong>The Free Software Media System</strong>
</div>

<br>

Jellyfin is a Free Software Media System that puts you in control of managing and streaming your media. It is an alternative to the proprietary Emby and Plex, to provide media from a dedicated server to end-user devices via multiple apps. Jellyfin is descended from Emby's 3.5.2 release and ported to the .NET Core framework to enable full cross-platform support. There are no strings attached, no premium licenses or features, and no hidden agendas: just a team who want to build something better and work together to achieve it.

This clion/jellyfin docker image provides a better alternative to the official Jellyfin container. It's built on the latest Alpine Linux, offering a smaller footprint while fixing FFmpeg decoding issues, hardware acceleration support, and Chinese character display problems. The image automatically updates when new Jellyfin versions are released.

## 🚀 Application Setup

* WebUI can be accessed at `http://<your-ip>:8096`
* For detailed configuration options, please refer to the [official Jellyfin documentation](https://jellyfin.org/docs/)

## 🖥️ Hardware Acceleration

Hardware acceleration significantly improves transcoding performance. While not strictly required, it's highly recommended for optimal media streaming experience.

### For Intel/AMD/ATI GPUs:
Mount the `/dev/dri` device into the container:
```
--device=/dev/dri:/dev/dri
```

The container automatically configures proper permissions for the jellyfin user to access these devices.

## 📋 Usage

You can deploy this container using either docker-compose (recommended) or the docker CLI.

### Docker Compose (Recommended)

```yaml
services:
  jellyfin:
    container_name: Jellyfin
    image: registry.cn-chengdu.aliyuncs.com/clion/jellyfin:latest
    environment:
      - UMASK=022
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Shanghai
      - JELLYFIN_PublishedServerUrl=192.168.0.5 #optional
    ports:
      - 8096:8096
      - 8920:8920 #optional
      - 7359:7359/udp #optional
      - 1900:1900/udp #optional
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /path/to/jellyfin/library:/config
      - /path/to/media:/media/nas
    devices:
      - /dev/dri:/dev/dri #optional - for hardware transcoding
    restart: unless-stopped
```

### Docker CLI

```bash
docker run -d \
  --name=Jellyfin \
  -e UMASK=022 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Shanghai \
  -e JELLYFIN_PublishedServerUrl=192.168.0.5 `#optional` \
  -p 8096:8096 \
  -p 8920:8920 `#optional` \
  -p 7359:7359/udp `#optional` \
  -p 1900:1900/udp `#optional` \
  -v /path/to/config:/config \
  -v /path/to/media:/media/nas \
  -v /etc/localtime:/etc/localtime:ro \
  --device=/dev/dri:/dev/dri `#optional - for hardware transcoding` \
  --restart unless-stopped \
  registry.cn-chengdu.aliyuncs.com/clion/jellyfin:latest
```

## ⚙️ Parameters

Containers are configured using parameters passed at runtime. These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port 80 from inside the container to be accessible from the host's IP on port 8080.

### Port Mappings
| Parameter | Function |
| :----: | --- |
| `-p 8096:8096` | Primary HTTP web interface |
| `-p 8920:8920` | HTTPS web interface (requires your own certificate) |
| `-p 7359:7359/udp` | Allows clients to discover Jellyfin on the local network |
| `-p 1900:1900/udp` | Service discovery used by DLNA and clients |

### Environment Variables
| Parameter | Function |
| :----: | --- |
| `-e PUID=1000` | User ID for container user (see User/Group section below) |
| `-e PGID=1000` | Group ID for container user (see User/Group section below) |
| `-e TZ=Asia/Shanghai` | Specify timezone |
| `-e UMASK=022` | Control permission bits for newly created files (see Umask section) |
| `-e JELLYFIN_PublishedServerUrl=192.168.0.5` | Set the autodiscovery response domain or IP address |

### Volume Mappings
| Parameter | Function |
| :----: | --- |
| `-v /config` | Jellyfin data storage location (can grow very large, 50GB+ for large collections) |
| `-v /media/nas` | Media location. Add as many as needed (e.g., /media/nas/movies, /media/nas/tv) |

### Device Mappings
| Parameter | Function |
| :----: | --- |
| `--device=/dev/dri:/dev/dri` | For Intel/AMD GPU hardware acceleration |

## 🔧 Performance Tuning

For optimal performance with large media libraries:

1. **Memory Allocation**: Consider allocating sufficient memory:
   ```
   --memory=4g --memory-swap=6g
   ```

2. **Storage Performance**: Mount configuration and media directories on high-performance storage

3. **Network Configuration**: For local streaming, consider using host networking:
   ```
   --network=host
   ```

## 🔐 Umask for Running Applications

This image provides the ability to override default permission settings using the optional `-e UMASK=022` parameter. Remember that umask subtracts from permissions based on its value; it does not add permissions.

## 👥 User / Group Identifiers

When using volumes, permission issues can arise between the host OS and the container. To avoid this, specify the user PUID and group PGID.

Ensure any volume directories on the host are owned by the same user you specify, and permission issues will be resolved automatically.

## ❓ Troubleshooting

### Transcoding Issues
- ✅ Verify hardware acceleration is properly configured
- ✅ Check Jellyfin dashboard for transcoding errors
- ✅ Ensure media formats are supported

### Network Discovery Problems
- ✅ Confirm UDP ports 7359 and 1900 are properly mapped
- ✅ Set the correct `JELLYFIN_PublishedServerUrl` environment variable

### Permission Issues
- ✅ Verify PUID/PGID match the owner of your host directories
- ✅ Check umask settings if files have incorrect permissions
