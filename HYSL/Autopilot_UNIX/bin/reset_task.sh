#!/usr/bin/ksh
# reset_task.sh : Reset task for specific version/build and platform.
# Description:
#   This program delete tasks from task queue and set FLAG file to
#   "KILL/SKIP/START" condition, this setting let regression process
#   to just stop and kill current execution then skip current running
#   task then move to start condition.
#   So, you can stop current execution and queued tasks for specific
#   version and build, platform.
# Syntax: reset_task.sh [<plat>|-h|-i <ptn>] <ver> [<bld>]
# Parameter:
#   <ver>    : Reset version
#   <bld>    : Reset build
#              When you skip this parameter, this program reset every
#              builds from running task and task queue.
#   <plat>   : Target platfrom
#              When you skip this parameter, this program uses curent
#              platform for the target. You can also use "all" for 
#              all platforms.
# Option:
#   -h       : Display help
#   -i <ptn> : Ignore pattern
#              This pattern is used for egrep command.
#              ign=`echo $node | egrep "<ptn>"`
#              If $ign is not null, this program won't kill that task.
#              So, when you want to ignore vgee and bao user's task,
#              please use -i "vgee|bao" option.
# History:
# 2013/02/15	YKono	First edition from reset_all.sh

. apinc.sh

me=$0
opar=$@
ver=
bld=
plat=all
ignptn=
while [ $# -ne 0 ]; do
	case $1 in
		-h)	display_help.sh $me
			exit 0 ;;
		`isplat $1`)	plat=$1 ;;
		all)	plat=all;;
		-i)	if [ $# -lt 2 ]; then
				echo "${me##*/}:'-i' need second parameter as ignore pattern."
				exit 1
			fi
			shift
			ignptn=$1
			;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			elif [ -z "$bld" ]; then
				bld=$1
			else
				echo "Too much parameter."
				exit 1
			fi
			;;
	esac
	shift
done
[ -z "$bld" ] && b="-" || b="$bld"
rmtsk.sh -p $plat $ver $b -
[ -z "$bld" ] && v="$ver" || v="${ver}:${bld}"
apctl.sh $plat -s | grep $v | while read plat node dm rest; do
	[ -n "$ignptn" ] && sts=`echo "$node $rest" | egrep "$ignptn"` || sts=
	if [ -z "$sts" ]; then
		echo "# STOP $plat $node - $rest"
		apctl.sh $node KILL/SKIP/START
	fi
done


