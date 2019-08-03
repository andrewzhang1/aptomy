#!/usr/bin/ksh

#########################################################################
# Filename: 	apcleaner.sh
# Author:		Yukio Kono
# Description:	Run apmaild.sh in the back ground mode.
#
#########################################################################
# History:
# 08/17/2010 YK	First Edition

# Out: $?
#   0 : Success to launch apmond.sh.
#   1 : AUTOPILOT not defined.
#   2 : lock_ping.sh success, but target PID not found.
#   3 : Failed to lock_ping.sh.

lcktarg="$AUTOPILOT/lck/apcleaner"
aplog="$AUTOPILOT/mon/apcleaner.log"

trap "" 2

if [ -z "$AUTOPILOT" ]; then
	echo "AUTOPILOT not defined."
	exit 1
fi

apcleanerd.sh > /dev/null 2>&1 < /dev/null &
pid=$!

sleep 5
lock_ping.sh "$lcktarg"
if [ $? -eq 0 ]; then
	if [ "`ps -p ${pid} 2> /dev/null | grep -v PID`" = "" ]; then
		echo "Lock is succeeded. But process $pid is not found."
		echo "apcleanerd.sh might be terminated. Please check the process."
		if [ -f "$aplog" ]; then
			cat "$aplog" | while read line; do
				cat ">> $line"
			done
		fi
		exit 2
	fi
	echo "Start apcleanerd.sh in the background mode as PID=${pid}."
else
	echo "Failed to ping($lcktarg)."
	if [ -f "$aplog" ]; then
		cat "$aplog" | while read line; do
			cat ">> $line"
		done
	fi
	exit 3
fi

exit 0
