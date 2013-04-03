#!/bin/bash

# Gets the list of post identifiers from the given directory.
# Optionally emit the dates and print in chronologically-reversed order.

if [ "$#" -lt "1" ]
then
  echo "ERROR: Directory name missing." 1>&2
  exit 1
fi

if [ "$1" = "-d" ]
then
  EMIT_DATES=true
  SORT_CMD="sort -nr"
  shift 1
else
  EMIT_DATES=false
  SORT_CMD="cat"
fi

if [ ! -d "$1" ]
then
  echo "ERROR: Directory \"$1\" not found." 1>&2
  exit 1
fi

cd "$1"
for i in *.htm4
do
  POST_ID=$(basename $i .htm4)
  if [ "$POST_ID" != "index" ]
  then
    if [ "$EMIT_DATES" = "true" ]
    then
      # Process lines like "m4_define(`m4_post_date', `YYYY-MM-DD')m4_dnl"
      POST_DATE=$(grep m4_post_date $i | cut -f2 -d\' | sed s/[^0-9-]//g)
      if [ -n "${POST_DATE}" ]
      then
	echo -n "${POST_DATE}:"
      fi
    fi
    echo "${POST_ID}"
  fi
done | ${SORT_CMD}
