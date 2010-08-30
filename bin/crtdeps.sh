#!/bin/sh

# Figures out the HTML and XML files to be generated ("GEN_HTML" and
# "GEN_XML") as well as the dependencies between the files.
#
# This information is put into $OUTFILE in a format understood by make.

if test -z "$1"
then
  echo "ERROR: Source directory missing!" 1>&2
  exit 1
fi

if test -z "$2"
then
  echo "ERROR: Target directory missing!" 1>&2
  exit 1
fi

ORIG_DIR="$PWD"

SRC_DIR="$1"
SRC_DIR=`cd $SRC_DIR; pwd`
TGT_DIR="$2"

BIN_DIR=`dirname $0`
BIN_DIR=`cd $BIN_DIR; pwd`

OUTFILE="$ORIG_DIR/deps.mk"

# These are the files that should *not* be generated.
IGNORE_LIST="header.html \| footer.html \| template.html \| sitesrch.html"

echo Generating dependencies information in \"$OUTFILE\"...
cd "$SRC_DIR"

rm -f "$OUTFILE"

# Prepare a list of generated HTML files.
echo Listing HTML files...
echo "GEN_HTML=\\" >>$OUTFILE
for i in `find . -name "*.htm4"`
do
  # The names are of the form "./foo/bar.htm4". Convert it to "foo/bar.html".
  HTML_FILE=`echo $i | cut -b3- | sed s/\.htm4$/\.html/`
  echo "  $TGT_DIR/$HTML_FILE \\" | grep -v "$IGNORE_LIST" >>$OUTFILE
done

echo >>$OUTFILE

# Prepare a list of generated XML files.
echo Listing XML files...
echo "GEN_XML=\\" >>$OUTFILE
for i in `find . -name "*.xm4"`
do
  # The names are of the form "./foo/bar.xm4". Convert it to "foo/bar.xml".
  XML_FILE=`echo $i | cut -b3- | sed s/\.xm4$/\.xml/`
  echo "  $TGT_DIR/$XML_FILE \\" | grep -v "$IGNORE_LIST" >>$OUTFILE
done

# Get the dependencies for each of the HTML files.
echo Getting dependencies for HTML files...
for i in `find . -name "*.htm4"`
do
  # The names are of the form "./foo/bar.htm4". Convert it to "foo/bar.html".
  HTML_FILE=`echo $i | cut -b3- | sed s/\.htm4$/\.html/`

  DEPS=""
  
  # Find files directly included using "m4_include".
  for j in `grep m4_include\( $i | sed 's/ //g'`
  do
    # We have something like "m4_include(`foo/bar.htm4')".
    INC_FILE=`echo $j | cut -f2 -d\( | cut -b2- | cut -f1 -d\'`
    DEPS="$DEPS $INC_FILE"
  done

  # Find files directly included using "m4_include_post".
  for j in `grep m4_include_post\( $i | sed 's/ //g'`
  do
    # We have something like "m4_include_post(`NNNN',`foo')".
    TMP=`echo $j | cut -f2 -d\( | cut -b2-`
    DIR=`echo $TMP | cut -f1 -d\'`
    FILE=`echo $TMP | cut -f2 -d, | cut -b2- | cut -f1 -d\'`
    DEPS="$DEPS $DIR/$FILE.htm4"
  done

  # Find files indirectly included using "m4_collect_posts".
  for j in `grep m4_collect_posts\( $i | sed 's/ //g'`
  do
    # We have something like "m4_collect_posts(`foo',`NNNN')"
    # or "m4_collect_posts(`foo',m4_news_year)".
    TMP=`echo $j | cut -f2 -d\, | cut -f1 -d\)`

    if test "$TMP" = "m4_news_year"
    then
      # XXX: Assume that the "m4_news_year"-style usage is only inside
      # the index files of the yearly archives.
      DIR=`dirname $HTML_FILE`
    else
      DIR=`echo $TMP | cut -f1 -d\' | cut -b2-`
    fi

    for k in `$BIN_DIR/getposts.sh $SRC_DIR/$DIR`
    do
      FILE=`echo $k | cut -f2 -d:`
      DEPS="$DEPS $DIR/$FILE.htm4"
    done
  done

  if test -n "$DEPS"
  then
    echo >>$OUTFILE
    echo $TGT_DIR/$HTML_FILE: $DEPS >>$OUTFILE
  fi
done

# Get the dependencies for each of the XML files.
echo Getting dependencies for XML files...
for i in `find . -name "*.xm4"`
do
  # The names are of the form "./foo/bar.xm4". Convert it to "foo/bar.xml".
  XML_FILE=`echo $i | cut -b3- | sed s/\.xm4$/\.xml/`

  DEPS=""
  
  # Find files directly included using "m4_include".
  for j in `grep m4_include\( $i | sed 's/ //g'`
  do
    # We have something like "m4_include(`foo/bar.xm4')".
    INC_FILE=`echo $j | cut -f2 -d\( | cut -b2- | cut -f1 -d\'`
    DEPS="$DEPS $INC_FILE"
  done

  # Find files indirectly included using "m4_collect_posts".
  for j in `grep m4_collect_posts\( $i | sed 's/ //g'`
  do
    # We have something like "m4_collect_posts(`foo',`NNNN')".
    TMP=`echo $j | cut -f2 -d\, | cut -f1 -d\)`

    DIR=`echo $TMP | cut -f1 -d\' | cut -b2-`
    for k in `$BIN_DIR/getposts.sh $SRC_DIR/$DIR`
    do
      FILE=`echo $k | cut -f2 -d:`
      DEPS="$DEPS $DIR/$FILE.htm4"
    done
  done

  if test -n "$DEPS"
  then
    echo >>$OUTFILE
    echo $TGT_DIR/$XML_FILE: $DEPS >>$OUTFILE
  fi
done

echo Done.
