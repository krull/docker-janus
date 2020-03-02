#!/usr/bin/env bash

# use bash strict mode
set -euo pipefail

# init build env & install apt deps
if [ $JANUS_WITH_POSTPROCESSING = "1" ]; then export JANUS_CONFIG_OPTIONS="$JANUS_CONFIG_OPTIONS --enable-post-processing"; fi
if [ $JANUS_WITH_BORINGSSL = "1" ]; then export JANUS_BUILD_DEPS_DEV="$JANUS_BUILD_DEPS_DEV golang-go" && export JANUS_CONFIG_OPTIONS="$JANUS_CONFIG_OPTIONS --enable-boringssl --enable-dtls-settimeout"; fi
if [ $JANUS_WITH_DOCS = "1" ]; then export JANUS_BUILD_DEPS_DEV="$JANUS_BUILD_DEPS_DEV graphviz" && export JANUS_BUILD_DEPS_EXT="$JANUS_BUILD_DEPS_EXT flex bison file sensible-utils" && export JANUS_CONFIG_OPTIONS="$JANUS_CONFIG_OPTIONS --enable-docs"; fi
if [ $JANUS_WITH_REST = "1" ]; then export JANUS_BUILD_DEPS_DEV="$JANUS_BUILD_DEPS_DEV libmicrohttpd-dev"; else export JANUS_CONFIG_OPTIONS="$JANUS_CONFIG_OPTIONS --disable-rest"; fi
if [ $JANUS_WITH_DATACHANNELS = "0" ]; then export JANUS_CONFIG_OPTIONS="$JANUS_CONFIG_OPTIONS --disable-data-channels"; fi
if [ $JANUS_WITH_WEBSOCKETS = "0" ]; then export JANUS_CONFIG_OPTIONS="$JANUS_CONFIG_OPTIONS --disable-websockets"; fi
if [ $JANUS_WITH_MQTT = "0" ]; then export JANUS_CONFIG_OPTIONS="$JANUS_CONFIG_OPTIONS --disable-mqtt"; fi
if [ $JANUS_WITH_PFUNIX = "0" ]; then export JANUS_CONFIG_OPTIONS="$JANUS_CONFIG_OPTIONS --disable-unix-sockets"; fi
if [ $JANUS_WITH_RABBITMQ = "0" ]; then export JANUS_CONFIG_OPTIONS="$JANUS_CONFIG_OPTIONS --disable-rabbitmq"; fi
/usr/sbin/groupadd -r janus && /usr/sbin/useradd -r -g janus janus
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -yq --no-install-recommends install $JANUS_BUILD_DEPS_DEV ${JANUS_BUILD_DEPS_EXT}

# build libnice
git clone https://gitlab.freedesktop.org/libnice/libnice ${BUILD_SRC}/libnice
cd ${BUILD_SRC}/libnice
git checkout ${JANUS_LIBNICE_VERSION}
./autogen.sh
./configure --prefix=/usr
make
make install

# build libsrtp
curl -fSL https://github.com/cisco/libsrtp/archive/v${JANUS_LIBSRTP_VERSION}.tar.gz -o ${BUILD_SRC}/v${JANUS_LIBSRTP_VERSION}.tar.gz
tar xzf ${BUILD_SRC}/v${JANUS_LIBSRTP_VERSION}.tar.gz -C ${BUILD_SRC}
cd ${BUILD_SRC}/libsrtp-${JANUS_LIBSRTP_VERSION}
./configure --prefix=/usr --enable-openssl
make shared_library
make install

# build boringssl
if [ $JANUS_WITH_BORINGSSL = "1" ]; then
    git clone https://boringssl.googlesource.com/boringssl ${BUILD_SRC}/boringssl
    cd ${BUILD_SRC}/boringssl
    git checkout ${JANUS_BORINGSSL_VERSION}
    sed -i s/" -Werror"//g CMakeLists.txt
    mkdir -p ${BUILD_SRC}/boringssl/build
    cd ${BUILD_SRC}/boringssl/build
    cmake -DCMAKE_CXX_FLAGS="-lrt" ..
    make
    mkdir -p /opt/boringssl
    cp -R ${BUILD_SRC}/boringssl/include /opt/boringssl/
    mkdir -p /opt/boringssl/lib
    cp ${BUILD_SRC}/boringssl/build/ssl/libssl.a /opt/boringssl/lib/
    cp ${BUILD_SRC}/boringssl/build/crypto/libcrypto.a /opt/boringssl/lib/
fi

# build usrsctp
if [ $JANUS_WITH_DATACHANNELS = "1" ]; then
    git clone https://github.com/sctplab/usrsctp ${BUILD_SRC}/usrsctp
    cd ${BUILD_SRC}/usrsctp
    git checkout ${JANUS_USRSCTP_VERSION}
    ./bootstrap
    ./configure --prefix=/usr
    make
    make install
fi

# build libwebsockets
if [ $JANUS_WITH_WEBSOCKETS = "1" ]; then
    git clone https://github.com/warmcat/libwebsockets.git ${BUILD_SRC}/libwebsockets
    cd ${BUILD_SRC}/libwebsockets
    git checkout ${JANUS_LIBWEBSOCKETS_VERSION}
    mkdir ${BUILD_SRC}/libwebsockets/build
    cd ${BUILD_SRC}/libwebsockets/build
    # See https://github.com/meetecho/janus-gateway/issues/732 re: LWS_MAX_SMP
    cmake -DLWS_MAX_SMP=1 -DLWS_IPV6=ON -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" ..
    make
    make install
fi

# build paho.mqtt.c
if [ $JANUS_WITH_MQTT = "1" ]; then
    git clone https://github.com/eclipse/paho.mqtt.c.git ${BUILD_SRC}/paho.mqtt.c
    cd ${BUILD_SRC}/paho.mqtt.c
    git checkout ${JANUS_PAHO_MQTT_VERSION}
    make
    make install
fi

# build rabbitmq-c
if [ $JANUS_WITH_RABBITMQ = "1" ]; then
    git clone https://github.com/alanxz/rabbitmq-c ${BUILD_SRC}/rabbitmq-c
    cd ${BUILD_SRC}/rabbitmq-c
    git checkout ${JANUS_RABBITMQ_VERSION}
    git submodule init
    git submodule update
    mkdir ${BUILD_SRC}/rabbitmq-c/build
    cd ${BUILD_SRC}/rabbitmq-c/build
    cmake -DCMAKE_INSTALL_PREFIX=/usr ..
    cmake --build . --target install
fi

# Install doxygen (built from sources)
if [ $JANUS_WITH_DOCS = "1" ]; then
    curl -fSL http://ftp.de.debian.org/debian/pool/main/c/checkinstall/checkinstall_1.6.2+git20170426.d24a630-2~bpo10+1_amd64.deb -o ${BUILD_SRC}/checkinstall.deb
    cd ${BUILD_SRC}
    echo "ce3fec00c5129dca445d759bbe5996b8f51cb4fb68744ca4c1c41c04f38aa9a5 checkinstall.deb" | sha256sum -c -;
    dpkg -i ${BUILD_SRC}/checkinstall.deb
    git clone https://github.com/doxygen/doxygen.git ${BUILD_SRC}/doxygen
    cd ${BUILD_SRC}/doxygen
    git checkout Release_1_8_11
    mkdir ${BUILD_SRC}/doxygen/build
    cd ${BUILD_SRC}/doxygen/build
    cmake -G "Unix Makefiles" ..
    make
    checkinstall --pkgname doxygen -y
fi

# build janus-gateway
git clone https://github.com/meetecho/janus-gateway.git ${BUILD_SRC}/janus-gateway
if [ $JANUS_WITH_FREESWITCH_PATCH = "1" ]; then curl -fSL https://raw.githubusercontent.com/krull/docker-misc/master/init_fs/tmp/janus_sip.c.patch -o ${BUILD_SRC}/janus-gateway/plugins/janus_sip.c.patch && cd ${BUILD_SRC}/janus-gateway/plugins && patch < janus_sip.c.patch; fi
cd ${BUILD_SRC}/janus-gateway
git checkout ${JANUS_VERSION}
./autogen.sh
./configure ${JANUS_CONFIG_DEPS} $JANUS_CONFIG_OPTIONS
make
make install
make configs

# folder ownership
chown -R janus:janus /opt/janus

# build cleanup
cd ${BUILD_SRC}
if [ $JANUS_WITH_BORINGSSL = "1" ]; then rm -rf boringssl; fi
if [ $JANUS_WITH_DATACHANNELS = "1" ]; then rm -rf usrsctp; fi
if [ $JANUS_WITH_WEBSOCKETS = "1" ]; then rm -rf libwebsockets; fi
if [ $JANUS_WITH_MQTT = "1" ]; then rm -rf paho.mqtt.c; fi
if [ $JANUS_WITH_RABBITMQ = "1" ]; then rm -rf rabbitmq-c; fi
if [ $JANUS_WITH_DOCS = "1" ]; then
    rm checkinstall.deb
    rm -rf doxygen
    DEBIAN_FRONTEND=noninteractive apt-get -y --auto-remove purge checkinstall doxygen
fi
rm -rf \
        v${JANUS_LIBSRTP_VERSION}.tar.gz \
        libsrtp-${JANUS_LIBSRTP_VERSION} \
        janus-gateway
DEBIAN_FRONTEND=noninteractive apt-get -y --auto-remove purge ${JANUS_BUILD_DEPS_EXT}
DEBIAN_FRONTEND=noninteractive apt-get -y clean
DEBIAN_FRONTEND=noninteractive apt-get -y autoclean
DEBIAN_FRONTEND=noninteractive apt-get -y autoremove
rm -rf /usr/share/locale/*
rm -rf /var/cache/debconf/*-old
rm -rf /usr/share/doc/*
rm -rf /var/lib/apt/*
