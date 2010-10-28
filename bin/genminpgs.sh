#!/bin/bash
# Generates only the necessary pages on the web-site for a given post.
# (FIXME: Works only for book-review posts at the moment.)
#
# Usage:
#
#   genminpgs.sh <page_id> [<cat_id>]
#
# <cat_id> is the category identifier and has the default value "others".

if [ -n "$1" ]
then
  BOOK_ID="$1"
else
  echo ERROR: Missing book-review page id.
  echo
  echo Usage: genminpgs.sh \<page_id\> \[\<cat_id\>\]
  echo
  echo "  If unspecified, <cat_id> has the default value \"others\"."
  exit 1
fi

BOOK_CAT=others
if [ -n "$2" ]
then
  BOOK_CAT="$2"
fi

CURR_YEAR=`date +%Y`
if [ ! -f "$PWD/src/$CURR_YEAR/$BOOK_ID.htm4" ]
then
  echo ERROR: Missing book-review page \"src/$CURR_YEAR/$BOOK_ID.htm4\".
  exit 1
fi

BOOK_IMG="books/images/$BOOK_ID.jpg"
if [ ! -f "$PWD/src/$BOOK_IMG" ]
then
  echo ERROR: Missing book-cover image \"src/$BOOK_IMG\".
  exit 1
fi

if [ ! -f deps.mk ]
then
  make deps
fi

UPDT_FILES="index.html atom.xml $CURR_YEAR/index.html"
UPDT_FILES="$UPDT_FILES $CURR_YEAR/$BOOK_ID.html books/$BOOK_CAT.html"

for A_FILE in $UPDT_FILES
do
  make $PWD/pub/$A_FILE
done

UPLOAD_FILES="$UPDT_FILES $BOOK_IMG"
echo
echo "Files to upload:"
for A_FILE in $UPLOAD_FILES
do
  echo "  \"$A_FILE\""
done
