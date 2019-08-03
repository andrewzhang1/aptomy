#!/usr/bin/ksh

#########################################################################
# Filename: 	autopilotbg.sh
# Author:	Yukio Kono
# Description:	Run autopilot.sh as back ground task
#
#########################################################################
# History:
# 07/17/2008 YK	First Edition from autopilot2.sh
# 08/02/2010 YKono Also run delegate.sh in the autopilotbg.sh

trap "" 2
echo ""
apver.sh
echo ""
if [ -z "$AUTOPILOT" ]; then
	echo "AUTOPILOT not defined."
	exit 1
fi

export _APLOGF="$AUTOPILOT/mon/${LOGNAME}@`hostname`.ap.log"
rm -f "$_APLOGF"
export _AP_BG=true
if [ $# -eq 0 ]; then
	(autopilot.sh start;echo "logto.sh return status=$?") 2>&1 < /dev/null | logto.sh "$_APLOGF" &
	ps=$!
else
	(autopilot.sh $@;echo "logto.sh return status=$?") 2>&1 < /dev/null | logto.sh "$_APLOGF"  &
	ps=$!
fi
echo "autopilot.sh is running in back ground as $ps"

exit 0
