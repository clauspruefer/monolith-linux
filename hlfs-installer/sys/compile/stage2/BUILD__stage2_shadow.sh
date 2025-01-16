#!/tools/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh

#>> ------------------------------------------------------
#>> DEPACK + COMPILE -------------------------------------

depack_src_file "shadow"

#>> ------------------------------------------------------
#>> COMPILER SETTINGS ------------------------------------

. /compiler.settings

export CFLAGS=$CFLAGS
export CXXFLAGS=$CXXFLAGS
export LDFLAGS=$LDFLAGS

#>> ------------------------------------------------------
#>> DISABLE GROUPS INSTALL COREUTIL PACKAGE BETTER -------

sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;

#>> ------------------------------------------------------
#>> DISABLE CHINESE/KOREAN MAN PAGES ---------------------

sed -i -e 's/ ko//' -e 's/ zh_CN zh_TW//' man/Makefile.in

#>> ------------------------------------------------------
#>> USE MD5 PER DEFAULT ----------------------------------

sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
       -e 's@/var/spool/mail@/var/mail@' etc/login.defs

#>> ------------------------------------------------------
#>> CONFIGURE --------------------------------------------

./configure \
--sysconfdir=/etc

#>> ------------------------------------------------------
#>> COMPILE ----------------------------------------------

make $MAKEFLAGS

#>> ------------------------------------------------------
#>> INSTALL ----------------------------------------------

make install

#>> ------------------------------------------------------
#>> INSTALL ----------------------------------------------

mv -v /usr/bin/passwd /bin

