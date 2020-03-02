############################################################
# Dockerfile - Janus Gateway on Debian Buster
# https://github.com/jemmic/docker-janus
############################################################

# set base image debian buster with minimal packages installed
FROM debian:buster-slim

# file maintainer author
MAINTAINER Christophe Kamphaus <christophe.kamphaus@jemmic.com>
LABEL maintainer="Christophe Kamphaus <christophe.kamphaus@jemmic.com>"

# docker build environments
ENV CONFIG_PATH="/opt/janus/etc/janus"

# docker build arguments
ARG BUILD_SRC="/usr/local/src"

ARG JANUS_VERSION="v0.9.0"
ARG JANUS_LIBNICE_VERSION="0.1.16"
ARG JANUS_LIBSRTP_VERSION="2.3.0"
ARG JANUS_LIBWEBSOCKETS_VERSION="v3.2.2"

ARG JANUS_WITH_POSTPROCESSING="1"
ARG JANUS_WITH_BORINGSSL="1"
ARG JANUS_WITH_DOCS="0"
ARG JANUS_WITH_REST="1"
ARG JANUS_WITH_DATACHANNELS="0"
ARG JANUS_WITH_WEBSOCKETS="0"
ARG JANUS_WITH_MQTT="0"
ARG JANUS_WITH_PFUNIX="0"
ARG JANUS_WITH_RABBITMQ="0"
# https://goo.gl/dmbvc1
ARG JANUS_WITH_FREESWITCH_PATCH="0"
ARG JANUS_CONFIG_DEPS="\
    --prefix=/opt/janus \
    "
ARG JANUS_CONFIG_OPTIONS="\
    "
ARG JANUS_BUILD_DEPS_DEV="\
    libcurl4-openssl-dev \
    libjansson-dev \
    libssl-dev \
    libsofia-sip-ua-dev \
    libglib2.0-dev \
    liblua5.3-dev \
    libconfig-dev \
    libopus-dev \
    libogg-dev \
    pkg-config \
    "
ARG JANUS_BUILD_DEPS_EXT="\
    libavutil-dev \
    libavcodec-dev \
    libavformat-dev \
    gengetopt \
    libtool \
    automake \
    git-core \
    build-essential \
    cmake \
    ca-certificates \
    curl \
    gtk-doc-tools \
    "

ADD ./build.sh /tmp
RUN /tmp/build.sh \
    && rm /tmp/build.sh

USER janus

CMD ["/opt/janus/bin/janus"]
