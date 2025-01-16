#!/tools/bin/bash

#>> ------------------------------------------------------
#>> MAKE DIRECTORIES -------------------------------------

mkdir -pv /{bin,boot,etc/{opt,sysconfig},home,lib,mnt,opt}
mkdir -pv /{media/{floppy,cdrom},sbin,srv,var}

install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp

mkdir -pv /usr/{,local/}{bin,include,lib,libexec,sbin,src}
mkdir -pv /usr/{,local/}share/{doc,info,locale,man}
mkdir -v  /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}share/man/man{1..8}

for dir in /usr /usr/local; do
	ln -sv share/{man,doc,info} $dir
done

case $(uname -m) in
	x86_64)
		ln -sv lib /lib64
         	ln -sv lib /usr/lib64
         	ln -sv lib /usr/local/lib64
	;;
esac

mkdir -v /var/{lock,log,mail,run,spool}
mkdir -pv /var/{opt,cache,lib/{misc,locate},local}

#>> ------------------------------------------------------
#>> MAKE SYMLINKS ----------------------------------------

ln -sv /tools/bin/{bash,cat,echo,pwd,stty} /bin
ln -sv /tools/bin/perl /usr/bin
ln -sv /tools/lib/libgcc_s.so{,.1} /usr/lib
ln -sv /tools/lib/libstdc++.so{,.6} /usr/lib
ln -sv bash /bin/sh
ln -sv /tools/lib/ld-linux-x86-64.so.2 /lib/ld-linux-x86-64.so.2

#>> ------------------------------------------------------
#>> MAKE MTAB --------------------------------------------

touch /etc/mtab

#>> ------------------------------------------------------
#>> MAKE /etc/password -----------------------------------

cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF

#>> ------------------------------------------------------
#>> MAKE /etc/group --------------------------------------

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:4:
daemon:x:6:
disk:x:8:
dialout:x:10:
utmp:x:13:
usb:x:14:
cdrom:x:15:
mail:x:34:
nogroup:x:99:
EOF

#>> ------------------------------------------------------
#>> MAKE LOGIN FILES -------------------------------------

touch /var/run/utmp /var/log/{btmp,lastlog,wtmp}
chgrp -v utmp /var/run/utmp /var/log/lastlog
chmod -v 664 /var/run/utmp /var/log/lastlog

exit 0

