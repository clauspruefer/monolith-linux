#>> ------------------------------------------------------
#>> MOUNT PROCFS -----------------------------------------

if [ $CHROOT__mount_procfs -eq 1 ]; then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> MOUTING PROC FILESYS"
	echo "#>> ----------------------------------------"

	PATH__install_chroot_proc="$PATH__install_chroot/proc";

	tst=`mount | grep $PATH__install_chroot_proc | wc -l`
	if [ $tst -eq 0 ]
	then
		mkdir -p $PATH__install_chroot_proc;	
		echo "MOUNTING /proc TO: $PATH__install_chroot_proc"
		mount -t proc proc $PATH__install_chroot_proc;
	fi

fi


#>> ------------------------------------------------------
#>> MAKE STATIC DEVICE NODES -----------------------------

if [ $CHROOT__mk_devnodes -eq 1 ]; then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> MAKING STATIC DEVICE NODES"
	echo "#>> ----------------------------------------"

	#>> set MAKEDEV version
	mkdev_version="MAKEDEV-1.8"

	#>> MAKE /dev DIR
	mkdir -p $PATH__install_chroot/dev

	#>> DEPACK MAKEDEV SCRIPT TO /dev
	tar -C $PATH__install_chroot/dev -xjf $PATH__install_chroot_sources/$mkdev_version.tar.bz2

	#>> MAKE SCRIPT EXECUTABLE
	chmod u+x $PATH__install_chroot/dev/$mkdev_version

	#>> CHANGE DIR TO DEV DIR
	actual_path=`pwd`;
	cd $PATH__install_chroot/dev

	#>> SET EXECUTABLE
	MAKEDEV=./$mkdev_version

	#>> MAKE STANDARD DEVICES
	$MAKEDEV std

	#>> MAKE CONSOLE DEVICES
  	$MAKEDEV console

	#>> MAKE HARDDRIVES (hdX, sdX)
	$MAKEDEV hda hdb hdc hdd sda sdb sdc sdd sde sdf sdg

	#>> MAKE REALTIME CLOCK
	$MAKEDEV rtc
 
	#>> MAKE ttyS0-S1
	$MAKEDEV ttyS0 ttyS1

	#>> MAKE PSEUDO TERMINAL MULTIPLEXER
	$MAKEDEV ptmx

        #>> MAKE PSEUDO TERMINAL MULTIPLEXER
        $MAKEDEV xvd

	#>> REMOVE MAKDEV SCRIPT
	rm $PATH__install_chroot/dev/$mkdev_version

	#>> MAKE /dev/pts
	mkdir -v $PATH__install_chroot/dev/pts

	#>> MAKE /dev/shm
	mkdir -v $PATH__install_chroot/dev/shm

	#>> CHANGE BACK DIR
	cd $actual_path

fi


#>> ------------------------------------------------------
#>> MAKE FSTAB
#>> ------------------------------------------------------

if [ $CHROOT__etc_mk_fstab -eq 1 ]
then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> GENERATING FSTAB"
	echo "#>> ----------------------------------------"

	#>> ------------------------------------------------------
	#>> CREATE /etc/fstab FILE
	#>> ------------------------------------------------------

	mkdir -p $PATH__install_chroot/etc
	chown root:root $PATH__install_chroot/etc
	chmod 755 $PATH__install_chroot/etc

	fstab_file="$PATH__install_chroot/etc/fstab"
	touch $fstab_file
	echo "#>> -- PARTITIONS" > $fstab_file

	#>> ------------------------------------------------------
	#>> DYNAMICALLY GENERATE PARTITIONS IN /etc/fstab
	#>> ------------------------------------------------------

	#>> LOOP ON DEVICES/PARTITIONS
	for device in $FS__devices; do

		for partitionnr in $( cat $CONFIGFILE__partitions | egrep -v "^#" | egrep -v "^exist" | egrep -v "^exten" | grep $device | sed "s/[\t][\t]*/\t/g" | cut -f2 | egrep -o "[0-9]+" | sort -n ); do

			tmp_grep="$device$partitionnr";

			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "2" "P_dev";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "5" "P_fs";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "8" "P_mount";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "9" "P_mount_opt";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "12" "P_fs_dump";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "13" "P_fs_order";

			printf "/dev/$P_dev\t$P_mount\t$P_fs\t$P_mount_opt\t$P_fs_dump $P_fs_order\n" >> $PATH__install_chroot/etc/fstab

		done

	done

fi

