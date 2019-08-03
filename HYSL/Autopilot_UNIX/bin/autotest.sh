#!/usr/bin/ksh

# autotest.sh : Setup autopilot environment

# HISTORY:
# 02/04/2011 YKono  First edition

unset hit pre_rel essbasesxr
case `uname` in
	Windows_NT)
		echo "autotest.sh doesn't support this platform."
		echo "Please use autotest.bat insted of this script."
		exit 1
		;;
	Linux)
#  /net/nar200/vol/vol3/hit on -hosts ignore,direct,nest,dev=4400010d on Fri Oct  8 10:22:40 2010
		for one in "vol3/hit" "vol3/essbasesxr" "vol2/pre_rel"; do
		varname=${one#*/}
		varval=`/bin/mount | grep "$one " | grep "hosts "`
		eval "$varname=\"${varval%% *}\""
		echo "$varname=$varval"
		if [ -z "$varval" ]; then
			echo "nar200:/vol/$one location is not mounted on this system."
			exit 1
		fi
		done
		;;
	HP-UX)
#  /net/nar200/vol/vol3/hit on -hosts ignore,direct,nest,dev=4400010d on Fri Oct  8 10:22:40 2010
		for one in "vol3/hit" "vol3/essbasesxr" "vol2/pre_rel"; do
		varname=${one#*/}
		varval=`/usr/sbin/mount | grep "$one " | grep "hosts "`
		eval "$varname=\"${varval%% *}\""
		echo "$varname=$varval"
		if [ -z "$varval" ]; then
			echo "nar200:/vol/$one location is not mounted on this system."
			exit 1
		fi
		done
		;;
	*)
		echo "Unknown platform."
		;;
esac
echo "HIT:$hit"
echo "PRE_REL:$pre_rel"
echo "ESSBASESXR:$essbasesxr"

