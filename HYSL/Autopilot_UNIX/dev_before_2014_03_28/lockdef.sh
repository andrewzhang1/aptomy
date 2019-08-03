#!/usr/bin/ksh
umask 000
# [ "`uname`" = "HP-UX" ] && debug=true || unset debug
[ "$AP_LOCKLOG" = "true" ] && debug=true || unset debug
if [ -z "$AP_DELEGATE" ]; then
	lockfld="$AUTOPILOT/mon"
else
	lockfld="$AP_DELEGATE"
fi
locklog="$lockfld/lock.log"

dbgwrt()
{
	if [ "$debug" = "true" ]; then
		IFS=
		if [ $# -ne 0 ]; then
			echo "`date +%D_%T` ${LOGNAME}@$(hostname) ${me##*/} $@" >> $locklog
		else
			while read line; do
				echo "`date +%D_%T` ${LOGNAME}@$(hostname) ${me##*/} $line" >> $locklog
			done
		fi
	fi
}
