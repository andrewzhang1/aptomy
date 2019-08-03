#!/usr/bin/ksh

# lock_ping.sh <lock target>
# Return:
# 0 : ping success = locked.
# 1 : No reaction
# 2 : No target file
# 3 : parameter error
# HISTORY ###########################################
# 03/02/2011 YKono	Change pin file name format.

. lockdef.sh
me=$0
orgpar=$@
trg=
view=false
while [ $# -ne 0 ]; do
	case $1 in
	-v)
		view=true
		;;
	*)
		trg=$1
		;;
	esac
	shift
done

[ "$debug" = "true" ] && dbgwrt "=== $@"
if [ -z "$trg" ]; then
	[ "$view" != "false" ] && echo "#3 Bad arg"
	exit 3
fi
pinname="$trg.${LOGNAME}@`hostname`_$$.pin"

if [ -f "$trg.lck" ]; then
	pinmax=10
	pincnt=0
	echo "PIN($LOGNAME@`hostname`)$$ to $trg" > "$pinname"
	chmod 777 "$pinname" > /dev/null 2>&1
	while [ $pincnt -lt $pinmax ]; do
		[ ! -f "$pinname" ] && break
		let pincnt=pincnt+1
		sleep 1
	done
	if [ ! -f "$pinname" ]; then
		[ "$debug" = "true" ] && dbgwrt "${pinname##*/} - alive. exit 0"
		[ "$view" != "false" ] && echo "#0 alive"
		exit 0
	else
		[ "$debug" = "true" ] && dbgwrt "${pinname##*/} - dead. Remove related files. exit 1"
		rm -f $trg.*.pin > /dev/null 2>&1
		rm -f "$trg.lck" > /dev/null 2>&1
		rm -f "$trg.quit" > /dev/null 2>&1
		rm -f "$trg.kill" > /dev/null 2>&1
		[ "$view" != "false" ] && echo "#1 dead"
		exit 1
	fi
else
		[ "$debug" = "true" ] && dbgwrt "No ${1##*/}.lck file. Remove related files. exit 2"
		rm -f $trg.*.pin > /dev/null 2>&1
		rm -f "$trg.lck" > /dev/null 2>&1
		rm -f "$trg.quit" > /dev/null 2>&1
		rm -f "$trg.kill" > /dev/null 2>&1
		rm -f "$trg.term_lock" > /dev/null 2>&1
	[ "$view" != "false" ] && echo "#2 No $trg.lck"
	exit 2
fi
