#!/bin/bash

#>> ----------------------------------------------------------------------------
#>> FILL AUTHORIZED KEYS FILE WITH KEYS FROM CONFIG TEMPLATE
#>> ----------------------------------------------------------------------------

if [ $SSH__login_user_auth_key -eq 1 ]; then
	cat $PATH__profile/ssh/pub.key > /mnt/hlfs/home/$SSH__login_user/.ssh/authorized_keys
fi
 
