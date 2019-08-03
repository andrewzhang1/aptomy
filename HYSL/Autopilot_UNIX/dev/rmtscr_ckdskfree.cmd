#!/usr/bin/ksh
# This file is sample file to execute on each machine
# You need to change this file name to <usr>@<hostname>.cmd and put to $AUTOPILOT/mon folder.
# i.e) $AUTOPILOT/mon/ykono@stiahp5.cmd
# Then autopilot.sh get that file and execute it.
# After execution, the file name is rename to <usr>@<hostname>.<time-stamp>.done
# And output is sent to $AUTOPILOT/mon/<usr>@<hostname>.<time-stamp>.out

mynode="${LOGNAME}@$(hostname)"
echo "# Disk free of $mynode."
echo "HOME($HOME)=`getdskfree.sh $HOME -c`"

exit 0

	
