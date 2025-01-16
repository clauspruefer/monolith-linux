#!/bin/bash

#>> ------------------------------------------------------
#>> ENVIRONMENT ------------------------------------------

. ./ENV__user.env

#>> ------------------------------------------------------
#>> FUNCTIONS --------------------------------------------

. ./build_functions.sh


#>> ------------------------------------------------------
#>> TEXINFO  ---------------------------------------------

depack_src_file "util-linux"

#>> ------------------------------------------------------
#>> PATCH + PROCESS  -------------------------------------

./configure \
--prefix=/tools \
--disable-makeinstall-chown \
--without-systemdsystemunitdir \
PKG_CONFIG=""

make $MAKEFLAGS
make install

