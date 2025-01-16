#>> ------------------------------------------------------
#>> STARTUP REMOVE UNWANTED KERNEL MODS ------------------

if [ $STARTUP__kernel_modules_rm -eq 1 ] && [ $INSTALL__on_host -eq 1 ]; then
	remove_mods "$STARTUP__rmmods"
fi


#>> ------------------------------------------------------
#>> STARTUP INSERT KERNEL MODS ---------------------------

if [ $STARTUP__kernel_modules_insert -eq 1 ] &&  [ $INSTALL__on_host -eq 1 ]; then
	insert_mods "$STARTUP__insmods"
fi


#>> ------------------------------------------------------
#>> STOP UNWANTED SERVICES -------------------------------

if [ $STARTUP__services_stop -eq 1 ] && [ $INSTALL__on_host -eq 1 ]; then
	stop_services "$STARTUP__stop_services"
fi


#>> ------------------------------------------------------
#>> KILL UNWANTED SERVICES -------------------------------

if [ $STARTUP__services_kill -eq 1 ] && [ $INSTALL__on_host -eq 1 ]; then
	kill_services "$STARTUP__kill_services"
fi


#>> ------------------------------------------------------
#>> UPDATE resolv.conf TO DISABLE INTERNET ACCESS
#>> FROM INSTALL SYSTEM -> JUST ALLOW ACCESS FROM
#>> WITHIN CHROOT
#>> ------------------------------------------------------
if [ $STARTUP__set_ns_entries -eq 1 ] && [ $INSTALL__on_host -eq 1 ]; then

	echo "domain null" > /etc/resolv.conf
	echo "nameserver 0.0.0.0" >> /etc/resolv.conf

fi


#>> ------------------------------------------------------
#>> SET DATE ---------------------------------------------

if [ $STARTUP__set_date -eq 1 ] && [ $INSTALL__on_host -eq 1 ]; then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> SETTING DATE"
	echo "#>> ----------------------------------------"

	set_date=0;

	while [ $set_date -eq 0 ]
	do

		echo -n "ENTER DATE AND TIME (2007-12-31 11:10:01) >";
		read date

		echo "DATE:$date"

		echo -n "DATE RIGHT? (y/n) >";
		read dateok

		if [ "$dateok" == "y" ]
		then
			date -s '%Y-%m-%d %H:%M:%S' --set="$date"
			set_date=1;
		fi

	done

fi

