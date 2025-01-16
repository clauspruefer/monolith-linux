#!/bin/bash

#>> ------------------------------------------------------
#>> ENVIRONMENT ------------------------------------------

. ./ENV__user.env

#>> ------------------------------------------------------
#>> FUNCTIONS --------------------------------------------

. ./build_functions.sh


#>> ------------------------------------------------------
#>> M4  --------------------------------------------------

depack_src_file "m4"

#>> ------------------------------------------------------
#>> PATCH + PROCESS  -------------------------------------

./configure \
--prefix=/tools

make $MAKEFLAGS
make install

