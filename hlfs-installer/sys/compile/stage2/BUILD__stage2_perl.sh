#!/tools/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh

#>> ------------------------------------------------------
#>> DEPACK + COMPILE -------------------------------------

depack_src_file "perl"

#>> ------------------------------------------------------
#>> FIX STACKPROTECTOR IN CONFIGURE SCRIPT ---------------

sed -i 's/-fstack-protector/&-all/' Configure

#>> ------------------------------------------------------
#>> COMPILE EXTERNAL ZLIB --------------------------------

sed -i -e "s|BUILD_ZLIB\s*= True|BUILD_ZLIB = False|" \
       -e "s|INCLUDE\s*= ./zlib-src|INCLUDE    = /usr/include|" \
       -e "s|LIB\s*= ./zlib-src|LIB        = /usr/lib|" \
    cpan/Compress-Raw-Zlib/config.in

#>> ------------------------------------------------------
#>> PATCH ------------------------------------------------

patch -Np1 -i ../perl-5.18.2-libc-1.patch

#>> ------------------------------------------------------
#>> COMPILER SETTINGS ------------------------------------

. /compiler.settings

export CFLAGS=$CFLAGS
export CXXFLAGS=$CXXFLAGS
export LDFLAGS=$LDFLAGS

#>> ------------------------------------------------------
#>> CONFIGURE --------------------------------------------

sh Configure \
-des \
-Dprefix=/usr \
-Dvendorprefix=/usr \
-Dman1dir=/usr/share/man/man1 \
-Dman3dir=/usr/share/man/man3 \
-Dpager="/usr/bin/less -isR" \
-Dccflags="$CFLAGS" \
-Dldflags="$LDFLAGS" \
-Duseshrplib

#>> ------------------------------------------------------
#>> COMPILE ----------------------------------------------

make $MAKEFLAGS

#>> ------------------------------------------------------
#>> INSTALL ----------------------------------------------

make install

