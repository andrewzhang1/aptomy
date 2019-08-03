#!/usr/bin/ksh

# tsklst.sh : Task list command
# Return:
#  0: Success
#  1: Few parameter
#  2: Too many parameter
#  3: Failed to lock the target <node> or <plat> or all

# History:
# 04/04/2008 YKono First edition
# 06/19/2008 YKono Change syntax
# 06/26/2010 YKono Add "writing history"
# 08/06/2010 YKono When someone lock read/parse, wait it.

. apinc.sh

display_help()
{
	echo "rmtsk.sh - Remove tasks from the task queue."
	echo ""
	echo "Syntax:"
	echo "  rmtsk.sh [crr|done|que] [-ap] <ver> <bld> <test> "
	echo "           {<platform>|all|-m|-mp|-p <plat>|-pri <pri>}"
	echo ""
	echo "Options:"
	echo "  que:        Delete task from the task queue.(Default)"
	echo "  crr:        Delete task from the current execution queue."
	echo "  done:       Delete task from the done buffer."
	echo "  <ver>:      Version number"
	echo "  <bld>:      Build number"
	echo "  <test>:     Test script name"
	echo "  <platform>: Platform or Node specification"
	echo "              You can use folloeing platforms:"
	echo "                aix,aix64,solaris,solaris64,solaris.x64,hpux,hpux64,"
	echo "                linux,linuxamd64,linuxx64exawin32,win64,winamd64"
	echo "              Or you can use node specification below:"
	echo "                <usr name>@<machine name>"
	echo "                e.x.) regrrk1@stiahp4"
	echo "  all:        Delete task files for all platforms and nodes."
	echo "  -m:         Delete task files for a current node(user and mahcien)."
	echo "  -mp:        Delete task files for a current platform."
	echo "  -ap:        AP mode message."
	echo "  -p <plat>:  Delete task files for the specific platform."
	echo "  -pri <pri>: Delete task which has <pri> priority."
	echo " Note:You can use '-' on ver/bld/test for same mean as '*'."
	if [ $# -ne 0 ]; then
		echo ""
		echo "Example:"
		echo "  1) Remove all zola tasks for current node."
		echo "    $ rmtsk.sh -m zola - -"
	fi
}


lstknd=$AP_TSKQUE
unset ver bld scr plat

outfrm=norm
_sepch="	"
pri=*
[ "$AP_NOPLAT" = "false" ] && plat=`get_platform.sh -l` || plat=${node}
while [ $# -ne 0 ]; do
	case $1 in
		crr|-crr)
			lstknd=$AP_CRRTSK
			;;
		que|-que)
			lstknd=$AP_TSKQUE
			;;
		done|-done)
			lstknd=$AP_TSKDONE
			;;
		-help|-h)
			display_help with example
			exit 0
			;;
		-m|me|myself)
			plat=${node}
			;;
		`isplat $1`)
			plat=${1#-}
			;;
		-mp|myplat)
			plat=`get_platform.sh -l`
			;;
		-p)
			shift
			plat=$1
			;;
		-pri)
			shift
			pri=$1
			;;
		-ap)
			outfrm=apform
			_sepch="|"
			;;
		*@*)
			plat=$1
			;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			elif [ -z "$bld" ]; then
				bld=$1
			elif [ -z "$scr" ]; then
				scr=$1
			else
				echo "rmtsk.sh:Too much parameter."
				display_help
				exit 2
			fi
			;;
	esac
	shift
done

if [ -z "$ver" -o -z "$bld" -o -z "$scr" -o -z "$plat" ]; then
	echo "rmtsk.sh:Not enough parameters."
	echo "Please define all <platfrom>, <ver>, <bld> and <test> parameters."
	echo "<plat>=$plat, <ver>=$ver, <bld>=$bld, <test>=$scr, <pri>=$pri"
	echo ""
	display_help
	exit 1
fi

[ "$ver" = "-" ] && ver="*"
[ "$bld" = "-" ] && bld="*"
[ "$scr" = "-" ] && scr="*"
[ "$plat" = "all" ] && plat="*"

crr=`pwd`
cd $lstknd
if [ "$lstknd" = "$AP_TSKQUE" ]; then
	srchptn="${pri}~${ver}~${bld}~*${scr}~${plat}.ts[kd]"
else
	srchptn="${ver}~${bld}~${scr}~${plat}.tsk"
fi

# Decide read lock mode. (all, <plat>, <node>)
case $plat in
	*@*)
		if [ "${plat}" = "${plat#*\*}" -a "${plat}" = "${plat#*\?}" ]; then
			lckkind=$plat
		else
			lckkind=all
		fi
		;;
	`isplat $1`)
		lckkind=$plat
		;;
	*)
		lckkind=all
		;;
esac


trg=$AUTOPILOT/lck/${lckkind}.read
pid=`lock.sh $trg $$ 2> /dev/null`
if [ $? -ne 0 ]; then
	echo "Someone lock $trg."
	echo "Will retry 5 seconds later."
	if [ -f "$trg.lck" ]; then
		cat $trg.lck | while read line; do
			echo " > $line"
		done
	fi
	sleep 5
	pid=`lock.sh $trg $$ 2> /dev/null`
fi

# echo "Read Lock=$trg.lck"
# cat $trg.lck | while read line; do
# 	echo " # $line"
# done

prs=$AUTOPILOT/lck/${lckkind}.parse
pid=`lock.sh $prs $$ 2> /dev/null`
if [ $? -ne 0 ]; then
	echo "Someone lock $prs."
	echo "Will retry 5 seconds later."
	if [ -f "$prs.lck" ]; then
		cat $prs.lck | while read line; do
			echo " > $line"
		done
	fi
	sleep5
	pid=`lock.sh $prs $$ 2> /dev/null`
fi

# echo "Parse Lock=$prs.lck"
# cat $prs.lck | while read line; do
# 	echo " # $line"
# done

[ "$outfrm" = "norm" ] && echo "remove ver=$ver, bld=$bld, test=$scr on $plat tasks."
cnt=`ls ${srchptn} 2> /dev/null | wc -l`
echo "srchptn=$srchptn"
ls ${srchptn} 2> /dev/null |
while read line; do
	if [ "$outfrm" = "norm" ]; then
		if [ "$line" != "${line#*~*~*~*~*~}" ]; then
			tmp=${line%~*~*~*}
			tmp="${tmp}~${line#*~*~*~*~}"
		else
			tmp=$line
		fi
		echo "$tmp" | sed -e "s/~/${_sepch}/g" -e "s/\.tsk//g" -e "s/\.tsd//g" -e "s/!/\//g" -e "s/+/ /g"
	fi
	rm -f "$line" 2> /dev/null
	# Write history
	echo "`date +%D_%T` $LOGNAME@$(hostname) : REMOVE TASK $line." >> $aphis
done
unlock.sh $prs
unlock.sh $trg

let cnt="$cnt + 0"
if [ "$outfrm" = "norm" ]; then
	if [ $cnt -eq 0 ]; then
		echo "No task removed."
	elif [ $cnt -eq 1 ]; then
		echo "Removed one task."
	else
		echo "Removed ${cnt} tasks."
	fi
else
	echo "true"
fi
exit 0
