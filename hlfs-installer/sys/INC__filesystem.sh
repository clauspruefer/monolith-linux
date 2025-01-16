#>> ------------------------------------------------------
#>> UNMOUNT MOUNTED PARTITIONS ---------------------------

if [ $FS__unmount_partitions -eq 1 ]; then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> UNMOUNTING PARTITIONS"
	echo "#>> ----------------------------------------"

	# umount /dev
	umount_partition "$PATH__install_chroot/dev"

	# umount /proc
	umount_partition "$PATH__install_chroot/proc"

	# umount all mounted partitions found in partitions.txt

	# check for installation on real host
	[ $INSTALL__on_host -eq 0 ] && part_mp_col_index=8
	[ $INSTALL__on_host -eq 1 ] && part_mp_col_index=7

	# unmount existing partitions for type "existing"
	for mount in $( cat $CONFIGFILE__partitions | egrep -v "^#" | egrep "^exist" | sed "s/[\t][\t]*/\t/g" | cut -f$part_mp_col_index ); do
		umount_partition "$mount"
	done

	# unmount existing partitions for type "new" (primary or logically)
	for mount in $( cat $CONFIGFILE__partitions | egrep -v "^#" | egrep "^(prima|logic)" | grep -v swap | sed "s/[\t][\t]*/\t/g" | cut -f$part_mp_col_index | sort -r ); do
		[ "$mount" == "/" ] && mount='';
		umount_partition "$PATH__install_chroot$mount"
	done

fi


#>> ------------------------------------------------------
#>> DELETE OLD PARTITIONS --------------------------------

if [ $FS__rm_partitions -eq 1 ]; then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> DELETE OLD PARTITIONS"
	echo "#>> ----------------------------------------"

	[ $INSTALL__on_host -eq 0 ] && loop_on_devices=$FS__devices_install_host
	[ $INSTALL__on_host -eq 1 ] && loop_on_devices=$FS__devices

	for device in $loop_on_devices; do

		for partitionnr in $( cat $CONFIGFILE__partitions | egrep -v "^#" | egrep -v "^exist" | grep $device | sed "s/[\t][\t]*/\t/g" | cut -f3 | egrep -o "[0-9]+" | sort -rn ); do

			fstype=`cat $CONFIGFILE__partitions | egrep "$device$partitionnr" | sed "s/[\t][\t]*/\t/g" | cut -f5`;
			#echo "FSTYPE:$fstype"

			# check if partition type is swap, if yes turn swap off
			if [ "$fstype" == "swap" ]; then
				echo "TURNING SWAPOFF ON:/dev/$device$partitionnr"
				swapoff /dev/$device$partitionnr 2>/dev/null
			fi

			echo "DELETING PARTITION /dev/$device$partitionnr"
			parted -s /dev/$device rm $partitionnr 1>/dev/null 2>/dev/null

		done

	done;

fi


#>> ------------------------------------------------------
#>> MAKE DISKLABEL ---------------------------------------

if [ $FS__mk_disklabel -eq 1 ]; then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> MAKING DISKLABEL"
	echo "#>> ----------------------------------------"

	[ $INSTALL__on_host -eq 0 ] && loop_on_devices=$FS__devices_install_host
	[ $INSTALL__on_host -eq 1 ] && loop_on_devices=$FS__devices

	for device in $loop_on_devices; do

		varname=FS__mk_disklabel_$device;
		eval disklabel_type=\$$varname;

		if [ "$disklabel_type" != "" ]; then

			echo "MAKING DISKLABEL TYPE:$disklabel_type ON DEV:$device";

			parted -s /dev/$device mklabel $disklabel_type 1>/dev/null 2>/dev/null

		fi

	done;

fi


#>> ------------------------------------------------------
#>> CREATE NEW PARTITIONS --------------------------------

if [ $FS__mk_partitions -eq 1 ]; then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> CREATE PARTITIONS"
	echo "#>> ----------------------------------------"

	P_start='';
	P_end='';

	P_end_BLOCKS=0;
	P_end_BYTES=0;

	[ $INSTALL__on_host -eq 0 ] && loop_on_devices=$FS__devices_install_host
	[ $INSTALL__on_host -eq 1 ] && loop_on_devices=$FS__devices

	for device in $loop_on_devices; do

		echo "DEVICE:/dev/$device"
		echo

		#>> TOUCH TMPFILE FOR FDISK PARTITIONS
		tmpfile="/tmp/partitions_$device.in";

		#>> REMOVE FILE IF EXISTS
		rm -f $tmpfile > /dev/null 2>&1

		#>> CREATE FILE
		touch $tmpfile;

		#>> GET DRIVE HEADS, SECTORS AND CYLINDER UNITS
		P_device_heads=$( fdisk -l /dev/$device | egrep "^[0-9]+ heads" | egrep -o "^[0-9]+ ");
		P_device_sectors=$( fdisk -l /dev/$device | egrep -o "[0-9]+ sectors/track" | egrep -o "[0-9]+" );
		P_device_unit_size=$( fdisk -l /dev/$device | egrep "^Units" | egrep -o "[0-9]+ bytes$" | egrep -o "[0-9]+" );

		echo "DEVICE_HEADS:$P_device_heads";
		echo "DEVICE_SECTORS:$P_device_sectors";
		echo "DEVICE_UNIT_SIZE:$P_device_unit_size";
		echo

		for partitionnr in $( cat $CONFIGFILE__partitions | egrep -v "^#" | grep $device | sed "s/[\t][\t]*/\t/g" | cut -f3 | egrep -o "[0-9]+" | sort -n ); do

			tmp_grep="$device$partitionnr";

			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "1" "P_type";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "2" "P_dev";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "3" "P_instdev";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "4" "P_parttype";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "5" "P_fs";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "6" "P_size";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "7" "P_boot";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "8" "P_mount";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "9" "P_mount_opt";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "10" "P_label";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "11" "P_fs_opt";

			#>> SET OUTPUT DEVICE
			formated_device="/dev/$device$partitionnr"

			#>> TRANSLATE PARTITION TYPES
			[ "$P_type" == "prima" ] && P_type="primary"
			[ "$P_type" == "exten" ] && P_type="extended"
			[ "$P_type" == "logic" ] && P_type="logical"

			#>> DEBUG OUTPUT
			if [ "$GLOBAL__debug" -gt 10 ]; then
				echo -n "P_TYPE:$P_type ";
				echo -n "P_DEV:$P_dev ";
				echo -n "P_INSTDEV:$P_instdev ";
				echo -n "P_PARTTYPE:$P_parttype ";
				echo -n "P_FS:$P_fs ";
				echo -n "P_SIZE:$P_size ";
				echo -n "P_BOOT:$P_boot ";
				echo -n "P_MOUNT:$P_mount ";
				echo -n "P_MOUNT_OPT:$P_mount_opt ";
				echo -n "P_LABEL:$P_label ";
				echo -n "P_FS_OPT:$P_fs_opt";
				echo;
			fi

			#>> CALCULATE SIZES OF EXISTING PARTITIONS
			if [ "$P_type" == "exist" ]; then

				echo "DEVICE:$device"

				tmp_line=`fdisk -l /dev/$device | egrep "^\/dev\/$device$partitionnr" | sed 's/\*//g'`;
				tmp_line=`echo $tmp_line | sed 's/[\t][\t]*/ /g'`;

				PART_EXIST__cylinders=`echo $tmp_line | cut -d " " -f 3`;

				echo "EXIST_CYL:$PART_EXIST__cylinders"

				let "P_end_BYTES=($PART_EXIST__cylinders*$P_device_unit_size)";
				echo "EXIST_PART END_BYTES:$P_end_BYTES";

				if [ "$GLOBAL__debug" -gt 10 ]; then
					echo "P_start_BYTES:$P_start_BYTES P_end_BYTES:$P_end_BYTES"
				fi

				echo "GOT CYLINDER SIZE FROM: $formated_device FS:$P_fs CYLINDER SIZE:$PART_EXIST__cylinders";
			fi

			#>> MAKE PRIMARY/EXTENDED/LOGICAL PARTITIONS
			if [ "$P_type" == "primary" ] || [ "$P_type" == "extended" ] || [ "$P_type" == "logical" ]; then

				#>> CALCULATE PARTITION MULTIPLIER
				P_size_type='B';
				P_size_multipl=0;

				P_size_type=`echo $P_size | egrep -o "[M|G|B]$"`;
				P_size_found=`echo $P_size | egrep -o "[0-9]+"`;

				if [ "$P_size_type" == "G" ]; then
					P_size_multipl=1000000;
				fi

				if [ "$P_size_type" == "M" ]; then
					P_size_multipl=1000;
				fi

				#>> DEBUG
				if [ "$GLOBAL__debug" -gt 10 ]; then
					echo -n "P_size_type:$P_size_type ";
					echo -n "P_size_found:$P_size_found ";
					echo -n "P_size_multipl:$P_size_multipl";
					echo;
				fi

				#>> GET PREVIOUS PARTITION END BYTES, IF NO EXISTING PART FOUND THIS IS 0
				P_start_BYTES=$P_end_BYTES;

				let "P_calc_size=$P_size_found*$P_size_multipl*1000";
				let "P_end_BYTES=$P_start_BYTES+$P_calc_size";

				echo "P_start_BYTES:$P_start_BYTES P_end_BYTES:$P_end_BYTES"

				let "P_start_CYL=($P_start_BYTES/$P_device_unit_size)+2049";
				let "P_end_CYL=($P_end_BYTES/$P_device_unit_size)+2048";

				echo "PROCESS: $formated_device CYL_start:$P_start_CYL CYL_end:$P_end_CYL"

				#>> DEBUG OUT
				[ "$GLOBAL__debug" -gt 0 ] && echo "PART_NR:$partitionnr TYPE:$P_type FILESYS:$P_fs START_CYL:$P_start_CYL END_CYL:$P_end_CYL"

				#>> -------------------------
				#>> WRITE FDISK FILE
				#>> -------------------------

				#>> NEW PARTITION
				echo "n" >> $tmpfile;

				#>> PARTITION_TYPE
				[ "$P_type" == "primary" ] && echo "p" >> $tmpfile
				[ "$P_type" == "extended" ] && echo "e" >> $tmpfile
				[ "$P_type" == "logical" ] && echo "l" >> $tmpfile

				#>> PARTITION NR (JUST FOR PRIMARY/EXTENDED PARTITIONS)
				[ "$P_type" == "primary" ] && echo $partitionnr >> $tmpfile
				[ "$P_type" == "extended" ] && echo $partitionnr >> $tmpfile

				#>> START/END CYLINDERS
				echo $P_start_CYL >> $tmpfile
				echo $P_end_CYL >> $tmpfile

				#>> SET PARTITION TYPE
				if [ $P_type == "primary" ] || [ $P_type == "logical" ]; then
					echo "t" >> $tmpfile
					[ $partitionnr -ne 1 ]	&& echo $partitionnr >> $tmpfile
					echo $P_parttype >> $tmpfile
				fi

				#>> MAKE PARTITION BOOTABLE
				if [ "$P_boot" == "1" ]; then
					echo "a" >> $tmpfile
					echo $partitionnr >> $tmpfile
				fi

				#>> IF PART_TYPE = EXTENDED -> RESET P_end_BYTES
				if [ "$P_type" == "extended" ]; then
					let "P_end_BYTES=$P_start_BYTES";
				fi

			fi

		done;

	#>> SET FDISK TO WRITE PART TABLE AND QUIT
	echo "w" >> $tmpfile
	echo "q" >> $tmpfile

	echo
	echo "WRITING PARTITION TABLE!"

	#>> START FDISK
	fdisk /dev/$device < $tmpfile

	#>> REMOVE FILE
	#rm -f $tmpfile > /dev/null 2>&1

	done;

fi


#>> ------------------------------------------------------
#>> MAKE DEVICE FILESYSTEMS ------------------------------
if [ "$FS__mk_fs" -eq 1 ]; then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> MAKE DEVICE FILESYSTEMS"
	echo "#>> ----------------------------------------"

	[ $INSTALL__on_host -eq 0 ] && loop_on_devices=$FS__devices_install_host
	[ $INSTALL__on_host -eq 1 ] && loop_on_devices=$FS__devices

	for device in $loop_on_devices; do

		for partitionnr in $( cat $CONFIGFILE__partitions | egrep -v "^#" | egrep "^(prima|logic)" | grep $device | sed "s/[\t][\t]*/\t/g" | cut -f3 | egrep -o "[0-9]+" | sort -n ); do

			tmp_grep="$device$partitionnr";

			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "1" "P_type";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "2" "P_dev";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "3" "P_instdev";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "4" "P_parttype";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "5" "P_fs";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "6" "P_size";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "7" "P_boot";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "8" "P_mount";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "9" "P_mount_opt";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "10" "P_label";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "11" "P_fs_opt";

			#>> CLEAR FS_OPT WHEN "-" IN CONFIG FILE
			[ "$P_fs_opt" == "-" ] && P_fs_opt='';

			#>> IF P_type jfs
			if [ "$P_fs" == "jfs" ]; then
				P_fs_opt="$P_fs_opt -q"
			fi

			#>> IF P_type SWAP
			if [ "$P_fs" == "swap" ]; then
				echo "MAKING SWAP ON:/dev/$device$partitionnr"
				mkswap -v1 /dev/$device$partitionnr;
				echo "TURNING SWAP ON:/dev/$device$partitionnr"
				swapon /dev/$device$partitionnr
			else
				echo "MAKING FILESYSTEM:$P_fs OPTIONS:$P_fs_opt LABEL:$P_label ON DEVICE:/dev/$device$partitionnr"
				mkfs -t $P_fs $P_fs_opt -L $P_label /dev/$device$partitionnr 1>/dev/null;
			fi

		done

	done

fi


#>> ------------------------------------------------------
#>> MOUNT PARTITIONS -------------------------------------

#>> WE HAVE TO MOUNT "/" FIRST, ELSE IT COULD BE POSSIBLE
#>> e.g.
#>> 1. MOUNT /devXY /mnt/gentoo/chroot/boot
#>> 2. MOUNT /devXY /mnt/gentoo/chroot
#>>
#>> WHICH SCRAMBLES THE MOUNT POINTS

if [ $FS__mount_partitions -eq 1 ]; then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> MOUNTING PARTITIONS"
	echo "#>> ----------------------------------------"

	[ $INSTALL__on_host -eq 0 ] && loop_on_devices=$FS__devices_install_host
	[ $INSTALL__on_host -eq 1 ] && loop_on_devices=$FS__devices

	#>> LOOP ON DEVICES/PARTITIONS AND SEARCH FOR "/"
	for device in $loop_on_devices; do

		for partitionnr in $( cat $CONFIGFILE__partitions | egrep -v "^#" | egrep -v "^exten" | grep $device | sed "s/[\t][\t]*/\t/g" | cut -f3 | egrep -o "[0-9]+" | sort -n ); do

			#echo "NR:$partitionnr"
			tmp_grep="$device$partitionnr";

			mount_point=`cat $CONFIGFILE__partitions | egrep "$tmp_grep[^0-9]" | sed "s/[\t][\t]*/\t/g" | cut -f8`;
			#echo "MOUNT_POINT:$mount_point"

			if [ "$mount_point" == "/" ]; then

				mount_src=`cat $CONFIGFILE__partitions | egrep "$tmp_grep" | sed "s/[\t][\t]*/\t/g" | cut -f3`;

                        #>> MAKE ROOT MOUNT POINT DIRECTORY IF DOESNT EXIST
                        echo "MAKING DIR:$PATH__install_chroot"
                        mkdir -p $PATH__install_chroot;

				echo "MOUNT: / TO $PATH__install_chroot (/dev/$device$partitionnr)"

				mount /dev/$device$partitionnr $PATH__install_chroot;

			fi

		done

	done

	#>> LOOP ON DEVICES/PARTITIONS
	for device in $loop_on_devices; do

		for partitionnr in $( cat $CONFIGFILE__partitions | egrep -v "^#" | egrep -v "^exten" | grep $device | sed "s/[\t][\t]*/\t/g" | cut -f3 | egrep -o "[0-9]+" | sort -n ); do

			tmp_grep="$device$partitionnr";

			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "1" "P_type";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "2" "P_dev";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "3" "P_instdev";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "4" "P_parttype";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "5" "P_fs";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "6" "P_size";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "7" "P_boot";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "8" "P_mount";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "9" "P_mount_opt";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "10" "P_label";
			cut_column_from_tabline "$CONFIGFILE__partitions" "$tmp_grep" "11" "P_fs_opt";

			#>> IF P_type != SWAP && P_mount != /
			if [ "$P_fs" != "swap" ] && [ "$P_mount" != "/" ] ; then

				#>> RESET VARIABLES
				mk_dir='';

				#>> IF EXISTING PARTITION -> MOUNT TO MOUNT POINT GIVEN IN partitions.txt
				#>> ELSE MOUNT TO $PATH__install_chroot
				if [ "$P_type" == "exist" ]; then
					mk_dir="$P_mount";
				else
					mk_dir="$PATH__install_chroot$P_mount";
				fi

				mount_src="/dev/$P_dev"
				mount_dst="$mk_dir"

				#>> MAKE DIRECTORY
				echo "MAKING DIR:$mk_dir"
				mkdir -p $mk_dir;

				#>> MOUNT TO RIGHT MOUNT POINT
				echo "MOUNTING: $mount_src ON $mount_dst"
				mount $mount_src $mount_dst;

			fi

		done

	done

fi

