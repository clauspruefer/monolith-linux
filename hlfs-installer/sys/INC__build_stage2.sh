#>> ------------------------------------------------------
#>> BUILD SYSTEM -----------------------------------------

if [ $STAGE__2_compile -eq 1 ]; then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> START BUILDING STAGE 2"
	echo "#>> ----------------------------------------"

	#>> ------------------------------------------------------
	#>> COPY INCLUDE FUNCTIONS -------------------------------

	TMP_FILE="build_functions.sh"

	PATH_DST="$PATH__install_chroot/tmp"
	FILE_DST="$PATH_DST/$TMP_FILE"

	mkdir -p $PATH_DST
	chown root:root $PATH_DST
	chmod 777 $PATH_DST
	chmod +t $PATH_DST

	cp $PATH__sys/compile/stage1/$TMP_FILE $FILE_DST

	chown 0:0 $FILE_DST
	chmod 750 $FILE_DST

	#>> ------------------------------------------------------
	#>> SET CHROOT PATHS -------------------------------------

	echo "LFS=" > $PATH__install_chroot/tmp/HLFS_paths
	echo "HLFS=" >> $PATH__install_chroot/tmp/HLFS_paths
	echo "HLFS_CONFIG=/tmp" >> $PATH__install_chroot/tmp/HLFS_paths

	cp $SYS_PWD/config/packages.conf $PATH__install_chroot/tmp/packages.conf

	#>> ------------------------------------------------------
	#>> CREATE NETWORK FILES------ ---------------------------

	echo "127.0.0.1 localhost $NET__hostname $NET__hostname.$NET__domain" > $PATH__install_chroot/etc/hosts

	echo $NET__hostname > $PATH__install_chroot/etc/hostname

	FILE_RESOLV_CONF="$PATH__install_chroot/etc/resolv.conf"
	echo "# monolith linux resolv.conf" > $FILE_RESOLV_CONF
	[ -n "$NET__nameserver1" ] && echo $NET__nameserver1 >> $FILE_RESOLV_CONF
	[ -n "$NET__nameserver2" ] && echo $NET__nameserver2 >> $FILE_RESOLV_CONF

	#>> ------------------------------------------------------
	#>> MAKE DIRS / LINKS ------------------------------------

	exec_stage2_tmpfile "prepare_fs"

	#>> ------------------------------------------------------
	#>> START COMPILING --------------------------------------

	exec_stage2_tmpfile "linux_headers"
	exec_stage2_tmpfile "man_pages"
	exec_stage2_tmpfile "glibc"
	exec_stage2_tmpfile "adjust_toolchain"
	exec_stage2_tmpfile "zlib"
	exec_stage2_tmpfile "file"
	exec_stage2_tmpfile "binutils"
	exec_stage2_tmpfile "gmp"
	exec_stage2_tmpfile "mpfr"
	exec_stage2_tmpfile "mpc"
	exec_stage2_tmpfile "sed"
	exec_stage2_tmpfile "bzip2"
	exec_stage2_tmpfile "pkg-config"
	exec_stage2_tmpfile "ncurses"
	exec_stage2_tmpfile "attr"
	exec_stage2_tmpfile "shadow"
	exec_stage2_tmpfile "psmisc"
	exec_stage2_tmpfile "procps"
	exec_stage2_tmpfile "util-linux"
	exec_stage2_tmpfile "e2fsprogs"
	exec_stage2_tmpfile "coreutils"
	exec_stage2_tmpfile "iana-etc"
	exec_stage2_tmpfile "m4"
	exec_stage2_tmpfile "flex"
	exec_stage2_tmpfile "bison"
	exec_stage2_tmpfile "grep"
	exec_stage2_tmpfile "readline"
	exec_stage2_tmpfile "bash"
	exec_stage2_tmpfile "bc"
	exec_stage2_tmpfile "libtool"
	exec_stage2_tmpfile "gdbm"
	exec_stage2_tmpfile "expat"
	exec_stage2_tmpfile "inetutils"
	exec_stage2_tmpfile "perl"
	exec_stage2_tmpfile "autoconf"
	exec_stage2_tmpfile "automake"
	exec_stage2_tmpfile "diffutils"
	exec_stage2_tmpfile "gawk"
	exec_stage2_tmpfile "findutils"
	exec_stage2_tmpfile "gettext"
	exec_stage2_tmpfile "gzip"
	exec_stage2_tmpfile "xz"
	exec_stage2_tmpfile "less"
	exec_stage2_tmpfile "iproute2"
	exec_stage2_tmpfile "kbd"
	exec_stage2_tmpfile "make"
	exec_stage2_tmpfile "patch"
	exec_stage2_tmpfile "sysklogd"
	exec_stage2_tmpfile "sysvinit"
	exec_stage2_tmpfile "tar"
	exec_stage2_tmpfile "vim"
	exec_stage2_tmpfile "iptables"

fi

