#!/usr/bin/ksh

# apmon.sh	: Autopilot monitor
# Description:
# This shell monitor the autopilot.sh is alive or not.
# And call task_parser.sh by AP_WAITTIME interval.
# External reference:
# AP_WAITTIME	duration for parsing the task file. (Default=nextday)
# AP_NOPARSE_MIDNIGHT	# When define this variable to true, doesn't parse 
#                         task file during the mid night.(22:00-02:00)
# History:
# Apr. 07, 2008 YKono - First edition
# Jul. 16, 2008 Ykono - Add "trap 2" for support linux platform.
# Dev. 28, 2998 Ykono - Remove first parser phase.

trap 'echo "ctrl+C (apmon.sh)"' 2

. apinc.sh

# check parameter file.
if [ $# -ne 1 ]; then
	echo "apmon.sh: no paramter file."
	exit 0
fi

# Read parameter
appid=`head -1 "$1" 2> /dev/null`

# Check and stop another task parser if it is present.
if [ -f "$amsal" ]; then
	ampid=`head -1 "$amsal" 2> /dev/null`
	tmp=`ps -fi $ampid 2> /dev/null | grep $ampid`
	if [ -n "$tmp" ]; then
		echo "\nThere is another apmon.sh(pid=$ampid)."
		rm -f "$amsal"
		sleep 5
		tmp=`ps -fi $ampid 2> /dev/null | grep $ampid`
		if [ -n "$tmp" ]; then
			echo "Another apmon.sh is not replay."
			echo "Kill $ampid"
			kill -9 $ampid
			sleep 5
		fi
	else
		rm -f "$amsal"
	fi
fi

# Create autopilot monitor sal file
echo "$$" > "$amsal"
echo "Start at `date +%D_%T`" >> "$amsal"
echo "$appid" >> "$amsal"

if [ -z "$AP_WAITTIME" ]; then
	waittime="nextday"
else
	waittime=$AP_WAITTIME
fi

# Tell parent (autopilot) apmon.sh is ready
echo "Start apmon.sh($appid->$$,waittime=$waittime)"

brk=false
while [ "$brk" != "true" ]; do
	# task_parser.sh -silent
	rm -f $1 2> /dev/null
	if [ "$waittime" = "nextday" ]; then
		tpcond=`date +%D`
	else
		tpcond=`crr_sec`
		tpcond=`expr $tpcond + $waittime`
	fi
	while [ 1 ]; do
		midnf=false
		if [ "$AP_NOPARSE_MIDNIGHT" = "true" ]; then
			crrtm=`expr 1\`date +%H%M\` - 10000`
			if [ "$crrtm" -lt "200" -o "$crrtm" -gt "2200" ]; then
				midnf=true
			fi
		fi
		if [ "$midnf" = "false" ]; then
			if [ "$waittime" = "nextday" ]; then
				if [ "`date +%D`" != "$tpcond" ]; then
					break;
				fi
			else
				if [ "`crr_sec`" -gt "$tpcond" ]; then
					break;
				fi
			fi
		fi
		# Check sal file(command for stop)
		if [ ! -f "$amsal" ]; then
			brk=true
			break
		fi
		# Check parent
		tmp=`ps -fp $appid  2> /dev/null | grep $appid`
		if [ -z "$tmp" ]; then
			echo "apmon.sh : No parent($appid)"
			echo "`date +%D_%T` ${LOGNAME}@$(hostname) $appid $_AP_IN_BG : CAUGHT MISSING AUTOPILOT by apmon.sh." \
				>> $AUTOPILOT/pid/${LOGNAME}\@$(hostname).log
			if [ -f "$apsal" ]; then
				crrtskf=`tail -1 "$apsal"`
				if [ -f "$AP_CRRTSK/$crrtskf" ]; then
					# Move back the task to the queue
					cont=`head -1 $AP_CRRTSK/${crrtskf}`
					pby=`head -2 $AP_CRRTSK/${crrtskf} | tail -1`
					tskquen=`head -3 $AP_CRRTSK/${crrtskf} | tail -1`
					rm -f "$AP_CRRTSK/${crrtskf}"
					echo $cont > "$AP_TSKQUE/${tskquen}"
					echo $pby >> "$AP_TSKQUE/${tskquen}"
				fi
				rm -f "$apsal" 2> /dev/null
			fi
			rm -f "$amsal" 2> /dev/null
			rm -f "$AUTOPILOT/pid/$(hostname)_${LOGNAME}.pid"
			rm -f "$AUTOPILOT/sts/$(hostname)_${LOGNAME}.sts"
	rm -rf "$AUTOPILOT/mon/${LOGNAME}@$(hostname).ap.vdef.txt" > /dev/null 2>&1
	rm -rf "$AUTOPILOT/mon/${LOGNAME}@$(hostname).reg.vdef.txt" > /dev/null 2>&1
			rm -f "$AP_RTFILE"
			remove_locks
			brk=true
			break
		fi
		sleep 10
	done
	task_parser.sh -silent
done

