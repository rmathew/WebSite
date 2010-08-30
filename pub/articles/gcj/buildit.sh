#!/bin/sh

# You *MUST* update this variable to reflect your setup.
#
XGCC_DIR=/extra/xgcc

# You do not have to change anything below this, but it does not
# hurt to review it anyway.

MAKE=make

PATH=$XGCC_DIR/bin:$PATH
export PATH

$MAKE
BUILD_STATUS=$?

if test "$BUILD_STATUS" = "0"
then
  echo Press ENTER when you are ready to install...
  read dummy

  $MAKE install
fi
