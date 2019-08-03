#!/usr/bin/ksh
# regsts.sh : display regression status of current execution
# Description:
#   This tool display the current regression status for specific
#   platform.
# Syntax: regsts.sh [<plat>...|idle|noidle]
#   <plat> : Platform to display
#   idle   : Display idle processes
#   noidle : Don't display idle processes(default)
# Reference:
#   AP_REGSTS: You can define specific parameter in this variable
#              export AP_REGSTS="win32 winamd64 idle"
#              Then this command display spcified platform's status
#              from AP_REGSTS value.
#              But when you provide the parameter to this command,
#              this command ignore AP_REGSTS definition.
# History:
# 2013/11/13 YKono   First edition

. apinc.sh

[ -n "$AP_REGSTS" -a $# -eq 0 ] && regsts=$AP_REGSTS
plats=
supidle=true
while [ -n "$regsts" -o $# -ne 0 ]; do
	if [ -n "$regsts" ]; then
		one=${regsts%% *}
		[ "$one" = "$regsts" ] && regsts= || regsts=${regsts#* }
	else
		one=$1
		shift
	fi
	case $one in
		all)	plats=`isplat`;;
		`isplat $one`)
			if [ -z "$plats" ]; then
				plats="$one"
			else
				s=`echo $plats | grep $one`
				[ -z "$s" ] && plats="$plats $one"
			fi
			;;
		idle)	supidle=false;;
		noidle)	supidle=true;;
	esac
done
[ -z "$plats" ] && plats=`isplat`
[ "$supidle" = "true" ] && grepcmd="grep -v tasks.$ | grep -v IDLE" || grepcmd="grep -v tasks.$"
cmd=
for one in $plats; do
	[ -z "$cmd" ] && cmd="apctl.sh -S $one;" || cmd="$cmd apctl.sh -S $one;"
done
cmd="( $cmd ) | $grepcmd"
echo "# $plats"
echo "# $cmd"
while [ 1 ]; do
	curr=`eval $cmd`
	if [ "$curr" != "$back" ]; then
		echo "`date +%D_%T` ==============================="
		eval $cmd
		back=$curr
	else
		sleep 10
	fi
done

