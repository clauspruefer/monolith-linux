#>> ------------------------------------------------------
#>> CLEAN UP
#>> ------------------------------------------------------

if [ $GLOBAL__cleanup -eq 1 ]
then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> CLEAN UP"
	echo "#>> ----------------------------------------"


	#>> ------------------------------------------------------
	#>> CHANGE PATH ------------------------------------------

	TMP_PATH=`pwd`
	cd $PATH__install_chroot


	#>> ------------------------------------------------------
	#>> REMOVE UNWANTED BINARIES -----------------------------
	
	rm ./sbin/ctrlaltdel
	rm ./sbin/findfs
	rm ./sbin/sln
	rm ./usr/bin/rpcgen
	rm ./usr/bin/rcp
	rm ./usr/bin/rsh
	rm ./usr/bin/rlogin
	rm ./usr/bin/unshare
	rm ./usr/bin/rev
	rm ./usr/bin/msgcat
	rm ./usr/bin/msgcmp
	rm ./usr/bin/msgcomm
	rm ./usr/bin/msgconv
	rm ./usr/bin/msgen
	rm ./usr/bin/msgexec
	rm ./usr/bin/msgfilter
	rm ./usr/bin/msgfmt
	rm ./usr/bin/msggrep
	rm ./usr/bin/msginit
	rm ./usr/bin/msgmerge
	rm ./usr/bin/msgunfmt

	
	#>> ------------------------------------------------------
	#>> REMOVE UNWANTED LIBRARIES ----------------------------
	
	rm ./lib/libcidn-*
	rm ./lib/libnss_nis*
	rm ./usr/lib/libnss*
	
	
	#>> ------------------------------------------------------
	#>> REMOVE UNWANTED DIRECTORIES --------------------------
	
	rm -R ./usr/src/*
	rm -R ./sources/
	rm -R ./tools/
	rm -R ./usr/include/*
	rm -R ./usr/local/include/*
	
	rm -R ./usr/share/info/
	rm -R ./usr/share/man/
	rm -R ./usr/share/doc/

	rm -R ./usr/share/autoconf/
	rm -R ./usr/share/bison/
	rm -R ./usr/share/gettext/

	
	#>> ------------------------------------------------------
	#>> REMOVE UNWANTED HEADER FILES -------------------------
	
	find ./ -name "*.h" | xargs rm


	#>> ------------------------------------------------------
	#>> REMOVE TMP INSTALL FILES -----------------------------

	rm ./compiler.settings

	rm ./tmp/*.sh
	rm ./tmp/packages.conf
	rm ./tmp/HLFS_paths


	#>> ------------------------------------------------------
	#>> CHANGE PATH ------------------------------------------

	cd $TMP_PATH

fi

