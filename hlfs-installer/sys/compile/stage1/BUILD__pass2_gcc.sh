#!/bin/bash

#>> ------------------------------------------------------
#>> ENVIRONMENT ------------------------------------------

. ./ENV__user.env

#>> ------------------------------------------------------
#>> FUNCTIONS --------------------------------------------

. ./build_functions.sh

#>> ------------------------------------------------------
#>> GCC STAGE 2  -----------------------------------------

rm -Rf $HLFS/sources/gcc-build

cd_by_pkgname "gcc"

# build system limit.h headers
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
`dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h

# correct dynamic linker for temp toolchain
for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done

# remove depacked from pass1
rm -R ./mpfr 2>&1 1>/dev/null
rm -R ./mpc 2>&1 1>/dev/null
rm -R ./gmp 2>&1 1>/dev/null
rm -R ./mpfr-3.1.2 2>&1 1>/dev/null
rm -R ./mpc-1.0.2 2>&1 1>/dev/null
rm -R ./gmp-6.0.0 2>&1 1>/dev/null

# depack mpfr, gmp, mpc libraries
tar -xf ../mpfr-3.1.2.tar.xz
mv -v mpfr-3.1.2 mpfr
tar -xf ../gmp-6.0.0a.tar.xz
mv -v gmp-6.0.0 gmp
tar -xf ../mpc-1.0.2.tar.gz
mv -v mpc-1.0.2 mpc

mkdir -v ../gcc-build
cd ../gcc-build

CC=$LFS_TGT-gcc \
AR=$LFS_TGT-ar \
RANLIB=$LFS_TGT-ranlib \
../gcc-4.8.2/configure \
--prefix=/tools \
--with-local-prefix=/tools \
--with-native-system-header-dir=/tools/include \
--enable-clocale=gnu \
--enable-shared \
--enable-threads=posix \
--enable-__cxa_atexit \
--enable-languages=c,c++ \
--disable-libstdcxx-pch \
--disable-multilib \
--disable-bootstrap \
--disable-libgomp \
--without-ppl \
--without-cloog \
--with-mpfr-include=$(pwd)/../gcc-4.8.2/mpfr/src \
--with-mpfr-lib=$(pwd)/mpfr/src/.libs

make $MAKEFLAGS
make install

#>> MAKE CC SYMBOLIC LINK
ln -vs gcc /tools/bin/cc

