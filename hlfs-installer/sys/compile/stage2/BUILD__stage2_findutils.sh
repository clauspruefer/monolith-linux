#!/tools/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh

#>> ------------------------------------------------------
#>> DEPACK + COMPILE -------------------------------------

depack_src_file "findutils"

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
--localstatedir=/var/lib/locate

#>> ------------------------------------------------------
#>> COMPILE ----------------------------------------------

make $MAKEFLAGS

#>> ------------------------------------------------------
#>> INSTALL ----------------------------------------------

make install

#>> ------------------------------------------------------
#>> MV BINARIES ------------------------------------------

mv -v /usr/bin/find /bin
sed -i 's/find:=${BINDIR}/find:=\/bin/' /usr/bin/updatedb

