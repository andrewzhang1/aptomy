#!/usr/bin/ksh

# 08/17/2010 YKono First Edition

. apinc.sh

mylck=$AUTOPILOT/lck/cleaner
mylog=$AUTOPILOT/mon/cleaner.log

lock.sh $mylck $$
if [ $? -ne 0 ]; then
	echo "`date +%D_%T`:${LOGNAME}@$(hostname):$$:Found cleaner lock file." >> $mylog
	exit 1
fi

while [ 1 ]; do
	execdate=`date +%D`
	echo "==========================================================" >> $mylog
	echo "`date +%D_%T`:${LOGNAME}@$(hostname):$$:Start cleaning..." >> $mylog
	ls $AUTOPILOT/mon/*.crr | while read one; do
		bname=`basename $one`
		base=${bname%.*}
		hname=${base%_*}
		uname=${base##*_}
		node="${uname}@${hname}"
		if [ -f "$AUTOPILOT/lck/${node}.ap.lck" ]; then
			lock_ping.sh "$AUTOPILOT/lck/${node}.ap"
			sts=$?
			if [ $sts -eq 0 ]; then
				echo "`date +%D_%T`:${LOGNAME}@$(hostname):$$:$node.crr:Alive." >> $mylog
			else
				echo "`date +%D_%T`:${LOGNAME}@$(hostname):$$:$node.crr:Found AP lock but no resply - Delete." >> $mylog
				rm -rf $one > /dev/null 2>&1
			fi
		else
			echo "`date +%D_%T`:${LOGNAME}@$(hostname):$$:$node.crr:No AP lock -> Delete." >> $mylog
			rm -rf $one > /dev/null 2>&1
		fi
	done
	crrdate=`date +%D`
	while [ "$execdate" = "$crrdate" ]; do
		sleep 600
	done
done

unlock.sh $mylck > /dev/null 2>&1

exit 0
