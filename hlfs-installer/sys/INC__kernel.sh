#>> ------------------------------------------------------
#>> COMPILE KERNEL SOURCE
#>> ------------------------------------------------------

if [ $CONFIG__kernel -eq 1 ]; then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> BUILD KERNEL"
	echo "#>> ----------------------------------------"

	#>> ------------------------------------------------------
	#>> SET PATHS/VARS
	#>> ------------------------------------------------------

	KERNEL__packed="$KERNEL__version.tar.gz"

	KERNEL__chroot_install="$PATH__install_chroot/usr/src"
	KERNEL__chroot_linux="$KERNEL__chroot_install/linux"

	KERNEL__dir="$KERNEL__chroot_install/$KERNEL__version"

	KERNEL__patch_grsecurity="grsecurity-3.0-3.2.56-201404031155.patch"
	KERNEL__patch_disable_ptrace="linux-3.2.56-disable_ptrace.patch"


	#>> ------------------------------------------------------
	#>> REMOVE DEPACKED KERNEL DIR IF EXIST
	#>> ------------------------------------------------------
	rm -fR $KERNEL__dir

	#>> ------------------------------------------------------
	#>> EXTRACT LINUX KERNEL AND MAKE SYMLINK
	#>> ------------------------------------------------------
	cp $PATH__sources/$KERNEL__packed $KERNEL__chroot_install

	FILENAME="KERNEL__extract"
	CHROOT_TMPFILE="$PATH__chroot_tmp/CHROOT__$FILENAME.sh"

	echo "#!/bin/bash" > $CHROOT_TMPFILE
	echo "cd /usr/src" >> $CHROOT_TMPFILE
	echo "tar -xf $KERNEL__packed" >> $CHROOT_TMPFILE
	echo "ln -s $KERNEL__version linux" >> $CHROOT_TMPFILE

	exec_chroot_tmpfile $FILENAME


	#>> ------------------------------------------------------
	#>> COPY LINUX PATCHES+APPLY
	#>> ------------------------------------------------------
	cp $PATH__sources/$KERNEL__patch_grsecurity $KERNEL__chroot_install
	cp $PATH__sources/$KERNEL__patch_disable_ptrace $KERNEL__chroot_install

	FILENAME="KERNEL__patch"
	CHROOT_TMPFILE="$PATH__chroot_tmp/CHROOT__$FILENAME.sh"

	echo "#!/bin/bash" > $CHROOT_TMPFILE
	echo "cd /usr/src" >> $CHROOT_TMPFILE
	echo "patch -p0 < $KERNEL__patch_disable_ptrace" >> $CHROOT_TMPFILE

	echo "cd /usr/src/linux" >> $CHROOT_TMPFILE
	echo "patch -p1 < ../$KERNEL__patch_grsecurity" >> $CHROOT_TMPFILE

	exec_chroot_tmpfile $FILENAME


	#>> ------------------------------------------------------
	#>> COPY KERNEL CONFIG FILE
	#>> ------------------------------------------------------

	cp $PATH__profile/kernel.conf $KERNEL__chroot_linux/.config

	#>> ------------------------------------------------------
	#>> BUILD THE KERNEL
	#>> ------------------------------------------------------

	FILENAME="KERNEL__build"
	CHROOT_TMPFILE="$PATH__chroot_tmp/CHROOT__$FILENAME.sh"

	echo "#!/bin/bash" > $CHROOT_TMPFILE

	#>> MODULES ENABLED KERNEL
	if [ $BUILD__kernel_modules -eq 1 ]; then
		echo "cd /usr/src/linux && make $MAKEFLAGS && make modules && make modules_install" >> $CHROOT_TMPFILE
	fi

	#>> NON MODULES ENABLED KERNEL
	if [ $BUILD__kernel_modules -eq 0 ]; then
		echo "cd /usr/src/linux && make $MAKEFLAGS" >> $CHROOT_TMPFILE
	fi

	exec_chroot_tmpfile $FILENAME


	#>> ------------------------------------------------------
	#>> COPY BUILT KERNEL TO BOOT PARTITION
	#>> ------------------------------------------------------
	cp -f $KERNEL__chroot_linux/arch/$ARCH__system/boot/bzImage $PATH__install_chroot/boot/$KERNEL__name
	chmod 640 $PATH__install_chroot/boot/$KERNEL__name

fi
 
