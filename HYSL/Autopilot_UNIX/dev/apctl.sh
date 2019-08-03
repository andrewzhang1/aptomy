#!/usr/bin/ksh
# apctl.sh : Control autopilot processs
# Synxtax:
#	apctl.sh [-n <node>|<plat>|all|-s|-c|-rm|-help] [start|pause|restart|stop|KILL[/<other command>]]
#	<node>	: Target process in <user>@<machine> format. 
#				note: If you are in Linux Boxes, you should use <user>\@<machine>.
#	<plat>	: Platform kind. (win32,win64,win64,solaris,solaris64,solaris.x64,
#						aix,aix4,hpux,hpux64,linux,linux64,linuxamd64)
#	all		: Send command to all regression machines which are running now.
#	-help	: Display help.
#	start	: Send START command to target autopilot.
#	pause	: Send PAUSE command to target autopilot.
#	restart	: Send REESTART command to target autopilot.
#	stop	: Send STOP command to target autopilot.
#	KILL/	: Send KILL command to target autopilot.
#			  If other command is added after "KILL/", the autopilot move to that status
#			  after killing current regression process. When you only send "KILL" command,
#			  the autopilot process move to START status.
#	When you skip <node> and <plat> parameters, apctl.sh assume you want to send a command
#	on current machine with current user.
# Options:
#       -s  : Display current status
#       -S  : Display current status with prev result
#       -c  : Check alive
#       -rm : Remove dead task
#
# History:
# 04/18/2008 YKono - First edition
# 09/30/2010 YKono - Change plat serch logic
#                    Add -c option
. apinc.sh

list_current_aptasks()
{
	rm -rf "$tmp" 2> /dev/null
	if [ "$platk" = "node" ]; then
		ls $AUTOPILOT/mon/${plat}.ap 2> /dev/null > "$tmp"
	else
		[ "$plat" != "${plat#win}" ] && ptn="^$plat" || ptn="^$plat\$"
		grep $ptn $AUTOPILOT/mon/*.ap 2> /dev/null > "$tmp"
	fi
	ccnt=0
	while read line; do
		line=${line%:*}
		plt=$(head -3 "$line" 2> /dev/null | tail -1 | tr -d '\r')
		sts=$(tail -1 $line | tr -d '\r')
		line=$(basename $line)
		line=${line%.ap*}
		u=${line%@*}
		m=${line#*@}
		crrf=$AUTOPILOT/mon/${m}_${u}.crr
		[ "${sts##*.}" = "tsk" ] && sts=$(echo $sts | sed -e "s/~/:/g")
		dsp="$plt $line - ${sts%:*}"
		if [ "$disp_status" != "false" -a "$sts" != "${sts#*:}" ]; then
			if [ -f "$crrf" ]; then
				sc=`cat $crrf | awk -F~ '{print $9}'`
				dc=`cat $crrf | awk -F~ '{print $10}'`	
				tl=0
				let tl=sc+dc 2> /dev/null
				if [ "$disp_status" = "TRUE" -a -f "$AUTOPILOT/mon/${plt}.rec2" ]; then
					_scr=`echo ${dsp#*:*:} | sed -e "s/+/ /g"`
					_ver=${dsp%%:*}
					prevrec=`cat ${AUTOPILOT}/mon/${plt}.rec2 2> /dev/null \
						grep "$_ver" | grep "$_scr" | sort | tail -1`
					if [ -n "$prevrec" ]; then
						prevrec=${prevrec%\|*}
						_dc=${prevrec##*\|}
						prevrec=${prevrec%\|*}
						_sc=${prevrec##*\|}
						let _tl=_sc+_dc 2> /dev/null
						dsp="$dsp $tl($sc,$dc) $_tl($_sc,$_dc)"
					else
						dsp="$dsp $tl($sc,$dc)"
					fi
				else
					dsp="$dsp $tl($sc,$dc)"
				fi
			fi
		fi
		if [ "$check_alive" = "true" ]; then
			if [ -f "$AUTOPILOT/lck/${line}.ap.lck" ]; then
				acc=$(lock_ping.sh $AUTOPILOT/lck/${line}.ap)
				if [ $? -ne 0 ]; then
					dsp="$dsp - DEAD"
					if [ "$remove_nolock" = "true" ]; then
						rm -rf $AUTOPILOT/mon/${line}.ap 2> /dev/null
						rm -rf $crrf 2> /dev/null
					fi
				else
					dsp="$dsp - ALIVE"
				fi
			else
				dsp="$dsp - NOLOCK"
				if [ "$remove_nolock" = "true" ]; then
					rm -rf $AUTOPILOT/mon/${line}.ap 2> /dev/null
					rm -rf $crrf 2> /dev/null
				fi
			fi
		fi
		echo $dsp
		let ccnt=ccnt+1
	done < "$tmp"

	if [ $ccnt -ne 0 ]; then
		if [ $ccnt -eq 1 ]; then
			echo "One task."
		else
			echo "$ccnt tasks."
		fi
	else
		echo "There is no task now."
	fi
	rm -rf "$tmp"
}

set_apflag()
{
	sts=$(lock.sh $AUTOPILOT/flg/${1}_${2}.flg $$)
	while [ $? -ne 0 ]; do
		if [ -f "$AUTOPILOT/flg/${1}_${2}.flg.lck" ]; then
			echo "There is a lock file exist."
			cat "$AUTOPILOT/flg/${1}_${2}.flg.lck" | while read line; do
				echo "> $line"
			done
		fi
		sleep 5
		sts=$(lock.sh $AUTOPILOT/flg/${1}_${2}.flg $$)
	done
	echo "$3" | tr -d '\r' > $AUTOPILOT/flg/${1}_${2}.flg
	chmod 666 $AUTOPILOT/flg/${1}_${2}.flg > /dev/null 2>&1
	unlock.sh $AUTOPILOT/flg/${1}_${2}.flg
}



# set task flags
set_apflags()
{
	rm -rf "$tmp" 2> /dev/null
	if [ "$platk" = "node" ]; then
		if [ "${1#*\*}" != "$1" -o "${1#*\?}" != "$1" ]; then
			ls $AUTOPILOT/mon/$1.ap > "$tmp"
		else
			[ ! -f "$AUTOPILOT/mon/$1.ap" ] && echo "There is no autopilot.sh running on $1 now."
			echo "$AUTOPILOT/mon/$1.ap" > "$tmp"
		fi
	else
		[ "$1" != "${1#win}" ] && ptn="^$1" || ptn="^$1\$"
		grep $ptn $AUTOPILOT/mon/*.ap > "$tmp"
	fi
	ccnt=0
	while read line; do
		line=$(basename $line)
		usr=${line%@*}
		mac=${line#*@}
		mac=${mac%.*}
		echo "SET ${usr}@${mac}'s FLAG TO $2"
		set_apflag $mac $usr $2
		let ccnt=ccnt+1
	done < "$tmp"
	if [ $ccnt -ne 0 ]; then
		if [ $ccnt -eq 1 ]; then
			echo "One task modified."
		else
			echo "Total $ccnt tasks modified."
		fi
	else
		echo "There is no autopilot.sh running on $1 now."
	fi
	rm -rf "$tmp"
}

#echo "hostname=`hostname`"
#echo "username=${LOGNAME}"
#echo "node    =${node}"

tmp="$HOME/${node}_apctl.$$.tmp"
me=$0
plat=
platk=
action=
check_alive=false
remove_nolock=false
disp_status="false"
while [ $# -ne 0 ]; do
	case $1 in
		-h|-help)
			display_help.sh $me
			exit 0
			;;
		-s)
			disp_status="ture"
			;;
		-S)
			disp_status="TRUE"
			;;
		-c)
			check_alive=true
			;;
		-rm)
			remove_nolock=true
			;;
		all)
			plat="*"
			platk=node
			;;
		`isplat $1`)
			plat=$1
			platk=plat
			;;
		-n)
			if [ $# -lt 2 ]; then
				echo "-n parameter need second parameter for node."
				exit 1
			fi
			shift
			plat=$1
			platk=node
			;;
		-p)
			if [ $# -lt 2 ]; then
				echo "-p parameter need second parameter for platform."
				exit 1
			fi
			shift
			plat=$1
			platk=plat
			;;
		start|stop|restart|pause|kill|kill/*|START|STOP|RESTART|PAUSE|KILL|KILL/*)
			action=$(echo $1 | awk '{print toupper($0)}')
			;;
		*)
			plat="$1"
			platk=node
			;;
	esac
	shift
done
if [ -n "$action" ]; then
	if [ -z "$plat" ]; then
		plat=${thisnode}
		platk=node
	fi
	set_apflags "$plat" "$action"
else
	if [ -z "$plat" ]; then
		plat=${thisplat}
		platk=plat
	fi
	list_current_aptasks
fi
