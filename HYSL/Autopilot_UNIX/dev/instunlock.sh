#!/usr/bin/ksh
# instunlock.sh : Unlock installation related processes.
# Description:
#    This script unlock installation related processes like user and machine.
# Syntax: instunlock.sh $$
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
[ -n "$nfshome_machine" ] && usersts="locked" || usersts="unlocked_not_needed"
msg "nfshome machine=$nfshome_machine."

msg "Check ${hostlck##*/} is locked."
lock_ping.sh $hostlck
if [ $? -eq 0 ]; then
	locknd=`cat ${hostlck}.lck 2> /dev/null | head -1 | tr -d '\r'`
	locknd=${locknd%% *}
	msg "\"$locknd\" keep lock for ${hostlck##*/}."
	if [ "$locknd" = "$thisnode" ]; then
		lockpid=`cat ${hostlck}.lck 2> /dev/null | grep "target=" | tr -d '\r'`
		lockpid=${lockpid##*target=}
		msg "${hostlck##*/} is locked by $lockpid."
		if [ "$lockpid" = "$ppid" ]; then
			msg "Unlocked ${hostlck##*/}."
			unlock.sh $hostlck
		else
			msg "${hostlck##*/} was not locked by my parent $ppid(lock_process=$lockpid)."
		fi
	fi
else
	msg "No one lock ${hostlck##*/}."
fi

if [ "$usersts" = "locked" ]; then
	msg "Check ${userlck##*/} is locked."
	lock_ping.sh $userlck
	if [ $? -eq 0 ]; then
		locknd=`cat ${userlck}.lck 2> /dev/null | head -1 | tr -d '\r'`
		locknd=${locknd%% *}
		msg "\"$locknd\" keep lock for ${userlck##*/}."
		if [ "$locknd" = "$thisnode" ]; then
			lockpid=`cat ${userlck}.lck 2> /dev/null | grep "target=" | tr -d '\r'`
			lockpid=${lockpid##*target=}
			msg "${userlck##*/} is locked by $lockpid."
			if [ "$lockpid" = "$ppid" ]; then
				msg "Unlocked ${userlck##*/}."
				unlock.sh $userlck
			else
				msg "${userlck##*/}  was not locked by my parent $ppid(lock_process=$lockpid)."
			fi
		fi
	else
		msg "No one lock ${userlck##*/}."
	fi
fi


