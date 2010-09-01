#!/bin/sh

# Prints out the m4 macros to include an ordered list of posts from a given
# year.

if [ "$#" != "2" ]
then
  echo "ERROR: Output option (\"-html\"/\"-xml\") and year missing." 1>&2
  exit 1
fi

if [ "$1" != "-html" -a "$1" != "-xml" ]
then
  echo "ERROR: Output option should be one of \"-html\" or \"-xml\"." 1>&2
  exit 1
fi

BIN_DIR=`dirname $0`
BIN_DIR=`cd $BIN_DIR; pwd`

SRC_DIR="$BIN_DIR/../src"
SRC_DIR=`cd $SRC_DIR; pwd`

for i in `$BIN_DIR/getposts.sh "$SRC_DIR"/"$2"`
do
  POST_DATE=`echo $i | cut -f1 -d:`
  POST_ID=`echo $i | cut -f2 -d:`

  if [ "$1" = "-html" ]
  then
    echo m4_include_post\( \`$2\', \`$POST_ID\'\)
  else
    # The following causes the correct m4_define line to be emitted
    # and subsequently interpreted by m4.
    head -3 "$SRC_DIR/$2/$POST_ID".htm4 | grep m4_post_title | sed 's/&/&amp;/g'

    echo m4_define\( \`m4_post_id\', \`$POST_ID\'\)m4_dnl
    echo m4_define\( \`m4_root_dir\', \`..\'\)m4_dnl

    echo "  <entry>"
    echo "    <id>http://rmathew.com/$2/$POST_ID.html</id>"
    echo "    <title type=\"html\">m4_post_title</title>"
    echo "    <updated>$POST_DATE""T00:00:00+05:30</updated>"
    echo "    <link rel=\"alternate\" href=\"http://rmathew.com/$2/$POST_ID.html\"/>"
    echo "    <content type=\"html\">"
    awk -f $BIN_DIR/postconv.awk "$SRC_DIR/$2/$POST_ID".htm4
    echo "    </content>"
    echo "  </entry>"
  fi
done
