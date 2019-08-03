#!/usr/bin/ksh

if [ -z "$AUTOPILOT" ]; then
	echo "No AUTOPILOT defined."
fi

while [ 1 ]; do
	ls -l $AUTOPILOT/mon/*.ap.log | while read attr d usr grp sz dt1 dt2 dt3 fn; do
		if [ "$sz" -gt 524228000 ]; then
			echo "Delete $sz $fn"
			rm -f $fn
		fi
	done
	sleep 30
done

