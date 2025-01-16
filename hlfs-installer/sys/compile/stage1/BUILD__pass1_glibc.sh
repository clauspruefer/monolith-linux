#!/bin/bash

#>> ------------------------------------------------------
#>> ENVIRONMENT ------------------------------------------

. ./ENV__user.env

#>> ------------------------------------------------------
#>> FUNCTIONS --------------------------------------------

. ./build_functions.sh

#>> ------------------------------------------------------
#>> DEPACK  ----------------------------------------------

depack_src_file "glibc"

#>> ------------------------------------------------------
#>> PROCESS  ---------------------------------------------

mkdir -v ../glibc-build
cd ../glibc-build

../glibc-2.19/configure \
--prefix=/tools \
--host=$LFS_TGT \
--build=$(../glibc-2.19/scripts/config.guess) \
--disable-profile \
--enable-kernel=2.6.32 \
--enable-add-ons \
--with-headers=/tools/include \
libc_cv_forced_unwind=yes \
libc_cv_ctors_headers=yes \
libc_cv_c_cleanup=yes

make
make install

