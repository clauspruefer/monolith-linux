#!/tools/bin/bash

#>> ------------------------------------------------------
#>> FUNCTIONS --------------------------------------------

. /tmp/build_functions.sh

#>> ------------------------------------------------------
#>> DEPACK  ----------------------------------------------

depack_src_file "vim"

#>> ------------------------------------------------------
#>> DEFAULT CONFIG LOCATION /etc  ------------------------

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

#>> ------------------------------------------------------
#>> COMPILER SETTINGS ------------------------------------

. /compiler.settings

export CFLAGS=$CFLAGS
export CXXFLAGS=$CXXFLAGS
export LDFLAGS=$LDFLAGS

#>> ------------------------------------------------------
#>> CONFIGURE  -------------------------------------------

./configure \
--prefix=/usr \
--disable-multibyte

#>> ------------------------------------------------------
#>> COMPILE  ---------------------------------------------

make $MAKEFLAGS

#>> ------------------------------------------------------
#>> INSTALL  ---------------------------------------------

make install

#>> ------------------------------------------------------
#>> VI WRAPPER  ------------------------------------------

ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done

#>> ------------------------------------------------------
#>> WRITE CONFIGURATION  ---------------------------------

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

set nocompatible
set backspace=2
syntax on
if (&term == "iterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF

