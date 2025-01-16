#!/tools/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh

#>> ------------------------------------------------------
#>> DEPACK + COMPILE -------------------------------------

depack_src_file "sysklogd"

#>> ------------------------------------------------------
#>> PATCH ------------------------------------------------

pwd=$(pwd)
cd ..
patch -p0 < sysklogd-1.5-fix_close_no_systemmap_segfault.patch
cd $pwd

#>> ------------------------------------------------------
#>> COMPILER SETTINGS ------------------------------------

. /compiler.settings

export CFLAGS=$CFLAGS
export CXXFLAGS=$CXXFLAGS
export LDFLAGS=$LDFLAGS

#>> ------------------------------------------------------
#>> COMPILE ----------------------------------------------

make BINDIR=/sbin $MAKEFLAGS

#>> ------------------------------------------------------
#>> INSTALL ----------------------------------------------

make BINDIR=/sbin install

#>> ------------------------------------------------------
#>> WRITE CONFIG -----------------------------------------

cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# End /etc/syslog.conf
EOF

