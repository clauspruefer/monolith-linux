#!/tools/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh

#>> ------------------------------------------------------
#>> DEPACK + COMPILE -------------------------------------

depack_src_file "ncurses"

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
#>> CONFIGURE --------------------------------------------

./configure \
--prefix=/usr \
--mandir=/usr/share/man \
--with-shared \
--without-debug \
--enable-pc-files \
--enable-widec

#>> ------------------------------------------------------
#>> MAKE -------------------------------------------------

make $MAKEFLAGS

#>> ------------------------------------------------------
#>> INSTALL ----------------------------------------------

make install

#>> ------------------------------------------------------
#>> POSTINST ---------------------------------------------

mv -v /usr/lib/libncursesw.so.5* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so

for lib in ncurses form panel menu ; do
	rm -vf /usr/lib/lib${lib}.so
	echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
	ln -sfv lib${lib}w.a /usr/lib/lib${lib}.a
	ln -sfv ${lib}w.pc /usr/lib/pkgconfig/${lib}.pc
done

ln -sfv libncurses++w.a /usr/lib/libncurses++.a

