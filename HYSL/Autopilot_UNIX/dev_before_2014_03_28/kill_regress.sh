#!/usr/bin/ksh

# 08/06/2010 YKono Fix failed to kill on some platform which has old .env file
#                  and it PATH is old path.
# 09/02/2011 YKono Not kill ap.sh process
# 10/08/2013 YKono Bug 17531687 NEED A WAY TO TAG THE RELEASE NAME

. apinc.sh

psucmd="psu"
killesscmd=`which kill_essprocs.sh`

# Kill shell process which inlcude $1 string
killsh()
{
	${psucmd} | egrep -i "$shstr" | grep -v grep  | \
	  egrep -v "$$" | egrep -v "$snglsh" | \
	  egrep "$1" 2> /dev/null | while read pid data
	do
		if [ "${data#*ap.sh}" = "$data" ]; then
			echo "Kill $pid:$data"
			kill -9 $pid
		fi
	#	sleep 1
	done
}

skiptsk=
regonly=false
while [ $# -ne 0 ]; do
	case $1 in
		-s|-skip|-skiptask)
			skiptsk="-s"
			;;
		-h|-help)
			echo "kill_regress.sh [-s|-r]"
			echo "Kill autopilot tasks. And restore current task file."
			echo "Parameter:"
			echo " -s : Skip restore the task file."
			echo " -r : regression only. keep autopilot task."
			exit 1
			;;
		-r)
			regonly=true
			;;
		*)
	esac
	shift
done


if [ `uname` = "Windows_NT" ]; then
	shstr="sh.exe"
	snglsh=".*sh.exe$|-~"
else
	shstr="/usr/bin/ksh|/bin/sh"
	snglsh="\-ksh"
fi

path_backup=$PATH
envfile="$AUTOPILOT/mon/${LOGNAME}@`hostname`.env"
if [ -f "$envfile" ]; then
	for var in PATH SXR_HOME _OPTION CRRPRIORITY
	do
		_tmp_=`cat "$envfile" 2> /dev/null | grep "^${var}="`
		if [ -n "$_tmp_" ]; then
			_tmp_=${_tmp_#${var}=}
			if [ "${_tmp_#\"}" != "${_tmp_}" ]; then
				_tmp_=${_tmp_#?}; _tmp_=${_tmp_%?}
			fi
			export $var="$_tmp_"
		fi
	done
fi

# Keep sh.exe which are related $AUTOPILOT
[ "$regonly" = "false" ] && killsh "$AUTOPILOT"
killsh "$VIEW_PATH/"
killsh "${SXR_HOME%/*}"
${killesscmd} -all
export PATH=$path_backup
# Remove autopilot related temporary work files.
node="${LOGNAME}@`hostname`"
svusr="`hostname`_${LOGNAME}"
rm -f $AUTOPILOT/mon/$node.ap 2> /dev/null
rm -f $AUTOPILOT/mon/$node.am 2> /dev/null
rm -f $AUTOPILOT/mon/$node.log 2> /dev/null
rm -f $AUTOPILOT/mon/$svusr.crr 2> /dev/null
rm -f $AUTOPILOT/mon/$svusr.regmon.sal 2> /dev/null
rm -f $AUTOPILOT/pid/$svusr.pid 2> /dev/null
rm -rf "$AUTOPILOT/mon/${node}.ap.vdef.txt" > /dev/null 2>&1
rm -rf "$AUTOPILOT/mon/${node}.reg.vdef.txt" > /dev/null 2>&1
rm -rf "$AUTOPILOT/lck/${node}.ap.lck" > /dev/null 2>&1
rm -rf "$AUTOPILOT/lck/${node}.reg.lck" > /dev/null 2>&1
rm -rf "$AUTOPILOT/lck/${node}.lck" > /dev/null 2>&1
rm -rf "$AUTOPILOT/lck/${node}.terminate" > /dev/null 2>&1

echo "`date +%D_%T` $node ??? $_AP_IN_BG : autopilot.sh was killed by kill_regress.sh." >> $aphis
recover_crrtsk.sh $skiptsk -m kill_regress.sh
