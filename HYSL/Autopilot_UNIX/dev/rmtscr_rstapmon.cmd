#!/usr/bin/ksh
# This file is sample file to execute on each machine
# You need to change this file name to <usr>@<hostname>.cmd and put to $AUTOPILOT/mon folder.
# i.e) $AUTOPILOT/mon/ykono@stiahp5.cmd
# Then autopilot.sh get that file and execute it.
# After execution, the file name is rename to <usr>@<hostname>.<time-stamp>.done
# And output is sent to $AUTOPILOT/mon/<usr>@<hostname>.<time-stamp>.out

# Following sample check apmon.sh is running and kill apmon.sh process.
# If you add change to apmon.sh and want to re-start it, use this sample
# against each autopilot processes.
# i.e)
# cp $AUTOPILOT/dev/sample_script.cmd $AUTOPILOT/mon/ykono@stiahp5.cmd
# ... repeat each autopilot processes

mynode="${LOGNAME}@$(hostname)"
amf=$AUTOPILOT/mon/${mynode}.am
if [ -f "$amf" ]; then
	pid=`cat $amf | head -1 | tr -d '\r'`
	echo "Found $amf. And use PID=$pid"
else
	echo "Couldn't find $amf."
	pid=`psu | grep [a]pmon.sh`
	if [ -z "$pid" ]; then
		echo "Failed to get pid of apmon."
	else
		echo "Use PID from $pid."
		pid=${pid%% *}
	fi
fi
if [ -n "$pid" ]; then
	pstree.sh -kill $pid
fi
exit 0

	
