#>> ----------------------------------------------------------------------------
#>> DEPACK PACKAGE BY PACKAGE NAME
#>> ----------------------------------------------------------------------------
#>> 1. raw Package Name like "autoconf" has to be passed as parameter
#>>
#>> 2. get_pkg_info is called,
#>>
#>> "returns": 	pkg_fullname
#>> pkg_depack_dir
#>> pkg_type

function depack_src_file
{

	. /tmp/HLFS_paths

	name=$1;

	echo "#>> -----------------------------------------------"
	echo "#>> DepackSrcFile:$name"
	echo "#>> -----------------------------------------------"

	get_pkg_info "$name"

	HLFS_SOURCE_DIR="$HLFS/sources";

	echo "Change Dir to:$HLFS_SOURCE_DIR"
	cd $HLFS_SOURCE_DIR

	echo "PKG_FULLNAME:$pkg_fullname"
	echo "PKG_DEPACK_DIR:$pkg_depack_dir"
	echo "PKG_TYPE:$pkg_type"

	if [ -n "$pkg_depack_dir" ]; then
		echo "Removing Dir:$pkg_depack_dir"
		rm -fR ./$pkg_depack_dir
	fi

	echo "Depacking file - $pkg_fullname"
	tar -xf ./$pkg_fullname
	cd $HLFS_SOURCE_DIR/$pkg_depack_dir

}

#>> ----------------------------------------------------------------------------
#>> GET PACKAGE INFO
#>> ----------------------------------------------------------------------------
#>> 1. Lookup in config file "HLFS_Installer/config/packages.conf"
#>>
#>>    package_fullname
#>>    package_depack_dir
#>>    package_type
#>>
#>> 2. package_type (tar.bz2 or tar.gz) is looked up from package_fullname

function get_pkg_info
{
	echo "#>> -----------------------------------------------"
	echo "#>> Get Package Information for:$name"
	echo "#>> -----------------------------------------------"

	. /tmp/HLFS_paths

	name=$1

	pkg_fullname=''
	pkg_depack_dir=''
	pkg_type=''

	pkg_fullname=`cat $HLFS_CONFIG/packages.conf | egrep -v "^#" | egrep "^$name" | sed "s/[ ][ ]*/\t/g" | sed "s/[\t][\t]*/\t/g" | cut -f 2`
	pkg_depack_dir=`cat $HLFS_CONFIG/packages.conf | egrep -v "^#" | egrep "^$name" | sed "s/[ ][ ]*/\t/g" | sed "s/[\t][\t]*/\t/g" | cut -f 3`

	pkg_type=`echo $pkg_fullname | egrep -o "(tar\.bz2|tar\.gz)$"`

}

#>> ----------------------------------------------------------------------------
#>> CD BY PACKAGE NAME
#>> ----------------------------------------------------------------------------

function cd_by_pkgname
{

	name=$1;

	echo "#>> -----------------------------------------------"
	echo "#>> CD BY Package Name:$name"
	echo "#>> -----------------------------------------------"

	. /tmp/HLFS_paths

	get_pkg_info "$name"

	HLFS_SOURCE_DIR="$HLFS/sources";

	echo "Change Dir to:$HLFS_SOURCE_DIR/$pkg_depack_dir"
	cd $HLFS_SOURCE_DIR/$pkg_depack_dir

}

