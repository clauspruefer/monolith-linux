#!/tools/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh

#>> ------------------------------------------------------
#>> DEPACK + COMPILE -------------------------------------

depack_src_file "zlib"

#>> ------------------------------------------------------
#>> COMPILER SETTINGS ------------------------------------

. /compiler.settings

CFLAGS=$(echo $CFLAGS | sed "s/-fPIE//g")
CXXFLAGS=$(echo $CXXFLAGS | sed "s/-fPIE//g")
LDFLAGS=$(echo $LDFLAGS | sed "s/-pie//g")

export CFLAGS=$CFLAGS
export CXXFLAGS=$CXXFLAGS
export LDFLAGS=$LDFLAGS

#>> ------------------------------------------------------
#>> OPTIMIZE CFLAGS --------------------------------------

CFLAGS="$CFLAGS -mstackrealign -fPIC" ./configure --prefix=/usr && make

#>> ------------------------------------------------------
#>> INSTALL ----------------------------------------------

make install

#>> ------------------------------------------------------
#>> MOVE SOs TO RIGHT PLACES -----------------------------

mv -v /usr/lib/libz.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so

