#!/usr/bin/ksh
# get_freemem.sh : Get free virtual memory
# Description:
#   This script display the free virtual memory size in KB.
# Syntax: get_freemem.sh [-b|-k|-m|-g|-l]
# Option:
#   -h : Display help
#   -b : Display in byte
#   -k : Display in KB
#   -M : Display in MB
#   -G : Display in GB
#   -l : Display long format.
# 
# History:
# 2012/03/27	YKono	First edition

me=$0
orgpar=$@
unit=KB
format=short
while [ $# -ne 0 ]; do
	case $1 in
		-h)	display_help.sh $me; exit 0;;
		-k|k|KB)	unit=KB;;
		-m|m|MB)	unit=MB;;
		-b|b|B)		unit=B;;
		-g|g|GB)	unit=GB;;
		-l)		format=long;;
		*)	echo "${me##*/}:Syntax error."
			exit 1
			;;
	esac
	shift
done

if [ "`uname`" = "Windows_NT" ]; then
	mem=`sysinf memory | awk '{print $6}'`
else
	mem=`vmstat | tail -1 | awk '{print $5}'`
	let mem=mem\*1024
fi
case $unit in
	KB)	let dmem=mem/1024;;
	MB)	let dmem=mem/1048576;;
	GB)	let dmem=mem/1073741824;;
	*)	dmem=mem;;
esac
[ "$format" = "long" ] && echo "${dmem}${unit}(${mem}B)" || echo "$dmem"


