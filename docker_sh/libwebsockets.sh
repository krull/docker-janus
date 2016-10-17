#!/usr/bin/env bash

git clone git://git.libwebsockets.org/libwebsockets $BUILD_SRC/libwebsockets
cd $BUILD_SRC/libwebsockets
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" ..
make && make install

