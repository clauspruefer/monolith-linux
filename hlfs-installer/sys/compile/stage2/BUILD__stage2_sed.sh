#!/tools/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh

#>> ------------------------------------------------------
#>> DEPACK + COMPILE -------------------------------------

depack_src_file "sed"

#>> ------------------------------------------------------
#>> COMPILER SETTINGS ------------------------------------

. /compiler.settings

export CFLAGS=$CFLAGS
export CXXFLAGS=$CXXFLAGS
export LDFLAGS=$LDFLAGS

#>> ------------------------------------------------------
#>> CONFIGURE --------------------------------------------

./configure \
--prefix=/usr \
--bindir=/bin \
--htmldir=/usr/share/doc/sed-4.2.2

#>> ------------------------------------------------------
#>> MAKE -------------------------------------------------

make $MAKEFLAGS

#>> ------------------------------------------------------
#>> INSTALL ----------------------------------------------

make install

