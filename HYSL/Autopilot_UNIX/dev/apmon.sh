#!/usr/bin/ksh

# apmon.sh	: Autopilot monitor
# Description:
# This shell monitor the autopilot.sh is alive or not.
# History:
# Apr. 07, 2008 YKono - First edition
# Jul. 16, 2008 Ykono - Add "trap 2" for support linux platform.
# Dev. 28, 2008 Ykono - Remove first parser phase.
# Nov. 11, 2013 YKono - Bug 17438148 - CHANGE TASK PARSING TIME TO 05:00 FROM 02:00
#                       Re-write with new parse_time.txt.

trap 'echo "ctrl+C (apmon.sh)"' 2
. apinc.sh

unset set_vardef
set_vardef AP_PARSETIME

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

read_pt()
{
	if [ -f "$ptf" ]; then
		if [ "$ptc" != "`cat $ptf 2> /dev/null`" ]; then
			unset vers
			pttmp="$HOME/.pttmp.$$"
			rm -rf $pttmp
			cat $ptf 2> /dev/null | grep -v "^#" | grep -v "^$" | sort | tr -d '\r' | while read line; do
				echo ${line%% *}
			done > $pttmp
			times=
			while read line; do
				t=${line%%=*}
				t="${t%:*}${t#*:}"
				ver=${line#*=}
				if [ "$line" != "$ver" ]; then
					[ -z "$vers" ] && vers=$ver || vers="$vers $ver"
					t="${t}=${ver}"
				fi
				[ -z "$times" ] && times=$t || times="$times $t"
			done < $pttmp
			rm -rf $pttmp
			ptc=`cat $ptf 2> /dev/null`
		fi
	else
		if [ "$ptc" != "set by AP_PARSETIME" ]; then
			unset times vers
			for one in $AP_PARSETIME; do
				ver=${one#*=}
				t=${one%%=*}
				t="${t%:*}${t#*:}"
				if [ "$one" != "$ver" ]; then
					[ -z "$vers" ] && vers=$ver || vers="$vers $ver"
					t="${t}=${ver}"
				fi
				[ -z "$times" ] && times=$t || times="$times $t"
			done
			[ -z "$times" ] && times="1000"
			ptc="set by AP_PARSETIME"
		fi
	fi
}

ptf=$AUTOPILOT/data/parse_time.txt
ptc=
vers=
times=
prevdate=`date +%d`
prevtime=`date +%H%M`
brk=false
read_pt
echo "Start apmon.sh($appid->$$,times=$times,vers=$vers)"
# Tell parent (autopilot) apmon.sh is ready
rm -f $1 2> /dev/null
while [ 1 ]; do
	# Check sal file(command for stop)
	[ ! -f "$amsal" ] && break
	# Check parent
	tmp=`ps -fp $appid  2> /dev/null | grep $appid`
	if [ -z "$tmp" ]; then
		echo "apmon.sh : No parent($appid)"
		echo "`date +%D_%T` ${LOGNAME}@$(hostname) $appid $_AP_IN_BG : CAUGHT MISSING AUTOPILOT by apmon.sh." \
			>> $AUTOPILOT/pid/${LOGNAME}\@$(hostname).log
		break
	fi
	read_pt
	trg=
	crrtime=`date +%H%M`
	crrdate=`date +%d`
	ver=
	for one in $times; do
		ttime=${one%%=*}
		if [ "$ttime" -le "$crrtime" ]; then
			trg=$ttime
			[ "$ttime" != "$one" ] && ver=${one#*=} || ver=
		elif [ "$ttime" -gt "$crrtime" ]; then
			break
		fi
	done
	if [ -n "$trg" ]; then
		if [ "$crrdate" = "$prevdate" ]; then
			[ "$prevtime" -ge "$trg" ] && trg=
		fi
	fi
	if [ -n "$trg" ]; then
		if [ -n "$vers" ]; then
			if [ -n "$ver" ]; then
				task_parser.sh $ver
			else
				task_parser.sh -i $vers
			fi
		else
			task_parser.sh -silent
		fi
		prevdate=$crrdate
		prevtime=$crrtime
	fi
	sleep 300
done

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
