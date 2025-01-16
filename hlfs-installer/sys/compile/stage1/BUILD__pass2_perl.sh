#!/bin/bash

#>> ------------------------------------------------------
#>> ENVIRONMENT ------------------------------------------

. ./ENV__user.env

#>> ------------------------------------------------------
#>> FUNCTIONS --------------------------------------------

. ./build_functions.sh


#>> ------------------------------------------------------
#>> PERL  ------------------------------------------------

depack_src_file "perl"

patch -Np1 -i ../perl-5.18.2-libc-1.patch

sh Configure -des -Dprefix=/tools

make

cp -v perl cpan/podlators/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.18.2
cp -Rv lib/* /tools/lib/perl5/5.18.2

