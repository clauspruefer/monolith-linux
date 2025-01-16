#!/bin/bash

#>> ------------------------------------------------------
#>> ENVIRONMENT ------------------------------------------

. ./ENV__user.env

#>> ------------------------------------------------------
#>> FUNCTIONS --------------------------------------------

. ./build_functions.sh


#>> ------------------------------------------------------
#>> BUILD STAGE1 GCC -------------------------------------

# depack gcc
depack_src_file "gcc"

# depack used libs
tar -xf ../mpfr-3.1.2.tar.xz
mv -v mpfr-3.1.2 mpfr
tar -xf ../gmp-6.0.0a.tar.xz
mv -v gmp-6.0.0 gmp
tar -xf ../mpc-1.0.2.tar.gz
mv -v mpc-1.0.2 mpc

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

# compile
mkdir -v ../gcc-build
cd ../gcc-build

../gcc-4.8.2/configure                           \
--target=$LFS_TGT                                \
--prefix=/tools                                  \
--with-sysroot=$LFS                              \
--with-newlib                                    \
--without-headers                                \
--with-local-prefix=/tools                       \
--with-native-system-header-dir=/tools/include   \
--disable-nls                                    \
--disable-shared                                 \
--disable-multilib                               \
--disable-decimal-float                          \
--disable-threads                                \
--disable-libatomic                              \
--disable-libgomp                                \
--disable-libitm                                 \
--disable-libmudflap                             \
--disable-libquadmath                            \
--disable-libsanitizer                           \
--disable-libssp                                 \
--disable-libstdc++-v3                           \
--enable-languages=c,c++                         \
--with-mpfr-include=$(pwd)/../gcc-4.8.2/mpfr/src \
--with-mpfr-lib=$(pwd)/mpfr/src/.libs

make $MAKEFLAGS gcc_cv_libc_provides_ssp=yes
make install

ln -vs libgcc.a `$LFS_TGT-gcc -print-libgcc-file-name | \
    sed 's/libgcc/&_eh/'`

