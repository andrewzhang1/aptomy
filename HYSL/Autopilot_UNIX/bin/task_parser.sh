#!/usr/bin/ksh
# task_parser.sh : Task parser for autopilot framework.
# 
# Description:
# This script parse *.tsk file and deploy each task into the queue folder.
# Task file should be located in $AUTOPILOT/tsk folder with following name:
#   User specific task file = ${LOGNAME}.tsk
#   Platform specific task file = ${`get_platform.sh`}.tsk (win32, win64...)
#   All platform task file = all.tsk
# This scrit read those files and create execute-task file under the
# $AUTOPILOT/que folder with following name format:
#   <priority>~<verion>~<build>~<test>~<plat|node>.tsk
# When create execute-task file, this script check the target task alreadu done or
# currently executing. If target task has igndone(true) option, it doesn't mind that
# that task already done or not. Those checks reference following folder:
#   Done task = $AUTOPILOT/que/done
#   Current task = $AUTOPILOT/que/crr
# Note: if there is same task in the current executing task, this script update the
# priority level of current execution to new priority in the task file.

# Reference:
# get_platform.sh	
# get_latest.sh		
# chk_para.sh		
# get_elapsetime.sh	# to get the elapse time for the platform or all task file.

# Queue file name format:
# <priority>~<verion>~<build>~<test>~<plat|node>.tsk
# <priority>	4 digits numeric. Priority level multipled by 10. i.e. priority(15) -> 0150
# <version>		Version string like "kennedy", "9.3.1.2.0"...
# <build>		Build number. When use "latest" in the task file, 
#				it will be expanded to the current latest number.
# <test>		Test script name. If a test script name has a space like 
#				"agtpjlmain.sh serial direct", a space is replaced with "+".
# <plat|node>	Platform name or node name like <user>@<machin name>. i.e. ykono@stsun12

# History:
# 04/04/2008 YKono - First edition
# 04/22/2008 YKono - Add parser information into task file.
# 05/28/2008 YKono - Add HIT build version
# 08/06/2008 YKono - Use parse_one_task.sh
# 04/09/2009 YKono - Add task order priority
# 07/06/2009 YKono - Use new read & parse lock logic.
# 05/17/2010 YKono - Remove AP_TSKORDER and implement force order.
# 08/04/2010 YKono Change task lock file location from tsk fodler to lck folder.

. apinc.sh

##############################################
# FUNCTIONS

# chk_schedule $opt
chk_schedule()
{
	ret=false
	schdls=`chk_para.sh schedule "${1#*:*:*:}" | tr -d '\r'`
	if [ -n "$schdls" ]; then
		for schdl in $schdls
		do
			case $schdl in
				$today|$wkday|$day|$nthwk|$biwk)
					ret=true
					break
					;;
			esac
		done
	else
		ret=true
	fi
	echo $ret
}


#############################################
# MAIN START

# Get today's information for schedule option
if [ "$LANG" != "C" ]; then
	lang_save=$LANG
	export LANG=C
else
	unset lang_save
fi

plat=`get_platform.sh -l`
today=`date "+%m/%d/%Y"`
wkday=`date +%a`
day=`date +%d`
nthwk=`expr \`date +%e\` / 7 + 1``date +%a`
biwk=`date +%U`
biwk=`date +%a``expr 1${biwk} % 2`
[ -n "$lang_save" ] && export LANG=$lang_save

if [ "$1" = "-silent" ]; then
	silent=true
else
	silent=false
fi
echo "## $today, `date +%T`, $wkday, $day, $nthwk, $biwk"

if [ -n "$AP_TSKFILE" ]; then
	mytsk="$AP_TSKFILE"
fi

# Task parse process for specific machine/user.
if [ -f "$mytsk" ]; then
	# Create node lock file. This file is refered from autopilot.sh.
	# When processing the specific user/machine task, autopilot.sh should wait on reading queue.
	cnt=0
	while [ $cnt -lt 10 ]; do
		_pid=`lock.sh $AUTOPILOT/lck/${node}.read $$`
		if [ $? -eq 0 ]; then
			cnt=locked
			break;
		fi
		let cnt=cnt+1
	done
	if [ "$cnt" = "locked" ]; then
		cnt=0
		while [ $cnt -lt 10 ]; do
			_pid=`lock.sh $AUTOPILOT/lck/${node}.parse $$`
			if [ $? -eq 0 ]; then
				cnt=locked
				break;
			fi
			let cnt=cnt+1
		done
		if [ "$cnt" = "locked" ]; then
			fn=`basename "$mytsk"`
			cnt=0
			grep "^${node}:" $mytsk | sed -e "s/^[^:]*://g" | tr -d '\r' | \
			while read line; do
				if [ -n "$line" -a `chk_schedule "$line"` = "true" ]; then
					tskodr="order=$cnt"
					[ "$silent" = "true" ] \
						&& parse_one_task.sh $node "$line" "using $fn from task_parser.sh" $tskodr > /dev/null \
						|| parse_one_task.sh $node "$line" "using $fn from task_parser.sh" $tskodr
					let cnt=cnt+1
				fi
			done
			grep "^`hostname`:" $mytsk | sed -e "s/^[^:]*://g" | tr -d '\r' | \
			while read line; do
				if [ -n "$line" -a `chk_schedule "$line"` = "true" ]; then
					tskodr="order=$cnt"
					[ "$silent" = "true" ] \
						&& parse_one_task.sh $node "$line" "using $fn from task_parser.sh" $tskodr > /dev/null \
						|| parse_one_task.sh $node "$line" "using $fn from task_parser.sh" $tskodr
					let cnt=cnt+1
				fi
			done
			unlock.sh $AUTOPILOT/lck/${node}.parse > /dev/null 2>&1
		else
			[ "$silent" != "true" ] && echo "## Failed to lock the ${node}."
		fi
		unlock.sh $AUTOPILOT/lck/${node}.read > /dev/null 2>&1
	else
		[ "$silent" != "true" ] && echo "## Failed to lock the ${node}."
	fi
fi

if [ "$AP_NOPLAT" = "false" ]; then

	cnt=0
	while [ $cnt -lt 10 ]; do
		_pid=`lock.sh $AUTOPILOT/lck/${plat}.read $$`
		if [ $? -eq 0 ]; then
			cnt=locked
			break;
		fi
		let cnt=cnt+1
	done
	if [ "$cnt" = "locked" ]; then
		_pid=`lock.sh $AUTOPILOT/lck/${plat}.parse $$`
		if [ $? -eq 0 ]; then
			if [ -f "$plattsk" ]; then
				fn=`basename "$plattsk"`
				cnt=0
				cat "$plattsk" | tr -d '\r' | \
					grep -v "^#" | \
					grep -v "^$" | \
				while read line; do
					if [ -n "$line" -a `chk_schedule "$line"` = "true" ]; then
						tskodr="order=$cnt"
						[ "$silent" = "true" ] \
							&& parse_one_task.sh $plat "$line" "using $fn from task_parser.sh" $tskodr > /dev/null \
							|| parse_one_task.sh $plat "$line" "using $fn from task_parser.sh" $tskodr
						let cnt=cnt+1
					fi
				done
			fi
			unlock.sh $AUTOPILOT/lck/${plat}.parse > /dev/null 2>&1
		else
			if [ "$silent" != "true" ]; then
				echo "## Someone is parsing ${plat}.tsk."
				echo "## Skip parsing ${plat}.tsk."
				if [ -f "$AUTOPILOT/tsk/${plat}.parse.lck" ]; then
					cat $AUTOPILOT/tsk/${plat}.parse.lck | while read line; do
						echo "## > $line"
					done
				fi
			fi
		fi
		unlock.sh $AUTOPILOT/lck/${plat}.read > /dev/null 2>&1
	else
		[ "$silent" != "true" ] && echo "## Failed to lock the ${plat}."
	fi
fi
