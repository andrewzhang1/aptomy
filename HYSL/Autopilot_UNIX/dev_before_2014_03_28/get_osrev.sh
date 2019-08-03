#!/usr/bin/ksh
#######################################################################
# get_osrev.sh : Get current OS revision.
# Syntax:
#   get_platform.sh [-h|-d]
# Options:
#   -h : Display help
# Description:
#   This script return the OS platform kind likw win32, winamd64...
#   When define "-d" option, this script returned detailed information.
#######################################################################
# History:
# 12/12/2012 YK Fist edition. 
me=$0
orgpar=$@
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			exit 0
			;;
		*)
			echo "get_osrev.sh:Syntax error."
			exit 1
			;;
	esac
	shift
done

case `uname` in
	HP-UX)		echo "`uname -r``uname -v`";;
	SunOS) 		uname -r;;
	AIX)		echo "`uname -v``uname -r`";;
	# AIX : oslevel -r # This display 6100-12
	Windows_NT)	echo "`uname -r``uname -v`";;
	CYGWIN*)	echo "`uname -r``uname -v`" ;;
	Linux)
		if [ -f "/etc/SuSE-release" ]; then
			os_v=`cat /etc/SuSE-release 2> /dev/null | grep ^VERSION`
			os_v=${os_v##* }
			os_p=`cat /etc/SuSE-release 2> /dev/null | grep ^PATCHLEVEL`
			os_p=${os_p##* }
			echo "SuSE_$os_v.$os_p"
		else
			os_rev=`uname -r`
			echo ${os_rev%%-*}
		fi
		;;		
	*)	echo "unknown";;
esac
