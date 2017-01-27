#!/bin/bash
#
# A simple script to upload all the generated web-pages via FTP.
#
# It expects the following environment variables to be set:
#   PUB_DIR: the directory with all the generated web-pages.
#   FTP_HOST: the FTP server.
#   FTP_USER: the user-name to be used with the FTP server.
#   FTP_DIR: the directory on the FTP server for the web-root.
#
# NOTE: It assumes that all the necessary sub-directories have already been
# created on the FTP server.

if [ -z "$PUB_DIR" ]
then
    echo ERROR: \"PUB_DIR\" has not been defined.
    exit 1
fi
if [ ! -d "${PUB_DIR}" ]
then
    echo ERROR: \"${PUB_DIR}\" does not exist.
    exit 2
fi
if [ -z "$FTP_HOST" ]
then
    echo ERROR: \"FTP_HOST\" has not been defined.
    exit 3
fi
if [ -z "$FTP_USER" ]
then
    echo ERROR: \"FTP_USER\" has not been defined.
    exit 4
fi
if [ -z "$FTP_DIR" ]
then
    echo ERROR: \"FTP_DIR\" has not been defined.
    exit 5
fi

cd "${PUB_DIR}"

read -p "Password: " -s PASSWD
echo ""
TEMP_SCR=$(mktemp -t ftpscrXXXXXX)

echo user "${FTP_USER}" "${PASSWD}" >> "${TEMP_SCR}"
echo cd "${FTP_DIR}" >> "${TEMP_SCR}"
echo passive >> "${TEMP_SCR}"
echo binary >> "${TEMP_SCR}"

find . -type f -printf "put %p\n" >> "${TEMP_SCR}"
find . -type l -printf "put %p\n" >> "${TEMP_SCR}"

echo quit >> "${TEMP_SCR}"

/bin/ftp -n -v "${FTP_HOST}" < "${TEMP_SCR}"

if [ -r "${TEMP_SCR}" ]
then
    rm "${TEMP_SCR}"
fi
