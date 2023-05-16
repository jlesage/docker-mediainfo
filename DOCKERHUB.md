# Docker container for MediaInfo
[![Release](https://img.shields.io/github/release/jlesage/docker-mediainfo.svg?logo=github&style=for-the-badge)](https://github.com/jlesage/docker-mediainfo/releases/latest)
[![Docker Image Size](https://img.shields.io/docker/image-size/jlesage/mediainfo/latest?logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/mediainfo/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/jlesage/mediainfo?label=Pulls&logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/mediainfo)
[![Docker Stars](https://img.shields.io/docker/stars/jlesage/mediainfo?label=Stars&logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/mediainfo)
[![Build Status](https://img.shields.io/github/actions/workflow/status/jlesage/docker-mediainfo/build-image.yml?logo=github&branch=master&style=for-the-badge)](https://github.com/jlesage/docker-mediainfo/actions/workflows/build-image.yml)
[![Source](https://img.shields.io/badge/Source-GitHub-blue?logo=github&style=for-the-badge)](https://github.com/jlesage/docker-mediainfo)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg?style=for-the-badge)](https://paypal.me/JocelynLeSage)

This is a Docker container for [MediaInfo](https://mediaarea.net/en/MediaInfo).

The GUI of the application is accessed through a modern web browser (no
installation or configuration needed on the client side) or via any VNC client.

---

[![MediaInfo logo](https://images.weserv.nl/?url=raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/mediainfo-icon.png&w=110)](https://mediaarea.net/en/MediaInfo)[![MediaInfo](https://images.placeholders.dev/?width=288&height=110&fontFamily=monospace&fontWeight=400&fontSize=52&text=MediaInfo&bgColor=rgba(0,0,0,0.0)&textColor=rgba(121,121,121,1))](https://mediaarea.net/en/MediaInfo)

MediaInfo is a convenient unified display of the most relevant technical and tag data for video and audio files.

---

## Quick Start

**NOTE**: The Docker command provided in this quick start is given as an example
and parameters should be adjusted to your need.

Launch the MediaInfo docker container with the following command:
```shell
docker run -d \
    --name=mediainfo \
    -p 5800:5800 \
    -v /docker/appdata/mediainfo:/config:rw \
    -v /home/user:/storage:ro \
    jlesage/mediainfo
```

Where:
  - `/docker/appdata/mediainfo`: This is where the application stores its configuration, states, log and any files needing persistency.
  - `/home/user`: This location contains files from your host that need to be accessible to the application.

Browse to `http://your-host-ip:5800` to access the MediaInfo GUI.
Files from the host appear under the `/storage` folder in the container.

## Documentation

Full documentation is available at https://github.com/jlesage/docker-mediainfo.

## Support or Contact

Having troubles with the container or have questions?  Please
[create a new issue].

For other great Dockerized applications, see https://jlesage.github.io/docker-apps.

[create a new issue]: https://github.com/jlesage/docker-mediainfo/issues
