#!/tools/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh

#>> ------------------------------------------------------
#>> DEPACK + COMPILE -------------------------------------

depack_src_file "e2fsprogs"

#>> ------------------------------------------------------
#>> COMPILER SETTINGS ------------------------------------

. /compiler.settings

CFLAGS="$CFLAGS -I/tools/include"

export CFLAGS=$CFLAGS
export CXXFLAGS=$CXXFLAGS
export LDFLAGS=$LDFLAGS

#>> ------------------------------------------------------
#>> MAKE BUILD DIR ---------------------------------------

mkdir -v build
cd build

#>> ------------------------------------------------------
#>> FIX CROSSCOMPILE CHECK -------------------------------

sed '3293,3351d' ../configure

#>> ------------------------------------------------------
#>> CONFIGURE --------------------------------------------

LIBS=-L/tools/lib \
PKG_CONFIG_PATH=/tools/lib/pkgconfig \
../configure \
--prefix=/usr \
--bindir=/bin \
--with-root-prefix="" \
--disable-libblkid \
--disable-libuuid \
--disable-uuidd \
--disable-fsck \
--with-gnu-ld

#>> ------------------------------------------------------
#>> COMPILE ----------------------------------------------

make $MAKEFLAGS

#>> ------------------------------------------------------
#>> INSTALL ----------------------------------------------

make install

#>> ------------------------------------------------------
#>> INSTALL LIBS -----------------------------------------

make install-libs

chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

