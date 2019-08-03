#!/usr/bin/ksh
# resdmp.sh : Dump result
# Description:
#   This command dump the result for the specific version, build and platform.
# Syntax:
#   resdmp.sh [-h|-t <tsk>] <ver> <bld> [<plat>...]
# Parameters:
#   <ver>  : Version
#   <bld>  : Build
#   <plat> : Platform. When skip this parameter, use current platform.
#
# History:
# 2012/09/23 YKono	First edition

. apinc.sh

unset set_vardef
set_vardef AP_TSKFLD
me=$0
orgpar=$@
plats=
ver=
bld=
tskf=
dbg=false
while [ $# -ne 0 ]; do
	case $1 in
		-d)
			dbg=true
			;;
		-h)
			display_help.sh $me
			exit 0
			;;
		-t|-tsk|-f)
			if [ $# -lt 2 ]; then
				echo "${me##*/}:'$1' need a second parameter as a task definition file."
				exit 1
			fi
			shift
			tskf=$1
			;;
		`isplat $1`)
			[ -z "$plats" ] && plats=$1 || plats="$plats $1"
			;;
		t=*|tsk=*|f=*)
			tskf=${1#*=}
			;;
		-o)
			if [ $# -lt 2 ]; then
				echo "${me##*/}:'-o' need a second parameter as a task option."
				exit 1
			fi
			shift
			[ -z "$_OPTION" ] && export _OPTION=$1 || export _OPTION="$_OPTION $1"
			;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			elif [ -z "$bld" ]; then
				bld=$1
			else
				echo "${me##*/}:Too many parameter."
				echo "  par=$orgpar"
				exit 1
			fi
			;;
	esac
	shift
done

if [ -z "$ver" -o -z "bld" ]; then
	echo "${me##*/}:Need both <ver> and <bld> parameter."
	echo "  par=$orgpar"
	echo "  ver=$ver"
	echo "  bld=$bld"
	exit 1
fi
tag=`chk_para.sh tag "$_OPTION"`
export tag=${tag##* }
[ "$dbg" = "true" ] && echo "### _OPTION=$_OPTION"
[ "$dbg" = "true" ] && echo "### tag=$tag"

resfld=essbase
if [ ! -d "$AUTOPILOT/../$ver/$resfld" ]; then
	echo "${me##*/}:There is no \$AUTOPILOT/../$ver/$resfld folder."
	exit 2
fi

[ -z "$plats" ] && plats=`get_platform.sh`
echo "$ver $bld"
tsktmp=$HOME/resdmp.${LOGNAME}@$(hostname).tsk.tmp
for plat in $plats; do
	# Decide the task file and create temp script list file
	rm -rf $tsktmp 2> /dev/null
	tf=
	if [ -z "$tskf" ]; then
		if [ "$AP_NOPLAT" = "false" -a -f "$AP_TSKFLD/${plat}.tsk" ]; then
			[ "$dbg" = "true" ] && echo "# Check $AP_TSKFLD/${plat}.tsk"
			a=`grep "^${ver}" $AP_TSKFLD/${plat}.tsk`
			if [ -n "$a" ]; then
				[ "$dbg" = "true" ] && echo "# - Found ${ver} in ${plat}.tsk"
				grep "^${ver}" $AP_TSKFLD/${plat}.tsk | grep -v "^#" \
					| grep -v "^$" | awk -F: '{print $3}' > $tsktmp
				tf=$tsktmp
			else
				[ "$dbg" = "true" ] && echo "# - Not found ${ver} in ${plat}.tsk"
			fi
		else
			[ "$dbg" = "true" ] && echo "# tskf not defined but not use ${plat}.tsk (AP_NOPLAT=$AP_NOPLAT)"
		fi
	else
		[ "$dbg" = "true" ] && echo "# tskf=$tskf"
		[ "${tskf#*/}" = "$tskf" ] && tskf="$AP_TSKFLD/$tskf"
		[ -f "$tskf" ] && tf=$tskf
		[ "$dbg" = "true" ] && echo "# > tskf=$tskf"
	fi
	if [ -z "$tf" ]; then
		cmpv="011001002002101"
		[ -z "$vern" ] && vern=`ver_vernum.sh $ver`
		[ "$dbg" = "true" ] && echo "# Check version $vern and $cmpv"
		if [ `cmpstr $vern $cmpv` = "<" ]; then
			tf=$AUTOPILOT/tsk/reg.tsk
		else
			tf=$AUTOPILOT/tsk/new.tsk
		fi
		[ "$dbg" = "true" ] && echo "# > tf=$tf"
	fi
	if [ "$tf" != "$tsktmp" ]; then
		cat $tf 2> /dev/null | grep -v "^#" | grep -v "^$" | awk -F: '{print $1}' > $tsktmp
	fi
	n=${#plat}
	let n=n+8
	s=
	i=0
	while [ $i -lt $n ]; do
		s="${s}#"
		let i=i+1
	done
	echo $s
	echo "### $plat ###"
	echo $s
	[ "$dbg" = "true" ] && (IFS=; echo "# $tsktmp #"; cat $tsktmp 2> /dev/null | while read line; do echo "# > $line"; done)
	cat $tsktmp 2> /dev/null | while read line; do
		abbr=`cat $AP_DEF_SHABBR | grep "^$line:" | awk -F: '{print $2}'`
		if [ -z "$abbr" ]; then
			[ "$line" = "${line#* }" ] && abbr=${line%.*} \
				|| abbr="${line%.*}_`echo ${line#* } | sed -e s/\ /_/g`"
		fi
		scr=`echo "$line" | sed -e s/\ /_/g`
		scr2=`echo "$line" | sed -e s/\ /+/g`
		running=
		[ "$dbg" = "true" ] && echo "# $line|_=$scr|+=$scr2|$abbr"
		if [ -f "$AUTOPILOT/que/crr/${ver}~${bld}~${scr2}~${plat}.tsk" ]; then
			node=`grep "^On:" $AUTOPILOT/que/crr/${ver}~${bld}~${scr2}~${plat}.tsk`
			node=`echo "${node#*:}" | tr -d '\r'`
			if [ -n "$node" ]; then
				svnode="${node#*@}_${node%@*}"
				lock_ping.sh $AUTOPILOT/lck/$node.ap
				sts=$?
				if [ $sts -eq 0 ]; then
					running="Running on $node"
					if [ -f "$AUTOPILOT/mon/$svnode.crr" ]; then
						a=`cat $AUTOPILOT/mon/$svnode.crr 2> /dev/null`
						if [ -n "$a" ]; then
							suc=`echo $a | awk -F~ '{print $9}'`
							dif=`echo $a | awk -F~ '{print $10}'`
							running="$running($suc/$dif)"
						fi
					fi
				else
					running="Status said \"Running on $node\" but $node doesn't respond to lock_ping.sh."
				fi
			fi
		fi
		[ "$dbg" = "true" ] && echo "#   running=$running"
		if [ -n "$running" ]; then
			echo "$abbr:$running"
		else
			a=`egrep "^${bld}${tag}[ |]${plat}[ |]ignore[ |]$scr" \
				$AUTOPILOT/../$ver/$resfld/res.rec 2> /dev/null \
				| tail -1 | sed -e s/\ /\|/g`
			[ "$dbg" = "true" ] && echo "# ignore_rec($tag)=$a"
			if [ -z "$a" ]; then
				a=`egrep "^${bld}${tag}[ |]${plat}[ |]error[ |]$scr" \
					$AUTOPILOT/../$ver/$resfld/res.rec 2> /dev/null \
					| tail -1 | \
					sed -e s/\ /\|/g`
				[ "$dbg" = "true" ] && echo "# error_rec=$a"
				if [ -n "$a" ]; then
					err=`echo $a | awk -F\| '{print $6}'`
					rtf=`echo $a | awk -F\| '{print $7}'`
					h=`grep "Machine" $AUTOPILOT/../${ver}/$resfld/$rtf \
						2> /dev/null | head -1`
					u=`grep "User" $AUTOPILOT/../${ver}/$resfld/$rtf \
						2> /dev/null | head -1`
					echo "$abbr:ERR($err) on ${u}@${h}"
				else
					echo "$abbr:"
				fi
			else
				suc=`echo $a | awk -F\| '{print $5}'`
				dif=`echo $a | awk -F\| '{print $6}'`
				rtf=`echo $a | awk -F\| '{print $7}'`
				echo "$abbr:$suc/$dif"
				if [ "$dif" -ne 0 ]; then
					stl=`grep -n "Listing all the diff files:" $AUTOPILOT/../$ver/$resfld/$rtf`
					edl=`grep -n "Predefined variables:" $AUTOPILOT/../$ver/$resfld/$rtf`
					stl=${stl%%:*}
					edl=${edl%%:*}
					let stl=edl-stl-3
					let edl=edl-2
					head -$edl $AUTOPILOT/../$ver/$resfld/$rtf 2> /dev/null \
						| tail -$stl | tr -d '\r' | while read onedif; do
						(IFS=; echo "	$onedif")
					done
				fi
			fi
		fi
	done
done

rm -rf $tsktmp 2> /dev/null
