#!/tools/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh

#>> ------------------------------------------------------
#>> DEPACK + COMPILE -------------------------------------

depack_src_file "binutils"

#>> ------------------------------------------------------
#>> COMPILER SETTINGS ------------------------------------

. /compiler.settings

export CFLAGS=$CFLAGS
export CXXFLAGS=$CXXFLAGS
export LDFLAGS=$LDFLAGS

#>> ------------------------------------------------------
#>> REMOVE BUILD DIR STAGE1 ------------------------------

rm -R /sources/binutils-build

#>> ------------------------------------------------------
#>> RM OUTDATED STANDARDS FILE ---------------------------

rm -fv etc/standards.info
sed -i.bak '/^INFO/s/standards.info //' etc/Makefile.in

#>> ------------------------------------------------------
#>> MAKE BUILD DIR ---------------------------------------

mkdir -v ../binutils-build
cd ../binutils-build

#>> ------------------------------------------------------
#>> CONFIGURE --------------------------------------------

../binutils-2.24/configure \
--prefix=/usr \
--enable-shared

#>> ------------------------------------------------------
#>> COMPILE ----------------------------------------------

make $MAKEFLAGS tooldir=/usr

#>> ------------------------------------------------------
#>> INSTALL ----------------------------------------------

make tooldir=/usr install

#>> ------------------------------------------------------
#>> INSTALL HEADER FILES ---------------------------------

cp -v ../binutils-2.24/include/libiberty.h /usr/include

