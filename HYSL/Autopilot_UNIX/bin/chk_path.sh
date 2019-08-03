#!/usr/bin/ksh
#########################################################################
# Filename: 	chkpath.sh
# Author:	Yukio Kono
# Description:	Check the library path and PATH directorys are exist.
# exit 0 : Each directory in the libarary path and PATH are exists.
#      1 : Unknown platform
#      2 : Missing directory
#########################################################################
# External references:
# apinc.sh : Variable and some function definition for autopilot.
# ARBORPATH
# HYPERION_HOME
# AP_DEF_TMPPATH : create `hostname`_${LOGNAME}path.tmp under there.
# AP_IGNORE_JRE_LIBPATH : If define this, skip the test for the JRE.
#########################################################################
# History:
# 09/17/2007 YK First edition
# 10/19/2007 YK Add AP_IGNORE_JRE_LIBPATH option

. apinc.sh

pathtmp=$AP_DEF_TMPPATH/$(hostname)_${LOGNAME}path.tmp

case `uname` in
	Windows_NT)
		if [ -f "$pathtmp" ];then
			chmod 0777 $pathtmp
		fi
		CMD.EXE /C path > $pathtmp
		path=`cat $pathtmp | sed -e "s/\\\\\\/\\//g"`
		path=${path#*=}
		rm -rf $pathtmp
		;;
	AIX)
		path="$LIBPATH:$PATH"
		;;
	SunOS|Linux)
		path="$LD_LIBRARY_PATH:$PATH"
		;;
	HP-UX)
		path="$SHLIB_PATH:$PATH"
		;;
	*)
		echo "Unknown platform."
		exit 1
		;;
esac
ret=0
while [ -n "$path" ]; do
	one=${path%%${pathsep}*}
	path=${path#*${pathsep}}
	isess=`echo $one | egrep -e "$HYPERION_HOME|$ARBORPATH"`
	if [ -n "$isess" ];then
		if [ -n "$AP_IGNORE_JRE_LIBPATH" ]; then
			isjre=`echo $one | grep "JRE"`
		else
			isjre=
		fi
		if [ -z "$isjre" -a ! -d "$one" ]; then
			echo "Missing $one directory."
			ret=2
		fi
	fi
	if [ "$path" = "$one" ]; then
		break;
	fi
done

exit $ret
