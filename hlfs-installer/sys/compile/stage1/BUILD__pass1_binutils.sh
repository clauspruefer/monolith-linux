#!/bin/bash

#>> ------------------------------------------------------
#>> ENVIRONMENT ------------------------------------------

. ./ENV__user.env

#>> ------------------------------------------------------
#>> FUNCTIONS --------------------------------------------

. ./build_functions.sh

#>> ------------------------------------------------------
#>> DEPACK -----------------------------------------------

depack_src_file "binutils"

#>> ------------------------------------------------------
#>> PATCH + PROCESS  -------------------------------------

#>> make binutils build dir
mkdir -v ../binutils-build
cd ../binutils-build

#>> configure
../binutils-2.24/configure \
--target=$LFS_TGT \
--prefix=/tools \
--with-sysroot=$LFS \
--with-lib-path=/tools/lib \
--disable-nls \
--disable-werror

#>> build
make $MAKEFLAGS

#>> make symlinks
case $(uname -m) in
  x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
esac

#>> install
make install

