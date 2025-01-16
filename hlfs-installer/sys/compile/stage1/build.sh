#!/bin/bash

#>> ------------------------------------------------------
#>> CREATE ENVIRONMENT -----------------------------------

./build_set_environment.sh

#>> ------------------------------------------------------
#>> COMPILE ----------------------------------------------

su hlfs ./BUILD__pass1_binutils.sh
su hlfs ./BUILD__pass1_gcc.sh
su hlfs ./BUILD__pass1_kernel_headers.sh
su hlfs ./BUILD__pass1_glibc.sh
su hlfs ./BUILD__pass2_binutils.sh
su hlfs ./BUILD__pass2_gcc.sh
su hlfs ./BUILD__pass2_tcl.sh
su hlfs ./BUILD__pass2_expect.sh
su hlfs ./BUILD__pass2_dejagnu.sh
su hlfs ./BUILD__pass2_check.sh
su hlfs ./BUILD__pass2_ncurses.sh
su hlfs ./BUILD__pass2_bash.sh
su hlfs ./BUILD__pass2_bzip2.sh
su hlfs ./BUILD__pass2_coreutils.sh
su hlfs ./BUILD__pass2_diffutils.sh
su hlfs ./BUILD__pass2_file.sh
su hlfs ./BUILD__pass2_findutils.sh
su hlfs ./BUILD__pass2_gawk.sh
su hlfs ./BUILD__pass2_gettext.sh
su hlfs ./BUILD__pass2_grep.sh
su hlfs ./BUILD__pass2_gzip.sh
su hlfs ./BUILD__pass2_m4.sh
su hlfs ./BUILD__pass2_make.sh
su hlfs ./BUILD__pass2_patch.sh
su hlfs ./BUILD__pass2_perl.sh
su hlfs ./BUILD__pass2_sed.sh
su hlfs ./BUILD__pass2_tar.sh
su hlfs ./BUILD__pass2_texinfo.sh
su hlfs ./BUILD__pass2_util-linux.sh
su hlfs ./BUILD__pass2_xz.sh

#>> ------------------------------------------------------
#>> CLEANUP ----------------------------------------------

su hlfs ./CLEANUP.sh

