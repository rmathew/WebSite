#!/bin/bash

# Figures out the HTML and XML files to be generated ("GEN_HTML" and
# "GEN_XML") as well as the dependencies between the files.
#
# This information is put into $OUT_FILE in a format understood by make.

if [ "$#" != "2" ]
then
  echo "ERROR: Invalid number of arguments." 1>&2
  echo "USAGE: $0 <src_dir> <tgt_dir>" 1>&2
  exit 1
fi

ORIG_DIR="$PWD"
SRC_DIR="$(cd $1; pwd)"

TGT_DIR="$2"
cd "$ORIG_DIR"
if [ ! -d "$TGT_DIR" ]
then
  echo -n Creating folder \"$TGT_DIR\"...
  mkdir -p "$TGT_DIR"
  echo done.
fi
TGT_DIR="$(cd $TGT_DIR; pwd)"

BIN_DIR="$(dirname $0)"
BIN_DIR="$(cd $BIN_DIR; pwd)"

# NOTE: Subsequent code assumes this working directory.
cd "$SRC_DIR"

# Create sub-folders under the target folder as needed.
find . -type d -exec mkdir -p "$TGT_DIR"/\{\} \;

# Create symbolic links for as-is files in the target folder.
echo -n Linking to as-is files...
AS_IS_EXTNS="jpg gif png ico pdf sh css js txt"
for extn in $AS_IS_EXTNS
do
  for i in $(find . -name "*.""$extn")
  do
    # The names are of the form "./foo/bar.ext" - convert to "foo/bar.ext".
    A_FILE="$(echo $i | cut -b3-)"
    if [ ! -e "$TGT_DIR"/"$A_FILE" ]
    then
      ln -s "$SRC_DIR"/"$A_FILE" "$TGT_DIR"/"$A_FILE"
    fi
  done
done
echo done.

OUT_FILE="$ORIG_DIR/deps.mk"
if [ -e "${OUT_FILE}" ]
then
  echo -n Removing existing output file \"${OUT_FILE}\"...
  rm "${OUT_FILE}"
  echo done.
fi
echo Generating dependencies information in \"${OUT_FILE}\".

# These are the HTML files that should *not* be generated.
# (Uses extended grep syntax for an OR pattern.)
OMIT_HTMLS="header.html|footer.html|template.html|sitesrch.html"

# Prepare a list of generated HTML files.
echo -n Listing HTML files...
echo "GEN_HTML=\\" >>$OUT_FILE
for i in $(find . -name "*.htm4")
do
  # The names are of the form "./foo/bar.htm4" - convert to "foo/bar.html".
  HTML_FILE="$(echo $i | cut -b3- | sed s/\.htm4$/\.html/)"
  HTML_FILE=$(echo $HTML_FILE | grep -Ev "$OMIT_HTMLS")
  if [ -n "$HTML_FILE" ]
  then
    echo "  $TGT_DIR/$HTML_FILE \\" >>$OUT_FILE
  fi
done
echo done.

# Prepare a list of generated XML files.
echo -n Listing XML files...
echo >>$OUT_FILE
echo "GEN_XML=\\" >>$OUT_FILE
for i in $(find . -name "*.xm4")
do
  # The names are of the form "./foo/bar.xm4" - convert to "foo/bar.xml".
  XML_FILE="$(echo $i | cut -b3- | sed s/\.xm4$/\.xml/)"
  echo "  $TGT_DIR/$XML_FILE \\" >>$OUT_FILE
done
echo done.

# Get the dependencies for each of the HTML files.
# TODO: This could be done in a much better manner with awk.
echo -n Getting dependencies for HTML files...
for i in $(find . -name "*.htm4")
do
  # The names are of the form "./foo/bar.htm4" - convert to "foo/bar.htm4".
  HTM4_FILE="$(echo $i | cut -b3-)"
  DEPS="common.m4 sitesrch.htm4"
  
  # Find files directly included using "m4_include".
  for j in $(grep m4_include\( $i | sed 's/ //g')
  do
    # We have something like "m4_include(`foo/bar.htm4')".
    INC_FILE="$(echo $j | cut -f2 -d\( | cut -b2- | cut -f1 -d\')"
    DEPS="$DEPS $INC_FILE"
    if [ "${INC_FILE}" = "posttrans.m4" ]
    then
      DEPS="${DEPS} header.htm4 footer.htm4"
    fi
  done

  # Find files directly included using "m4_include_post".
  for j in $(grep m4_include_post\( $i | sed 's/ //g')
  do
    # We have something like "m4_include_post(`NNNN',`foo')".
    TMP="$(echo $j | cut -f2 -d\( | cut -b2-)"
    DIR="$(echo $TMP | cut -f1 -d\')"
    FILE="$(echo $TMP | cut -f2 -d, | cut -b2- | cut -f1 -d\')"
    DEPS="$DEPS $DIR/${FILE}.htm4"
  done

  # Find files indirectly included using "m4_collect_posts".
  for j in $(grep m4_collect_posts\( $i | sed 's/ //g')
  do
    # We have something like "m4_collect_posts(`foo',`NNNN')"
    # or "m4_collect_posts(`foo',m4_news_year)".
    TMP="$(echo $j | cut -f2 -d\, | cut -f1 -d\))"

    if [ "$TMP" = "m4_news_year" ]
    then
      # XXX: Assume that the "m4_news_year"-style usage is only inside
      # the index files of the yearly archives.
      DIR="$(dirname $HTM4_FILE)"
    else
      DIR="$(echo $TMP | cut -f1 -d\' | cut -b2-)"
    fi

    for k in $(${BIN_DIR}/getposts.sh ${SRC_DIR}/${DIR})
    do
      DEPS="${DEPS} ${DIR}/${k}.htm4"
    done
  done

  HTML_FILE="$(echo ${HTM4_FILE} | sed s/\.htm4$/\.html/)"
  HTML_FILE=$(echo $HTML_FILE | grep -Ev "$OMIT_HTMLS")
  if [ -n "$HTML_FILE" ]
  then
    echo >>$OUT_FILE
    echo ${TGT_DIR}/${HTML_FILE}: ${DEPS} >>${OUT_FILE}
  fi
done
echo done.

# Get the dependencies for each of the XML files.
echo -n Getting dependencies for XML files...
for i in $(find . -name "*.xm4")
do
  # The names are of the form "./foo/bar.xm4" - convert to "foo/bar.xm4".
  XM4_FILE="$(echo $i | cut -b3-)"
  DEPS="${XM4_FILE}"
  
  # Find files directly included using "m4_include".
  for j in $(grep m4_include\( $i | sed 's/ //g')
  do
    # We have something like "m4_include(`foo/bar.xm4')".
    INC_FILE="$(echo $j | cut -f2 -d\( | cut -b2- | cut -f1 -d\')"
    DEPS="$DEPS $INC_FILE"
  done

  # Find files indirectly included using "m4_collect_posts".
  for j in $(grep m4_collect_posts\( $i | sed 's/ //g')
  do
    # We have something like "m4_collect_posts(`foo',`NNNN')".
    DIR="$(echo $j | cut -f2 -d\, | cut -f1 -d\) | cut -f1 -d\' | cut -b2-)"
    for k in $(${BIN_DIR}/getposts.sh ${SRC_DIR}/${DIR})
    do
      DEPS="${DEPS} ${DIR}/${k}.htm4"
    done
  done

  XML_FILE="$(echo ${XM4_FILE} | sed s/\.xm4$/\.xml/)"
  echo >>$OUT_FILE
  echo ${TGT_DIR}/${XML_FILE}: ${DEPS} >>${OUT_FILE}
done
echo done.

echo Finished writing out \"${OUT_FILE}\".
