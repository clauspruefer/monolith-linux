#!/tools/bin/bash

#>> ------------------------------------------------------
#>> SOURCE FUNCTIONS -------------------------------------

. /tmp/build_functions.sh


#>> ------------------------------------------------------
#>> DEPACK + COMPILE -------------------------------------

depack_src_file "man-pages"

make install

