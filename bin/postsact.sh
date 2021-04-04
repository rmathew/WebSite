#!/bin/bash
#
# Uses the "actcal.awk" script to generate an activity-calendar for blog-posts
# till the current year (or the year given by the first argument).
#
# It finds the number of posts created per month and then feeds it to the AWK-
# script. For every month "20YY-MM" in which there was at least one blog-post,
# the emitted input-lines for the script are of the form:
#
#   N 20YY-MM
#
# The terminal year is given as a command-line argument to the script.
FINAL_YEAR=${1:-$(date "+%Y")}

BIN_DIR=$(dirname $0)
BIN_DIR=$(cd "${BIN_DIR}"; pwd)
SRC_DIR=$(cd "${BIN_DIR}/../src"; pwd)

find "${SRC_DIR}" -type f -path "${SRC_DIR}/20??/*.htm4" \
    -exec grep m4_post_date \{\} \; | cut -f3 -d'`' | cut -b1-10 | sort \
    | cut -b1-7 | uniq -c | sed 's/^[ ]*//' \
    | awk -f "${BIN_DIR}/actcal.awk" -v FINAL_YEAR="${FINAL_YEAR}"
