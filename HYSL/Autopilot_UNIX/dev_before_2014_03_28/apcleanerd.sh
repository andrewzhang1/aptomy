#!/usr/bin/ksh

# 08/17/2010 YKono First Edition

. apinc.sh

mylck=$AUTOPILOT/lck/apcleaner
mylog=$AUTOPILOT/mon/apcleaner.log

trap 'echo "Got init"' 1 2 3 15
if [ -f "$mylog" ]; then
	rm -rf $mylog
fi
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
				echo "`date +%D_%T`:${LOGNAME}@$(hostname):$$:$node.crr:Found AP lock but no response - Delete." >> $mylog
				rm -rf $one > /dev/null 2>&1
			fi
		else
			echo "`date +%D_%T`:${LOGNAME}@$(hostname):$$:$node.crr:No AP lock -> Delete." >> $mylog
			rm -rf $one > /dev/null 2>&1
		fi
	done
	# Check current execution files
	echo "-----------------------------------------------------" >> $mylog
	echo "`date +%D_%T`:${LOGNAME}@$(hostname):$$:Start cleaning current execution tasks..." >> $mylog
	lstsk.sh -ap crr all opt | while read tsk; do
		ver=`echo $tsk | awk -F"|" '{print $1}'`
		bld=`echo $tsk | awk -F"|" '{print $2}'`
		scr=`echo $tsk | awk -F"|" '{print $3}' | sed -e "s/ /+/g"`
		plt=`echo $tsk | awk -F"|" '{print $4}'`
		runp=`echo $tsk | awk -F"|" '{print $7}'`
		tskf=$ver~$bld~$scr~$plt.tsk
		apf=$AUTOPILOT/mon/$runp.ap
		n=`cat $apf 2> /dev/null | grep "$tskf"`
		if [ -z "$n" ]; then
			echo "`date +%D_%T`:${LOGNAME}@$(hostname):$$:$tsk:No current exe-rec in AP/mon/$runp.ap. - Delete." >> $mylog
			rm -rf "$AUTOPILOT/que/crr/$tskf"
		else
			lock_ping.sh "$AUTOPILOT/lck/${runp}.ap"
			sts=$?
			if [ $sts -eq 0 ]; then		
				echo "`date +%D_%T`:${LOGNAME}@$(hostname):$$:$tsk:Found current exe-rec in AP/mon/$runp.ap and AP alive - Keep." >> $mylog
			else
				echo "`date +%D_%T`:${LOGNAME}@$(hostname):$$:$tsk:Found current exe-rec in AP/mon/$runp.ap but AP not responded - Delete." >> $mylog
				rm -rf "$AUTOPILOT/que/crr/$tskf"
			fi
		fi
	done

	echo "`date +%D_%T`:${LOGNAME}@$(hostname):$$:DONE." >> $mylog
	crrdate=`date +%D`
	while [ "$execdate" = "$crrdate" ]; do
		sleep 600
		crrdate=`date +%D`
	done
done

unlock.sh $mylck > /dev/null 2>&1

exit 0
