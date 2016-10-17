#!/usr/bin/env bash

wget -O $BUILD_SRC/v1.5.0.tar.gz https://github.com/cisco/libsrtp/archive/v1.5.0.tar.gz
tar xf $BUILD_SRC/v1.5.0.tar.gz -C /usr/local/src
cd $BUILD_SRC/libsrtp-1.5.0
./configure --prefix=/usr --enable-openssl
make libsrtp.so && make install

