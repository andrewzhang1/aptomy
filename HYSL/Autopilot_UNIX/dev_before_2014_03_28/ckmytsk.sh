#!/usr/bin/ksh
# ckmytsk.sh : Check my task
# Syntax: ckmytsk.sh [-d|-h]
#   -d : Display current lock status and list up the tasks which
#        current platform can execute.
#   -h : Display help.
# Out status:
#   0: Got correct task > echo file name in crr
#   1: No task for this node and plat
#   2: Found all lock
#   3: Task found but errir task. Move task to *.bad
# History:
# 2012/05/23	YKono	First edition from autopilot.sh
# 2012/12/03	YKono	Add freemem() check
# 2013/02/27	YKono	Add check mode -d
# 2013/08/19	YKono	use getmemfree.sh.
# 2013/08/21	YKono	Bug 16356202 - ALLPLATFORMS.TSK(add plat)
#                       Support "<plat>:" condition for all.tsk
#                         runplat(win32:scl20203 biee11):
#                             execute this task when the machine is win32
#                             and name is scl20203. For other platform,
#                             run this task when machine name is biee11.
#                       Support AP_RUNPLATONLY : When define this variable, 
#                                                this machine won't run a
#                                                task which doesn't have
#                                                runplat() option.

. apinc.sh

#########################################################################
# Functions
#########################################################################

# chk_execplat $opt
chk_execplat()
{
	[ -n "$AP_PLATGROUP" ] && grp="$AP_PLATGROUP" || grp="XXXXXXXXXXXXX"
	ignplats=`chk_para.sh ignplat "${1#*:*:*:}"`
	runplats=`chk_para.sh runplat "${1#*:*:*:}"`
	[ "$AP_RUNPLATONLY" = "true" ] && ret=false || ret=true

	thishostL=`echo $thishost | tr A-Z a-z`
	thishostU=`echo $thishost | tr a-z A-Z`
	thisnodeL=`echo $thisnode | tr A-Z a-z`
	thisnodeU=`echo $thisnode | tr a-z A-Z`
	while [ -n "$ignplats" ]; do
		oneplat=${ignplats%% *}
		[ "$oneplat" = "$ignplats" ] && ignplats= || ignplats=${ignplats#$oneplat }
		plcond=${oneplat%:*}
		[ "$plcond" = "$oneplat" ] && unset plcond || oneplat=${oneplat#*:}
		if [ -z "$plcond" -o "$plcond" = "$thisplat" ]; then
			case $oneplat in
				$LOGNAME|$thishost|$thisnode|$thisplat|$thishostL|$thishostU|$thisnodeL|$thisnodeU)
					ret=ign
					break
					;;
				*)
					gsts=`echo "$grp" | grep "$oneplat"`
					if [ -n "$gsts" ]; then
						ret=ign
						break
					fi
					;;
			esac
		fi
	done
	if [ "$ret" != "ign" -a -n "$runplats" ]; then
		ret=false
		checked=false
		while [ -n "$runplats" ]; do
			oneplat=${runplats%% *}
			[ "$oneplat" = "$runplats" ] && runplats= || runplats=${runplats#$oneplat }
			plcond=${oneplat%:*}
			[ "$plcond" = "$oneplat" ] && unset plcond || oneplat=${oneplat#*:}
			if [ -z "$plcond" -o "$plcond" = "$thisplat" ]; then
				checked=true
				case $oneplat in
					$LOGNAME|$thishost|$thisnode|$thisplat|$thishostL|$thishostU|$thisnodeL|$thisnodeU)
						ret=true
						break
						;;
					*)
						gsts=`echo "$grp" | grep "$oneplat"`
						if [ -n "$gsts" ]; then
							ret=true
							break
						fi
						;;
				esac
			fi
		done
		[ "$checked" = "false" -a "$AP_RUNPLATONLY" != "true" -a "$ret" = "false" ] && ret=true
	fi
	if [ "$ret" = "true" ]; then
		freemem=`chk_para.sh freemem "${1#*:*:*:}"`
		if [ -n "$freemem" ]; then
			case $freemem in
				*KB)    freemem=${freemem%??};;
				*MB)	feemem=$(echo "scale=2;${freemem%??}\*1024"| bc);;
				*GB)	feemem=$(echo "scale=2;${freemem%??}\*1048576"| bc);;
				*B)     let freemem=\(${freemem%?}+512\)/1024 2> /dev/null;;
				*)	;;
			esac
			crrmem=`getmemfree.sh loc`
			crrmem=${crrmem%% *}
			[ "$crrmem" -lt "$freemem" ] && ret="mem_${freemem}_${crrmem}"
		fi
	fi
	echo $ret
}

me=$0
chkonly=false
while [ $# -ne 0 ]; do
	case $1 in
		-d)	chkonly="true";;
		-h)	display_help.sh $me; exit 0;;
		*)
	esac
	shift
done

tsktmp="$HOME/${thisnode}.tsktmp"
rm -f "$tsktmp" 2> /dev/null
nodelck=
platlck=
tsk=
sts=2
lock_ping.sh $AUTOPILOT/tsk/all.read
if [ $? -ne 0 ]; then
	_pid=`lock.sh $AUTOPILOT/lck/${thisnode}.read -m "Check node task on START phase($thisnode:$thisplat)" $$`
	if [ $? -eq 0 ]; then
		ls $AUTOPILOT/que/*~${thisnode}.tsk 2> /dev/null > $tsktmp
		nodelck="true"
	else
		if [ "$chkonly" = "true" ]; then
			echo "# Failed node lock"
			if [ -f "$AUTOPILOT/lck/${thisnode}.read.lck" ]; then
				echo "### \$AUTOPILOT/lck/${thisnode}.read is locked by:"
				IFS=
				cat $AUTOPILOT/lck/${thisnode}.read.lck 2> /dev/null | while read line; do
					echo "> $line"
				done
			fi
			ls $AUTOPILOT/que/*~${thisnode}.tsk 2> /dev/null > $tsktmp
		fi
	fi
	if [ "$AP_NOPLAT" = "false" ]; then
		_pid=`lock.sh $AUTOPILOT/lck/${thisplat}.read -m "Check plat task on START phase($thisnode:$thisplat)" $$`
		if [ $? -eq 0 ]; then
			ls $AUTOPILOT/que/*~${thisplat}.tsk 2> /dev/null >> $tsktmp
			platlck="true"
		else
			if [ "$chkonly" = "true" ]; then
				echo "# Failed plat lock."
				if [ -f "$AUTOPILOT/lck/${thisplat}.read.lck" ]; then
					echo "### \$AUTOPILOT/lck/${thisplat}.read is locked by:"
					IFS=
					cat $AUTOPILOT/lck/${thisplat}.read.lck 2> /dev/null | while read line; do
						echo "> $line"
					done
				fi
				ls $AUTOPILOT/que/*~${thisplat}.tsk 2> /dev/null > $tsktmp
			fi
		fi
	fi
	sts=1
else
	if [ "$chkonly" = "true" ]; then
		echo "# Failed to all.read"
		if [ -f "$AUTOPILOT/tsk/all.read.lck" ]; then
			echo "### \$AUTOPILOT/tsk/all.read is locked by:"
			IFS=
			cat $AUTOPILOT/tsk/all.read.lck 2> /dev/null | while read line; do echo "> $line"; done
		fi
	fi
fi

if [ -f "$tsktmp" ]; then
	if [ "$chkonly" = "true" ]; then
		sort "$tsktmp" | while read one; do
			cont=`head -1 "$one" | tr -d '\r'`
			sts=`chk_execplat "$cont"`
			[ -n "$cont" -a "$sts" = "true" ] && echo "${one##*/}~${cont#*:*:*:}" | sed -e "s!~!	!g" -e "s!.tsk!!g"
		done
		unset tsk
	else
		tsk=$(
			sort "$tsktmp" | while read one; do
				cont=`head -1 "$one" | tr -d '\r'`
				if [ -n "$cont" -a `chk_execplat "$cont"` = "true" ]; then
					echo "$one"
					break
				fi
			done
		)
	fi
	rm -rf "$tsktmp" 2> /dev/null
fi

if [ -n "$tsk" ]; then
	content=`head -1 "$tsk"`
	parsedby=`head -2 "$tsk" | tail -1`
	tsk=${tsk##*/}
	ver=`echo $tsk | awk -F~ '{print $2}' | sed -e "s/!/\//g"`
	bld=`echo $tsk | awk -F~ '{print $3}'`
	tst=`echo $content | awk -F: '{print $3}' | sed -e "s/+/ /g" -e "s/\^/:/g"`
	donename=${tsk#*~}	# without priority
	if [ "$donename" != "${donename#*~*~*~*~}" ]; then # Remove script order field
		_name=${donename%~*~*~*}
		_name=${_name}~${donename#*~*~*~}
		donename=$_name
	fi
	# Check error contents.
	if [ "${bld#\#}" != "${bld}" \
	    -o "${content#*~}" != "${content}" \
	    -o -z "$ver" -o -z "$bld" -o -z "$tst" ]; then
		mv "$AUTOPILOT/que/$tsk" "$AUTOPILOT/que/$tsk.bad" 2> /dev/null
		sts=3
	else
		rm -rf $AUTOPILOT/que/crr/$donename 2> /dev/null
		echo "$content" > "$AUTOPILOT/que/crr/$donename"
		echo "$parsedby" >> "$AUTOPILOT/que/crr/$donename"
		echo "$tsk" >> "$AUTOPILOT/que/crr/$donename"
		echo "On:${thisnode}" >> "$AUTOPILOT/que/crr/$donename"
		echo "Plat:${thisplat}" >> "$AUTOPILOT/que/crr/$donename"
		echo "Start:`date +%D_%T`" >> "$AUTOPILOT/que/crr/$donename"
		rm -f "$AUTOPILOT/que/$tsk"
		echo $donename
		sts=0
	fi
fi
[ "$nodelck" = "true" ] && unlock.sh $AUTOPILOT/lck/${thisnode}.read > /dev/null 2>&1
[ "$platlck" = "true" ] && unlock.sh $AUTOPILOT/lck/${thisplat}.read > /dev/null 2>&1

exit $sts
