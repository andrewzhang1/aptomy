#!/usr/bin/ksh


# $? = 0 : Start well
#    = 1 : Already exist


[ -z "$AP_DEFVAR" ] && . apinc.sh


node="${LOGNAME}@`hostname`"
monfld="$AUTOPILOT/tst"
apfile="${monfld}/${node}.template"
termfile="${apfile}.terminate"

# if use "-forcequit" parameter, the keep_lock.sh create terminate request file
#   if you ignore that request, keep_lock.sh forcely kill parent process wfter 30 min.
#   if you delete the terminate file, then keep_lock.sh won't kill your process.
#     it just delete lock file.
lckid=`lock.sh -fq "$apfile" $$`
if [ $? -ne 0 ]; then
	echo "Error: There is another bgtemplate.sh."
	cat "$apfile.lck"
	exit 1
fi

# Main loop
trap '' 1 2 3 15
while [ 1 ]; do
	if [ -f "$termfile" ]; then
		# rm -f "$termfile" > /dev/null 2>&1
		break
	fi
	sleep 10
done

trap 1 2 3 15

exit 0
