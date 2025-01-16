#!/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh

#>> ------------------------------------------------------
#>> GLIBC  -----------------------------------------------

depack_src_file "glibc"

#>> ------------------------------------------------------
#>> REMOVE BUILD DIR STAGE1 ------------------------------

rm -R /sources/glibc-build

#>> ------------------------------------------------------
#>> PATCH  -----------------------------------------------

patch -Np1 -i ../glibc-2.12.2-pt_pax-1.patch
patch -Np1 -i ../glibc-2.19-fhs-1.patch

#>> ------------------------------------------------------
#>> BUILD  -----------------------------------------------

mkdir -v ../glibc-build
cd ../glibc-build

# build glibc nonhardened
cat >> configparms << "EOF"
CC += -fPIC -fno-stack-protector -U_FORTIFY_SOURCE
CXX += -fPIC -fno-stack-protector -U_FORTIFY_SOURCE
EOF

../glibc-2.19/configure \
--prefix=/usr \
--disable-profile \
--enable-kernel=2.6.32 \

make $MAKEFLAGS

# build glibc tools hardened
cat > configparms << "EOF"
CC += -fPIE -fstack-protector-all -D_FORTIFY_SOURCE=2
CXX += -fPIE -fstack-protector-all -D_FORTIFY_SOURCE=2
CFLAGS-sln.c += -fno-PIC -fno-PIE
+link = $(CC) -pie -Wl,-O1 -nostdlib -nostartfiles -o $@ \
    $(sysdep-LDFLAGS) $(config-LDFLAGS) $(LDFLAGS) $(LDFLAGS-$(@F)) \
    $(combreloc-LDFLAGS) $(relro-LDFLAGS) $(hashstyle-LDFLAGS) \
    -Wl,-z,now -Wl,--warn-shared-textrel,--fatal-warnings \
    $(addprefix $(csu-objpfx),S$(start-installed-name)) \
    $(+preinit) $(+prectorS) \
    $(filter-out $(addprefix $(csu-objpfx),start.o \
    S$(start-installed-name))\
    $(+preinit) $(link-extra-libs) \
    $(common-objpfx)libc% $(+postinit),$^) \
    $(link-extra-libs) $(link-libc) $(+postctorS) $(+postinit)
EOF

make $MAKEFLAGS

# install
cp -v ../glibc-2.19/iconvdata/gconv-modules iconvdata

touch /etc/ld.so.conf

make install

#>> ------------------------------------------------------
#>> MAKE LOCALES  ----------------------------------------

mkdir -pv /usr/lib/locale

localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8

#>> ------------------------------------------------------
#>> CONFIGURE GLIBC  -------------------------------------

cat > /etc/nsswitch.conf << "EOF"
#BEGIN - Monolith Linux - glibc "/etc/nsswitch.conf"

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

#END - Monolith Linux - glibc "/etc/nsswitch.conf"
EOF

#>> ------------------------------------------------------
#>> SELECT TIMEZONE  -------------------------------------

TZ="$GLIBC__timezone"; export TZ

cp -v --remove-destination /usr/share/zoneinfo/$TZ /etc/localtime


#>> ------------------------------------------------------
#>> CONFIGURE DYNAMIC LOADER  ----------------------------

cat > /etc/ld.so.conf << "EOF"
#BEGIN - Monolith Linux - glibc "/etc/ld.so.conf"

/usr/local/lib
/opt/lib

#END Monolith Linux - glibc "/etc/ld.so.conf"
EOF

