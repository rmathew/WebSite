#!/usr/bin/env bash
# Generates the canonical URL on the web-site for a given local file.
#
# Usage:
#
#   canonical.sh <relative-file-path>
#

if [[ -z "${1}" ]]; then
  echo ERROR: Missing relative file-path.
  echo
  echo Usage: canonical.sh \<relative-file-path\>
  exit 1
fi

echo -n "${1}" | \
  sed 's/^src\//https:\/\/rmathew\.com\//;s/\.htm4$/\.html/;s/index\.html$//'
