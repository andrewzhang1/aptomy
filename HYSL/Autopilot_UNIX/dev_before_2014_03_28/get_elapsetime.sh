#!/usr/bin/ksh
# get_elapsetime.sh
# Get rlapse time of the file from current time
if [ -f "$1" ]; then
	if [ `uname` = "AIX" ]; then
		export LC_ALL=C
	fi
	tarfile=$1
	export tarfile
	eltime=`perl -e '$ftime=(stat("$ENV{'tarfile'}"))[9];$ctime=time; $elapstim=$ctime - $ftime;print $elapstim;'`
	echo $eltime
else
	echo 0
fi

