#
# mediainfo Dockerfile
#
# https://github.com/jlesage/docker-mediainfo
#

ARG DOCKER_IMAGE_VERSION=unknown

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.9-v3.5.2

# Define software versions.
ARG MEDIAINFO_VERSION=19.09

# Define software download URLs.
ARG MEDIAINFO_URL=https://github.com/MediaArea/MediaInfo/archive/v${MEDIAINFO_VERSION}.tar.gz

# Define working directory.
WORKDIR /tmp

# Install dependencies.
RUN add-pkg \
        mediainfo \
        mesa-dri-swrast \
        qt5-qtsvg

# Compile and install MediaInfo.
RUN \
    # Install packages needed by the build.
    add-pkg --virtual build-dependencies \
        build-base \
        curl \
        qt5-qtbase-dev \
        libmediainfo-dev \
        && \
    # Download sources.
    echo "Downloading MediaInfo package..." && \
    mkdir mediainfo && \
    curl -# -L ${MEDIAINFO_URL} | tar xz --strip 1 -C mediainfo && \
    # Compile.
    cd mediainfo/Project/QMake/GUI && \
    /usr/lib/qt5/bin/qmake && \
    make -j$(nproc) install && \
    cd ../../../../ && \
    # Install
    strip -v /usr/bin/mediainfo-gui && \
    cd ../ && \
    # Cleanup.
    del-pkg build-dependencies && \
    rm -rf /tmp/* /tmp/.[!.]*

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://github.com/jlesage/docker-templates/raw/master/jlesage/images/mediainfo-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /

# Set environment variables.
ENV APP_NAME="MediaInfo"

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/storage"]

# Metadata.
LABEL \
      org.label-schema.name="mediainfo" \
      org.label-schema.description="Docker container for MediaInfo" \
      org.label-schema.version="$DOCKER_IMAGE_VERSION" \
      org.label-schema.vcs-url="https://github.com/jlesage/docker-mediainfo" \
      org.label-schema.schema-version="1.0"
