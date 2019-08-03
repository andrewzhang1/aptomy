#!/usr/bin/ksh

# delegate.sh

. apinc.sh

trap '' 1 2 3 15

node="${LOGNAME}@`hostname`"
apfile="${AUTOPILOT}/lck/${node}"
apcmd="${AUTOPILOT}/mon/${node}.cmd"
aptrm="${AUTOPILOT}/lck/${node}.terminate"


lckid=`lock.sh "$apfile" $$`
if [ $? -ne 0 ]; then
	echo "Error: There is another delegate.sh."
	cat "$apfile.lck" | while read line; do
		echo "> $line"
	done
	exit 1
fi
unset cmdpid
while [ 1 ]; do
	if [ -f "$aptrm" ]; then	
		break
	elif [ -f "$apcmd" -a ! -f "${apcmd}.lck" ]; then
		runbg.sh "$apcmd" > /dev/null 2>&1 < /dev/null &
		while [ -f "$apcmd" ]; do
			sleep 1
		done
	else
		sleep 1
	fi
done

unlock.sh "$apfile"

rm -f "$aptrm"

exit 0
