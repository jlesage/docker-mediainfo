#
# mediainfo Dockerfile
#
# https://github.com/jlesage/docker-mediainfo
#

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=

# Define software versions.
ARG MEDIAINFO_VERSION=25.09
ARG MEDIAINFOLIB_VERSION=25.09
ARG ZENLIB_VERSION=0.4.41

# Define software download URLs.
ARG MEDIAINFO_URL=https://github.com/MediaArea/MediaInfo/archive/refs/tags/v${MEDIAINFO_VERSION}.tar.gz
ARG MEDIAINFOLIB_URL=https://github.com/MediaArea/MediaInfoLib/archive/refs/tags/v${MEDIAINFOLIB_VERSION}.tar.gz
ARG ZENLIB_URL=https://github.com/MediaArea/ZenLib/archive/refs/tags/v${ZENLIB_VERSION}.tar.gz

# Get Dockerfile cross-compilation helpers.
FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

# Build MediaInfo.
FROM --platform=$BUILDPLATFORM alpine:3.20 AS mediainfo
ARG TARGETPLATFORM
ARG MEDIAINFO_URL
ARG MEDIAINFOLIB_URL
ARG ZENLIB_URL
COPY --from=xx / /
COPY src/mediainfo /build
RUN /build/build.sh "$MEDIAINFO_URL" "$MEDIAINFOLIB_URL" "$ZENLIB_URL"
RUN xx-verify \
    /tmp/mediainfo-install/usr/bin/mediainfo \
    /tmp/mediainfo-install/usr/bin/mediainfo-gui \
    /tmp/mediainfo-install/usr/lib/libmediainfo.so \
    /tmp/mediainfo-install/usr/lib/libzen.so

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.20-v4.9.0

ARG MEDIAINFO_VERSION
ARG DOCKER_IMAGE_VERSION

# Define working directory.
WORKDIR /tmp

# Install dependencies.
RUN add-pkg \
        tinyxml2 \
        qt6-qtbase-x11 \
        qt6-qtsvg \
        adwaita-qt \
        # mesa-gl dependency is not automatically pulled with some architectures
        # (e.g. arm64).
        mesa-gl \
        # A font is needed.
        font-roboto-mono

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://github.com/jlesage/docker-templates/raw/master/jlesage/images/mediainfo-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /
COPY --from=mediainfo /tmp/mediainfo-install/usr/bin /usr/bin
COPY --from=mediainfo /tmp/mediainfo-install/usr/lib /usr/lib

# Set internal environment variables.
RUN \
    set-cont-env APP_NAME "MediaInfo" && \
    set-cont-env APP_VERSION "$MEDIAINFO_VERSION" && \
    set-cont-env DOCKER_IMAGE_VERSION "$DOCKER_IMAGE_VERSION" && \
    true

# Define mountable directories.
VOLUME ["/storage"]

# Metadata.
LABEL \
      org.label-schema.name="mediainfo" \
      org.label-schema.description="Docker container for MediaInfo" \
      org.label-schema.version="${DOCKER_IMAGE_VERSION:-unknown}" \
      org.label-schema.vcs-url="https://github.com/jlesage/docker-mediainfo" \
      org.label-schema.schema-version="1.0"
