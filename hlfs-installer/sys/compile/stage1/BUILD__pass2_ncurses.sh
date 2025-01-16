#!/bin/bash

#>> ------------------------------------------------------
#>> ENVIRONMENT ------------------------------------------

. ./ENV__user.env

#>> ------------------------------------------------------
#>> FUNCTIONS --------------------------------------------

. ./build_functions.sh


#>> ------------------------------------------------------
#>> NCURSES  ---------------------------------------------

depack_src_file "ncurses"

./configure \
--prefix=/tools \
--with-shared \
--without-debug \
--without-ada \
--enable-widec \
--enable-overwrite

make $MAKEFLAGS
make install

