#!/usr/bin/env bash

git clone https://github.com/sctplab/usrsctp $BUILD_SRC/usrsctp
cd $BUILD_SRC/usrsctp
./bootstrap
./configure --prefix=/usr && make && make install

