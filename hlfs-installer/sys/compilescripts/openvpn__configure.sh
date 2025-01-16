#!/bin/bash

./configure \
--with-ssl-headers=/usr/local/ssl/include \
--with-ssl-lib=/usr/local/ssl/lib \
--enable-iproute2 \
--enable-small \
--enable-strict \
--disable-lzo \
--disable-management \
--disable-socks \
--disable-http \
--disable-selinux \
--disable-debug \
--disable-pf \
--disable-port-share \
--disable-eurephia \
--disable-pkcs11 \

exit 0;

