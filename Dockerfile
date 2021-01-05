#
# mediainfo Dockerfile
#
# https://github.com/jlesage/docker-mediainfo
#

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.12-v3.5.6

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=unknown

# Define software versions.
ARG MEDIAINFO_VERSION=20.09

# Define software download URLs.
ARG MEDIAINFO_URL=https://github.com/MediaArea/MediaInfo/archive/v${MEDIAINFO_VERSION}.tar.gz
ARG MEDIAINFOLIB_URL=https://mediaarea.net/download/source/libmediainfo/${MEDIAINFO_VERSION}/libmediainfo_${MEDIAINFO_VERSION}.tar.xz

# Define working directory.
WORKDIR /tmp

# Install dependencies.
RUN add-pkg \
        libzen \
        libcurl \
        tinyxml2 \
        mesa-dri-swrast \
        qt5-qtsvg

# Compile and install MediaInfo.
RUN \
    # Install packages needed by the build.
    add-pkg --virtual build-dependencies \
        build-base \
        curl \
        cmake \
        automake \
        autoconf \
        libtool \
        curl-dev \
        libmms-dev \
        libzen-dev \
        tinyxml2-dev \
        qt5-qtbase-dev \
        && \
    # Set same default compilation flags as abuild.
    export CFLAGS="-Os -fomit-frame-pointer" && \
    export CXXFLAGS="$CFLAGS" && \
    export CPPFLAGS="$CFLAGS" && \
    export LDFLAGS="-Wl,--as-needed" && \
    # Download MediaInfoLib.
    echo "Downloading MediaInfoLib package..." && \
    mkdir MediaInfoLib && \
    curl -# -L ${MEDIAINFOLIB_URL} | tar xJ --strip 1 -C MediaInfoLib && \
    rm -r \
        MediaInfoLib/Project/MS* \
        MediaInfoLib/Project/zlib \
        MediaInfoLib/Source/ThirdParty/tinyxml2 \
        && \
    # Compile MediaInfoLib.
    echo "Compiling MediaInfoLib..." && \
    cd MediaInfoLib/Project/CMake && \
    cmake -DCMAKE_BUILD_TYPE=None \
          -DCMAKE_INSTALL_PREFIX=/usr \
          -DCMAKE_VERBOSE_MAKEFILE=OFF \
          -DBUILD_SHARED_LIBS=ON \
          && \
    make -j$(nproc) install && \
    cd ../../../ && \
    # Download MediaInfo.
    echo "Downloading MediaInfo package..." && \
    mkdir MediaInfo && \
    curl -# -L ${MEDIAINFO_URL} | tar xz --strip 1 -C MediaInfo && \
    # Compile the GUI.
    echo "Compiling MediaInfo GUI..." && \
    cd MediaInfo/Project/QMake/GUI && \
    /usr/lib/qt5/bin/qmake && \
    make -j$(nproc) install && \
    cd ../../../../ && \
    # Compile the CLI.
    echo "Compiling MediaInfo CLI..." && \
    cd MediaInfo/Project/GNU/CLI && \
    ./autogen.sh && \
    ./configure \
        --prefix=/usr \
        --enable-static=no \
        && \
    make -j$(nproc) install && \
    # Strip binaries.
    strip -v /usr/bin/mediainfo && \
    strip -v /usr/bin/mediainfo-gui && \
    strip -v /usr/lib/libmediainfo.so && \
    cd ../ && \
    # Cleanup.
    del-pkg build-dependencies && \
    rm -r \
        /usr/include/MediaInfo \
        /usr/lib/cmake/mediainfolib \
        /usr/lib/pkgconfig/libmediainfo.pc \
        && \
    rm -r \
        /usr/include \
        /usr/lib/cmake \
        /usr/lib/pkgconfig \
        && \
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
