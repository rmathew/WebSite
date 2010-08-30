#!/bin/sh

# Gets the ordered list of post identifiers from the given directory.

if test "$#" -lt "1"
then
  echo "ERROR: Directory name missing!" 1>&2
  exit 1
fi

if test ! -d "$1"
then
  echo "ERROR: Directory \"$1\" not found!" 1>&2
  exit 1
fi

cd $1

for i in *.htm4
do
  POST_ID=`echo $i | cut -f1 -d.`
  if test "$POST_ID" != "index"
  then
    POST_DATE=`grep m4_post_date $i | cut -f2 -d\' | sed s/[^0-9-]//g`
    echo $POST_DATE:$POST_ID
  fi
done | sort -nr
