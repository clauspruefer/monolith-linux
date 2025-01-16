#>> ----------------------------------------------------------------------------
#>> MAKE /dev ENTRY FOR /dev/pts AND ADD mount POINT TO fstab
#>> ----------------------------------------------------------------------------

mkdir -p /dev/pts
chmod 755 /dev/pts

count_pts=`cat /etc/fstab | grep /dev/pts | wc -l`

if [ $count_pts -eq 0 ]; then

	echo "" >> /etc/fstab
	echo "#>> -- DEVPTS" >> /etc/fstab
	echo "none		/dev/pts		devpts		gid=4,mode=620,nosuid,noexec	0 0" >> /etc/fstab

fi


#>> ----------------------------------------------------------------------------
#>> ADD GROUP/USER FOR SSHd PRIVILEGE SEPARATION USER
#>> ----------------------------------------------------------------------------

groupadd sshd
useradd -d /var/empty -g sshd -M -s /sbin/nologin sshd


#>> ----------------------------------------------------------------------------
#>> ADD WHEEL GROUP
#>> ----------------------------------------------------------------------------

groupadd wheel


#>> ----------------------------------------------------------------------------
#>> CHECK IF SSH__login_user EXISTS => CREATE ACCOUNT AND ADD TO WHEEL GROUP
#>> ----------------------------------------------------------------------------

if [ -n "$SSH__login_user" ]; then

	#>> ----------------------------------------------------------------------------
	#>> ADD GROUP AND USER
	#>> ----------------------------------------------------------------------------

	groupadd $SSH__login_user
	useradd -d /home/$SSH__login_user -g $SSH__login_user -G wheel -m -s $SSH__login_user_shell $SSH__login_user
	usermod --password=''$SSH__login_user_pwd'' $SSH__login_user

	#>> ----------------------------------------------------------------------------
	#>> ENVIRONMENT
	#>> ----------------------------------------------------------------------------

	DIR_PROCESS="/home/$SSH__login_user/.ssh"
	AUTH_KEYS_FILE="$DIR_PROCESS/authorized_keys"


	#>> ----------------------------------------------------------------------------
	#>> CREATE SSH DIR + AUTHORIZED_KEYS FILE
	#>> ----------------------------------------------------------------------------

	mkdir -p $DIR_PROCESS
	chown $SSH__login_user:$SSH__login_user $DIR_PROCESS
	chmod 700 $DIR_PROCESS

	touch $AUTH_KEYS_FILE
	chown $SSH__login_user:$SSH__login_user $AUTH_KEYS_FILE
	chmod 600 $AUTH_KEYS_FILE


fi

#>> ----------------------------------------------------------------------------
#>> AUTOSTART sshd (rc3.d)
#>> ----------------------------------------------------------------------------

cd /etc/rc.d/rc3.d
ln -s ../init.d/sshd ./S30sshd

