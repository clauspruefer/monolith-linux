#!/bin/bash

#>> ------------------------------------------------------
#>> ENVIRONMENT ------------------------------------------

. ./ENV__user.env

#>> ------------------------------------------------------
#>> FUNCTIONS --------------------------------------------

. ./build_functions.sh


#>> ------------------------------------------------------
#>> GETTEXT  ---------------------------------------------

depack_src_file "gettext"

cd gettext-tools

EMACS="no" \
./configure \
--prefix=/tools \
--disable-shared

make -C gnulib-lib
make -C src msgfmt
make -C src msgmerge
make -C src xgettext

cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin

