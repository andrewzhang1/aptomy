#!/usr/bin/ksh

# unlock.sh <file>

# 0: Unlock succeeded
# 1: Syntax error
# 2: No *.lck found

# 03/27/2012 YKono	Check lock owner

umask 000
. lockdef.sh
me=$0
orgpar=$@
trg=
force=false
[ "$debug" = "true" ] && dbgwrt "=== $@"
while [ $# -ne 0 ]; do
	case $1 in
		-f)	force=true;;
		*)	trg=$1;;
	esac
	shift
done

if [ -z "$trg" ]; then
	echo "Bad parameter."
	[ "$debug" = "true" ] && dbgwrt "bad parameter. exit 1"
	exit 1
fi

if [ ! -f "$trg.lck" ]; then
	echo "No $trg.lck file."
	[ "$debug" = "true" ] && dbgwrt "No ${trg##*/}.lck. exit 2"
	exit 2
fi

lock_ping.sh "$trg"
if [ $? -eq 0 ]; then
	whoselock=`head -1 "$trg.lck" 2> /dev/null`
	whoselock=${whoselock%% *}
	[ "$debug" = "true" ] && dbgwrt "whoselock=$whoselock. will create ${trg##*/}.term_lock."
	if [ "$force" = "true" -o "${LOGNAME}@`hostname`" = "$whoselock" ]; then
		kppid=`grep "keep_lock_pid:" $trg.lck 2> /dev/null`
		kppid=${kppid#keep_lock_pid:}
		a=`cat $trg.lck 2> /dev/null`
		echo "${LOGNAME}@`hostname` `date +%D_%T`" > "$trg.term_lock"
		cnt=0
		kp=
		while [ $cnt -lt 60 ]; do
			if [ -n "$kppid" ]; then
				kp=`ps -p $kppid 2> /dev/null | grep -v PID`
				if [ -z "$kp" ]; then
					cnt=9999
					break
				fi
			else
				if [ ! -f "$trg.term_lock" ]; then
					cnt=9999
					break
				fi
			fi
			sleep 1
			let cnt=cnt+1
		done
		# if [ $cnt -ne 9999 ]; then
		# 	send_email.sh noap \
                # 		"to:yukio.kono@oracle.com" \
                # 		"sbj:Failed to Unlock ${trg##*/}." \
                # 		"Failed to unlock $trg file." \
		# 		"sep:" "ind:    " \
		# 		"machine=${LOGNAME}@`hostname`(`get_platform.sh`)" \
		# 		"trg=$trg" \
		# 		"kppid=$kppid" \
		# 		"kp=$kp" \
		# 		"cnt=$cnt" \
		# 		"$a" \
		# 		"ind:" "sep:" \
                # 		"from autopilot unlock.sh(`date +%D_%T`)."
		# fi
	fi
else
	[ "$debug" = "true" ] && dbgwrt "Not found ${trg##*/}.lck. delete related files."
	rm -f "$trg.lck" > /dev/null 2>&1
	rm -f "$trg.pin" > /dev/null 2>&1
	rm -f "$trg.term_lock" > /dev/null 2>&1
fi

exit 0
