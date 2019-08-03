#!/usr/bin/ksh

rm -rf "$HOME/crrlog.txt"
while [ 1 ]; do
	if [ -f "$AUTOPILOT/mon/ykono5_ykono.crr" ]; then
		one=`cat $AUTOPILOT/mon/ykono5_ykono.crr`
	else
		one="### NO CRR FILE for ykono@ykono5 ###"
	fi
	if [ "$one" != "$prev" ]; then
		echo $one | tee -a "$HOME/crrlog.txt"
	fi
	prev=$one
	sleep 5
done

	