#!/usr/bin/ksh
# rmfld.sh : Remove folder contents.
# History:
# 2012/09/06	YKono	First Edition

me=$0
orgpar=$@
targs=
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			exit 0
			;;
		*)
			targs="$targs $1"
			;;
	esac
	shift
done

remove_folder()
{
	if [ -d "$1" ]; then
		rm -rf $1 > /dev/null 2>&1
		if [ -d "$1" -a "`uname`" = "Windows_NT" ]; then
			kill_essprocs.sh all
			rm -rf $1 > /dev/null 2>&1
		fi
		if [ -d "$1" ]; then
			rendir.sh $1
			rm -rf $1 2> /dev/null
			if [ -d "$1" ]; then
				echo "${me##*/}: Couldn't remove $1. Keep it."
			fi
		fi
	elif [ -f "$1" ]; then
		rm -f $1 > /dev/null 2>&1
	else
		echo "${me##*/}: Directory $1 not found."
	fi
	# mkddir.sh $1
}

crrdir=`pwd`
for onedir in $targs; do
	remove_folder $onedir
done

