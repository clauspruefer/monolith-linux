#!/tools/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh

#>> ------------------------------------------------------
#>> DEPACK + COMPILE -------------------------------------

depack_src_file "iproute2"

#>> ------------------------------------------------------
#>> COMPILER SETTINGS ------------------------------------

. /compiler.settings

export CFLAGS=$CFLAGS
export CXXFLAGS=$CXXFLAGS
export LDFLAGS=$LDFLAGS

# prepare makefile for hardened build (ignores exported flags)

# if -O found in exported flags remove hard set -O2 in Makefile
[ "$( echo $CFLAGS | grep -o -e "-O" )" = "-O" ] && sed -i "s/CCOPTS = -O2/CCOPTS = /g" Makefile

# replace correct cflags
sed -i "s/CCOPTS = /CCOPTS = $CFLAGS/g" Makefile

# add linker flags
sed -i "s/WFLAGS := -Wall -Wstrict-prototypes  -Wmissing-prototypes/WFLAGS := -Wall -Wstrict-prototypes  -Wmissing-prototypes $LDFLAGS/g" Makefile

#>> ------------------------------------------------------
#>> FIX ARPD ---------------------------------------------

sed -i '/^TARGETS/s@arpd@@g' misc/Makefile
sed -i /ARPD/d Makefile

#>> ------------------------------------------------------
#>> COMPILE ----------------------------------------------

make $MAKEFLAGS DESTDIR=

#>> ------------------------------------------------------
#>> INSTALL ----------------------------------------------

make DESTDIR= SBINDIR=/sbin MANDIR=/usr/share/man \
     DOCDIR=/usr/share/doc/iproute2-3.12.0 install

