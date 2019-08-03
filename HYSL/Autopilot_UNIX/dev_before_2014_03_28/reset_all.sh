#!/usr/bin/ksh
# Reset all task and runnning task related to specific version
# 2013/03/26 - YKono Bug 16356258 - COMMAND TO KILL ALL THE RUNS AND REMOVE TASKS FROM QUEUE

ver=

while [ $# -ne 0 ]; do
	case $1 in
		*)
			if [ -z "$ver" ]; then
				ver=$1
			else
				echo "Too much parameter."
				exit 1
			fi
			;;
	esac
	shift
done

rmtsk.sh -p all ${ver} - -
apctl.sh all | grep ${ver} | while read plat node rest; do
echo "# $plat $node $rest"
apctl.sh $node KILL/SKIP/START
done


