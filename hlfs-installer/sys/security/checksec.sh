#!/bin/bash
#
# Copyright (C) 2009-2010 Tobias Klein.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by Tobias Klein.
# 4. The name Tobias Klein may not be used to endorse or promote
#    products derived from this software without specific prior written
#    permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# Name    : checksec.sh
# Version : 1.2
# Author  : Tobias Klein
# Date    : January 2010
# Download: http://www.trapkit.de/tools/checksec.html
# Changes : http://www.trapkit.de/tools/checksec_changes.txt
#
# Description:
#
# Modern Linux distributions offer some mitigation techniques to make it 
# harder to exploit software vulnerabilities reliably. Mitigations such 
# as RELRO, NoExecute (NX), Stack Canaries, Address Space Layout 
# Randomization (ASLR) and Position Independent Executables (PIE) have 
# made reliably exploiting any vulnerabilities that do exist far more 
# challenging. The checksec.sh script is designed to test what *standard* 
# Linux OS and PaX (http://pax.grsecurity.net/) security features are being 
# used.
#
# Credits:
#
# Thanks to Brad Spengler (grsecurity.net) for the PaX support.
#

# help
if [ "$#" = "0" ]; then
  echo "usage: checksec OPTIONS"
  echo -e "\t--file <binary name>"
  echo -e "\t--dir <directory name>"
  echo -e "\t--proc <process name>"
  echo -e "\t--proc-all"
  echo -e "\t--proc-libs <process ID>"
  echo -e "\t--version"
  echo
  exit 1
fi

# version information
version() {
  echo "checksec v1.2, Tobias Klein, www.trapkit.de, January 2010"
  echo 
}

# check file(s)
filecheck() {
  # check for RELRO support
  if readelf -l $1 2>/dev/null | grep -q 'GNU_RELRO'; then
    if readelf -d $1 2>/dev/null | grep -q 'BIND_NOW'; then
      echo -n -e '\033[32mFull RELRO   \033[m   '
    else
      echo -n -e '\033[33mPartial RELRO\033[m   '
    fi
  else
    echo -n -e '\033[31mNo RELRO     \033[m   '
  fi

  # check for stack canary support
  if readelf -s $1 2>/dev/null | grep -q '__stack_chk_fail'; then
    echo -n -e '\033[32mCanary found   \033[m   '
  else
    echo -n -e '\033[31mNo canary found\033[m   '
  fi

  # check for NX support
  if readelf -l $1 2>/dev/null | grep 'GNU_STACK' | grep -q 'RWE'; then
    echo -n -e '\033[31mNX disabled\033[m   '
  else
    echo -n -e '\033[32mNX enabled \033[m   '
  fi 

  # check for PIE support
  if readelf -h $1 2>/dev/null | grep -q 'Type:[[:space:]]*EXEC'; then
    echo -n -e '\033[31mNo PIE               \033[m   '
  elif readelf -h $1 2>/dev/null | grep -q 'Type:[[:space:]]*DYN'; then
    if readelf -d $1 2>/dev/null | grep -q '(DEBUG)'; then
      echo -n -e '\033[32mPIE enabled          \033[m   '
    else   
      echo -n -e '\033[33mDynamic Shared Object\033[m   '
    fi
  else
    echo -n -e '\033[33mNot an ELF file      \033[m   '
  fi 
}

# check process(es)
proccheck() {
  # check for RELRO support
  if readelf -l $1/exe 2>/dev/null | grep -q 'Program Headers'; then
    if readelf -l $1/exe 2>/dev/null | grep -q 'GNU_RELRO'; then
      if readelf -d $1/exe 2>/dev/null | grep -q 'BIND_NOW'; then
        echo -n -e '\033[32mFull RELRO       \033[m '
      else
        echo -n -e '\033[33mPartial RELRO    \033[m '
      fi
    else
      echo -n -e '\033[31mNo RELRO         \033[m '
    fi
  else
    echo -n -e '\033[33mPermission denied\033[m\n'
    exit 1
  fi

  # check for stack canary support
  if readelf -s $1/exe 2>/dev/null | grep -q 'Symbol table'; then
    if readelf -s $1/exe 2>/dev/null | grep -q '__stack_chk_fail'; then
      echo -n -e '\033[32mCanary found         \033[m  '
    else
      echo -n -e '\033[31mNo canary found      \033[m  '
    fi
  else
    if [ "$1" != "1" ]; then
      echo -n -e '\033[33mPermission denied    \033[m  '
    else
      echo -n -e '\033[33mNo symbol table found\033[m  '
    fi
  fi

  # first check for PaX support
  if cat $1/status 2> /dev/null | grep -q 'PaX:'; then
    pageexec=( $(cat $1/status 2> /dev/null | grep 'PaX:' | cut -b6) )
    segmexec=( $(cat $1/status 2> /dev/null | grep 'PaX:' | cut -b10) )
    mprotect=( $(cat $1/status 2> /dev/null | grep 'PaX:' | cut -b8) )
    randmmap=( $(cat $1/status 2> /dev/null | grep 'PaX:' | cut -b9) )
    if [[ "$pageexec" = "P" || "$segmexec" = "S" ]] && [[ "$mprotect" = "M" && "$randmmap" = "R" ]]; then
      echo -n -e '\033[32mPaX enabled\033[m   '
    elif [[ "$pageexec" = "p" && "$segmexec" = "s" && "$randmmap" = "R" ]]; then
      echo -n -e '\033[33mPaX ASLR only\033[m '
    elif [[ "$pageexec" = "P" || "$segmexec" = "S" ]] && [[ "$mprotect" = "m" && "$randmmap" = "R" ]]; then
      echo -n -e '\033[33mPaX mprot off \033[m'
    elif [[ "$pageexec" = "P" || "$segmexec" = "S" ]] && [[ "$mprotect" = "M" && "$randmmap" = "r" ]]; then
      echo -n -e '\033[33mPaX ASLR off\033[m  '
    elif [[ "$pageexec" = "P" || "$segmexec" = "S" ]] && [[ "$mprotect" = "m" && "$randmmap" = "r" ]]; then
      echo -n -e '\033[33mPaX NX only\033[m   '
    else
      echo -n -e '\033[31mPaX disabled\033[m  '
    fi
  # fallback check for NX support
  elif readelf -l $1/exe 2>/dev/null | grep 'GNU_STACK' | grep -q 'RWE'; then
    echo -n -e '\033[31mNX disabled\033[m   '
  else
    echo -n -e '\033[32mNX enabled \033[m   '
  fi 

  # check for PIE support
  if readelf -h $1/exe 2>/dev/null | grep -q 'Type:[[:space:]]*EXEC'; then
    echo -n -e '\033[31mNo PIE               \033[m   '
  elif readelf -h $1/exe 2>/dev/null | grep -q 'Type:[[:space:]]*DYN'; then
    if readelf -d $1/exe 2>/dev/null | grep -q '(DEBUG)'; then
      echo -n -e '\033[32mPIE enabled          \033[m   '
    else   
      echo -n -e '\033[33mDynamic Shared Object\033[m   '
    fi
  else
    echo -n -e '\033[33mNot an ELF file      \033[m   '
  fi
}

# check mapped libraries
libcheck() {
  libs=( $(awk '{ print $6 }' /proc/$1/maps | grep '/' | sort -u | xargs file | grep ELF | awk '{ print $1 }' | sed 's/:/ /') )
 
  printf "\n* Loaded libraries (file information, # of mapped files: ${#libs[@]}):\n\n"
  
  for element in $(seq 0 $((${#libs[@]} - 1)))
  do
    echo "  ${libs[$element]}:"
    echo -n "    "
    filecheck ${libs[$element]}
    printf "\n\n"
  done
}

# check for system-wide ASLR support
aslrcheck() {
  # PaX ASLR support
  if !(cat /proc/1/status 2> /dev/null | grep -q 'Name:') ; then
    echo -n -e ':\033[33m insufficient privileges for PaX ASLR checks\033[m\n'
    echo -n -e '  Fallback to standard Linux ASLR check'
  fi
  
  if cat /proc/1/status 2> /dev/null | grep -q 'PaX:'; then
    printf ": "
    if cat /proc/1/status 2> /dev/null | grep 'PaX:' | grep -q 'R'; then
      echo -n -e '\033[32mPaX ASLR enabled\033[m\n\n'
    else
      echo -n -e '\033[31mPaX ASLR disabled\033[m\n\n'
    fi
  else
    # standard Linux 'kernel.randomize_va_space' ASLR support
    # (see the kernel file 'Documentation/sysctl/kernel.txt' for a detailed description)
    printf " (kernel.randomize_va_space): "
    if /sbin/sysctl -a 2>/dev/null | grep -q 'kernel.randomize_va_space = 1'; then
      echo -n -e '\033[33mOn (Setting: 1)\033[m\n\n'
      printf "  Description - Make the addresses of mmap base, stack and VDSO page randomized.\n"
      printf "  This, among other things, implies that shared libraries will be loaded to \n"
      printf "  random addresses. Also for PIE-linked binaries, the location of code start\n"
      printf "  is randomized. Heap addresses are *not* randomized.\n\n"
    elif /sbin/sysctl -a 2>/dev/null | grep -q 'kernel.randomize_va_space = 2'; then
      echo -n -e '\033[32mOn (Setting: 2)\033[m\n\n'
      printf "  Description - Make the addresses of mmap base, heap, stack and VDSO page randomized.\n"
      printf "  This, among other things, implies that shared libraries will be loaded to random \n"
      printf "  addresses. Also for PIE-linked binaries, the location of code start is randomized.\n\n"
    elif /sbin/sysctl -a 2>/dev/null | grep -q 'kernel.randomize_va_space = 0'; then
      echo -n -e '\033[31mOff (Setting: 0)\033[m\n'
    else
      echo -n -e '\033[31mNot supported\033[m\n'
    fi
    printf "  See the kernel file 'Documentation/sysctl/kernel.txt' for more details.\n\n"
  fi 
}

# check cpu nx flag
nxcheck() {
  if grep -q nx /proc/cpuinfo; then
    echo -n -e '\033[32mYes\033[m\n\n'
  else
    echo -n -e '\033[31mNo\033[m\n\n'
  fi
}

if [ "$1" = "--dir" ]; then
  cd $2
  printf "RELRO           STACK CANARY      NX            PIE                     FILE\n"
  for N in [a-z]*; do
    if [ "$N" != "[a-z]*" ]; then
      filecheck $N
      if [ `find $2$N \( -perm -004000 -o -perm -002000 \) -type f -print` ]; then
        printf "\033[37;41m%s%s\033[m" $2 $N
      else
        printf "%s%s" $2 $N
      fi
      echo
    fi
  done
  exit 0
fi

if [ "$1" = "--file" ]; then
  printf "RELRO           STACK CANARY      NX            PIE                     FILE\n"
  filecheck $2
  if [ `find $2 \( -perm -004000 -o -perm -002000 \) -type f -print` ]; then
    printf "\033[37;41m%s%s\033[m" $2 $N
  else
    printf "%s" $2
  fi
  echo
  exit 0
fi

if [ "$1" = "--proc-all" ]; then
  cd /proc
  printf "* System-wide ASLR"
  aslrcheck
  printf "* Does the CPU support NX: "
  nxcheck 
  printf "         COMMAND    PID RELRO             STACK CANARY           NX/PaX        PIE\n"
  for N in [1-9]*; do
    if [ $N != $$ ] && readlink -q $N/exe > /dev/null; then
      printf "%16s" `head -1 $N/status | cut -b 7-`
      printf "%7d " $N
      proccheck $N
      echo
    fi
  done
  exit 0
fi

if [ "$1" = "--proc" ]; then
  cd /proc
  printf "* System-wide ASLR"
  aslrcheck
  printf "* Does the CPU support NX: "
  nxcheck
  printf "         COMMAND    PID RELRO             STACK CANARY           NX/PaX        PIE\n"
  for N in `ps -Ao pid,comm | grep $2 | cut -b1-6`; do
    if [ -d $N ]; then
      printf "%16s" `head -1 $N/status | cut -b 7-`
      printf "%7d " $N
      proccheck $N
      echo
    fi
  done
fi

if [ "$1" = "--proc-libs" ]; then
  cd /proc
  printf "* System-wide ASLR"
  aslrcheck
  printf "* Does the CPU support NX: "
  nxcheck
  printf "* Process information:\n\n"
  printf "         COMMAND    PID RELRO             STACK CANARY           NX/PaX        PIE\n"
  N=$2
  if [ -d $N ]; then
      printf "%16s" `head -1 $N/status | cut -b 7-`
      printf "%7d " $N
      proccheck $N
      echo
      libcheck $N
    fi
fi

if [ "$1" = "--version" ]; then
  version
fi
