#!/usr/bin/ksh

#########################################################################
# Filename: 	autopilot.sh
# Author:	Yukio Kono
# Description:	This is the controller script for the autopilot regressions
#
#########################################################################
# History:
# Original framework was written by Joseph Li and had been upgrading by 
# Rumitka Kumar. Overtook on May 2007 by YK.
# 06/20/2007 YK	First Edition from autopilot2.sh
# 06/25/2007 YK	Add task file option
# 07/17/2007 YK Add notifylevel
# 10/23/2007 YK Add help.
# 01/24/2008 YK Add AP_TRIGGER and AP_REGMON_TRIGGER
# 04/08/2008 YK Re-write every thing with using a task queue feature.
# 04/22/2008 YK Add parser information into crr/done task file.
# 04/22/2008 YK Add -noplat option
# 04/25/2008 YK Change write_apsal function to write sts to .crr file.
# 05/22/2008 YK Add AP_NOPLAT check
#               When define AP_NOPLAT=true, this autopilot won't run the
#               platform task. Only execute a node task(usr@host).
# 12/05/2008 YK Add AP_UNCOMMENTJVM and UnCommentJVM()
# 12/24/2008 YK Add AP_DIFFCNT_NOTIFY and diffCntNotify()
# 01/14/2009 YK Add SKIP task option.
# 02/06/2009 YK Add AP_CLEANUPFOLDER
# 05/14/2009 YK Remove current task file from crr que.
# 08/07/2009 YK Add BaseInst() task option.
# 06/28/2010 YK Change set default proc -> set_vardef()
# 07/12/2010 YK Add running the envdef script file.
# 08/02/2010 YKono Add calling lock.sh
# 08/04/2010 YKono Change task lock file location from tsk fodler to lck folder.
# 08/09/2010 YKono Rewrite the variable definition block. - Doc AP variables.
# 11/08/2010 YKono Move back .tsk file when the result 0/0.
# 06/03/2011 YKono Change task move back method. 

. apinc.sh

aplckf="$AUTOPILOT/lck/${LOGNAME}@$(hostname).ap"
trap 'unlock.sh "$aplckf" > /dev/null 2>&1 ; echo "autopilot.sh exit" > ~/ap.log ' EXIT

#########################################################################
# Functions
#########################################################################

# Check task parser and if not exist, lunch it.
chk_tp()
{
	if [ -f "$amsal" ]; then
		ampid=`head -1 "$amsal" 2> /dev/null`
		_tmp_=`ps -fp $ampid 2> /dev/null | grep $ampid`
		if [ -z "$_tmp_" ]; then
			rm -f "$amsal"
			sleep 5
		fi
	fi
	if [ ! -f "$amsal" ]; then
		echo "No apmon.sh. Launch it."
		echo $$ > "$ampar"
		apmon.sh "$ampar" > /dev/null 2>&1 < /dev/null &
		while [ -f "$ampar" ]; do
			sleep 5
		done
	fi
}

# chk_execplat $opt

chk_execplat()
{
	hname=`hostname`
	ignplats=`chk_para.sh ignplat "${1#*:*:*:}"`
	runplats=`chk_para.sh runplat "${1#*:*:*:}"`
	ret=true
	if [ -n "$ignplats" ]; then
		for oneplat in $ignplats
		do
			case $oneplat in
				$LOGNAME|$hname|$node)
					ret=false
					break
					;;
			esac
		done
	fi
	if [ "$ret" != "false" -a -n "$runplats" ]; then
		ret=false
		for oneplat in $runplats
		do
			case $oneplat in
				$LOGNAME|$hname|$node)
					ret=true
					break
					;;
			esac
		done
	fi
	echo $ret
}

# Write apsal $1          > Write $1 to apsal and write $1 as status to .crr file
# write_apsal $1 $2       > Write $1 to apsal
# write_apsal $1 $2 $3    > Write $1 to apsal and $1=Status, $2=main_scr, $3=ver:bld to .crr file
# write_apsal $1 $2 $3 $4 > Write $1 to apsal and $2=Status, $3=main_scr, $4=ver:bld to .crr file
write_apsal()
{
	crrdt=`date '+%m_%d_%y %H:%M:%S'`
	echo "$$" > "$apsal"
	echo "Start at `date +%D_%T`" >> "$apsal"
	echo "${plat}" >> "$apsal"
	echo "$1" >> "$apsal"
	if [ $# -eq 2 ]; then
		wrtcrr0 "" "---" "---" "$crrdt" "$1" 0 0
	elif [ $# -eq 3 ]; then
		wrtcrr0 "" "$2" "$3" "$crrdt" "$1" 0 0
	elif [ $# -eq 4 ]; then
		wrtcrr0 "" "$3" "$4" "$crrdt" "$2" 0 0
	fi
}


msg()
{
	if [ "$_AP_BG" = "true" ]; then
		echo $@ >> $_APLOGF
	else
		echo $@
	fi
}

#######################################################################
# Main Thread that will continuously run unless given non-START cmd
#######################################################################
run_autopilot()
{
	msgflip=on

	write_apsal "IDLE" both

	echo $$ > "$AUTOPILOT/pid/$(hostname)_${LOGNAME}.pid"
	set_sts "WAITING"

	while [ 1 ]; do
		cmdf="$AUTOPILOT/mon/${LOGNAME}@$(hostname).cmd"
		if [ -f "$cmdf" ]; then
			echo "### Found command file ($cmdf)."
			lcnt=0
			lock.sh "$cmdf" > /dev/null 2>&1
			sts=$?
			while [ "$sts" -ne 0 -a "$lcnt" -lt 30 ]; do
				if [ -f "${cmdf}.lck" ]; then
					echo "### Command file is locked by:"
					cat "${cmdf}.lck" | while read line; do
						echo "### > $line"
					done
				fi
				sleep 1
				let lcnt=lcnt+1
				lock.sh "$cmdf" > /dev/null 2>&1
				sts=$?
			done
			if [ "$sts" -eq 0 ]; then
				echo "### Execute $cmdf."
				chmod +x "$cmdf"
				cmdfdt=`date '+%Y%m%d_%H%M%S'`
				. "$cmdf" > "$cmdf.$cmdfdt.out" 2>&1
				mv "$cmdf" "$cmdf.$cmdfdt.done"
				unlock.sh "$cmdf" > /dev/null 2>&1
			else
				echo "### Failed to lock the command file."
				echo "### Give up to exec $cmdf."
			fi
		fi
		chk_tp
		flg=`get_flag`
		case $flg in
		START)
			if [ "$flg" != "$pflg" ]; then
				echo "`date +%D_%T` $LOGNAME@$(hostname) $$ $_AP_IN_BG : START." >> $aphis
			fi
			tsktmp="$AUTOPILOT/tmp/${node}.tsktmp"
			rm -f "$tsktmp" 2> /dev/null
			lock_ping.sh $AUTOPILOT/tsk/all.read
			if [ $? -ne 0 ]; then

				_pid=`lock.sh $AUTOPILOT/lck/${node}.read $$`
				if [ $? -eq 0 ]; then
					ls $AP_TSKQUE/*~${node}.tsk 2> /dev/null > $tsktmp
				else
					if [ -f "$AUTOPILOT/lck/${node}.read.lck" ]; then
						echo "## Find ${node}.read lock."
						cat $AUTOPILOT/lck/${node}.read.lck | while read line; do
							echo "## > $line"
						done
					fi
				fi
				if [ "$AP_NOPLAT" = "false" ]; then
					_pid=`lock.sh $AUTOPILOT/lck/${plat}.read $$`
					if [ $? -eq 0 ]; then
						ls $AP_TSKQUE/*~${plat}.tsk 2> /dev/null >> $tsktmp
					else
						if [ -f "$AUTOPILOT/lck/${plat}.read.lck" ]; then
							echo "## Find ${plat}.read lock."
							cat $AUTOPILOT/lck/${plat}.read.lck | while read line; do
								echo "## > $line"
							done
						fi
					fi
				fi

				ret=false
				tsk=
				if [ -f "$tsktmp" ]; then
					tsk=$(
						sort "$tsktmp" | while read one; do
							cont=`head -1 "$one"`
							if [ -n "$cont" -a `chk_execplat "$cont"` = "true" ]; then
								echo "$one"
								break
							fi
						done
					)
					rm -rf "$tsktmp" 2> /dev/null
				fi
				if [ -n "$tsk" ]; then
					content=`head -1 "$tsk"`
					parsedby=`head -2 "$tsk" | tail -1`
					set_sts RUNNING
					tsk=`basename "$tsk"`
					pri=${tsk%%~*}
					ver=`echo $tsk | awk -F~ '{print $2}' | sed -e "s/!/\//g"`
					bld=`echo $tsk | awk -F~ '{print $3}'`
					donename=${tsk#*~}
					if [ "$donename" != "${donename#*~*~*~*~}" ]; then
						# case of including script order <ver>~<bld>~<ord>~<tst>~<plat>
						_name=${donename%~*~*~*}
						_name=${_name}~${donename#*~*~*~}
						donename=$_name
					fi
echo "###########################"
echo "### content : $content"
echo "### oarsedby : $oarsedby"
echo "### tsk : $tsk"
echo "### donename : $donename"
echo "### ver : $ver"
echo "### bld : $bld"
cat $AUTOPILOT/que/$tsk | while read one; do
  echo "###> $one"
done
					# Chekc invalid build number start with #
					_badtsk=
					if [ ! "${bld#\#}" = "${bld}" ]; then
						_badtsk=true
					elif [ ! "${content#*~}" = "${content}" ]; then
						_badtsk=true
					fi
					if [ ! "$_badtsk" = "true" ]; then
						echo "$content" > "$AUTOPILOT/que/crr/$donename"
						echo "$parsedby" >> "$AUTOPILOT/que/crr/$donename"
						echo "$tsk" >> "$AUTOPILOT/que/crr/$donename"
						echo "On:${node}" >> "$AUTOPILOT/que/crr/$donename"
						echo "Start:`date +%D_%T`" >> "$AUTOPILOT/que/crr/$donename"
						tst=`echo $content | awk -F: '{print $3}' | sed -e "s/+/ /g" -e "s/\^/:/g"`
						opt=${content#*:*:*:}
						[ "$opt" = "$content" ] && opt=
						export _OPTION="$opt"
						obld=${content#${content%%:*}:}
						obld=${obld%%:*}

echo "### opt : $opt"
echo "### tst : $tst"
echo "### obld : $obld"
					#	rm -f "$AUTOPILOT/que/$tsk"
						rm -rf $AUTOPILOT/tmp/${thisnode}.run
						mv $AUTOPILOT/que/$tsk $AUTOPILOT/tmp/${thisnode}.run
						echo "$tsk" >> $AUTOPILOT/tmp/${thisnode}.run
					
						unlock.sh $AUTOPILOT/lck/${node}.read > /dev/null 2>&1
						unlock.sh $AUTOPILOT/lck/${plat}.read > /dev/null 2>&1

						# Make ap sal
						write_apsal "$donename" "PREPARATION" "${tst}" "${ver}:${bld}"
						# Run regression
						export CRRPRIORITY=$pri
						echo "## RUN <$content> : tsk($tsk)"
						export set_vardef=$AUTOPILOT/mon/${LOGNAME}@$(hostname).reg.vdef.txt
						[ -f "$set_vardef" ] && rm -rf "$set_vardef" > /dev/null 2>&1
						if [ "$_AP_BG" = "true" ]; then
							_reglog_="$AUTOPILOT/mon/${LOGNAME}@`hostname`.log"
							rm -f $_reglog_ 2> /dev/null
							(start_regress.sh $ver $obld $tst;echo "logto.sh return status=$?") 2>&1 \
								| logto.sh $_reglog_
							ret=$?
						else
							start_regress.sh $ver $obld $tst
							ret=$?
						fi
						unset set_vardef
						# Check for killed
						sts=`get_sts`
						while ( test "$sts" != "KILLED" -a "$sts" != "RUNNING" ); do
							sts=`get_sts`
						done
						rm -rf "$AUTOPILOT/mon/${LOGNAME}@$(hostname).reg.vdef.txt" > /dev/null 2>&1
						echo "Regression results code = $ret."
						if [ $ret -lt 10 ]; then
							_suc=`cat $AP_RTFILE | awk -F~ '{print $9}'`
							_dif=`cat $AP_RTFILE | awk -F~ '{print $10}'`
							if [ "$_suc" -eq 0 -a "$_dif" -eq 0 ]; then
								# Move back task file.
					# 			echo "$content" > "$AUTOPILOT/que/${tsk}"
					# 			echo "$parsedby" >> "$AUTOPILOT/que/${tsk}"
					# 			echo "Ret:$ret(${LOGNAME}@$(hostname) `date +%D_%T`)" >> "$AUTOPILOT/que/${tsk}"
								fname=`tail -1 $AUTOPILOT/tmp/${thisnode}.run`
								mv $AUTOPILOT/tmp/${thisnode}.run $AUTOPILOT/que/$fname
								echo "Ret:$ret(${thisnode} `date +%D_%T`)" >> "$AUTOPILOT/que/${fname}"
							else
								mv "$AUTOPILOT/que/crr/${donename}" "$AUTOPILOT/que/done/${donename}"
								echo "End:`date +%D_%T`" >> "$AUTOPILOT/que/done/${donename}"
								echo "Suc:$_suc, Dif:$_dif" >> "$AUTOPILOT/que/done/${donename}"
								echo "Ret:$ret(${thisnode} `date +%D_%T`)" \
									>> "$AUTOPILOT/que/done/${donename}"
								echo "## Wait for the next task..."
							fi
						elif [ $ret -lt 20 ]; then
							# Move back task file.
					#		echo "$content" > "$AUTOPILOT/que/${tsk}"
					#		echo "$parsedby" >> "$AUTOPILOT/que/${tsk}"
					#		echo "Ret:$ret(${LOGNAME}@$(hostname))" >> "$AUTOPILOT/que/${tsk}"
							fname=`tail -1 $AUTOPILOT/tmp/${thisnode}.run`
							mv $AUTOPILOT/tmp/${thisnode}.run $AUTOPILOT/que/$fname
							echo "Ret:$ret(${thisnode} `date +%D_%T`)" >> "$AUTOPILOT/que/${fname}"
						else
							# Skip the current task.
					#		echo "$content" > "$AUTOPILOT/que/${tsk}.skipped"
					#		echo "$parsedby" >> "$AUTOPILOT/que/${tsk}.skipped"
							fname=`tail -1 $AUTOPILOT/tmp/${thisnode}.run`
							mv $AUTOPILOT/tmp/${thisnode}.run $AUTOPILOT/que/$fname.skipped
							echo "Skipped on ${thisnode} at `date +%D_%T`" \
								>> $AUTOPILOT/que/${fname}.skipped
							echo "Return code = $ret" \
								>> $AUTOPILOT/que/${fname}.skipped
						fi
						rm -rf $AUTOPILOT/tmp/${thisnode}.run > /dev/null 2>&1
						# Maintain AP_RTFILE
						if [ $ret -gt 1 ]; then
							flg=`get_flag`
							write_apsal "${flg}" "${tst}" "${ver}:${bld}"
							tmp=${flg#KILL/}
							if [ "${flg}" != "$tmp" ]; then
								flg=${tmp#SKIP/}
								if [ "$tmp" != "$flg" ]; then
									set_flag "KILL/$flg"
									mv  "$AUTOPILOT/que/${pri}~${donename}" \
										"$AUTOPILOT/que/${pri}~${tsk}.skipepd" 2> /dev/null
									echo "Skipped on ${LOGNAME}@$(hostname) at `date '+%D_%T'`" \
										>> "$AUTOPILOT/que/${pri}~${tsk}.skipped"
								fi
							fi
						else
							write_apsal "IDLE"
						fi
						rm -f "$AUTOPILOT/que/crr/$donename" > /dev/null 2>&1
						set_sts WAITING
						msgflip=on
					else
						rm -f "$AUTOPILOT/que/$tsk" 2> /dev/null
						unlock.sh $AUTOPILOT/lck/${plat}.read > /dev/null 2>&1
						unlock.sh $AUTOPILOT/lck/${node}.read > /dev/null 2>&1
					fi # BLD start with "#" characer (parserd wrongly)
				else # -n $tsk
					unlock.sh $AUTOPILOT/lck/${plat}.read > /dev/null 2>&1
					unlock.sh $AUTOPILOT/lck/${node}.read > /dev/null 2>&1
				fi # -n $tsk
				if [ "$ret" = "false" ]; then
					if [ "$msgflip" = "on" ]; then
						msgflip=off
						echo "## No tasks for the regression on this platform now."
					fi
				fi
			else
				echo "## Find All read lock."
				if [ -f "$AUTOPILOT/tsk/all.read.lck" ]; then
					cat $AUTOPILOT/tsk/all.read.lck | while read line; do
						echo "## > $line"
					done
				fi
			fi # All lock
			sleep 5
			;;

		STOP)
			echo "Receive Stop command."
			set_sts "HALT"
			rm -f "$amsal"
			sleep 5
			echo "`date +%D_%T` $LOGNAME@$(hostname) $$ $_AP_IN_BG : STOP." >> $aphis
			break;
			;;

		PAUSE)
			echo "Receive Pause command."
			echo "Waiting another command in the flag file."
			if [ `get_sts` != "KILLED" ]; then
				write_apsal "PAUSE" both
			fi
			set_sts "IDLE"
			while [ `get_flag` = "PAUSE" ]; do
				chk_tp
				sleep 5
			done
			write_apsal "IDLE" both
			set_sts "WAITING"
			echo "`date +%D_%T` $LOGNAME@$(hostname) $$ $_AP_IN_BG : PAUSE." >> $aphis
			;;

		KILL*)
			flg=${flg#KILL/}
			echo "Receive KILL command."
			echo "Killed current regression and move to $flg mode."
			set_flag "$flg"
			echo "`date +%D_%T` $LOGNAME@$(hostname) $$ $_AP_IN_BG : KILL($flg)." $aphis
			;;

		SKIP*)
			if [ "${flg#SKIP/}" = "$flg" ]; then
				flg="START"
			else
				flg="${flg#SKIP/}"
			fi
			set_flag "$flg"
			;;

		RESTART)
			echo "Receive Restart command"
			echo "Clear log(previous history) and start again."
			rm -f $AP_TSKDONE/*~${node}.tsk 2> /dev/null
			set_flag "START"
			echo "`date +%D_%T` $LOGNAME@$(hostname) $$ $_AP_IN_BG : RESTART." >> $aphis
			;;

		*)
			echo "Unkown FLAG($flg)"
			write_apsal "BADFLAG($flg)" both
			set_sts "IDLE"
			while [ `get_flag` = "$flg" ]; do
				chk_tp
				sleep 5
			done
			write_apsal "IDLE" both
			set_sts "WAITING"
			;;

		esac
		pflg=$flg
	done
	rm -f "$apsal" 2> /dev/null
	rm -rf "$AUTOPILOT/mon/${LOGNAME}@$(hostname).ap.vdef.txt" > /dev/null 2>&1
	rm -rf "$AUTOPILOT/mon/${LOGNAME}@$(hostname).reg.vdef.txt" > /dev/null 2>&1
	rm -f "$AUTOPILOT/pid/$(hostname)_${LOGNAME}.pid"
	rm -f "$AUTOPILOT/sts/$(hostname)_${LOGNAME}.sts"
	rm -f "$AP_RTFILE"
	remove_locks
}


#######################################################################
# START
#######################################################################

# Check autopilot.sh aready running.
if [ -f "$apsal" ]; then
	appid=`head -1 "$apsal" 2> /dev/null`
	tmp=`ps -fp $appid  2> /dev/null | grep $appid`
	if [ -z "$tmp" ]; then
		echo "There is an apsal. But the process($appid) is not found."
		echo "Delete $apsal."
		unset appid
		rm -f "$apsal"
	fi
fi

aplck=`lock.sh "$aplckf" $$`
if [ $? -ne 0 ]; then
	echo "Failed to lock \"$aplckf\"(sts=$?)."
	if [ -f "$aplckf" ]; then
		cat "$aplckf" 2> /dev/null | while read line; do
			echo "> $line"
		done
	fi
	echo "Please check there is another autopilot.sh running ?"
	echo "Or you can access to the \$AUTOPILOT/lck folder ?"
	exit 1
fi

flg=`get_flag`
sts=`get_sts`

echo "FLAG=$flg"
echo "STS =$sts"

# Set and check the default value for the some AP_* variables.
export set_vardef=$AUTOPILOT/mon/${LOGNAME}@$(hostname).ap.vdef.txt
[ -f "$set_vardef" ] && rm -rf "$set_vardef" > /dev/null 2>&1
set_vardef AP_NOPLAT AP_KEEPWORK AP_NOAGTPSETUP AP_WAITTIME \
	AP_HANGUP AP_NOPARSE_MIDNIGHT AP_TSKFILE 
unset set_vardef

start_ts=`date '+%m_%d_%y %H:%M:%S'`

action=
param=
while [ "$#" -gt 0 ]
do
	case $1 in
		-tsk)
			if [ "$#" -gt 1 ]
			then
				if [ -f "$2" ]
				then
					export AP_TSKFILE=$2
				else
					echo "Task file not found.$2"
				fi
				shift
			fi
			;;
		-env)
			if [ "$#" -gt 1 ]
			then
				if [ -f "$2" ]
				then
					export AP_ENVFILE=$2
				else
					echo "Task file not found.($2)"
				fi
				shift
			fi
			;;
		-waittime=*)
			wtime=${1#*=}
			export AP_WAITTIME=$wtime
			;;
		-noinst)
			export AP_INSTALL="false"
			;;
		-force)
			export AP_FORCE="true"
			;;
		-refresh)
			export AP_INSTALL_KIND="refresh"
			;;
		-cd)
			export AP_INSTALL_KIND="cd"
			;;
		-both)
			export AP_INSTALL_KIND="both"
			;;
		-noagtpsetup)
			export AP_NOAGTPSETUP="true"
			;;
		-agtpsetup)
			export AP_NOAGTPSETUP="false"
			;;
		-keepwork|-keep)
			export AP_KEEPWORK="true"
			;;
		-keepwork=*|-keep=*)
			kpcnt=${1#*=}
			export AP_KEEPWORK=$kpcnt
			;;
		-noenv)
			export AP_NOENV="true"
			;;
		-help|-h)
			action="help"
			;;
		-noplat)
			AP_NOPLAT=true
			;;
		*)
			if [ -z "$action" ];then
				action=$1
			else
				if [ -z "$param" ];then
					param=$1
				else
					param="$param $1"
				fi
			fi
			;;
	esac
	shift
done

# Action handling

if [ "$_AP_BG" = "true" ]; then
	export _AP_IN_BG=BG
else
	export _AP_IN_BG=FG
fi

case "$action" in

	start)

		echo "Parameter is start"
		echo "`date +%D_%T` $LOGNAME@$(hostname) $$ $_AP_IN_BG : LAUNCH." >> $aphis

		if [ -n "$appid" ]
		then
			echo "There is another autopilot process.($appid)"
		fi
		set_flag START
		if [ -z "$appid" ]; then
			run_autopilot
		fi

		;;


	stop)
		
		echo "Parameter is stop"	

		if [ -n "$appid" ];then
			echo "There is another autopilot process.($appid)"
			echo "Stop that process."
			set_flag STOP
			echo "Waiting for another autopilot done."
			while [ "`get_sts`" != "HALT" ]
			do
				sleep 5
			done
		fi

		;;


	pause)
		
		echo "Parameter is pause"

		if [ -n "$appid" ];then
			echo "There is another autopilot process.($appid)"
			echo "Set the flag file to pause for that process."
			set_flag PAUSE
		else
			set_flag PAUSE
			run_autopilot
		fi

		;;


	restart)

		echo "Parameter is restart"

		if [ -n "$appid" ];then
			echo "There is another autopilot process.($appid)"
			echo "Stop that process and will re-start autopilot task on this shell."
			set_flag STOP
			echo "Waiting for another autopilot done."
			while [ "`get_sts`" != "HALT" ]
			do
				sleep 5
			done
		else
			echo "Receive Restart command"
			echo "Clear log(previous history) and start again."
			rm -f $AP_TSKDONE/*~${node}.tsk 2> /dev/null
		fi
		set_flag START;
		run_autopilot
		;;


	reset)
		
		echo "Parameter is reset"

		if [ -n "$appid" ];then
			echo "There is another process.($appid)"
			echo "Set the flag for that process to RESTART."
			set_flag RESTART
		else
			echo "There is no autopilot process."
		fi

		;;


	KILL/*)

		echo "Parameter is $action"

		if [ -n "$appid" ];then
			echo "There is another process.($appid)"
			echo "Set the flag for that process to KILL."
			set_flag "${action}"
		else
			echo "There is no autopilot process."
		fi

		;;


	help)
		mysh=`which $0`
		lno=`grep -n "^#HELPCONT" "$mysh"`
		lno=${lno%%:*}
		ttl=`wc -l "$mysh" | awk '{print $1}'`
		cnt=`expr $ttl - $lno`
		echo "### lno=$lno, ttl=$ttl, cnt=$cnt, $mysh"
		tail -$cnt $mysh
		;;


	*)

		if [ -n "$action" ];then
			echo "Illegal action = $action"
			echo "autopilot.sh {start|restart|stop|pause|KILL*}"
			echo "   [-noinst|-force|-refresh|-cd|-both|-noagtpsetup|-noenv|"
			echo "    -waittime=#|-keepwork=#|-env <env>|-tsk <tsk>]"
		fi

		if [ -n "$appid" ];then
			isidle=`tail -1 "$apsal" 2> /dev/null`
			if [ "$isidle" = "IDLE" ]; then
				echo "autopilot.sh($appid) is IDLE."
			else
				if [ -f "$AP_RTFILE" ]; then
					cont=`cat "$AP_RTFILE"`
					_host=`echo $cont | awk -F~ '{print $1}'`
					_usr=`echo $cont | awk -F~ '{print $2}'`
					_plat=`echo $cont | awk -F~ '{print $3}'`
					_vpath=`echo $cont | awk -F~ '{print $4}'`
					_mains=`echo $cont | awk -F~ '{print $5}'`
					_verbld=`echo $cont | awk -F~ '{print $6}'`
					_starttm=`echo $cont | awk -F~ '{print $7}'`
					_subs=`echo $cont | awk -F~ '{print $8}'`
					_sucs=`echo $cont | awk -F~ '{print $9}'`
					_difs=`echo $cont | awk -F~ '{print $10}'`
					_snaptm=`echo $cont | awk -F~ '{print $11}'`
					echo "PLATFORM:  ${_plat}(${_usr}@${_host})"
					echo "VIEW_PATH: ${_vpath}"
					echo "VERSION:   ${_verbld}"
					echo "SCRIPT:    ${_mains}/${_subs}"
					echo "START TIME:${_starttm}"
					echo "SNAP  TIME:${_snaptm}"
					echo "Sucs:${_sucs}, Difs:${_difs}"
				elif [ -f "$AUTOPILOT/que/crr/${isidle}" ]; then
					cat "$AUTOPILOT/que/crr/${isidle}"
				else
					cat $AUTOPILOT/view/$(hostname)_${LOGNAME}.vw
				fi
			fi
		else
			echo "There is no autopilot process on $(hostname):${LOGNAME}"
		fi

		;;


esac


exit 0
: << '### END OF HELP ###'
################################################################################
# PLEASE ADD DESCRIPTION IN THIS SECTION WHEN YOU PUT NEW FEATURE TO FRAMEWORK #
################################################################################
01234567890123456789012345678901234567890123456789012345678901234567890123456789
#HELPCONT	# FOLLOWING TEXT ARE USED FOR HELP COMMAND
Autopilot framewrok for the esssxr Ver. 5.0 Apr. 8, 2008

Usage: autopilot.sh <Command> [<task info>] [<Option>]

<Command> Order for the autopilot framework:

  start      : Start autopilot frame work on this machine.
               If there is another autopilot process, this command just
               set the FLAG to START. If there is another process in the
               IDLE status, this command resume it into a notmal loop.

  stop       : If there is another process, set FLAG to STOP. Otherwise
               this command do nothing.

  pause      : If there is another process, set FLAG to PAUSE.

  KILL/*     : Forced kill current regression task and move on to * status.

  restart    : Restart autopilot framework. This command clear the log
               file which records the execution historys.
               If there is another autopilot, STOP it then restart the
               framework on your console.

<Options>:

  -help        : Display this help.

  -noinst      : Doesn't install product. Use current installation.

  -force       : Forced install product evenif the ver/bld are same.

  -refresh     : Use refresh command only for the installation.

  -cd          : Use CD install image only for the installation.

  -both        : Use both command for the installation.

  -agtpsetup   : Run the agtpsetup.sh just before each test.

  -noagtpsetup : Don't run the agtpsetup.sh.

  -noenv       : Don't update user environment setup file.

  -keepwork={true|false|leave|#} : Care method for thet work folder.
          true : Keep work folder with build number and script name.
                 (same behavior as old autopilot framework)
         false : Don't keep work. Autopilot remove it just after the
                 each test at everytime.
         leave : Leave it until next execution.(default)
             # : Keep recent #th work with build num and script name.

  -waittime={#|nextday} : Waiting time for the next execution.
       nextday : Wait for the next day.
             # : Wait # sec for the next execution.(default=3600)=1H

  -tsk <tsk file> : Use <tsk file> isntead of the user task file.

  -env <env file> : Use <env file> instead of the user, version and
                    platform specific envitonment file

  -noplat : Do not execute platform task.

### Environment variables ################################################

< 1. Required variables for running the autopilot framework >
Note: Every machines which run the autopilot framework should define 
      those variables.

AUTOPILOT : The location to the autopilot framework.
Definition:
    The location to the autopilot framework. Current location is below:
        /nar200/essbasesxr/regressions/Autopilot_UNIX
    This location should be a relative path from /nar200/essbasesxr.
    Because framework access to the snapshot folder just under the 
    /nar200/essbasesxr by "$AUTOPILOT/../../<ver>/vobs" syntax and 
    access result folder under the /nar200/essbasesxr/regressions by 
    "$AUTOPILOT/../<ver>/essbase" syntax.
Defined at:
    undef (should defined in system environment variable.)
Refered from:
    all autopilor related scripts.

HOME : Home location for the login user.
Description:
    Current Oracle servers set it to /nfshome/<user> location.
    Recommend to set it to local location. Because, the autopilot 
    framework will define PROD_ROOT and VIEW_PATH to $HOME/hyperion 
    and $HOME/views when those are not defined. Some version of Essbase 
    doesn't support to start from the remote volumes. And Some version 
    of Essbase installer install shared modules into $HOME location.
    It might be problem when same user run that installer from different 
    machines. If you don't define PROD_ROOT and VIEW_PATH, we strongly 
    recommend to define $HOME to local location.

PATH : The command executable location for the shell script.
  This variable should have $AUTOPILOT/bin at top of its definition.


< 2. Optional variables for running the autopilot framework >
Note: Strongly recommend to define those variables. Otherwise, autopilot 
      framework automatically define it.

ARCH : CPU Architechture
Description:
    The autopilot framework define the platform with 'uname' command.
    But sometime machine can run multiple architechture on same box.
    So, the autopilot framework need to know what kind of architecture
    current machine should run.
    This setting is different per each platforms:
Defined at:
    start_regress.sh/se.sh/setchk_env.sh
Refered from:
    get_platform.sh
Values and meaning:
Windows:
    =64    : Win64 - Windows IA64 architecture
    =AMD64 : Winamd64 - Windows x64 or amd64 architecture
    =64M   : Winmonte - Montevina 64 bit architecture
    =<else>: Win32 - Windows 32 bit architecture.
    Note: if you don't define this variable, it will be set to win32.
Solaris/AIX:
    =32 : aix or solaris - 32 bit architecture
    =64 : aix64 or solaris64 - 64 bit architecture
    Note: if you don't define this variable, it will be set to 32
Linux:
    =64    : linux64 - Linux 64 bit architecture
    =AMD64 : linuxamd64 - Linux AMD 64 bit architecture
    =32    : Linux - Linux 32 bit architecture
    Note: if you don't define this variable, it will be set to 32
HP-UX: HP-UX don't need this definition. Because they cannot run both 
       archtecture on same box. And we can find architecture by 'uname -m' 
       command. if it return ia64, architecture automatically set to 
       hpux64. otherwise, hpux.
    
HIT_ROOT : Root location of HIT installer.
Defined at:
    apinc.sh (default is /nar200/hit)
Refered from:
    hitinst.sh, ver_hitloc.sh
Values and meaning:
    =<full path to the /nar200/hit>

BUILD_ROOT : Root location of Essbase builds locaiton.
Defined at:
    undef (if this variable is not defined, apinc.sh defined it to
           /nar200/pre_rel/essbase/builds)
Refered from:
    cdinst.sh, cmdgqinst.sh, hyslinst.sh(opach/refresh)
Values and meaning:
    =<full path to the /nar200/pre_rel/essbase/builds>

PROD_ROOT : Root location to product installation target.
Description:
    When HYPERION_HOME and ARBORPATH are not defined at install time, 
    autopilot refer this variable as install taget location. And install 
    product under $PROD_ROOT/<ver> folder.
    When autopilot not find both HYPERION_HOME and PROD_ROOT, autopilot
    create $HOME/hyperion folder and define PROD_ROOT to created folder.
Defined at:
    setchk_env.sh ($HOME/hyperion as default)
Refered from:
    setchk_env.sh, hyslinst.sh, hitinst.sh, cdinst.sh, cmdgqinst.sh
Values and meaning:
    =<full path to the product installation location>

VIEW_PATH : SXR view location.
Description:
    Autopilot uses VIEW_PATH as the sxr view location. When au
    When autopilot not find VIEW_PATH definition, autopilot create
    $HOME/views folder automatically and use it as VIEW_PATH.
Defined at:
    setchk_env.sh ($HOME/views as default)
Refered from:
    start_regress.sh
Values and meaning:
    =<full path to the sxr view location>

AP_NOPLAT : Do not execute platform task. Run user task only.
Defined at:
    autopilot.sh(data/vardef.txt) =false
Refered from:
    autopilot.sh
Values and meaning:
    =true : Do not parse and run the platform tasks. (Don't parse 
            <platform>.tsk file and only parse ${LOGNAME}.tsk file. 
            And don't run ${PLATFORM} tasks and only run 
            ${LOGNAME}@$(hostname) tasks.)
    =false: Do parse and run ${PLATFORM} related task-def-file and tasks.

PATH(2) : The command executable location for the shell script.
  This variable should have $BUILD_ROOT/bin at end of its definition. 
  Autopilot uses "refresh" command when CD/HIT installation failed.


< 3. Version related valirables for running regression test >
Note: Not recommend to define those variable in .profile or profile.ksh.
      Those are version sensitive variables. You can also define those 
      in the user env file, $AUTOPILOT/env/<user>/<ver>_<host>.env. 
      But we don't recommend to use it and strongly recommend to use or
      define those variables in the $AUTOPILOT/env/template/<plat>.env2.
      Because once you set the each variables in the <plat>.env2 file, 
      other user who use same platform can share those setting.

HYPERION_HOME : Product install location.
ARBORPATH : Essbase server location.
ESSABSEPATH : Essbase client location.
ESSLANG : Essbase language definition (=English_UnitedStates.Latin1@Binary)
SXR_HOME : The Home location of sxr frameowrk.
SXR_BASE : The snapshot or dynamic view location for the sxr framework.
Note: Please refer each manual about above 6 variables.

AP_AGENTPORT : Agent port number for each user.
Description:
  The autopilot framework is design to work multiple users on one machine.
  This framework uses AgentPort funciton for that purpose. autopilot assign 
  port number for each user from $AUTOPILOT/data/agentport_list.txt. 
  If login user is new for the autopilot framework, no entry in the 
  agentport_list.txt, autopilot automatically add new user into that text.
  And define this value into initial essbase.cfg file.
  Note: If test script call agtpsetup.sh like agtpori1.sh, agtpori2.sh,... ,
        essbase.cfg will be over-written and lose this port number by 
        $SXR_BASE/data/<user>.cfg file. So, if test uses agtpsetup.sh, 
        you may need to create <user>.cfg file in the sxr view folder
        in the ClearCase.
Defined at:
  setchk_env.sh (data/agentport_list.txt)
Refered from:
  start_regress.sh
Values and meaning:
  =<port number got from data/agentport_list.txt for current login user>

PATH(3) : The command executable location for the shell script. 
  This variable should have $ARBORPATH/bin, $SXR_HOME/bin, $JAVA_HOME/bin
  and $HYPERION_HOME/products/products/Essbase/EssbaseClient/bin on some 
  version.
  On Windows platform, PATH variable also work as a library path. Then 
  this variable should include $ODBC_HOME/Drivers on all Windows, 
  $JAVA_HOME/bin and $JAVA_HOME/bin/server on win32 and winamd64,
  and $JAVA_HOME/bin and $JAVA_HOME/bin/jrockit on win64.

[Library path definition]
  Essbase uses Merant ODBC driver and JAVA. So, the Library path shoud
  have the each library locations. Those definitions are different 
  on each platforms and each version. Then we recommend to use 
  $AUTOPILOT/env/template/<plat>.env2 file for those definition.
LIBPATH : Library path definition for AIX platform.
  aix:ODBC_HOME/lib, JAVA_HOME/bin, JAVA_HOME/bin/classic
  aix64:ODBC_HOME/lin, JAVA_HOME/bin, JAVA_HOME/bin/classic
SHLIB_PATH :  Library path definition for HP-UX platform.
  hpux:ODBC_HOME/lib, JAVA_HOME/lib/PA_RISC2.0, 
       JAVA_HOME/lib/PA_RISC2.0/server
  hpux64:ODBC_HOME/lib, JAVA_HOME/lib/IA64W, JAVA_HOME/lib/IA64W/server
LIBRARY_PATH : Library path definition for Solaris and Linux platform.
  linux:ODBC_HOME/lib, JAVA_HOME/lib/i386, JAVA_HOME/lib/i386/server
  linux64:ODBC_HOME/lib, JAVA_HOME/lib/amd64, JAVA_HOME/lib/amd64/server
  solaris:ODBC_HOME/lib, JAVA_HOME/lib/sparc. JAVA_HOME/lib/sparc/server
  solaris64:ODBC_HOME/lib, JAVA_HOME/lib/sparcv9, JAVA_HOME/lib/sparcv9/server
  solaris.x64:ODBC_HOME/lib, JAVA_HOME/lib/???, JAVA_HOME/lib/???

JAVA_HOME : JAVA root location.
Defined at:
    setchk_env.sh
Refered from:
    setchk_env.sh
Values and meaning:
    =<JAVA root location>
    This location is different per platforms and versions.
    aix:HYPERION_HOME/common/JRE/IBM/<ver>
    aix64:HYPERION_HOME/common/JRE-64/IBM/<ver>
    hpux:HYPERION_HOME/common/JRE/HP/<ver>
    hpux64:HYPERION_HOME/common/JRE-IA64/HP/<ver> or
           HYPERION_HOME/common/JRE-64/HP/<ver> or
           HYPERION_HOME/../jdk<ver>_<mver>/jre
    linux:HYPERION_HOME/common/JRE/Sun/<ver>
    linux64:HYPERION_HOME/common/JRE-64/Sun/<ver> or
           HYPERION_HOME/../jdk<ver>_<mver>/jre
    solaris:HYPERION_HOME/common/JRE/Sun/<ver>
    solaris64:HYPERION_HOME/common/JRE-64/Sun/<ver> or
           HYPERION_HOME/../jdk<ver>_<mver>/jre

ODBC_HOME : ODBC root location.
Defined at:
    setchk_env.sh
Refered from:
    setchk_env.sh
Values and meaning:
    =<ODBC root location>
    This location is different per platforms and versions.
    aix:HYPERION_HOME/common/ODBC/Merant/<ver>
    aix64:HYPERION_HOME/common/ODBC-64/Merant/<ver>
    hpux:HYPERION_HOME/common/ODBC/Merant/<ver>
    hpux64:HYPERION_HOME/common/ODBC-IA64/Merant/<ver> or
           HYPERION_HOME/common/ODBC-64/Merant/<ver>
    linux:HYPEIRON_HOME/common/ODBC/Merant/<ver>
    linux64:HYPERION_HOME/common/ODBC-64/Merant/<ver>
    solaris:HYPERION_HOME/common/ODBC/Merant/<ver>
    solaris64:HYPERION_HOME/common/ODBC-64/Merant/<ver>

ODBCINI : odbc.ini location on Unix platform.
Defined at:
    setchk_env.sh
Refered from:
	undef
Values and meaning:
     =<the location of odbc.ini>
     This location is set to $ODBC_HOME/odbc.ini normaly.

- C API Related varibles
PATH(4) : The command executable location for the shell script.
  C API test uses C compiler, linker and make command. So, the PATH
  envrionment variable should contains the path to those executable.
  The compiler and linker are different by platforms.
    aix/64:/usr/vac/bin/cc_r, /usr/vac/bin/cc_r
    hpux/64:/usr/bin/cc, /opt/aCC/bin/aCC
    linux/64:/usr/bin/gcc, /usr/bin/gcc
    solaris/64:/opt/SUNWspro/bin/cc, /opt/SUNWspro/bin/cc
    win32:<MSDEV>/VC/bin/cl.exe, <MSDEV>/VC/bin/link.exe
    win64:<MSDEV SDK>/bin/win64/cl.exe, <MSDEV SDK>/bin/win64/link.exe
    winamd64:<MSDEV>/VC/bin/cl.exe, <MSDEV>/VC/bin/link.exe
INCLUDE : 
  win32:<MSDEV>/VC/INCLUDE;<MSDEV>/VC/PlatformSDK/include;$INCLUDE
  win64:<MSDEV SDK>/Include;<MSDEV SDK>/Include/crt;$INCLUDE
  winamd64:<MSDEV>/VC/include;<MSDEV86>/VC/PlatformSDK/Include;
           <MSDEV86>/VC/include;$INCLUDE
0123456789012345678901234567890123456789012345678901234567890123456789
LibraryPath : 
  aix/64:$APIPATH/bin:$ARBORPATH/bin:$LIBPATH
  hpux:/lib:/usr/lib:/usr/lib/hpux:$APIPATH/bin:$ARBORPATH/bin:$SHLIB_PATH
  hpux64:/lib:/usr/lib:/usr/lib/hpux64:$APIPATH/bin:$ARBORPATH/bin:
         $SHLIB_PATH
  solaris/64:$APIPATH/bin:$ARBORPATH/bin:/usr/lib:/lib:$LD_LIBRARY_PATH
  linux/amd64:$APIPATH/bin:$ARBORPATH/bin:/usr/lib:$LD_LIBRARY_PATH
  win32:<MSDEV>/VC/ATLMFC/LIB;<MSDEV>/VC/LIB;<MSDEV>/PlatformSDK/lib;
        <FrameworkSDK>/lib;$LIB
  win64:$APIPATH/bin;<MSDEV SDK>/Lib/IA64;<MSDEV SDK>/Lib;$LIB
  winamd64:<MSDEV>/VC/lib;<MSDEV>/VC/lib/amd64;<MSDEV86>/VC/PlatformSDK/Lib;
           <MSDV86>/VC/PlatformSDK/Lib/AMD64;$LIB
APIPATH : Client API folder location.
  This definition is different from versions.(by installer)
  HIT=$HYPERION_HOME/products/Essbase/<EssbaseClient folder name>/api
  CD=$ARBORPATH/api
LAPTH(HP-UX) : Need for hp-ux platform.
  LPATH=$SHLIB_PATH


< 4. Behaivor control variables for the autopilot framework >
Note: Those variables change the behavior of the autopilot framework.
      Most of the setting can be over-written by the task option.

sxrfiles : SXR related files which need to archive after test execution.
Description:
  The autopilot framework make a work archive file when done the test.
  This variable defined what kind files need to backup into the archive.
Defined at:
    start_regress.sh(data/vardef.txt) =log sta sog suc dif dna xcp lastcfg
Values and meaning:
    =<extention list for the archive>
    
AP_NOAGTPSETUP : The agtpsetup.sh control.
Deinfed at:
    autopilot.sh(data/vardef.txt) = false
Refered from:
    start_regress.sh
Values and meaning:
    =false : Don't use agtpsetup.sh in autopilot framework.(default)
    =true  : Run agtpsetup.sh just before each test.
Equivalent task option:
    noagtsetup(true|false)
Equivalent start options:
    -agtpsetup, -noagtpsetup

AP_NOTIFYLVL : Dif notify threshold count.
Deinfed at:
    undef
Refered from:
    start_regress.sh
Values and meaning:
    =all : Send Dif notify e-mail every time.
    =#   : Send Dif notify e-mail when the dif count is less than #.
           (25 is used as default = when undef this variable)
Equivalent task option:
    notifylvl(all|#)
Equivalent start option:
    none

AP_FORCE : Forced Installation control.
Defined at:
    undef
Refered from:
    start_regress:
Values and reaning:
    =true  : Install product forceblyat every each test.
    =false : When the numbers of version and build are same as current
             installation, autopilot skip the instalaltion.
             (default or when undef this variable)
Equivalent task option:
    forceinst(true|false)
Equivalent start option:
    -force

AP_NOINST : No installation control.
Defined at:
    undef
Refered from:
    start_regress.sh
Values and meaning:
    =true  : Don't install product. Use current installation.
    =false : Install product when needed.
             (default or when undef this variable)
Equivalent task option:
    none
Equivalent start option:
    -noint

AP_INSTALL_KIND : The install method control
Defined at:
    undef
Refered from:
    start_regress.sh
Values and meaning:
    =cd      : Use CD or HIT image to install product.
    =refresh : Use "refresh" command to install product.
    =both    : Use CD or HIT image first, then use "refresh" command.
               (default or undef this variable)
Equivalent task options:
    refresh(true|false), instkind(both|cd|refresh)
Equivalent start options:
    -refresh

AP_KEEPWORK : The work folder control.
Description:
  This variable control the keep count of the SXR work folder
  after the test executions:
Defined at:
    autopilot.sh(data/vardef.txt) = 2
Refered from:
    start_regress.sh
Values and meaning:
    =true : Leave work folder with work_<ver>_<bld>_<test_abv> name.
            No deletion control.
    =false: Just delete work contents. No back up.
    =leave: Leave work folder with work_<test_abv> name.
            Over-write when same folder is exists.
    =#    : Keep # count of backup folder.
            Copy work contens to work_<ver>_<bld>_<test_abv> folder.

    This control the work folder treatment behavior. The set value
    is same as -keepwork option.
Equivalent task option:
    keepwork(true|false|leave|#)
Equivalent start option:
    -keepwork={true|false|leave|#}, -keep={true|false|leave|#}

AP_ESSBASECFG : Use user defined essbase.cfg file.
Defined at:
    undef
Refered from:
    start_regress.sh
Values and meaning:
    =<full path to the essbase.cfg file>
Equivalent task option:
    essbasecfg(<fpath>)

SXR_I18N_GREP : Use specified "grep.exe" on Windows platform.
Defined at:
    undef
Refered from:
    start_regress.sh
Values and meaning:
    =<full path to the specific grep.exe command>
Equivalent task option:
    i18ngrep(<fpath>)

AP_ENVFILE : Use specific environment setup file 
             instead of $AUTOPILOT/env/user/<ver>_<host>.env.
Defined on:
    undef/autopilot.sh(as start option)
Refered from:
    se.sh
Values and meaning:
    =<full path name to the environment setup file>
Equivalent start option:
    -env <env file>

AP_TSKFILE : Use specific task definition file 
             instead of $AUTOPILOT/tsk/<user>.tsk.
Defined at:
    autopilot.sh(data/verdef.txt) = $AUTOPILOT/tsk/<user>.tsk
Refered from:
    task_parser.sh
Values and meaning:
    =<full path name to the task file>
Equivalent start option:
    -tsk <tsk file>

AP_ALTEMAIL : Alternate E-mail account
Description:
    When define this variable, the autpilot add this e-mail address to
    the all notification e-mails.
Defined at:
    undef
Refered from:
    start_regress.sh
Values and meaning:
    =<email addresses>
Equivalent task option:
    altemail(<email addresses>)

AP_HANGUP : Hang up limit time in seconds for the regmon.sh.
Defined at:
    autopilot.sh(data/vardef.txt)=14400 # 4 hours.
Refered from:
    start_regress.sh
Values and meaning:
    =<hang up limit time in sec>
    =0|=false : Do not use regmon.sh for the controling hang-up.
Equivalent task option:
    hangup(#|0|false)

AP_EMAILLIST : Alternate email_list.txt
Defined at:
    start_regress.sh(data/vardef.txt) =$AUTOPILOT/data/email_list.txt
Refered from:
    start_regress.sh
Values and meaning:
    =<full path name for the e-mail list file>

AP_SCRIPTLIS : Alternate script_list.txt
Defined at:
    start_regress.sh(data/vardef.txt) =$AUTOPILOT/data/script_list.txt
Refered from:
    start_regress.sh
Values and meaning:
    =<full path name for the script list file>

AP_REGMON_INTERVAL : The interval time for checking hang-up.
Defined at:
    undef # When this is not defined, use 600 secs(10 mins) as default.
Values and meaning:
    =<#> : Interval time in seconds.

AP_REGMON_DEBUG : Debug output flag of the regression monitor.
Defined at:
    start_regress.sh
Refered from:
    regmon.sh
Values and meaning:
    =true  : Write debug information to the debug file.
             $AUTOPILOT/mon/$(hostname)_${LOGNAME}_regmon.dbg
    =false : Turn off ouput for debug (default)
Equivalent task option:
    regmondebug(true|false)

AP_TARCTL : Tar file control. (start_regress.sh)
Defined at:
    start_regress.sh(data/vardef.txt) =essexer(default)
Refered from:
    start_regress.sh
Values and meaning:
    =all     : Make archive of all files under the work.
    =essexer : Make archive of SXR related files($sxrfiles)
    =none    : Not make the archive
Equivalent task option:
	tarctl(essexer|all|none)

AP_TARCNT : Tar file counts on the central place($AUTOPILOT/res)
Defined at:
    start_regress.sh(data/vardef.txt) =10
Refered from:
    start_regress.sh
Values and meaning:
    =all : Don't erase previous tar files.
    =#   : Keep recennt #th copies. (default=10)
Equivalent task option:
    tarcnt(all|#)

AP_IGNORE_JRE_LIBPATH : If define this, skip the test for the JRE.
Defined at:
    undef
Refered from:
    chk_path.sh
Values and meaning:
    =true : Skip JRE related definition from PATH/LIBPATH check.

AP_WAITTIME : Interval time for parsing task definition file.
Degined at:
    autopilot(data/vardef.txt)
Refered from:
    apmon.sh
Values and meaning:
    =nextday : Parse once at 0:00AM per day.
               If you defined AP_NOPARSE_MIDNIGHT, it won't parse
               during 22:00 to 02:00. It will start to parse at 2:00AM.
    =###     : Interval time in seconds.
               If AP_NOPARSE_MIDNIGH is defined, apmon.sh doesn't launch
               task_parser.sh during 22:00 to 02:00.
Equivalent start option:
    -waittime=###

AP_NOPARSE_MIDNIGHT : Do not execute task_parser.sh until mid-night.
Description:
    When define this variable to true, autopilot framework doesn't parse
    the task file during 22:00 to 02:00. This option is implemented for 
    avoiding multiple build execution. When CM build new version around
    midnigh, autopilot take that new build for today's build. It cause 
    the multiple results per day. So, avoid to parse the task file 
    during midnight might avoid it.
Defined at:
    autopilot.sh(data/vardef.txt) =true
Refered from:
    apmon.sh
Values and meaning:
    =true : Avoid to start task_parser.sh, pasing task definition file,
            during mid-night (22:00-02:00).
    =false: Don't care about mid-night.

AP_REGMON_CRRSTS_INTERVAL : Interval duration for the crr file update.
Description:
    This variable define the interval duration for the creation of real
    time status file (*.crr in \$AUTOPILOT/mon folde
Defined at:
    undef
Refered from:
    regmon.sh
Values:
	=#  : Interval duration in second (default/undef=30)

AP_ALTSETUP : Alternate setup script.
Description:
    When define this value, start_regress.sh call this script after the
    installation of Essbase. You can use this variable to install extra
    modules like ASP.
    The setup script should exit 0 when the installation success. When
    return non 0 value, the start_regress.sh send the installation 
    failed notify and exit execution.
    This script is called by following parameter:
    ${AP_ALTSET} <Full Version number> <Normalized Build number>
Defined at:
    undef
Refered from:
    start_regress.sh
Values and meaning:
    =<full path name for the alternate product setup/install script>

AP_ALTSETENV : Alternate environment setup script.
Description:
    start_regress.sh call se.sh. And se.sh call <ver>_<hostname>.env under
    the $AUTOPILOT/env/<logname> folder. But when you need to add extra 
    setting to the regression environment. Define this variable to your
    extra setting up script. This script is called after se.sh.
    NOTE: this script will be called by ". ${AP_ALTSETENV}" from 
          start_regress.sh. So, if your set-up script do "exit" command, 
          it may terminate parent shell script(start_regress.sh) and it 
          may cause the test won't be executed.
Defined at:
    undef
Refered from:
    start_regress.sh
Values and meaning:
    =<full path name for the alternate environment setup script>

AP_RESFOLDER : The destination folder for execution report (.rtf and .wsp).
Description:
    When define this variable to something, the start_regress.sh send 
    a result report fiels, .rtf and .wsp, .wsp2, to this folder.
    The target folder will be created under the 
    /nar200/essbasesxr/regressions/<version> folder. When not define 
    this variable, start_regress will send the result report to 
    /nar200/essbasesxr/regressions/<ver>/essbase folder.
Defined at:
    undef
Refered from:
    send_result.sh, start_regress.sh, api.sh
Values and meaning:
    =<sub-folder name>

AP_RESSCRIPT : Alternate report creator script instead of send_result.sh
Description:
    When define this variable, the start_regress.sh call this script
    instead of send_result.sh. If you need a different format of the 
    result report, you can overwride it using this definition.
    When call this script from start_regress.sh. Your environment is in
    SXR_VIEW and $SXR_WORK hold all result of the execution. And you can
    refer $AP_RESFOLDER to find where you need put the result to.
    This script is called by following parameter:
    ${AP_RESSCRIPT} <FULL VERSION> <BUILD> <TEST SCRIPT>
Defined at:
    undef
Refered from:
    start_regress.sh
Values and meaning:
    =<full path to the alternative send_result.sh file>

AP_UNCOMMENTJVM: Uncomment JvmModuleLocation in the essbase.cfg file.
Defined at:
    undef
Refered from:
    ap_esinit.sh
Values and meaning:
    =true : When initalize the Essbase Agent and the essbase.cfg has the
            commented JvmModuleLocation entry, remove comment mark from
            the essbase.cfg.
    =false: do nothing(default).

AP_DIFFCNT_NOTIFY: Control diff count notify in the regression monitor.
Description:
    When you define this variable, the regression monitor check the diff
    count and when that count over the specified threshould count, it
    send a notify e-mail.
Defiend at:
    start_regress.sh
Refered from:
    regmon.sh
Values and meaning:
    ="<diff cnt> <e-mail addr> [<e-mail addr>...]"
      <diff cnt>    : Threshould count.
      <e-mail addr> : e-mail address.
Equivalent task option:
    DiffCntNotify(<diff cnt> <e-mail addr>[ <e-mail addr>...])

AP_CLEANUPVIEWFOLDERS : Control cleanning up the SXR_VIEW folders.
Defined at:
    undef
Refered from:
    start_regress.sh
Values and meaning:
	=true : Delete all contents of the sxr folders before running test.
             bin/csc/data/log/msh/rep/scr/sh/sxr
	=false: Not delete contents.
Equivalent task option:
    cleanUpViewFolders(true|false)


AP_MAILDELEGATE : Control using e-mail delegate program.
Defined at:
    undef (default=false)
Refered from:
    start_regress.sh
Values and meaning:
    =true  : Use e-mail delegate function.
    =false : Don't use the e-ail delegate feature.
    Note: This feature only work on Unix platform.
          Windows always use the e-mail delelgate server.

AP_SNAPROOT : Define the snapshot root location.
Defianed at:
    ver_setenv.sh (default=$AUTOPILOT/../..)
Refered from:
    ver_setenv.sh
Values and meaning:
    The root location for the snapshots. It is defined at $AUTOPILOT/../..
    as default. If you want to use local snapshot, you can define this 
    variable to that location.
    This function is implemented for support Santa Clara machines to access
    local(SC) snapshot copies.

AP_HITCACHE : Define HIT cache location.
Defianed at:
    undef (default=undef)
Refered from:
    hitinst.sh
Values and meaning:
    When you define AP_HITCACHE to your local location and that location
    has same file structure as HIT:
    $AP_HITCACHE -+- prodpost -+- <version> -+- build_<####>
                               +- <version> -+- build_<####>
    and hitinst.sh find same build number at there, hitinst.sh uses 
    that contents for the HIT installation.
    This function is implemented for support Santa Clara machines to access
    local(SC) caches. Otherwise, access to Utah from SC is verry slow.

AP_BISHIPHOME : Use BISHIPHOME installation
Refered from:
    se.sh, hyslinst.sh, setchk_env.sh, start_regress.sh
Values and meaning:
    If define this variable true, the autopilot uses BISHIPHOME installer
    for installation and use "Oracle_BI1" directory for the HYPERION_HOME.

### Task file options ####################################################

tsk file options:

schedule(<WeekDay>|<DayOfMonth>|<Date>|<NthWeek>|<BiWeek>|now|once)
           Weekday:    Mon/Tue/Wed/Fri/Sat/Sun
           DayOfMonth: 00..31
           Date:       MM/DD/YYYY ex.)06/23/2007
           NthWeek:    1Mon...5Mon/1Tue...5Tue/.../1Sun...5Sun
           BiWeek:     Mon0/Mon1/Tue0/Tue1/..../Sat0/Sat1/Sun0/Sun1
           now:        Execute it every execution time. (default)

i18ngrep(<Path to the grep.exe>) : Using old grep.exe command on Nti

noagtpsetup(true|false) : Not using agtpsetup.sh before running reg

essbasecfg(<Path to cfg>) : Using specific config file.

forceinst(true|false) : Force installation

refresh(true|false) : Using refresh command only

instkind(both|cd|refresh) : Install kind

chkfree(<location>=<Size in KB>) : Check free disk space

notifylvl(all|#) : Notify diff count # / all -> send every diff

altemail(<name>|<e-mail addr>) Alternate e-mail address for Notify

hangup(<hang up secs>) : Hang up limit seconds # Default 1.5H = 5600

regmondebug(true|false) : Regression monitor debug flag

tarctl(all|essexer*|none) : make archive file from all files from work

tarcnt(all|#) : make archive file from all files from work

priority(#) : Task priority level. (0 to 99. Default 10)

igndone(false|true) : Ignore done tasks when parse task. (Default false)

verbose(true|false) : Verbose mode. When set to true, autopilot.sh send e-mail
                      notification and make the result files. (Default true)

ignplat(<plat>) : Ignore platform.
                  <plat> := <platform name>/<machine name>/<node name>
                  <node name> := <user name>@<machine name>
                  When define this option, the task is not run on that
                  platform.

runplat(<plat>) : Assign running platform.

AltSetUp(<script>) : Alternate setup script.
	When define this option, start_regress.sh call this script after the
	installation of Essbase. You can use this option to install extra
	modules like ASP.
	The setup script should exit 0 when the installation success. When
	return non 0 value, the start_regress.sh send the installation failed
	notify and exit an execution.
	This script is called by following parameter:
	<script> <Full Version number> <Normalized Build number>
	When define this option, the AP_ALTSETUP is overrided by this option.

AltSetEnv(<env script>) : Alternate environment setup script.
	start_regress.sh call se.sh. And se.sh call <ver>_<hostname>.env under
	the $AUTOPILOT/env/<logname> folder. But when you need to add extra 
	setting to the regression environment. Define this option with your
	extra setting up script. This script is called after se.sh.
	When define this option, the AP_ALTSETENV is overrided by this option.

ResFolder(<folder name>) : The destination folder for execution reports.
	When define this option to something, the start_regress.sh send a result
	report fiels, .rtf and .wsp, .wsp2, to this folder.
	The target folder will be created under the /nar200/essbasesxr/regressions/
	<version> folder. When not define this option, start_regress send the
	result reports to /nar200/essbasesxr/regressions/<ver>/essbase folder.
	When define this option, the AP_RESFOLDER is overrided by this option.

ResScript(<script>) : Alternate report creator script instead of send_result.sh
	When define this option, the start_regress.sh call this script instead
	of send_result.sh. If you need a different format of the result report,
	you can override it using this definition.
	When call this script from start_regress.sh. Your environment is in
	SXR_VIEW and $SXR_WORK hold all results of the execution. And you can
	refer $AP_RESFOLDER to find where you need to put the result to.
	This script is called by following parameter:
	${AP_RESSCRIPT} <FULL VERSION> <BUILD> <TEST SCRIPT>
	When deine this option, the AP_RESSCRIPT is overrided by this option.

setenv(<env>=<value>), setenv2(<env>=<value>) : Set system environment variable.
    Define <env> variable with <value> value on that task. setenv() is called 
    before the product installation and setup-regression-environment.
    setenv2() is called after the product installation and setup the regression
    environment. You can define a specific environment variable per each tasks.
    Those variables are defined using "export <env>=<value>" command.

snapshot(<ss-name>) : Use <ss-name> snapshot for SXR_HOME.
    This option set SXR_HOME from following location:
      $AUTOPILOT/../../<ss-name>/vobs/essexer/latest.

UnCommentJVM(true|false): Control the JvmModuleLocation entry
    true : When initalize the Essbase Agent and the essbase.cfg has the
           commented JvmModuleLocation entry, remove that comment mark from
           the essbase.cfg.
    false(default) : do nothing.

DiffCntNotify: Control diff count notify
	When you define this option, the regression monitor check the diff
	count and when that count over the threshould count, it send
	a notify e-mail.
	diffCntNotify(<diff cnt> <e-mail addr> [<e-mail addr>...])
	<diff cnt>    : Threshould count.
	<e-mail addr> : e-mail address.

CleanUpViewFolders(true|false) : Clean up view contents.
	true  : Delete all contents of SXR_VIEW folders.(Default)
	false : Not delete.

BaseInst(<base-ver#>:<base-bld#>) : Base install option.
	When you define this option, the autopilot framework use <base-ver#>
	and <base-bld#> installation then use refresh command for the installation.
	ex.) Following task definition uses zola HIT latest installer and uses
	     refresh command to install for the latest version of the Talleyrand.
		talleyrand:latest:test.sh:BaseInst(zola:hit[latest])

Opack(<opack-ld#>) : Define OPack build number.

order(order#) : Script order in the same priority, version, build.

bi(true|false) : Use BISHIPHOME installer.
        true   : Use BISHIPHOME installer
        false  : Use CD/HIT installer

NoInst(true|false) : No installation option.
        When set this option to true, the autopilot framework won't install product.
        The autopilot run the target test with current installed products.
        But check the version and build numbers are exist in pre_rel folder.

NoBuildCheck(true|false) : No check the installation.
        This option is almost same as NoInst() option. But with this option, the
        autopilot won't check the valid verson and build numbers.

### END OF HELP ###
