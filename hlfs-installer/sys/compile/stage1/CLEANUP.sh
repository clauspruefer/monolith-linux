#!/bin/bash

#>> ------------------------------------------------------
#>> STRIP LIBS/BINS  -------------------------------------

strip --strip-debug /tools/lib/*
strip --strip-unneeded /tools/{,s}bin/*

rm -rf /tools/{,share}/{info,man}

