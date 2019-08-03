#!/usr/bin/ksh
# instlock.sh : Lock installation related processes.
# Description:
#    This script lock installation related processes like user and machine.
# Syntax: instlock.sh $$
# History:
# 2013/04/04	YKono	First edition
. apinc.sh

msg()
{
	if [ "$dbg" = "true" ]; then
		pre="`date +%D_%T`:"
		if [ $# -eq 0 ]; then
			(IFS=
			while read line; do
				echo "${pre}$line"
			done)
		else
			(IFS=
			while [ $# -ne 0 ]; do
				echo "${pre}$1"
				shift
			done)
		fi
	fi
}

ppid=
dbg=false
slp=15
msgonce=
while [ $# -ne 0 ]; do
	case $1 in
		+d|+dbg)	dbg=true;;
		-d|-dbg)	dbg=false;;
		*)		ppid=$1;;
	esac
	shift
done

if [ -z "$pid" ]; then
	ppid=`ps -f -p $$ | grep -v PPID`
	ppid=`echo $ppid | awk '{print $3}'`
	msg "my ppid=$ppid"
fi

hostlck=$AUTOPILOT/lck/instlock.host.$thishost
userlck=$AUTOPILOT/lck/instlock.user.$LOGNAME

# Check the machine uses nfshome as login location.
nfshome_machine=`cat $AUTOPILOT/data/nfshome.txt 2> /dev/null | grep -v ^# | grep $thishost`
msg "nfshome machine=$nfshome_machine"
[ -n "$nfshome_machine" ] && usersts="fail" || usersts="succeeded_not_needed"
hoststs="fail"
while [ "${hoststs#succeeded}" = "$hoststs" -o "${usersts#succeeded}" = "$usersts" ]; do
	msg "# host=$hoststs, user=$usersts"
	if [ "${usersts#succeeded}" = "$usersts" ]; then
		msg "Check ${userlck##*/} is locked."
		lock_ping.sh $userlck
		if [ $? -eq 0 ]; then
			locknd=`cat ${userlck}.lck 2> /dev/null | head -1 | tr -d '\r'`
			locknd=${locknd%% *}
			msg "\"$locknd\" keeps lock for ${userlck##*/}."
			if [ "$locknd" = "$thisnode" ]; then
				lockpid=`cat ${userlck}.lck 2> /dev/null | grep "target=" | tr -d '\r'`
				lockpid=${lockpid##*target=}
				pid=$ppid
				msg "Check ${userlck##*/} is locked by my parent tree(pid=$lockpid)."
				while [ -n "$lockpid" -a -n "$pid" -a "$pid" -ne 0 -a "${usersts#succeeded}" = "$usersts" ]; do
					msg "- check pid=$pid"
					if [ "$pid" = "$lockpid" ]; then
						msg "Found lock process($pid)."
						usersts="succeeded_by_parent"
					else
						pid=`ps -f -p $pid 2> /dev/null | grep -v PID`
						pid=`echo $pid | awk '{print $3}'`
					fi
				done
			fi
		else
			msg "Try to lock ${userlck##*/}."
			p=`lock.sh $userlck $ppid -m "instlck:$ppid"`
			if [ $? -eq 0 ]; then
				msg "- Lock ${userlck##*/} succeeded."
				usersts="succeeded_by_myself"
			else
				msg "- Failed to lack ${userlck##*/}."
			fi
		fi
	fi
	if [ "${usersts#succeeded}" != "$usersts" ]; then
		msg "Check ${hostlck##*/} is locked."
		lock_ping.sh $hostlck
		if [ $? -eq 0 ]; then
			locknd=`cat ${hostlck}.lck 2> /dev/null | head -1 | tr -d '\r'`
			locknd=${locknd%% *}
			msg "\"$locknd\" keep lock for ${hostlck##*/}."
			if [ "$locknd" = "$thisnode" ]; then
				lockpid=`cat ${hostlck}.lck 2> /dev/null | grep "target=" | tr -d '\r'`
				lockpid=${lockpid##*target=}
				pid=$ppid
				msg "Check ${hostlck##*/} is locked by my parent tree(locker_pid=$lockpid)."
				while [ -n "$lockpid" -a -n "$pid" -a "$pid" -ne 0 -a "${hoststs#succeeded}" = "$hoststs" ]; do
					msg "- check pid=$pid"
					if [ "$pid" = "$lockpid" ]; then
						msg "Found lock process($pid)."
						hoststs="succeeded_by_parent"
					else
						pid=`ps -f -p $pid 2> /dev/null | grep -v PID`
						pid=`echo $pid | awk '{print $3}'`
					fi
				done
			fi
		else
			msg "Try to lock ${hostlck##*/}."
			p=`lock.sh $hostlck $ppid -m "instlck:$ppid"`
			if [ $? -eq 0 ]; then
				msg "- Lock ${hostlck##*/} succeeded."
				hoststs="succeeded_by_myself"
			else
				msg "- Failed to lock ${hostlck##*/}."
			fi
		fi
		if [ "${hoststs#succeeded}" = "$hoststs" ]; then
			if [ "$usersts" = "succeeded_by_myself" ]; then
				msg "Unlock ${userlck##*/} because failed to loack host process."
				unlock.sh $userlck
				usersts="fail"
			fi
		fi
	fi
	if [ "${usersts#succeeded}" = "$usersts" -o "${hoststs#succeeded}" = "$hoststs" ]; then
		if [ -z "$msgonce" ]; then
			echo "`date +%D_%T`:Failed to lock installer. Wait for other done."
			(IFS=
			if [ -f "${userlck}.lck" ]; then
				echo "[${userlck}.lck]"
				cat ${userlck}.lck 2> /dev/null | while read line; do 
					echo "> $line"
				done
			fi
			if [ -f "${hostlck}.lck" ]; then
				echo "[${hostlck}.lck]"
				cat ${hostlck}.lck 2> /dev/null | while read line; do 
					echo "> $line"
				done
			fi
			)
			msgonce="displayed"
		fi
		msg "Sleep $slp secs."
		sleep $slp
	fi
done

	
