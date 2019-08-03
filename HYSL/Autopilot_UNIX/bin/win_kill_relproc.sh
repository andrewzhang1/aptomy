#!/usr/bin/ksh
# win_kill_relproc.sh : Kill DLL related processes
# Description:
#   Kill the process which is using specific DLL module.
# Syntax:
#   win_kill_relproc.sh [-h] <DLL>
# Parameter:
#   <DLL>: Target DLL name
# Option:
#   -h:    Display help
# Sample:
#   win_kill_relproc.sh dbghlp.dll
# Hitory:
# 2012/12/19	YKono	First edition

. apinc.sh

me=$0
orgpar=$@
trg=
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			exit 0
			;;
		*)
			trg=$1
			;;
	esac
	shift
done

if [ -z "$trg" ]; then
	echo "${me##*/}: No target defined."
	exit 1
fi
if [ `uname` = "Windows_NT" ]; then
	tasklist /m $trg | grep -v "^$" | grep -v "^Image Name" \
	    | grep -v "^===" | grep -v "^INFO: No tasks" | while read mod pid tar; do
		echo "Kill $pid $mod($tar)."
		kill -9 $pid 2> /dev/null
	done
fi
exit 0
