############################################################
# Dockerfile - Janus Gateway on Debian Jessie
# https://github.com/krull/docker-janus
############################################################

# set base image debian jessie
FROM debian:jessie

# file maintainer author
MAINTAINER brendan jocson <brendan@jocson.eu>

# docker build environments
ENV CONFIG_PATH="/opt/janus/etc/janus"

# docker build arguments
ARG BUILD_SRC="/usr/local/src"
ARG JANUS_WITH_BORINGSSL="0"
ARG JANUS_WITH_DATACHANNELS="1"
ARG JANUS_WITH_WEBSOCKETS="1"
ARG JANUS_WITH_PAHOMQTT="0"
ARG JANUS_WITH_RABBITMQ="0"
ARG JANUS_CONFIG_DEPS="\
    --prefix=/opt/janus \
    "
ARG JANUS_CONFIG_OPTIONS="\
    --enable-post-processing \
    --disable-docs \
    "
ARG JANUS_BUILD_DEPS_DEV="\
    libcurl4-openssl-dev \
    libmicrohttpd-dev \
    libjansson-dev \
    libnice-dev \
    libssl-dev \
    libsofia-sip-ua-dev \
    libglib2.0-dev \
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
    "

RUN \
# init build env & install apt deps
    export JANUS_WITH_BORINGSSL="${JANUS_WITH_BORINGSSL}"\
    && export JANUS_WITH_DATACHANNELS="${JANUS_WITH_DATACHANNELS}"\
    && export JANUS_WITH_WEBSOCKETS="${JANUS_WITH_WEBSOCKETS}"\
    && export JANUS_WITH_PAHOMQTT="${JANUS_WITH_PAHOMQTT}"\
    && export JANUS_WITH_RABBITMQ="${JANUS_WITH_RABBITMQ}"\
    && export JANUS_BUILD_DEPS_DEV="${JANUS_BUILD_DEPS_DEV}"\
    && export JANUS_CONFIG_OPTIONS="${JANUS_CONFIG_OPTIONS}"\
    && if [ $JANUS_WITH_BORINGSSL = "1" ]; then export JANUS_BUILD_DEPS_DEV="$JANUS_BUILD_DEPS_DEV golang-go" && export JANUS_CONFIG_OPTIONS="$JANUS_CONFIG_OPTIONS --enable-boringssl"; fi \
    && if [ $JANUS_WITH_DATACHANNELS = "0" ]; then export JANUS_CONFIG_OPTIONS="$JANUS_CONFIG_OPTIONS --disable-data-channels"; fi \
    && if [ $JANUS_WITH_WEBSOCKETS = "0" ]; then export JANUS_CONFIG_OPTIONS="$JANUS_CONFIG_OPTIONS --disable-websockets"; fi \
    && if [ $JANUS_WITH_PAHOMQTT = "0" ]; then export JANUS_CONFIG_OPTIONS="$JANUS_CONFIG_OPTIONS --disable-mqtt"; fi \
    && if [ $JANUS_WITH_RABBITMQ = "0" ]; then export JANUS_CONFIG_OPTIONS="$JANUS_CONFIG_OPTIONS --disable-rabbitmq"; fi \
    && DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install $JANUS_BUILD_DEPS_DEV ${JANUS_BUILD_DEPS_EXT} \
# build libsrtp
    && curl -fSL https://github.com/cisco/libsrtp/archive/v1.5.0.tar.gz -o ${BUILD_SRC}/v1.5.0.tar.gz \
    && tar xzf ${BUILD_SRC}/v1.5.0.tar.gz -C ${BUILD_SRC} \
    && cd ${BUILD_SRC}/libsrtp-1.5.0 \
    && ./configure --prefix=/usr --enable-openssl \
    && make libsrtp.so \
    && make install \
# build boringssl
    && if [ $JANUS_WITH_BORINGSSL = "1" ]; then git clone https://boringssl.googlesource.com/boringssl ${BUILD_SRC}/boringssl \
    && cd ${BUILD_SRC}/boringssl \
    && sed -i s/" -Werror"//g CMakeLists.txt \
    && mkdir -p ${BUILD_SRC}/boringssl/build \
    && cd ${BUILD_SRC}/boringssl/build \
    && cmake -DCMAKE_CXX_FLAGS="-lrt" .. \
    && make \
    && mkdir -p /opt/boringssl \
    && cp -R ${BUILD_SRC}/boringssl/include /opt/boringssl/ \
    && mkdir -p /opt/boringssl/lib \
    && cp ${BUILD_SRC}/boringssl/build/ssl/libssl.a /opt/boringssl/lib/ \
    && cp ${BUILD_SRC}/boringssl/build/crypto/libcrypto.a /opt/boringssl/lib/ \
    ; fi \
# build usrsctp
    && if [ $JANUS_WITH_DATACHANNELS = "1" ]; then git clone https://github.com/sctplab/usrsctp ${BUILD_SRC}/usrsctp \
    && cd ${BUILD_SRC}/usrsctp \
    && ./bootstrap \
    && ./configure --prefix=/usr \
    && make \
    && make install \
    ; fi \
# build libwebsockets
    && if [ $JANUS_WITH_WEBSOCKETS = "1" ]; then git clone https://github.com/warmcat/libwebsockets.git ${BUILD_SRC}/libwebsockets \
    && cd ${BUILD_SRC}/libwebsockets \
    && mkdir ${BUILD_SRC}/libwebsockets/build \
    && cd ${BUILD_SRC}/libwebsockets/build \
    && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. \
    && make \
    && make install \
    ; fi \
# build paho.mqtt.c
    && if [ $JANUS_WITH_PAHOMQTT = "1" ]; then git clone https://github.com/eclipse/paho.mqtt.c.git ${BUILD_SRC}/paho.mqtt.c \
    && cd ${BUILD_SRC}/paho.mqtt.c \
    && make \
    && make install \
    ; fi \
# build rabbitmq-c
    && if [ $JANUS_WITH_RABBITMQ = "1" ]; then git clone https://github.com/alanxz/rabbitmq-c ${BUILD_SRC}/rabbitmq-c \
    && cd ${BUILD_SRC}/rabbitmq-c \
    && git submodule init \
    && git submodule update \
    && autoreconf -i \
    && ./configure --prefix=/usr \
    && make \
    && make install \
    ; fi \
# build janus-gateway
    && git clone https://github.com/meetecho/janus-gateway.git ${BUILD_SRC}/janus-gateway \
    && cd ${BUILD_SRC}/janus-gateway \
    && ./autogen.sh \
    && ./configure ${JANUS_CONFIG_DEPS} $JANUS_CONFIG_OPTIONS \
    && make \
    && make install \
# build cleanup
    && cd ${BUILD_SRC} \
    && if [ $JANUS_WITH_BORINGSSL = "1" ]; then rm -rf boringssl; fi \
    && if [ $JANUS_WITH_DATACHANNELS = "1" ]; then rm -rf usrsctp; fi \
    && if [ $JANUS_WITH_WEBSOCKETS = "1" ]; then rm -rf libwebsockets; fi \
    && if [ $JANUS_WITH_PAHOMQTT = "1" ]; then rm -rf paho.mqtt.c; fi \
    && if [ $JANUS_WITH_RABBITMQ = "1" ]; then rm -rf rabbitmq-c; fi \
    && rm -rf \
        v1.5.0.tar.gz \
        libsrtp-1.5.0 \
        janus-gateway \
    && DEBIAN_FRONTEND=noninteractive apt-get -y --auto-remove purge ${JANUS_BUILD_DEPS_EXT} \
    && DEBIAN_FRONTEND=noninteractive apt-get -y clean \
    && DEBIAN_FRONTEND=noninteractive apt-get -y autoclean \
    && DEBIAN_FRONTEND=noninteractive apt-get -y autoremove \
    && rm -rf /usr/share/locale/* \
    && rm -rf /var/cache/debconf/*-old \
    && rm -rf /usr/share/doc/* \
    && rm -rf /var/lib/apt/*

CMD ["/opt/janus/bin/janus"]
