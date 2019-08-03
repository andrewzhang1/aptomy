#!/usr/bin/ksh

# lock_kill.sh <file>

# 0: Unlock succeeded
# 1: Syntax error
# 2: No *.lck found

umask 000
me=$0
orgpar=$@
. lockdef.sh
[ "$debug" = "true" ] && dbgwrt "=== $@"

if [ $# -ne 1 ]; then
	echo "Bad parameter."
	exit 1
fi

if [ ! -f "$1.lck" ]; then
	echo "No $1.lck file."
	exit 2
fi


lock_ping.sh "$1"
if [ $? -eq 0 ]; then
	[ "$debug" = "true" ] && dbgwrt "- ${1##*/}.lck - alive. will create ${1##*/}.kill file."
	echo "${LOGNAME}@`hostname` `date +%D_%T`" > "$1.kill"
else
	[ "$debug" = "true" ] && dbgwrt "- ${1##*/}.lck - dead. Remove related files."
	rm -f "$1.lck"
	rm -f "$1.pin"
	rm -f "$1.kill"
	rm -f "$1.quit"
	rm -f "$1.term_lock"
fi

exit 0
