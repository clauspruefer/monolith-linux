#!/tools/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh

#>> ------------------------------------------------------
#>> DEPACK + COMPILE -------------------------------------

depack_src_file "kbd"

#>> ------------------------------------------------------
#>> PATCH ------------------------------------------------

patch -Np1 -i ../kbd-2.0.1-backspace-1.patch

#>> ------------------------------------------------------
#>> REPAIR -----------------------------------------------

sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

#>> ------------------------------------------------------
#>> COMPILER SETTINGS ------------------------------------

. /compiler.settings

export CFLAGS=$CFLAGS
export CXXFLAGS=$CXXFLAGS
export LDFLAGS=$LDFLAGS

#>> ------------------------------------------------------
#>> CONFIGURE --------------------------------------------

PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure \
--prefix=/usr \
--disable-vlock

#>> ------------------------------------------------------
#>> COMPILE ----------------------------------------------

make $MAKEFLAGS

#>> ------------------------------------------------------
#>> INSTALL ----------------------------------------------

make install

#>> MV FILES ---------------------------------------------

mv -v /usr/bin/{kbd_mode,loadkeys,openvt,setfont} /bin

