#>> ------------------------------------------------------
#>> BUILD SYSTEM -----------------------------------------

if [ $STAGE__1_compile -eq 1 ]; then

	echo
	echo "#>> ----------------------------------------"
	echo "#>> START BUILDING STAGE 1"
	echo "#>> ----------------------------------------"

	#>> DEBUG OUTPUT

	#>> ------------------------------------------------------
	#>> COPY SOURCES -----------------------------------------

	mkdir -p $PATH__install_chroot/sources/
	cp $PATH__sources/* $PATH__install_chroot/sources/


	#>> ------------------------------------------------------
	#>> CALL BUILD SCRIPT ------------------------------------

	PATH__compile_stage1="$PATH__sys/compile/stage1";

	cd $PATH__compile_stage1
	$PATH__compile_stage1/build.sh
	cd $PATH__sys

fi

