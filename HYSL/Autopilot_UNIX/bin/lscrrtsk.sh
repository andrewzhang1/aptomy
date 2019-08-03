#!/usr/bin/ksh
# lscrrtsk.sh : List current execution task with confirmation.
# 
# DESCRIPTION:
#    List up current executing tasks with alive check.
#  
# Syntask:
#    lstcrrtsk.sh [-h]
# 
# Parameters:
#    -h : Display help
# 
# Sample:
#    $ lscrrtsk.sh
# 
# History:
# 2011/07/12	YKono	First edition

thisscript=$0
echo "$0"

display_help()
{
	n=`egrep -n -i "^# historyi:" $thisscript | head -1`
	n=${n%%:*}
	i=0
	head -$n $thisscript | while read one; do
		if [ $i -ne 0 ]; then
			echo ${one#??}
		fi
		let i=i+1
	done
}

orgpar=$@
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help
			;;
		*)
			echo "Too many parameters."
			echo "params: $orgpar"
			display_help
			exit 1
			;;
	esac
	shift
done


