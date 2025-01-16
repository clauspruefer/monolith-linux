#>> ------------------------------------------------------
#>> SET ROOT PWD
#>> ------------------------------------------------------

if [ $GLOBAL__set_root_pw -eq 1 ]
then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> SET ROOT PASSWORD"
	echo "#>> ----------------------------------------"

	FILENAME="ADDITIONAL__set_root_pw"
	CHROOT_TMPFILE="$PATH__chroot_tmp/CHROOT__$FILENAME.sh"

	echo "#!/bin/bash" > $CHROOT_TMPFILE
	echo "usermod --password='$ROOT__pwd' root" >> $CHROOT_TMPFILE
	echo "pwconv" >> $CHROOT_TMPFILE

	exec_chroot_tmpfile $FILENAME

fi


#>> ------------------------------------------------------
#>> WRITE /proc TO /etc/fstab
#>> ------------------------------------------------------

if [ $GLOBAL__write_proc_fstab -eq 1 ]
then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> WRITE MOUNT+OPTIONS /proc TO /etc/fstab"
	echo "#>> ----------------------------------------"

	echo "" >> $PATH__install_chroot/etc/fstab
	echo "#>> -- PROC" >> $PATH__install_chroot/etc/fstab
	echo "none		/proc			proc		noatime,nodev,nosuid,noexec		0 0" >> $PATH__install_chroot/etc/fstab

fi


#>> ------------------------------------------------------
#>> BUILD sysctl.conf
#>> ------------------------------------------------------

if [ $GLOBAL__build_sysctl -eq 1 ]
then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> BUILD SYSCTL VALUES"
	echo "#>> ----------------------------------------"

	#>> READ SYSCTL.CONF TEMPLATE, REPLACE VARIABLES, WRITE TMP FILE
	cat $PATH__config/sysctl.conf.tpl | sed "s/\$NET__hostname/$NET__hostname/gi" > /tmp/global_sysctl1
	cat /tmp/global_sysctl1 | sed "s/\$NET__domain/$NET__domain/gi" > /tmp/global_sysctl2

	#>> GENERATE INTERFACE BASED SYSCTL CONF
	cat /tmp/global_sysctl2 > /tmp/sysctl_config

	echo "" >> /tmp/sysctl_config
	echo "#>> INTERFACE BASED SYSCTL CONFIG" >> /tmp/sysctl_config

	for interface in `cat $CONFIGFILE__user_sysctl_interface | egrep -v "^#" | sed "s/[\t][\t]*/\t/g" | cut -f1`; do

		var1=`cat $CONFIGFILE__user_sysctl_interface | egrep "^$interface" | sed "s/[\t][\t]*/\t/g" | cut -f2`
		var2=`cat $CONFIGFILE__user_sysctl_interface | egrep "^$interface" | sed "s/[\t][\t]*/\t/g" | cut -f3`
		var3=`cat $CONFIGFILE__user_sysctl_interface | egrep "^$interface" | sed "s/[\t][\t]*/\t/g" | cut -f4`
		var4=`cat $CONFIGFILE__user_sysctl_interface | egrep "^$interface" | sed "s/[\t][\t]*/\t/g" | cut -f5`
		var5=`cat $CONFIGFILE__user_sysctl_interface | egrep "^$interface" | sed "s/[\t][\t]*/\t/g" | cut -f6`
		var6=`cat $CONFIGFILE__user_sysctl_interface | egrep "^$interface" | sed "s/[\t][\t]*/\t/g" | cut -f7`
		var7=`cat $CONFIGFILE__user_sysctl_interface | egrep "^$interface" | sed "s/[\t][\t]*/\t/g" | cut -f8`
		var8=`cat $CONFIGFILE__user_sysctl_interface | egrep "^$interface" | sed "s/[\t][\t]*/\t/g" | cut -f9`
		var9=`cat $CONFIGFILE__user_sysctl_interface | egrep "^$interface" | sed "s/[\t][\t]*/\t/g" | cut -f10`

		cat $CONFIGFILE__tpl_sysctl_interface | sed "s/\$interface/$interface/gi" > /tmp/dyn_sysctl1

		cat /tmp/dyn_sysctl1 | sed "s/\$var1/$var1/gi" > /tmp/dyn_sysctl2
		cat /tmp/dyn_sysctl2 | sed "s/\$var2/$var2/gi" > /tmp/dyn_sysctl3
		cat /tmp/dyn_sysctl3 | sed "s/\$var3/$var3/gi" > /tmp/dyn_sysctl4
		cat /tmp/dyn_sysctl4 | sed "s/\$var4/$var4/gi" > /tmp/dyn_sysctl5
		cat /tmp/dyn_sysctl5 | sed "s/\$var5/$var5/gi" > /tmp/dyn_sysctl6
		cat /tmp/dyn_sysctl6 | sed "s/\$var6/$var6/gi" > /tmp/dyn_sysctl7
		cat /tmp/dyn_sysctl7 | sed "s/\$var7/$var7/gi" > /tmp/dyn_sysctl8
		cat /tmp/dyn_sysctl8 | sed "s/\$var8/$var8/gi" > /tmp/dyn_sysctl9
		cat /tmp/dyn_sysctl9 | sed "s/\$var9/$var9/gi" > /tmp/dyn_sysctl10

		cat /tmp/dyn_sysctl10 >> /tmp/sysctl_config
		echo "" >> /tmp/sysctl_config

	done

	#>> IF LOCAL sysctl.conf EXISTS, APPEND TO GENERATED
	echo "#>> LOCAL (USER BASED) SYSCTL CONFIG" >> /tmp/sysctl_config
	cat $CONFIGFILE__user_sysctl >> /tmp/sysctl_config

	#>> COPY FILE TO /etc/sysctl.conf
	cp /tmp/sysctl_config $PATH__install_chroot/etc/sysctl.conf

fi


#>> ------------------------------------------------------
#>> "make" BOOT SCRIPTS
#>> ------------------------------------------------------

if [ $GLOBAL__build_bootscripts -eq 1 ]
then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> BUILD BOOTSCRIPTS"
	echo "#>> ----------------------------------------"

	FILENAME="ADDITIONAL__build_bootscripts"
	CHROOT_TMPFILE="$PATH__chroot_tmp/CHROOT__$FILENAME.sh"

	echo "#!/bin/bash" > $CHROOT_TMPFILE
	echo "cd /sources/" >> $CHROOT_TMPFILE
	echo "tar -xjf lfs-bootscripts-ml-0.1.tar.bz2" >> $CHROOT_TMPFILE
	echo "cd ./lfs-bootscripts-ml-0.1" >> $CHROOT_TMPFILE
	echo "make install-ml-nomodules" >> $CHROOT_TMPFILE

	exec_chroot_tmpfile $FILENAME

	cd $TMP_PATH

fi


#>> ------------------------------------------------------
#>> GENERATE /root .bash_profile AND .bashrc
#>> ------------------------------------------------------

if [ $GLOBAL__build_bashprofile -eq 1 ]
then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> BUILD BASHPROFILE"
	echo "#>> ----------------------------------------"

	cp $PATH__config/.bash_profile $PATH__install_chroot/root/
	cp $PATH__config/.bashrc $PATH__install_chroot/root/

	chmod 640 $PATH__install_chroot/root/.bash_profile
	chmod 640 $PATH__install_chroot/root/.bashrc

fi


#>> ------------------------------------------------------
#>> COPY SYSCONFIG CONFIGURATION FILES
#>> ------------------------------------------------------

if [ $GLOBAL__copy_sysconfig_files -eq 1 ]
then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> COPY SYSCONFIG FILES"
	echo "#>> ----------------------------------------"

	cp $PATH__profile/sysconfig/console $PATH__install_chroot/etc/sysconfig/
	chmod 640 $PATH__install_chroot/etc/sysconfig/console

	cp -R $PATH__profile/sysconfig/network-devices $PATH__install_chroot/etc/sysconfig/

	cp $PATH__profile/sysconfig/network $PATH__install_chroot/etc/sysconfig/

fi


#>> ------------------------------------------------------
#>> COPY /etc/ FILES
#>> ------------------------------------------------------

if [ $GLOBAL__copy_etc_files -eq 1 ]
then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> INSTALL /etc CONFIG FILES"
	echo "#>> ----------------------------------------"

	install -g root -o root -m 644 -T -v $PATH__config_etc/protocols $PATH__install_chroot/etc/protocols
	install -g root -o root -m 644 -T -v $PATH__config_etc/bashrc $PATH__install_chroot/etc/bashrc
	install -g root -o root -m 644 -T -v $PATH__config_etc/dircolors $PATH__install_chroot/etc/dircolors
	install -g root -o root -m 644 -T -v $PATH__config_etc/environment $PATH__install_chroot/etc/environment
	install -g root -o root -m 644 -T -v $PATH__config_etc/login.defs $PATH__install_chroot/etc/login.defs
	install -g root -o root -m 644 -T -v $PATH__config_etc/securetty $PATH__install_chroot/etc/securetty

fi


#>> ------------------------------------------------------
#>> COMPILE ADDITIONAL SOURCEs
#>> ------------------------------------------------------

if [ $COMPILE__additional -eq 1 ]
then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> COMPILE ADDITIONAL PACKAGES"
	echo "#>> ----------------------------------------"

	for source in `cat $CONFIGFILE__user_additional_pkgs | egrep -v "^#" | sed "s/[\t][\t]*/\t/g" | cut -f1`; do

		#>> ------------------------------------------------------
		#>> GET COLUMN VALUES
		#>> ------------------------------------------------------

		var1=`cat $CONFIGFILE__user_additional_pkgs | egrep "^$source" | sed "s/[\t][\t]*/\t/g" | cut -f2`
		var2=`cat $CONFIGFILE__user_additional_pkgs | egrep "^$source" | sed "s/[\t][\t]*/\t/g" | cut -f3`
		var3=`cat $CONFIGFILE__user_additional_pkgs | egrep "^$source" | sed "s/[\t][\t]*/\t/g" | cut -f4`
		var4=`cat $CONFIGFILE__user_additional_pkgs | egrep "^$source" | sed "s/[\t][\t]*/\t/g" | cut -f5`
		var5=`cat $CONFIGFILE__user_additional_pkgs | egrep "^$source" | sed "s/[\t][\t]*/\t/g" | cut -f6`
		var6=`cat $CONFIGFILE__user_additional_pkgs | egrep "^$source" | sed "s/[\t][\t]*/\t/g" | cut -f7`
		var7=`cat $CONFIGFILE__user_additional_pkgs | egrep "^$source" | sed "s/[\t][\t]*/\t/g" | cut -f8`
		var8=`cat $CONFIGFILE__user_additional_pkgs | egrep "^$source" | sed "s/[\t][\t]*/\t/g" | cut -f9`

		PKG__filename=$var1
		PKG__depack_dir=$var2
		PKG__script_compile=$var3
		PKG__script_pre=$var4
		PKG__script_post=$var5
		PKG__configure=$var6
		PKG__make=$var7
		PKG__make_install=$var8

		#echo "PKG__filename:$PKG__filename"
		#echo "PKG__depack_dir:$PKG__depack_dir"
		#echo "PKG__script_compile:$PKG__script_compile"
		#echo "PKG__script_pre:$PKG__script_pre"
		#echo "PKG__script_post:$PKG__script_post"
		#echo "PKG__configure:$PKG__configure"
		#echo "PKG__make:$PKG__make"
		#echo "PKG__make_install:$PKG__make_install"

		#>> ------------------------------------------------------
		#>> CHECK FOR DEPACK TYPE
		#>> ------------------------------------------------------

		PKG__depack_cmd='';

		TMP_grep=`echo $PKG__filename | egrep -o "\.gz$"`
		#echo "TMP_grep:$TMP_grep"

		if [ "$TMP_grep" = ".gz" ]; then
			PKG__depack_cmd="tar -xzf $PKG__filename";
		fi

		TMP_grep=`echo $PKG__filename | egrep -o "\.bz2$"`

		if [ "$TMP_grep" = ".bz2" ]; then
			PKG__depack_cmd="tar -xjf $PKG__filename";
		fi

		#echo "PKG__depack_cmd:$PKG__depack_cmd"

		#>> ------------------------------------------------------
		#>> PRE SCRIPT
		#>> ------------------------------------------------------

		if [ "$PKG__script_pre" = "x" ]; then

				echo
				echo "#>> ----------------------------------------"
				echo "#>> EXECUTE PRE COMPILE SCRIPT"
				echo "#>> ----------------------------------------"

		fi

		#>> ------------------------------------------------------
		#>> COMPILE
		#>> ------------------------------------------------------

		FILENAME="ADDITIONAL__depack_$source"
		CHROOT_TMPFILE="$PATH__chroot_tmp/CHROOT__$FILENAME.sh"

		echo "#!/bin/bash" > $CHROOT_TMPFILE
		echo "cd /sources/" >> $CHROOT_TMPFILE

		echo $PKG__depack_cmd >> $CHROOT_TMPFILE

		exec_chroot_tmpfile $FILENAME

		#>> ------------------------------------------------------
		#>> PREPARE CHROOT COMPILE SCRIPT
		#>> ------------------------------------------------------

		FILENAME="ADDITIONAL__compile__$source"
		CHROOT_TMPFILE="$PATH__chroot_tmp/CHROOT__$FILENAME.sh"

		echo "#!/bin/bash" > $CHROOT_TMPFILE
		echo "cd /sources/$PKG__depack_dir" >> $CHROOT_TMPFILE

		#>> ------------------------------------------------------
		#>> COMPILE SCRIPT
		#>> ------------------------------------------------------

		if [ "$PKG__script_compile" = "x" ]; then

			echo "#>> COMPILE SCRIPT"

			#>> OUTSIDE CHROOT COPY COMPILE SCRIPT TO EXISTING DEPACK DIR
			COMPILE_script=$PATH__install_chroot_sources/$PKG__depack_dir/compile
			cp $PATH__sys_compilescripts/$source $COMPILE_script
			chmod u+x $COMPILE_script

			echo "./compile" >> $CHROOT_TMPFILE

		#>> ------------------------------------------------------
		#>> COMPILE CMDs FROM CONFIG FILE
		#>> ------------------------------------------------------

		else

			echo "#>> COMPILE CMDs FROM CONFIG FILE"

			echo ". /compiler.settings" >> $CHROOT_TMPFILE
			echo "export CFLAGS=\"$CFLAGS\"" >> $CHROOT_TMPFILE
			echo "export CXXFLAGS=\"$CXXFLAGS\"" >> $CHROOT_TMPFILE
			echo "export LDFLAGS=\"$LDFLAGS\"" >> $CHROOT_TMPFILE

			echo "$PKG__configure" >> $CHROOT_TMPFILE
			echo "$PKG__make" >> $CHROOT_TMPFILE
			echo "$PKG__make_install" >> $CHROOT_TMPFILE

		fi

		exec_chroot_tmpfile $FILENAME


		#>> ------------------------------------------------------
		#>> POST SCRIPT
		#>> ------------------------------------------------------

		if [ "$PKG__script_post" = "x" ]; then

			echo
			echo "#>> ----------------------------------------"
			echo "#>> EXECUTE POST COMPILE SCRIPTS"
			echo "#>> ----------------------------------------"

			#>> ------------------------------------------------------
			#>> EXPORT ENVIRONMENT WHICH IS ACCESSIBLE IN
			#>> "OUTSIDE CHROOT" SCRIPTS
			#>> ------------------------------------------------------

			export PATH__config_etc_initd
			export PATH__install_chroot
			export PATH__profile

			export SSH__login_user
			export SSH__login_user_shell
			export SSH__login_user_auth_key
			export SSH__login_user_pwd

			#>> ------------------------------------------------------
			#>> EXECUTE POST SCRIPT 1 (OUTSIDE CHROOT)
			#>> ------------------------------------------------------

			echo
			echo "#>> ----------------------------------------"
			echo "#>> EXECUTE POST SCRIPT 1 (OUTSIDE CHROOT)"
			echo "#>> ----------------------------------------"

			SCRIPT_name="$source""__POST.sh"
			cp $PATH__sys_installscripts/$SCRIPT_name /tmp
			chmod u+x /tmp/$SCRIPT_name
			/tmp/$SCRIPT_name

			#>> ------------------------------------------------------
			#>> EXECUTE POST SCRIPT (INSIDE CHROOT)
			#>> ------------------------------------------------------

			echo
			echo "#>> ----------------------------------------"
			echo "#>> EXECUTE POST SCRIPT 1 (INSIDE CHROOT)"
			echo "#>> ----------------------------------------"

			FILENAME="ADDITIONAL__postprocess_$source"
			CHROOT_TMPFILE="$PATH__chroot_tmp/CHROOT__$FILENAME.sh"

			SCRIPT_name="$source""__POSTCHROOT.sh"

			echo "#!/bin/bash" > $CHROOT_TMPFILE
			echo "" >> $CHROOT_TMPFILE
			echo "SSH__login_user=$SSH__login_user" >> $CHROOT_TMPFILE
			echo "SSH__login_user_shell=$SSH__login_user_shell" >> $CHROOT_TMPFILE
			echo "SSH__login_user_auth_key=$SSH__login_user_auth_key" >> $CHROOT_TMPFILE
			echo "SSH__login_user_pwd=$SSH__login_user_pwd" >> $CHROOT_TMPFILE
			echo "" >> $CHROOT_TMPFILE

			cat $PATH__sys_installscripts/$SCRIPT_name >> $CHROOT_TMPFILE

			exec_chroot_tmpfile $FILENAME

			#>> ------------------------------------------------------
			#>> EXECUTE POST SCRIPT 2 (OUTSIDE CHROOT)
			#>> ------------------------------------------------------

			echo
			echo "#>> ----------------------------------------"
			echo "#>> EXECUTE POST SCRIPT 2 (OUTSIDE CHROOT)"
			echo "#>> ----------------------------------------"

			SCRIPT_name="$source""__POST_1.sh"
			cp $PATH__sys_installscripts/$SCRIPT_name /tmp
			chmod u+x /tmp/$SCRIPT_name
			/tmp/$SCRIPT_name

		fi


	done


	#>> ------------------------------------------------------
	#>> STRIP BINARIES ---------------------------------------

	find \
	$PATH__install_chroot/bin \
	$PATH__install_chroot/sbin \
	$PATH__install_chroot/usr/bin \
	$PATH__install_chroot/usr/sbin \
	$PATH__install_chroot/usr/local/bin \
	$PATH__install_chroot/usr/local/sbin \
	-type f | xargs file | grep "ELF" | cut --delimiter=: -f 1 | xargs strip --strip-all


	#>> ------------------------------------------------------
	#>> STRIP LIBRARIES --------------------------------------

	find \
	$PATH__install_chroot/lib \
	$PATH__install_chroot/usr/lib \
	$PATH__install_chroot/usr/local/lib \
	$PATH__install_chroot/usr/local/libexec \
	-type f | xargs file | grep "ELF" | cut --delimiter=: -f 1 | xargs strip --strip-all

fi

