#!/tools/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh


#>> ------------------------------------------------------
#>> DEPACK + COMPILE -------------------------------------

depack_src_file "gcc"


#>> ------------------------------------------------------
#>> REMOVE BUILD DIR STAGE1 ------------------------------

rm -R /sources/gcc-build


#>> ------------------------------------------------------
#>> DEPACK + COMPILE -------------------------------------

sed -i -e /autogen/d -e /check.sh/d fixincludes/Makefile.in
mv -v libmudflap/testsuite/libmudflap.c++/pass41-frag.cxx{,.disable}

mkdir -v ../gcc-build
cd ../gcc-build


#>> ------------------------------------------------------
#>> CONFIGURE --------------------------------------------

SED=sed \
../gcc-4.8.2/configure \
--prefix=/usr \
--enable-shared \
--enable-threads=posix \
--enable-__cxa_atexit \
--enable-clocale=gnu \
--enable-languages=c,c++ \
--disable-multilib \
--disable-bootstrap \
--with-system-zlib


#>> ------------------------------------------------------
#>> COMPILE ----------------------------------------------

make $MAKEFLAGS


#>> ------------------------------------------------------
#>> INSTALL ----------------------------------------------

make install


#>> ------------------------------------------------------
#>> INSTALL ----------------------------------------------

ln -sv ../usr/bin/cpp /lib
ln -sv gcc /usr/bin/cc

