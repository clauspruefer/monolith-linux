#>> ------------------------------------------------------
#>> PREPARE BOOT PARTITION / SET GRUB CONFIG
#>> ------------------------------------------------------

if [ $CONFIG__grub -eq 1 ]; then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> PREPARE BOOT PARTITION / GRUB"
	echo "#>> ----------------------------------------"

	#>> ------------------------------------------------------
	#>> COMPILE GRUB (NON HARDENED) AND INSTALL ON "BOOT CD"
	#>> ------------------------------------------------------

	TMP_PATH=`pwd`

	cd $PATH__install_chroot_sources

	tar -xzf $SOURCE__grub
	cd $SOURCE__grub_depack_dir

	./configure \
	--prefix=/usr \
	--sysconfdir=/etc \
	--disable-grub-emu-usb \
	--disable-grub-fstest \
	--disable-efiemu

	make
	make install

	cd $TMP_PATH


	#>> ------------------------------------------------------
	#>> GENERATE / COPY CONFIG FILE
	#>> ------------------------------------------------------

	BOOT_PARTITION="/boot"

	GRUB__CONFIG_DIR="$BOOT_PARTITION/grub"
	GRUB__CONFIG_FILE="grub.cfg"
	GRUB__SPLASHIMAGE_FILE="splash.xpm.gz"

	GRUB__CONFIG_DIR_ESCAPED=`echo $GRUB__CONFIG_DIR | sed 's/\//\\\\\//g'`

	GRUB__boot_title="$DISTRO__name $DISTRO__version $DISTRO__status"
	GRUB__boot_splashimage="splashimage=\($GRUB__install_partition\)$GRUB__CONFIG_DIR_ESCAPED\/$GRUB__SPLASHIMAGE_FILE"

	#>> READ GRUB.CONF TEMPLATE, REPLACE VARIABLES AND WRITE TO BOOT PARTITION
	cat $PATH__config/grub.cfg | sed "s/\$boot_timeout/$GRUB__boot_timeout/gi" > /tmp/grub_config1;
	cat /tmp/grub_config1 | sed "s/\$boot_default/$GRUB__boot_default/gi" > /tmp/grub_config2;
	cat /tmp/grub_config2 | sed "s/\$boot_fallback/$GRUB__boot_fallback/gi" > /tmp/grub_config3;
	cat /tmp/grub_config3 | sed "s/\$boot_splashimage/$GRUB__boot_splashimage/gi" > /tmp/grub_config4;
	cat /tmp/grub_config4 | sed "s/\$boot_title/$GRUB__boot_title/gi" > /tmp/grub_config5;
	cat /tmp/grub_config5 | sed "s/\$root_partition/\/dev\/$GRUB__root_partition/gi" > /tmp/grub_config6;
	cat /tmp/grub_config6 | sed "s/\$install_partition/$GRUB__install_partition/gi" > /tmp/grub_config7;
	cat /tmp/grub_config7 | sed "s/\$boot_kernel/boot\/$KERNEL__name/gi" > /tmp/grub_config8;

	#>> MAKE DIR AND COPY CONFIG FILE
	mkdir -p $PATH__install_chroot$GRUB__CONFIG_DIR
	cp -f /tmp/grub_config8 $PATH__install_chroot$GRUB__CONFIG_DIR/$GRUB__CONFIG_FILE

	#>> ------------------------------------------------------
	#>> INSTALL GRUB ON MBR
	#>> ------------------------------------------------------

	echo "Running grub-install with --root-directory=$PATH__install_chroot and GRUB__install_device:$GRUB__install_device"
	grub-install --root-directory=$PATH__install_chroot $GRUB__install_device

fi

