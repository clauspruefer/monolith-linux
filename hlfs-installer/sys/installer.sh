#!/bin/bash

#> -----------------------------------------------------------
#> Monolith-Linux v0.2 installer beta (20.05.2014)
#> -----------------------------------------------------------
#> ml-0.2 based on following projects:
#>
#> - Linux Hardened from Scratch (LHFS)
#> - Linux from Scratch (LFS)
#> - Beyond Linux from Scratch (BLFS)
#> - PaX/GrSecurity
#>
#> The LHFS Project seems to be dead, Monolith Linux tries to
#> continue the Hardened Linux approach started in the HLFS
#> project.
#>
#> Distributed under the GNU Public License
#> -----------------------------------------------------------
#>
#> Author: Claus Pruefer - WEB/codeX
#>
#> http://www.monolith-linux.org
#> http://www.webcodex.de
#>
#> Updated for a Installation as XEN Virtual Mashine
#>
#> - use especially for systems like fast and secure
#>   routers/firewalls, load balancers or web servers
#> - for a "real" lightweight "secure" server system
#> - use with HVM (hardware virtualization) to be "safer"
#> - example optimized for Intel XEON x86_64 build
#>
#> For exploiting protection we actually use pax/grsecurity.
#>
#> *** Exploiting techniques are far from what you believe ***
#> *** there are many techniques documented out there      ***
#> *** bypassing security mechanisms like                  ***
#> *** stack smashing protector, StackGuard, PaX, AppArmor ***
#> *** (phrack.org permits deeper insight)                 ***
#>
#> Architectures:
#>
#> - x86_64   - Intel XEON optimized        working
#> - arm-eabi - Cortex a7, Cubieboard3      planned
#>
#> Help:
#>
#> install options and command line parameters can be found
#> in INSTALL file or by calling installer via --help switch
#>

#> -----------------------------------------------------------
#> TODO:
#> -----------------------------------------------------------
#>
#> - kernel module compilation, module selection
#> - additional source code compilation like postgresql
#> - checksec.sh auto check of related security aspects
#> - automatic host partition generation, plugging via PV drivers
#> - list all actions switch does not work/not implemented

#> -----------------------------------------------------------
#> INSTRUCTIONS
#> -----------------------------------------------------------

#> - Installation #-------------------------------------------
#>
#> 1. prerequisites
#>    - proper configured build enviornment
#>      (gcc, g++, make, flex, bison, autotools, etc.)
#>    - use provided VM template with different toolchains
#>    - add/provide the partitions used in the template config
#>      to the VM for installation, after installation reassign
#>      them to your desired VM and boot. 
#>
#> 2. checkout installation sources
#>    - mkdir /monolith-linux && cd monolith-linux
#>    - "copy" or "git clone" into monolith-linux dir
#>    - recommended way is to clone installer and templates
#>      into two different subdirs beneath monolith-linux dir
#>
#> 3. generate config template files in
#>    /monolith-linux/installer/template/$domainname/$profilename
#>    or symlink the template git repository where you
#>    version your template configuration.
#>
#>    cd /monolith-linux/installer/template
#>    ln -s ../../templates/sfl04.b.webcodex.de ./
#>
#> 4. cd into /monolith-linux/installer
#>
#> 5. start installer
#>    ./sys/installer.sh -d $domain -p $profile
#>    where domain and profile are the subdir names provided

#> - Single Step Execution #----------------------------------
#>
#> You can reproduce every single Step (Action) by calling
#> the Installer Script like this:
#>
#> # ./sys/installer.sh -d $domain -p $profile -a FS__mount_partitions
#>
#> This example will try mounting all partitions specified in
#> the template related partitions.txt file
#>


#>> ----------------------------------------------------------
#>> SET PATHs ------------------------------------------------

SYS_PWD=`pwd`;

PATH__sys="$SYS_PWD/sys";
PATH__sys_installscripts="$PATH__sys/installscripts";
PATH__sys_compilescripts="$PATH__sys/compilescripts";

PATH__template="$SYS_PWD/template";

PATH__config="$SYS_PWD/config";
PATH__config_etc="$PATH__config/etc";
PATH__config_etc_initd="$PATH__config_etc/init.d";

PATH__sources="$SYS_PWD/build/src";

PATH__install_chroot='/mnt/hlfs';
PATH__install_chroot_sources="$PATH__install_chroot/sources";

PATH__chroot_tools='/tools';
PATH__chroot_bin_env="$PATH__chroot_tools/bin/env";

PATH__chroot_tmp="$PATH__install_chroot/tmp/"


#>> ------------------------------------------------------
#>> SET PATHs --------------------------------------------

echo "LFS=$PATH__install_chroot" > /tmp/HLFS_paths
echo "HLFS=$PATH__install_chroot" >> /tmp/HLFS_paths
echo "HLFS_CONFIG=$PATH__config" >> /tmp/HLFS_paths


#>> ------------------------------------------------------
#>> DISTRO PARAMS ----------------------------------------

DISTRO__name="monolith-linux"
DISTRO__version="v0.2"
DISTRO__status="beta"


#>> ------------------------------------------------------
#>> SOURCE -----------------------------------------------

SOURCE__grub="grub-1.98.tar.gz"
SOURCE__grub_depack_dir="grub-1.98"


#>> ------------------------------------------------------
#>> SOURCE REQUIRED FUNCTIONS ----------------------------

. $PATH__sys/functions.sh


#>> ------------------------------------------------------
#>> GET CMD LINE PARAMETER -------------------------------

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "-help" ]; then

	echo "#>> -------------------------------------------------------------------"
	echo "#>> Monolith Linux Installer ${DISTRO__version} ${DISTRO__status}"
	echo "#>> Based on Hardened Linux from Scratch SVN "
	echo "#>> -------------------------------------------------------------------"
	echo "#>>"
	echo "#>> -d / --domain        Installer Domain (e.g. name.de)"
	echo "#>>"
	echo "#>> -p / --profile       Specifies an Install Profile"
	echo "#>>                      The Profile Data must be stored in directory"
	echo "#>>                      ./$InstallerRoot/template/$domainname/$profilename"
	echo "#>>                      Profile Setup see Documentation Text or Man Pages"
	echo "#>>"
	echo "#>> -a / --action        Single Step Execution (Every Installer Action can"
	echo "#>>                      be performed as a single Task)."
	echo "#>>                      Domain (-d) and Profile (-p) switch must be given."
	echo "#>>"
	echo "#>> -------------------------------------------------------------------"
	echo "#>>"
	echo "#>> Examples:"
	echo "#>>"
	echo "#>> 1. ./installer.sh -d domain.de -p profile1"
	echo "#>>    This starts Installer for domain \"domain.de\" and Profile \"profile1\""
	echo "#>>"
	echo "#>> 2. ./installer.sh -d domain.de -p profile1 -a GLOBAL__set_root_pw"
	echo "#>>    Action \"GLOBAL__set_root_pw\" for for domain \"domain.de\" and Profile \"profile1\""
	echo "#>>    will be executed (Nothing else)."

	exit;

fi;

#>> ITERATE ON INPUT PARAMS
while [ -n "$1" ]; do

	if [ "$1" = "-d" ] || [ "$1" = "--domain" ]; then
		GLOBAL__domain_name=$2;
		shift;
	elif [ "$1" = "-p" ] || [ "$1" = "--profile" ]; then
		GLOBAL__profile_name=$2;
		shift;
	elif [ "$1" = "-a" ] || [ "$1" = "--action" ]; then
		SINGLESTEP__action=$2;
		shift;
	fi

shift;

done


#>> ------------------------------------------------------
#>> OUTPUT START MESSAGE ---------------------------------

echo "#>> ------------------------------------------------"
echo "#>> Monolith Linux Installer Version v0.2 beta"


#>> ------------------------------------------------------
#>> CHECK COMMAND LINE SYNTAX ----------------------------

[ -z "$GLOBAL__profile_name" ] && echo "You have to specify a Profile Name!" && exit 1;
[ -z "$GLOBAL__domain_name" ] && echo "You have to specify a Domain Name!" && exit 1;


#>> ------------------------------------------------------
#>> SET "VARIABLE" PATHs ---------------------------------

PATH__profile="$PATH__template/$GLOBAL__domain_name/$GLOBAL__profile_name";
PATH__kernel_src="$PATH__install_chroot/usr/src/linux";


#>> ------------------------------------------------------
#>> SET CONFIG FILES -------------------------------------

CONFIGFILE__partitions="$PATH__profile/partitions.txt";

CONFIGFILE__system_vars="$PATH__sys/SYSTEM__vars.txt";
CONFIGFILE__system_vars_additional="$PATH__sys/SYSTEM__vars_additional.txt";

CONFIGFILE__tpl_sysctl="$PATH__config/sysctl.conf.tpl";
CONFIGFILE__tpl_sysctl_interface="$PATH__config/sysctl.if.conf.tpl";

CONFIGFILE__user_sysctl="$PATH__profile/sysctl.conf";
CONFIGFILE__user_sysctl_interface="$PATH__profile/sysctl_interface.conf";

CONFIGFILE__user_additional_pkgs="$PATH__profile/packages_additional.conf";


#>> ------------------------------------------------------
#>> CHECK COMMAND LINE SYNTAX ----------------------------

[ ! -d "$PATH__profile" ] && echo "Template Directory does not exist!" && exit 1;


#>> ------------------------------------------------------
#>> RESET SYSTEM VARS TO 0 -------------------------------

reset_system_vars


#>> ------------------------------------------------------
#>> SOURCE CONFIGS ---------------------------------------

#>> IF SINGLESTEP ACTION NOT GIVEN, SOURCE GLOBAL CONFIG
if [ -z "$SINGLESTEP__action" ]; then

	#>> SOURCE GLOBAL CONFIG
	TMP_CONF_FILE='global.conf';
	SRC_CONF_FILE="$PATH__config/$TMP_CONF_FILE";

	[ -f $SRC_CONF_FILE ] && . $SRC_CONF_FILE

fi


#>> ------------------------------------------------------
#>> SOURCE LOCAL CONFIG ----------------------------------

#>> SOURCE LOCAL CONFIG
TMP_CONF_FILE='local.conf';
SRC_CONF_FILE="$PATH__profile/$TMP_CONF_FILE";

[ -f $SRC_CONF_FILE ] && . $SRC_CONF_FILE


#>> ------------------------------------------------------
#>> SET GIVEN ACTION VAR TO VALUE 1 ----------------------

[ -n "$SINGLESTEP__action" ] && eval "$SINGLESTEP__action=1"


#>> ------------------------------------------------------
#>> REVIEW CONFIG ---------------------------------------

echo "#>> ------------------------------------------------"
echo "#>> Config Review"
echo "#>> ------------------------------------------------"
echo "#>>"
echo "#>> Domain Name:        $GLOBAL__domain_name"
echo "#>> Profile Name:       $GLOBAL__profile_name"
echo "#>> Singlestep Action:  $SINGLESTEP__action"
echo "#>>"

print_values_system_vars
print_values_system_vars_additional


#>> ------------------------------------------------------
#>> SET MAKE.conf ENVIRONMENT- ---------------------------

. $PATH__profile/make.conf

echo
echo "#>> ------------------------------------------------"
echo "#>> make.conf Settings"
echo "#>> ------------------------------------------------"

# add hardened compiler and linker flags
CFLAGS="$CFLAGS -fno-delete-null-pointer-checks"
CXXFLAGS="$CXXFLAGS -fno-delete-null-pointer-checks"

CFLAGS="$CFLAGS -fPIE -fstack-protector-all -D_FORTIFY_SOURCE=2"
CXXFLAGS="$CXXFLAGS -fPIE -fstack-protector-all -D_FORTIFY_SOURCE=2"
LDFLAGS="$LDFLAGS -Wl,-z,now -Wl,-z,relro -pie"

echo "MAKEFLAGS:$MAKEFLAGS"
echo "CFLAGS:$CFLAGS"
echo "CXXFLAGS:$CXXFLAGS"
echo "LDFLAGS:$LDFLAGS"

#>> ------------------------------------------------------
#>> INCLUDE ALL NECESSARY TASK GROUPS --------------------

. $PATH__sys/INC__startup.sh
. $PATH__sys/INC__network.sh
. $PATH__sys/INC__filesystem.sh
. $PATH__sys/INC__build_stage1.sh
. $PATH__sys/INC__prepare_chroot.sh

#>> ------------------------------------------------------
#>> SET HARDENED BUILD FLAGS -----------------------------

compiler_settings="$PATH__install_chroot/compiler.settings"

echo "#!/bin/bash" > $compiler_settings
echo "CFLAGS=\"$CFLAGS\"" >> $compiler_settings
echo "CXXFLAGS=\"$CXXFLAGS\"" >> $compiler_settings
echo "LDFLAGS=\"$LDFLAGS\"" >> $compiler_settings
echo "MAKEFLAGS=\"$MAKEFLAGS\"" >> $compiler_settings

chmod 770 $compiler_settings

#>> ------------------------------------------------------
#>> BUILD HARDENED STAGE2 ONWARDS ------------------------

. $PATH__sys/INC__build_stage2.sh
. $PATH__sys/INC__kernel.sh
. $PATH__sys/INC__bootloader.sh
. $PATH__sys/INC__additional.sh
. $PATH__sys/INC__cleanup.sh

