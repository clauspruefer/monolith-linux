function check_mod_loaded
{

	mod=$1;

	modfound='';
	modfound=`lsmod | egrep "^$mod"`;

	[ "$GLOBAL__debug" -gt 10 ] && echo "CHECK_MOD:$mod FOUND:$modfound";

}


function check_service_running
{

	service=$1;

	servicefound='';
	servicefound=`ps -C $service | tail -n 1 | cut -d " " -f 1`;

	[ "$GLOBAL__debug" -gt 10 ] && echo "CHECK_SERVICE:$service FOUND:$servicefound";

}


function remove_mods
{

	mods=$1;

	for mod in $mods; do

		check_mod_loaded "$mod"

		if [ -n "$modfound" ]; then
			[ "$GLOBAL__debug" -gt 10 ] && echo "FOUND MOD:$mod, REMOVING!"
			rmmod $mod
		fi  

	done

}


function insert_mods
{

	mods=$1;

	for mod in $mods; do

		check_mod_loaded "$mod"

		if [ -z "$modfound" ]; then
			[ "$GLOBAL__debug" -gt 10 ] && echo "MOD:$mod NOT FOUND, INSMODDING!";
			modprobe $mod
		fi 

	done

}


function kill_services
{

	services=$1;

	for service in $services; do

		check_service_running "$service";

		tmpfound=$servicefound;

		while [ -n "$tmpfound" ]; do

			kill -9 $tmpfound
		
			check_service_running "$service"
			tmpfound=$servicefound;

		done;

	done;

}


function stop_services
{

	services=$1;

	for service in $services; do
		/etc/rc.d/init.d/$service stop
	done;

}


function set_default_sysctl_values
{

	net_device=$1;

	sysctl -w net.ipv4.conf.$net_device.disable_policy=1 1>/dev/null
	sysctl -w net.ipv4.conf.$net_device.disable_xfrm=1 1>/dev/null
	sysctl -w net.ipv4.conf.$net_device.log_martians=1 1>/dev/null
	sysctl -w net.ipv4.conf.$net_device.accept_source_route=0 1>/dev/null
	sysctl -w net.ipv4.conf.$net_device.send_redirects=0 1>/dev/null
	sysctl -w net.ipv4.conf.$net_device.shared_media=0 1>/dev/null
	sysctl -w net.ipv4.conf.$net_device.secure_redirects=0 1>/dev/null
	sysctl -w net.ipv4.conf.$net_device.accept_redirects=0 1>/dev/null
	sysctl -w net.ipv4.conf.$net_device.force_igmp_version=2 1>/dev/null

}


function set_net_default_gw
{

	gw_ip=$1;
	gw_if=$2;

	route_exists=`route -n | grep $gw_ip | grep $gw_if | grep UG`

	if [ -z "$route_exists" ]; then
		echo "SETTING DEFAULT GW:$gw_ip $gw_if"
		route add default gw $gw_ip $gw_if
	else
		echo "ROUTE EXISTS TO: GW:$gw_ip $gw_if"
	fi

}


function umount_device
{

	device_name=$1;

	umount_device="/dev/$device_name";

	#>> CHECK IF DEVICE MOUNTED
	tst=`mount | cut -d " " -f1 | grep $umount_device`; 

	if [ -n "$tst" ]; then
		echo "UNMOUNTING:$umount_device"
		umount $umount_device
	else
		echo "$umount_device IS NOT MOUNTED, I DONT TRY UNMOUNTING!"
	fi

}


function umount_partition
{

	partition_name=$1;

	#>> CHECK IF DEVICE MOUNTED
	tst=`mount | grep "on $partition_name"`; 

	if [ "$tst" != "" ]; then
		echo "PARTITION EXISTS, UNMOUNTING:$partition_name"
		umount $partition_name
	else
		echo "$partition_name IS NOT MOUNTED, I DONT TRY UNMOUNTING!"
	fi

}


function cut_column_from_tabline
{

	filename=$1;
	grepstring=$2;
	column=$3;
	varname=$4;

	if [ "$GLOBAL__debug" -gt 10 ]; then
		echo "FILENAME:$filename grepstring:$grepstring column:$column VARNAME:$varname"
	fi

	RETVAL=`cat $filename | sed "s/[\t][\t]*/\t/g" | egrep "$grepstring[^0-9]" | cut -f$column`;
	eval "$varname=$RETVAL";

}


function check_md5sum
{
	filename=$1;

	tmp_RC=`md5sum -c $filename`;

	MD5_RC="NOTOK"
	MD5_RC=`echo $tmp_RC | grep -o OK`

	if [ "$MD5_RC" != "OK" ]
	then
		echo "MD5 SUM CHECK FAILED FOR $filename"
		exit 1;
	fi

}


function exec_chroot_tmpfile
{

	EXEC_NAME=$1;

	CHROOT_FILENAME="CHROOT__$EXEC_NAME.sh";

	PATH__install_chroot_tmp="$PATH__install_chroot/tmp";

	CHMOD_TMPFILE="$PATH__install_chroot_tmp/$CHROOT_FILENAME"

	chown 0:0 $CHMOD_TMPFILE
	chmod 700 $CHMOD_TMPFILE

	CHROOT_TMPFILE="/tmp/$CHROOT_FILENAME"

	chroot "$PATH__install_chroot" /usr/bin/env -i \
	HOME=/root TERM="$TERM" PS1='\u:\w\$ ' \
        PATH=/bin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/tools/bin \
	/bin/bash $CHROOT_TMPFILE

}


function exec_stage2_tmpfile
{

	EXEC_NAME=$1;

	CHROOT_FILENAME="BUILD__stage2_$EXEC_NAME.sh";

	PATH__install_chroot_tmp="$PATH__install_chroot/tmp";

	SRC_FILE="$PATH__sys/compile/stage2/$CHROOT_FILENAME"
	cp $SRC_FILE $PATH__install_chroot_tmp/

	CHMOD_TMPFILE="$PATH__install_chroot_tmp/$CHROOT_FILENAME"

	chown 0:0 $CHMOD_TMPFILE
	chmod 700 $CHMOD_TMPFILE

	CHROOT_TMPFILE="/tmp/$CHROOT_FILENAME"

	echo "PATH__install_chroot:$PATH__install_chroot PATH__chroot_bin_env:$PATH__chroot_bin_env"

	chroot "$PATH__install_chroot" $PATH__chroot_bin_env -i \
	HOME=/root TERM="$TERM" PS1='\u:\w\$ ' \
	PATH=/usr/bin:/bin:/tools/bin:/tools/x86_64-ml-linux-gnu/bin \
	/tools/bin/bash $CHROOT_TMPFILE

}


function exec_stage2_cleanup
{

	EXEC_NAME=$1;

	CHROOT_FILENAME="BUILD__stage2_$EXEC_NAME.sh";

	PATH__install_chroot_tmp="$PATH__install_chroot/tmp";

	SRC_FILE="$PATH__sys/compile/stage2/$CHROOT_FILENAME"
	cp $SRC_FILE $PATH__install_chroot_tmp/

	CHMOD_TMPFILE="$PATH__install_chroot_tmp/$CHROOT_FILENAME"

	chown 0:0 $CHMOD_TMPFILE
	chmod 700 $CHMOD_TMPFILE

	CHROOT_TMPFILE="/tmp/$CHROOT_FILENAME"

	chroot "$PATH__install_chroot" $PATH__chroot_bin_env -i \
	HOME=/root TERM="$TERM" PS1='\u:\w\$ ' \
	PATH=/usr/bin:/bin:/tools/bin:/tools/x86_64-ml-linux-gnu/bin \
	/tools/bin/bash $CHROOT_TMPFILE

}


function escape_string
{
	string_to_escape=$1

	echo "String to escape:$string_to_escape"
	tmp_string=`echo "$string_to_escape" | sed "s/\//\\\\\\\\\//g"`

	ESCAPED_STRING=$tmp_string
	echo "Escaped String:$ESCAPED_STRING"

}


function reset_system_vars
{

	for var in `cat $CONFIGFILE__system_vars`; do
		eval "$var=0"
	done

}


function print_values_system_vars
{

	for var in `cat $CONFIGFILE__system_vars`; do
		echo -n "#>> $var="
		eval "echo \$$var"
		export $var
	done

	echo "#>>"

}


function print_values_system_vars_additional
{

	for var in `cat $CONFIGFILE__system_vars_additional`; do
		echo -n "#>> $var="
		eval "echo \$$var"
		export $var
	done

}

