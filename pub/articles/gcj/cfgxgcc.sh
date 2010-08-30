#!/bin/sh

# Script to configure a GCC cross-compiler for MinGW.

# IMPORTANT: 
# ----------
# a. You should have built and installed cross-binutils for MinGW in the
#    folder $PREFIX.
#
# b. You should have installed mingw-runtime and w32api binaries
#    for MinGW in the folder $SYSROOT/mingw.
#

# You MUST update these variables to reflect your set up.
#
GCC_SRC_DIR=/extra/src/gcc/gcc
PREFIX=/win_m/xgcc


# You do not have to change anything below this, but it does not
# hurt to review it anyway.

SYSROOT=$PREFIX/sys-root
TARGET=i686-pc-mingw32
BUILD=`$GCC_SRC_DIR/config.guess`
HOST=$BUILD

PATH=$PREFIX/bin:$PATH
export PATH

$GCC_SRC_DIR/configure --prefix="$PREFIX" \
    --with-sysroot="$SYSROOT" --with-build-sysroot="$SYSROOT" \
    --target=$TARGET --host=$HOST --build=$BUILD \
    --enable-languages=c,c++,java \
    --with-gnu-as --with-gnu-ld \
    --disable-shared --enable-static \
    --disable-nls --disable-debug --disable-checking \
    --enable-threads=win32 --disable-win32-registry --enable-sjlj-exceptions \
    --enable-libgcj --without-x --disable-java-awt
