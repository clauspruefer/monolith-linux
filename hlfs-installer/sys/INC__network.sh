#>> ------------------------------------------------------
#>> NETWORK CONFIGURATION --------------------------------

if [ $NET__network_config_static -eq 1 ] && [ $INSTALL__on_host -eq 1 ]; then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> NETWORK CONFIG STATIC"
	echo "#>> ----------------------------------------"

	#>> DEBUG OUTPUT
	[ $GLOBAL__debug -gt 10 ] && echo "NET_DEVICE: $NET__device" && echo "NET_IP: $NET__ip NET_NETMASK: $NET__netmask";
	[ $GLOBAL__debug -gt 10 ] && echo "CMD_INIT1: $NET__runon_init1" && echo "CMD_INIT2: $NET__runon_init2";
	[ $GLOBAL__debug -gt 10 ] && echo "CMD_POST1: $NET__runafter_init1" && echo "CMD_POST2: $NET__runafter_init2";

	#>> NET RUNON INIT
	`$NET__runon_init1`
	`$NET__runon_init2`

	#>> BRING UP LOCAL INTERFACE
	ifconfig lo up 2>/dev/null

	#>> BRING UP NET DEVICE
	ifconfig $NET__device up $NET__ip netmask $NET__netmask -multicast -broadcast arp

	#>> SET SYSCTL VALUES ON NET_DEVICES
	set_default_sysctl_values "lo"
	set_default_sysctl_values "$NET__device"

	#>> ADD DEFAULT GATEWAY
	if [ -n "$NET__default_gw_ip" ]; then
		set_net_default_gw "$NET__default_gw_ip" "$NET__device"
	fi

	#>> RUN COMMANDS AFTER NETWORK CARD CONFIG
	`$NET__runafter_init1`
	`$NET__runafter_init2`

fi

