#!/usr/bin/ksh
#######################################################################
# svrelease.sh : release from the server service
#######################################################################
# HISTORY #############################################################
# 03/03/2011 YKono	First Edition

. apinc.sh

######################################################################
# Start main
######################################################################

lckfld=$AUTOPILOT/lck
monfld=$AUTOPILOT/mon

# Get parent process ID.
ppid=`ps -p $$ -f | grep -v PID | awk '{print $3}'`

cl_lckf=$lckfld/${thisnode}.cl

# Check previous lock exists
lock_ping.sh $cl_lckf > /dev/null 2>&1
if [ $? -eq 0 ]; then
	tmp=
	[ -f "$cl_lckf.lck" ] && tmp=`cat "$cl_lckf.lck" 2> /dev/null | grep " target=" | awk -F= '{print $2}'`
	if [ "$ppid" != "$tmp" ]; then
		echo "Found client lock file."
		echo "But parent PID are not match."
		echo "Current PPID=$ppid. Lck PPID=$tmp"
		exit 2
	else
		unlock.sh $cl_lckf
	fi
else
	echo "There is no connection."
	exit 1
fi

exit 0
