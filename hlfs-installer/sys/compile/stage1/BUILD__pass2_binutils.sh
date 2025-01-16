#!/bin/bash

#>> ------------------------------------------------------
#>> ENVIRONMENT ------------------------------------------

. ./ENV__user.env

#>> ------------------------------------------------------
#>> FUNCTIONS --------------------------------------------

. ./build_functions.sh

#>> ------------------------------------------------------
#>> BINUTILS STAGE2  -------------------------------------

cd_by_pkgname "binutils"

rm -Rf $HLFS/sources/binutils-build

mkdir -v ../binutils-build
cd ../binutils-build

CC=$LFS_TGT-gcc \
AR=$LFS_TGT-ar \
RANLIB=$LFS_TGT-ranlib \
../binutils-2.24/configure \
--prefix=/tools \
--disable-nls \
--with-lib-path=/tools/lib \
--with-sysroot

make $MAKEFLAGS
make install

make -C ld clean
make -C ld LIB_PATH=/usr/lib:/lib

cp -v ld/ld-new /tools/bin

