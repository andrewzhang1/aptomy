#!/usr/bin/ksh
############################################################################
# chkcrr.sh : Check current tasks and return active number of execution
#
# Syntax:
#   chkcrr.sh [-h|-v|-d|-m|-p <plat>] [<ver> [<bld>]]
#
# Options:
#   -h : Display help.
#   -v : Display message.
#   -d : Move dead task to $AUTOPILOT/que/crr/dead folder.
#   -m : Move dead task back to $AUOTPILOT/que
#   -p <plat> : Check <plat> tasks
#
# Description:
#   This script check the current execution tasks and check the autopilot
#   process which is assumed to run target task alive or not.
#   If find the target process is dead and -mm option, this script move 
#   back the target task to the task queue ($AUTOPILOT/que).
#   When use "-d" option, the target task doesn't move back to the task
#   queue and move it to $AUTOPILOT/que/crr/dead folder.
#
# Exit code:
#   0 : Succeded check and move back.
#   1 : Syntax error.
#   2 : $AUTOPILOT/que/crr not found.
#
############################################################################
# History:
# 2011/07/27	YKono	First edition
# 2012/06/01	YKono	Add <ver> and <bld> parameter.

. apinc.sh
umask 000

# -------------------------------------------------------------------------
# Read parameters
me=$0
orgparam=$@
action=none
disp=ap
tver=
tbld=
tplt=
while [ $# -ne 0 ]; do
        case $1 in
		`isplat $1`)
			tplt=$1
			;;
		-p)
			shift
			if [ $# -eq 0 ]; then
				echo "chkcrr.sh : '-p' need second parameter."
				exit 1
			fi
			tplt=$1
			;;
		-v)
			disp=detail
			;;
                -h)
                        display_help.sh $me
                        exit 0
                        ;;
		-m)
			action="moveback"
			;;
		-d)
			action="deadfolder"
			;;
		*)
			if [ -z "$tver" ]; then
				tver=$1
			elif [ -z "$tbld" ]; then
				tbld=$1
			else
				echo "chkcrr.sh : too many parameter."
				display_help.sh $me
				exit 1
			fi
			;;
	esac
	shift
done

# ==========================================================================
# Main

if [ ! -d "$AUTOPILOT/que/crr" ]; then
	echo "Failed to cd to \$AUTOPILOT/que/crr."
	echo "Please make sure the \$AUTOPILOT/que/crr mounted."
	exit 2
fi

cd $AUTOPILOT/que/crr
tmpf="$HOME/.chkcrr.${LOGNAME}@$(hostname).tmp"
rm -rf $tmpf 2> /dev/null
ls *.tsk | while read one; do
	tsk=`head -1 $one | tr -d '\r'`
	parsedby=`cat "$one" 2> /dev/null | grep "^Parsed by" | tr -d '\r'`
	fname=`head -3 $one | tail -1 | tr -d '\r'`
	on=`cat $one 2> /dev/null | grep "^On:" | tr -d '\r'`
	dt=`cat $one 2> /dev/null | grep "^Start:" | tr -d '\r'`
	ver=`echo $tsk | awk -F: '{print $1}'`
	bld=`echo $tsk | awk -F: '{print $2}'`
	tst=`echo $tsk | awk -F: '{print $3}'`
	opt=`echo $tsk | awk -F: '{print $4}'`
	tar=${on#*:}
	dt=${dt#*:}
	plt=`echo $one | awk -F~ '{print $4}'`
	plt=${plt%%.*}
	[ -n "$tver" -a "$tver" != "$ver" ] && continue
	[ -n "$tbld" -a "$tbld" != "$bld" ] && continue
	lock_ping.sh $AUTOPILOT/lck/$tar.reg
	if [ $? -eq 0 ]; then
		if [ -z "$tplt" -o "$tplt" = "$plt" ]; then
			[ "$disp" = "detail" ] && echo "$ver $bld - $tst on $tar at $dt - alive"
			echo "$ver $bld - $tst on $tar at $dt - alive" >> $tmpf
		fi
	else
		if [ -z "$tplt" -p "$tplt" = "$plt" ]; then
			if [ "$action" = "deadfolder" ]; then
				if [ ! -d "dead" ]; then
					mkdir dead 2> /dev/null
					fi
				mv $one dead
				echo "$ver $bld - $tst on $tar at $dt - dead"
			elif [ "$action" = "moveback" ]; then
				if [ -z "$ver" -o -z "$bld" -o -z "$tst" -o -z "$fname" ]; then
					[ "$disp" = "detail" ] && echo "Missing information - $one"
					if [ ! -d "missing" ]; then
						mkdir missing 2> /dev/null
					fi
					mv $one missing 2> /dev/null
				else
					rm -f ../$fname 2> /dev/null
					echo "$tsk" > ../$fname
					echo "$parsedby" >> ../$fname
					[ "$disp" = "detail" ] && echo "$ver $bld - $tst on $tar at $dt - dead - move back"
				fi
			fi
		fi
	fi
done
if [ -f "$tmpf" ]; then
	cnt=`cat $tmpf | wc -l`
	let cnt=cnt
	rm -rf $tmpf 2> /dev/null
else
	cnt=0
fi
[ "$disp" = "detail" ] && echo "Running task=$cnt" || echo "$cnt"
exit 0

