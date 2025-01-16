#!/tools/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh


#>> ------------------------------------------------------
#>> DEPACK + COMPILE -------------------------------------

depack_src_file "grub"


#>> ------------------------------------------------------
#>> CONFIGURE --------------------------------------------

./configure --prefix=/usr           \
             --sysconfdir=/etc       \
             --disable-grub-emu-usb  \
             --disable-grub-fstest   \
             --disable-efiemu


#>> ------------------------------------------------------
#>> COMPILE ----------------------------------------------

make $MAKEFLAGS

#>> ------------------------------------------------------
#>> INSTALL ----------------------------------------------

make install
