#!/bin/bash

# Removes leading/trailing spaces/tabs and empty lines from a
# given file or from the standard input.

if [ -z "$1" ]
then
  sed 's/^[ \t]*//;s/[ \t]*$//' | sed '/^$/d'
else
  sed -i 's/^[ \t]*//;s/[ \t]*$//' "$1"
  sed -i '/^$/d' "$1"
fi
