#!/bin/bash

#>> ----------------------------------------------------------------------------
#>> COPY SSHd INIT.d SCRIPT TO INITRD DIR
#>> ----------------------------------------------------------------------------

cp $PATH__config_etc_initd/sshd $PATH__install_chroot/etc/rc.d/init.d/
chmod 754 $PATH__install_chroot/etc/rc.d/init.d/sshd


#>> ----------------------------------------------------------------------------
#>> COPY SSHd CONFIG TO /etc
#>> ----------------------------------------------------------------------------

mkdir -p $PATH__install_chroot/etc/ssh/
chmod 700 $PATH__install_chroot/etc/ssh/

cp $PATH__profile/ssh/sshd_config $PATH__install_chroot/etc/ssh/
chmod 600 $PATH__install_chroot/etc/ssh/sshd_config

