#!/tools/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh


#>> ------------------------------------------------------
#>> DEPACK -----------------------------------------------

depack_src_file "bzip2"

#>> ------------------------------------------------------
#>> COMPILER SETTINGS ------------------------------------

. /compiler.settings

export CFLAGS=$CFLAGS
export CXXFLAGS=$CXXFLAGS
export LDFLAGS=$LDFLAGS

#>> ------------------------------------------------------
#>> PATCH + PROCESS  -------------------------------------

patch -Np1 -i ../bzip2-1.0.6-install_docs-1.patch

# make symbolic links relative, man pages in correct location
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

# ensure hardened build
sed -i "s/^LDFLAGS=/LDFLAGS=$LDFLAGS/g" Makefile
sed -i "s/^CFLAGS=/CFLAGS=$CFLAGS /g" Makefile

# if -O optimization set, remove -O2 in Makefile
[ "$( echo $CFLAGS | grep -o -e "-O" )" = "-O" ] && sed -i "s/-Winline -O2 -g/-Winline -g/g" Makefile

make $MAKEFLAGS -f Makefile-libbz2_so
make clean
make

make PREFIX=/usr install

#>> ------------------------------------------------------
#>> CP/CLEANUP -------------------------------------------

cp -av libbz2.so* /lib
ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
rm -v /usr/bin/{bunzip2,bzcat,bzip2}
ln -sv bzip2 /bin/bunzip2
ln -sv bzip2 /bin/bzcat

