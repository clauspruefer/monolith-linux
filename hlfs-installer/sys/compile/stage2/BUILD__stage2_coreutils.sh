#!/tools/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh

#>> ------------------------------------------------------
#>> DEPACK + COMPILE -------------------------------------

depack_src_file "coreutils"

#>> ------------------------------------------------------
#>> PATCH ------------------------------------------------

patch -Np1 -i ../coreutils-8.22-i18n-4.patch

#>> ------------------------------------------------------
#>> COMPILER SETTINGS ------------------------------------

. /compiler.settings

LDFLAGS=$(echo $LDFLAGS | sed "s/-pie//g")

export CFLAGS=$CFLAGS
export CXXFLAGS=$CXXFLAGS
export LDFLAGS=$LDFLAGS

#>> ------------------------------------------------------
#>> CONFIGURE --------------------------------------------

FORCE_UNSAFE_CONFIGURE=1 \
./configure \
--prefix=/usr \
--enable-no-install-program=kill,uptime

#>> ------------------------------------------------------
#>> COMPILE ----------------------------------------------

make $MAKEFLAGS

#>> ------------------------------------------------------
#>> INSTALL ----------------------------------------------

make install

#>> ------------------------------------------------------
#>> MOVE FILES TO  -----------------------------------------

mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
/bin/mv -v /usr/bin/{rmdir,stty,sync,true,uname,test,[} /bin
/bin/mv -v /usr/bin/chroot /usr/sbin

/bin/mv -v /usr/bin/{head,sleep,nice} /bin

