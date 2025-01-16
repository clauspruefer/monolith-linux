#!/bin/bash

#>> ------------------------------------------------------
#>> ENVIRONMENT ------------------------------------------

. ./ENV__user.env


#>> ------------------------------------------------------
#>> MAKE USER+DIRS ---------------------------------------

#>> MAKE DIRECTORIES
mkdir $HLFS/tools 1>/dev/null 2>/dev/null
mkdir $HLFS/sources 1>/dev/null 2>/dev/null

#>> SET PERMISSIONS
chmod a+wt $HLFS/sources

#>> ADD HLFS USER/GROUP
/usr/sbin/groupadd hlfs
/usr/sbin/useradd -s /bin/bash -g hlfs -m -k /dev/null hlfs -p \$1\$TA210jUf\$JlO8vLvwRZNWL5UvxhK7b1

#>> SET OWNER
chown hlfs $HLFS/tools
chown hlfs $HLFS/sources


#>> ------------------------------------------------------
#>> MAKE /tools SYMLINK ----------------------------------

ln -sv $HLFS/tools /tools


#>> ------------------------------------------------------
#>> CHECK /etc/login.defs FOR RIGHT PATHS (/tools/bin) ---

check=`cat /etc/login.defs | grep PATH=/tools`


#>> ------------------------------------------------------
#>> IF IT DOES NOT EXIST: ADD IT -------------------------

if [ -z "$check" ]; then

	#>> REMOVE ENV_PATH LINE FROM login.defs
	sed -i '/ENV\_PATH/d' /etc/login.defs

	#>> ADD IT AGAIN WITH ADDITIONAL /tools/bin PATH
	echo "ENV_PATH        PATH=/tools/bin:/bin:/usr/bin" >> /etc/login.defs

fi


#>> ------------------------------------------------------
#>> MAKE USER ENVIRONMENT --------------------------------

cat > /home/hlfs/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat ./ENV__user.env > /home/hlfs/.bashrc

