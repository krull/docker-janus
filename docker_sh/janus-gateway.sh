#!/usr/bin/env bash

git clone https://github.com/meetecho/janus-gateway.git $BUILD_SRC/janus-gateway
cd $BUILD_SRC/janus-gateway
./autogen.sh
./configure --prefix=/opt/janus --enable-post-processing --disable-rabbitmq --disable-docs --disable-mqtt --disable-boringssl
make -j4
make install
#make configs

