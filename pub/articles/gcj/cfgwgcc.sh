#!/bin/sh

# Script to configure a GCC crossed-native-compiler for MinGW.

# IMPORTANT:
# ----------
# a. You should have built and installed cross-binutils and GCC cross-compiler
#    for MinGW in the folder $XGCC_DIR.
#
# b. You should have installed mingw-runtime and w32api binaries in the
#    folder $SYSROOT/mingw.
#

# You MUST update these variables to reflect your set up.
#
GCC_SRC_DIR=/extra/src/gcc/gcc
XGCC_DIR=/win_m/xgcc
PREFIX=/win_m/wgcc


# You do not have to change anything below this, but it does not
# hurt to review it anyway.

SYSROOT=$PREFIX/sys-root
TARGET=i686-pc-mingw32
BUILD=`$GCC_SRC_DIR/config.guess`
HOST=$TARGET

CC=$XGCC_DIR/bin/$TARGET-gcc
export CC

CXX=$XGCC_DIR/bin/$TARGET-g++
export CXX

AS=$XGCC_DIR/bin/$TARGET-as
export AS

LD=$XGCC_DIR/bin/$TARGET-ld
export LD

AR=$XGCC_DIR/bin/$TARGET-ar
export AR

PATH=$XGCC_DIR/bin:$PATH
export PATH

$GCC_SRC_DIR/configure --prefix="$PREFIX" \
    --with-sysroot="$SYSROOT" --with-build-sysroot="$SYSROOT" \
    --build=$BUILD --host=$HOST --target=$TARGET \
    --enable-languages=c,c++,java \
    --with-as="$AS" --with-ld="$LD" \
    --enable-static --disable-shared \
    --with-gcc --with-gnu-as --with-gnu-ld \
    --disable-debug --disable-nls --disable-checking \
    --enable-threads=win32 --disable-win32-registry --enable-sjlj-exceptions \
    --with-gcj=$TARGET-gcj --enable-libgcj --without-x --disable-java-awt
