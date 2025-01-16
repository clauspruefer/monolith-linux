#!/bin/bash

#>> ------------------------------------------------------
#>> ENVIRONMENT ------------------------------------------

. ./ENV__user.env

#>> ------------------------------------------------------
#>> FUNCTIONS --------------------------------------------

. ./build_functions.sh


#>> ------------------------------------------------------
#>> EXPECT  ----------------------------------------------

depack_src_file "expect"

cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure

./configure \
--prefix=/tools \
--with-tcl=/tools/lib \
--with-tclinclude=/tools/include \
--with-tk=no

make $MAKEFLAGS
make SCRIPTS="" install

