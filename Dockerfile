#
# mediainfo Dockerfile
#
# https://github.com/jlesage/docker-mediainfo
#

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.11-glibc-v3.5.3

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=unknown

# Define software versions.
ARG NGPOST_VERSION=4.7

# Define software download URLs.
ARG NGPOST_URL=https://github.com/mbruel/ngPost/archive/v${NGPOST_VERSION}.tar.gz

# Define working directory.
WORKDIR /tmp

# Install dependencies.
RUN add-pkg \
        curl \
        qt5-qtsvg \
        qt5-qtbase-dev \
        libssl1.1 \
        libressl-dev \
        build-base \
        p7zip \
        nodejs-current \
        npm \
        git \
        python \
        bash

# Compile and install ngPost.

RUN \
    # Download sources for ngPost.
    echo "Downloading ngPost package..." && \
    mkdir ngPost && \
    curl -# -L ${NGPOST_URL} | tar xz --strip 1 -C ngPost && \
    # Compile.
    cd ngPost/src && \
    /usr/lib/qt5/bin/qmake && \
    make && \
    cp ngPost /usr/bin/ngPost && \
    cd && \
    # Cleanup.
    rm -rf /tmp/* /tmp/.[!.]*

# Compile and install ParPar.

RUN \
    # Download sources for parpar
    echo "Downloading & Installing ParPar" && \
    npm install -g @animetosho/parpar --unsafe-perm    

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://raw.githubusercontent.com/mbruel/ngPost/master/src/resources/icons/ngPost.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /

# Set environment variables.
ENV APP_NAME="ngPost"

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/storage"]

# Metadata.
LABEL \
      org.label-schema.name="ngPost" \
      org.label-schema.description="Docker container for ngPost" \
      org.label-schema.version="$DOCKER_IMAGE_VERSION" \
      org.label-schema.vcs-url="https://github.com/Tr4il/docker-ngPost" \
      org.label-schema.schema-version="1.9"