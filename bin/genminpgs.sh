#!/usr/bin/env bash
# Generates only the necessary pages on the web-site for a given post.
#
# Usage:
#
#   genminpgs.sh <page_id> [<cat_id>]
#
# <cat_id>, if specified, is the category-identifier for a book.

set -o errexit
set -o pipefail

if [ -n "$1" ]
then
  PAGE_ID="$1"
else
  echo ERROR: Missing page-identifier.
  echo
  echo Usage: genminpgs.sh \<page_id\> \[\<cat_id\>\]
  echo
  echo "  If specified, <cat_id> indicates the category for a book."
  exit 1
fi

if [ -n "$2" ]
then
  BOOK_CAT="$2"
fi

CURR_YEAR=`date +%Y`
if [ ! -f "$PWD/src/$CURR_YEAR/$PAGE_ID.htm4" ]
then
  echo ERROR: Missing page \"src/$CURR_YEAR/$PAGE_ID.htm4\".
  exit 1
fi

if [ -n "$BOOK_CAT" ]
then
  BOOK_IMG="books/images/$PAGE_ID.jpg"
  if [ ! -f "$PWD/src/$BOOK_IMG" ]
  then
    echo ERROR: Missing book-cover image \"src/$BOOK_IMG\".
    exit 1
  fi
fi

if [ ! -f deps.mk ]
then
  make deps
fi

UPDT_FILES="index.html atom.xml $CURR_YEAR/index.html"
UPDT_FILES="$UPDT_FILES $CURR_YEAR/$PAGE_ID.html"
if [ -n "$BOOK_CAT" ]
then
  UPDT_FILES="$UPDT_FILES books/$BOOK_CAT.html"
fi

for A_FILE in $UPDT_FILES
do
  make $PWD/pub/$A_FILE
done

UPLOAD_FILES="sitemap.xml $UPDT_FILES"
if [ -n "$BOOK_CAT" ]
then
  UPLOAD_FILES="$UPLOAD_FILES $BOOK_IMG"
fi

echo
echo "Files to upload:"
for A_FILE in $UPLOAD_FILES
do
  echo "  \"$A_FILE\""
done
