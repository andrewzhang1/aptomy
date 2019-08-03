#~/usr/bin/ksh

# chgtsk.sh : Change task definition
# Return:
#  0: Success
#  1: Few parameter
#  2: Too many parameter
#  3: Failed to lock the target <node> or <plat> or all

# History:
# 06/30/2009 YKono - First edition

. apinc.sh

display_help()
{
	echo "chgtsk.sh - Change tasks option."
	echo ""
	echo "Syntax:"
	echo "  chgtsk.sh [-ap] <plat> <ver> <bld> <test> {disable|enable|-pri <pri>}"
	echo ""
	echo "Options:"
	echo "  <plat>:    Platform or Node specification"
	echo "             You can use following platforms:"
	echo "                 aix,aix64,solaris,solaris64,solaris.x64,hpux,hpux64,"
	echo "                 linux,linuxamd64,win32,win64,winamd64"
	echo "             Or you can use node specification below:"
	echo "                 <usr name>@<machine name>"
	echo "                 ex.) regrrk1@stiahp4"
	echo "  <ver>:      Version number"
	echo "  <bld>:      Build number"
	echo "  <test>:     Test script name"
	echo "  disable:    Disable task."
	echo "  enable:     Enable task."
	echo "  -ap:        AP mode message."
	echo "  -pri <pri>: Priority level.0-9999"
	echo "  -o <opt>:   Task options."
	echo "  -p <plat>:  The platforms for changing the task."
	echo " Note:You can use '-' on ver/bld/test for same mean as '*'."
	if [ $# -ne 0 ]; then
		echo ""
		echo "Example:"
		echo " 1) Change the priority of the "zola-120-agtpjlmain.sh" to 90."
		echo "   $ chgtsk.sh -m zola 120 agtpjlmain.sh -pri 90"
		echo " 2) Disable the task for zola 121 i18n_i.sh on ykono@ykono5."
		echo "   $ chgtsk.sh -d ykono@ykono5 zola 121 i18n_i.sh"
		echo " 3) Add refresh only task option."
		echo "   $ chgtsk.sh -o refresh[true] regrrk1@stiahp3 talleyrand 154 agtpjlmain.sh+serial+direct"
	fi
}

# Main start here
orgpar=$@
lstknd=$AP_TSKQUE
unset ver bld scr plat
pri=
opt=null
mod=
outfrm=norm
_sepch="	"

# Parse parameter
while [ $# -ne 0 ]; do
	case $1 in
		-help|-h)
			display_help with example
			exit 0
			;;
		-m|me|myself)
			plat=${node}
			;;
		-mp|myplat)
			plat=`get_platform.sh -l`
			;;
		`isplat $1`)
			plat=${1#-}
			;;
		-p)
			shift
			if [ $# -eq 0 ]; then
				echo "chgtsk.sh:-p option need second parameter for the platform."
				display_help
				exit 1
			fi
			plat=$1
			;;
		-ap)
			outfrm=apform
			_sepch="|"
			;;
		Disable|disable|-d)
			mod=Disable
			;;
		Enable|enable|-e)
			mod=Enable
			;;
		-pri)
			shift
			if [ $# -eq 0 ]; then
				echo "chgtsk.sh:-pri option need second parameter for a priority level."
				display_help
				exit 1
			fi
			pri=$1
			;;
		-o)
			shift
			if [ $# -eq 0 ]; then
				echo "chgtsk.sh:-o option need second parameter for the task option."
				display_help
				exit 1
			fi
			[ "$opt" = "null" ] && opt=$1 || opt="$opt $1"
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
				echo "chgtsk.sh:Too many parameters."
				echo "parameters: $orgpar"
				disp_help
				exit 2
			fi
			;;
	esac
	shift
done

# Check the required parameters are defined.
if [ -z "$ver" -o -z "$bld" -o -z "$scr" -o -z "$plat" ]; then
	echo "chgtsk.sh:Not enough parameters to change the task option."
	echo "Please define all <platfrom>, <ver>, <bld> and <test> parameters."
	echo "<plat>=$plat, <ver>=$ver, <bld>=$bld, <test>=$scr"
	echo ""
	display_help
	exit 1
fi

# Check the modifire commands.
if [ "$opt" = "null" -a -z "$mod" -a -z "$pri" ]; then
	echo "chgtsk.sh:There is no modification method."
	echo "Please difine 'enable', 'disable', -pri <pri> or '-o <opt>'."
	display_help
	exit 1
fi

[ "$ver" = "-" ] && ver="*"
[ "$bld" = "-" ] && bld="*"
[ "$scr" = "-" ] && scr="*"
[ "$plat" = "all" -o "$plat" = "-alll" ] && plat="*"

crr=`pwd`
cd $AP_TSKQUE
srchptn="*~${ver}~${bld}~*${scr}~${plat}.ts[kd]"

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

# Read Lock
trg=$AUTOPILOT/tsk/${lckkind}.read
pid=`lock.sh $trg $$ 2> /dev/null`
if [ $? -ne 0 ]; then
	echo "chgtsk.sh:Failed to lock $trg."
	cat $trg.lck | while read line; do
		echo " > $line"
	done
	exit 3
fi

# echo "Read Lock=$trg.lck"
# cat $trg.lck | while read line; do
# 	echo " # $line"
# done

# Parse lock
prs=$AUTOPILOT/tsk/${lckkind}.parse
pid=`lock.sh $prs $$ 2> /dev/null`
if [ $? -ne 0 ]; then
	echo "chgtsk.sh:Failed to lock $prs."
	cat $prs.lck | while read line; do
		echo " > $line"
	done
	unlock.sh $trg
	exit 4
fi

# echo "Parse Lock=$prs.lck"
# cat $prs.lck | while read line; do
# 	echo " # $line"
# done

if [ -n "$pri" ]; then
	pri="000${pri}"
	pri=${pri#${pri%????}}
fi

if [ "$outfrm" = "norm" ]; then
	echo "Change ver=$ver, bld=$bld, test=$scr on $plat tasks."
	echo "  with modify=$mod, pri=$pri, opt=$opt" 
fi
cnt=`ls ${srchptn} 2> /dev/null | wc -l`
ls ${srchptn} 2> /dev/null |
while read line; do
	unset msg
	if [ -n "$mod" -o -n "$pri" ]; then
		ext=${line##*.}
		basname=${line%.*}
		crrpri=${basname%%\~*}
		basname=${basname#*\~}
		if [ -n "$mod" ]; then
			[ "$mod" = "Disable" ] && ext="tsd" || ext="tsk"
			msg="\n  $mod task"
		fi
		if [ -z "$pri" ]; then
			newpri=$crrpri
		else
			newpri=$pri
			[ -z "$msg" ] \
				&& msg="\n  Priority:${crrpri}->${pri}" \
				|| msg="$msg\n  Priority:${crrpri}->${pri}"
		fi
		newname="${newpri}~${basname}.${ext}"
	else
		newname="$line"
	fi
	if [ "$opt" != "null" ]; then
		crrtsk=`head -1 $line`
		crropt=${crrtsk#*:*:*:}
		crrtsk=`echo $crrtsk | awk -F: '{print $1":"$2":"$3}'`
		prsby=`head -2 $line | tail -1`
		rm -rf $line
		echo "${crrtsk}:${opt}" > "$newname"
		echo $prfby >> "$newname"
		chmod 777 $newname 2> /dev/null
		[ -z "$opt" ] && opt="(Erase options)"
		[ -z "$msg" ] && msg="\n  New task option:${opt}" \
			|| msg="$msg\n  New task option:${opt}"
	else
		mv "$line" "$newname" 2> /dev/null
	fi
	[ "$outfrm" = "norm" ] \
		&& echo "Change:${line}${msg}" | sed -e "s/~/${_sepch}/g" -e "s/.ts[kd]//g" 
done
unlock.sh $prs
unlock.sh $trg

let cnt="$cnt + 0"
if [ "$outfrm" = "norm" ]; then
	if [ $cnt -eq 0 ]; then
		echo "No task modified."
	elif [ $cnt -eq 1 ]; then
		echo "Modified one task."
	else
		echo "Modified ${cnt} tasks."
	fi
else
	echo "true"
fi
exit 0
