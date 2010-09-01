#!/bin/sh

# Figures out the HTML and XML files to be generated ("GEN_HTML" and
# "GEN_XML") as well as the dependencies between the files.
#
# This information is put into $OUTFILE in a format understood by make.

if [ "$#" != "2" ]
then
  echo "ERROR: Invalid number of arguments." 1>&2
  echo "USAGE: $0 <src_dir> <tgt_dir>" 1>&2
  exit 1
fi

ORIG_DIR="$PWD"

SRC_DIR="$1"
SRC_DIR=`cd $SRC_DIR; pwd`

cd "$ORIG_DIR"

TGT_DIR="$2"
if [ ! -d "$TGT_DIR" ]
then
  echo Creating folder \"$TGT_DIR\"...
  mkdir -p "$TGT_DIR"
fi
TGT_DIR=`cd $TGT_DIR; pwd`

BIN_DIR=`dirname $0`
BIN_DIR=`cd $BIN_DIR; pwd`

OUTFILE="$ORIG_DIR/deps.mk"

# NOTE: Subsequent code assumes this working directory.
cd "$SRC_DIR"

# Create sub-folders under the target folder as needed.
find . -type d -exec mkdir -p "$TGT_DIR"/\{\} \;

# Create symbolic links for as-is files in the target folder.
echo Linking to as-is files...
AS_IS_EXTNS="jpg gif png ico pdf sh css js txt"
for extn in $AS_IS_EXTNS
do
  for i in `find . -name "*.""$extn"`
  do
    # The names are of the form "./foo/bar.ext" - convert to "foo/bar.ext".
    A_FILE=`echo $i | cut -b3-`
    if [ ! -e "$TGT_DIR"/"$A_FILE" ]
    then
      ln -s "$SRC_DIR"/"$A_FILE" "$TGT_DIR"/"$A_FILE"
    fi
  done
done

rm -f "$OUTFILE"
echo Generating dependencies information in \"$OUTFILE\"...

# These are the HTML files that should *not* be generated.
OMIT_HTMLS="header.html|footer.html|template.html|sitesrch.html"

# Prepare a list of generated HTML files.
echo Listing HTML files...
echo "GEN_HTML=\\" >>$OUTFILE
for i in `find . -name "*.htm4"`
do
  # The names are of the form "./foo/bar.htm4" - convert to "foo/bar.html".
  HTML_FILE=`echo $i | cut -b3- | sed s/\.htm4$/\.html/`
  echo "  $TGT_DIR/$HTML_FILE \\" | grep -Ev "$OMIT_HTMLS" >>$OUTFILE
done

# Prepare a list of generated XML files.
echo Listing XML files...
echo >>$OUTFILE
echo "GEN_XML=\\" >>$OUTFILE
for i in `find . -name "*.xm4"`
do
  # The names are of the form "./foo/bar.xm4" - convert to "foo/bar.xml".
  XML_FILE=`echo $i | cut -b3- | sed s/\.xm4$/\.xml/`
  echo "  $TGT_DIR/$XML_FILE \\" >>$OUTFILE
done

# Get the dependencies for each of the HTML files.
echo Getting dependencies for HTML files...
for i in `find . -name "*.htm4"`
do
  # The names are of the form "./foo/bar.htm4" - convert to "foo/bar.html".
  HTML_FILE=`echo $i | cut -b3- | sed s/\.htm4$/\.html/`
  HTML_FILE=`echo $HTML_FILE | grep -Ev "$OMIT_HTMLS"`

  if [ -n "$HTML_FILE" ]
  then
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

      if [ "$TMP" = "m4_news_year" ]
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

    if [ -n "$DEPS" ]
    then
      echo >>$OUTFILE
      echo $TGT_DIR/$HTML_FILE: $DEPS >>$OUTFILE
    fi
  fi
done

# Get the dependencies for each of the XML files.
echo Getting dependencies for XML files...
for i in `find . -name "*.xm4"`
do
  # The names are of the form "./foo/bar.xm4" - convert to "foo/bar.xml".
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

  if [ -n "$DEPS" ]
  then
    echo >>$OUTFILE
    echo $TGT_DIR/$XML_FILE: $DEPS >>$OUTFILE
  fi
done

echo Done.
