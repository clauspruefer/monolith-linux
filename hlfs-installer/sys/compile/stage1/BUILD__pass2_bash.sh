#!/bin/bash

#>> ------------------------------------------------------
#>> ENVIRONMENT ------------------------------------------

. ./ENV__user.env

#>> ------------------------------------------------------
#>> FUNCTIONS --------------------------------------------

. ./build_functions.sh


#>> ------------------------------------------------------
#>> BASH  ------------------------------------------------

depack_src_file "bash"

./configure \
--prefix=/tools \
--without-bash-malloc

make $MAKEFLAGS
make install

ln -vs bash /tools/bin/sh

