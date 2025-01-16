#!/tools/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh

#>> ------------------------------------------------------
#>> DEPACK + COMPILE -------------------------------------

depack_src_file "attr"

#>> ------------------------------------------------------
#>> COMPILER SETTINGS ------------------------------------

. /compiler.settings

export CFLAGS=$CFLAGS
export CXXFLAGS=$CXXFLAGS
export LDFLAGS=$LDFLAGS

#>> ------------------------------------------------------
#>> FIX MANPAGES -----------------------------------------

sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in

#>> ------------------------------------------------------
#>> CONFIGURE --------------------------------------------

./configure \
--prefix=/usr \
--bindir=/bin

#>> ------------------------------------------------------
#>> MAKE -------------------------------------------------

make $MAKEFLAGS

#>> ------------------------------------------------------
#>> INSTALL ----------------------------------------------

make install install-dev install-lib
chmod -v 755 /usr/lib/libattr.so

mv -v /usr/lib/libattr.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so

