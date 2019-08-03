#!/usr/bin/ksh

# extend path

# Exit:
#  0: file name only like abc.sh
#  1: include sub folder name like def/abc.sh
#  2: Absolute path or ./, ../
#     /vol1/ykono/views/abc.sh
#     C:/ykono/views/abc.sh
#     ./abc.sh
#     ../tmp/abc.sh

if [ "${1#/}" = "$1" -a "${1#?:}" = "$1" -a "${1#./}" = "$1" -a "${1#../}" = "$1" ]; then
	[ "${1#*/}" = "$1" ] && exit 0 || exit 1
else
	exit 2
fi
