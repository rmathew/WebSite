#!/bin/sh

# Script to configure cross-binutils for MinGW.

# You MUST update these variables to reflect your set up.
#
BU_SRC_DIR=/extra/src/binutils-2.16.1
PREFIX=/extra/xgcc
SYSROOT=$PREFIX/sys-root


# You do not have to change anything below this, but it does not
# hurt to review it anyway.

TARGET=i686-pc-mingw32
BUILD=`$BU_SRC_DIR/config.guess`
HOST=$BUILD

$BU_SRC_DIR/configure --prefix="$PREFIX" --with-sysroot="$SYSROOT" \
    --build=$BUILD --host=$HOST --target=$TARGET \
    --disable-nls --disable-shared --disable-debug
