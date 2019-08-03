#!/usr/bin/ksh
#######################################################################
# realplat.sh : Get real platform name
# Syntax:
#   grealplat.sh [-h] <plat>
# Options:
#   -h : Display help
# Description:
#######################################################################
# History:
# 12/12/2012 YK Fist edition. 
me=$0
orgpar=$@
plt=`get_platform.sh`
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			exit 0
			;;
		*)	plt=$1
	esac
	shift
done
[ "$plt" = "linuxx64exa" ] && echo "linuxamd64" || echo $plt
