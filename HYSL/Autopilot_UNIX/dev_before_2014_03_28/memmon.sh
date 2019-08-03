#!/usr/bin/ksh

# memmon.sh

# Memory usage monitor for Essbase related tasks.

# memmon.sh <parent id> <log file> <test name>

# Ext:
#    ${LOGNAME}@`hostname`.memmon
#    ${LOGNAME}@`hostname`.memmon.lck
#    ${LOGNAME}@`hostname`.memusage.txt <- memory usage record


# $? = 0 : Start well
#    = 1 : Already exist


. apinc.sh
. lockdef.sh

unset parpid testname
if [ $# -ne 0 ]; then
	parpid=$1
	shift
fi

if [ $# -ne 0 ]; then
	memfile=$1
	shift
fi

if [ $# -ne 0 ]; then
	testname=$1
	shift
fi

if [ -z "$memfile" -o -z "$parpid" ]; then
	exit 1
fi

apfile="${lockfld}/${LOGNAME}@`hostname`.memmon"
termfile="${apfile}.terminate"

# if use "-forcequit" parameter, the keep_lock.sh create terminate request file
#   if you ignore that request, keep_lock.sh forcely kill parent process wfter 30 min.
#   if you delete the terminate file, then keep_lock.sh won't kill your process.
#     it just delete lock file.
lckid=`lock.sh -forcequit "$apfile" $$`
if [ $? -ne 0 ]; then
	echo "Error: There is another memmon.sh."
	cat "$apfile.lck"
	exit 1
fi

# Initialize

rm -f "$memfile" > /dev/null 2>&1


# Main loop
plat=`get_platform.sh`
max=0
usage=0
trap '' 1 2 3 15
while [ 1 ]; do
	if [ -f "$termfile" ]; then
		dbgwrt "memusage.sh : Receive terminate request."
		break
	fi
	if [ -n "$parpid" -a "`ps -p ${parpid} 2> /dev/null | grep -v PID`" = "" ]; then
		dbgwrt "memmon.sh : No parent."
		unlock.sh $apfile > /dev/null 2>&1
		break
	fi
	case $plat in
		win*)
			tmpfile="$AUTOPILOT/mon/${LOGNAME}@`hostname`.memusage.tmp"
			psu -ess > $tmpfile
			subttl=0
			rm -f $tmpfile > /dev/null 2>&1
			while read pid cmd; do
				usage=`memusage.exe $pid | tail -1`
				let subttl="$subttl + $usage"
				echo "  $usage/$subttl($pid:$cmd) at `date +%D_%T`" >> ${memfile}
			done < $tmpfile
			rm -f $tmpfile > /dev/null 2>&1
			;;
		hpux64)
			tmpfile1="$AUTOPILOT/mon/${LOGNAME}@`hostname`.memusage1.tmp"
			tmpfile2="$AUTOPILOT/mon/${LOGNAME}@`hostname`.memusage2.tmp"
			rm -f $tmpfile1 > /dev/null 2>&1
			rm -f $tmpfile2 > /dev/null 2>&1
			top -f $tmpfile1
			grep $LOGNAME $tmpfile1 | egrep "ESSBASE|ESSCMD|ESSSVR|essmsh" > $tmpfile2
			subttl=0
			while read d1 d2 pid d3 d4 d5 usage d6 d7 d8 d9 d10 cmd; do
				if [ "${usage#${usage%?}}" = "M" ]; then
					usage=${usage%?}
				else
					usage=${usage%?}
					let usage="$usage * 1024"
				fi
				let subttl="$subttl + $usage"
				echo "  $usage/$subttl($pid:$cmd) at `date +%D_%T`" >> ${memfile}
			done < $tmpfile2
			rm -f $tmpfile1 > /dev/null 2>&1
			rm -f $tmpfile2 > /dev/null 2>&1
			;;
		*)
			;;
	esac
	[ "$max" -lt "$subttl" ] && max=$subttl
	echo "$subttl/$max at `date +%D_%T`" >> ${memfile}
	sleep 30
done
rm -f "$termfile" > /dev/null 2>&1
echo $max >> $memfile

trap 1 2 3 15
dbgwrt "memmon.sh : Terminate."
# echo "================================"
# echo "Peak is $max."

exit 0
