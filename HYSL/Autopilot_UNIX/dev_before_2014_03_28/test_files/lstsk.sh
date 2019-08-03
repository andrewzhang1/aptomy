#~/usr/bin/ksh

# lstsk.sh : Task list command
#
# History:
# 06/29/2009 YKono - Refine with Yuki's request
# 05/17/2010 YKono - Add script order record.

display_help()
{
cat << ENDHELP
List tasks in the task queue or done/current buffer.
Syntax:
  lstsk.sh [que|crr|done] [-h|-l|-o|-ap|-m|-mp|-count] 
           [<plat>|<node>] [<ver> [<bld> [<scr>]]]
Parameters:
  <plat> : Display platform.
           win, win64, winamd64, aix, aix64, solaris, solaris64, hpux, hpux64,
           linux, linux64 and all or -a.
  <node> : Display specifc node. <user>@<hostname>.
           Note: When you skip <plat> or <node> parameter, this command uses
                 "<crr-user>@<crr-machine> <crr-platform>" for the target.
  <ver>  : Listed versin number. You can use '-' for all versions.
  <bld>  : Listed build number. You can use '-' for all builds.
  <scr>  : Listed script name. You can use '-' for all scripts.
  que    : List waiting tasks in the task queue.(Default)
  crr    : List currently executing tasks.
  done   : List done tasks.
Options:
  -h     : Display help.
  -o     : Display script order.
  -l     : Display task options.
  -ap    : Display AP format.
  -m     : Current node.
  -mp    : Current platform.
  -count : Display count only.
  -p <plats> : Define listed platforms or nodes.
ENDHELP
}


	. apinc.sh

ord=
lng=
[ "$AP_NOPLAT" = "false" ] && plats="${node} ${plat}" || plats=${node}
ver=
bld=
scr=
rev=
outfrm=norm
lstknd=$AP_TSKQUE

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
		-ap)
			outfrm=apform
			;;
		-a|all|-all)
			plats="*"
			;;
		-count)
			outfrm=count
			;;
		-help|-h)
			display_help
			exit 0
			;;
		-o)
			ord=true
			;;
		-l|opt)
			lng=true
			;;
		-m|me|myself)
			plats=${node}
			;;
		-mp|myplat)
			plats=${plat}
			;;
		win32|win64|winamd64|hpux64|hpux|aix64|aix|solaris64|solaris|linux64|linux|linuxamd64)
			plats=$1
			;;
		*@*)
			plats=$1
			;;
		-p)
			shift
			plats=$1
			;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			elif [ -z "$bld" ]; then
				bld=$1
			elif [ -z "$scr" ]; then
				scr=$1
			else
				echo "Too many parameters."
				display_help
				exit 2
			fi
			;;
	esac
	shift
done

plats=`echo "$plats" | sed -e "s/\// /g"`

if [ -z "$ver" -o "$ver" = "-" ] ; then  ver="*" ; fi
if [ -z "$bld" -o "$bld" = "-" ] ; then  bld="*" ; fi
if [ -z "$scr" -o "$scr" = "-" ] ; then  scr="*" ; fi

if [ "$outfrm" = "norm" ]; then
	_sepch="	"
	_dstr="Disable"
	_estr="Enable"
else
	_sepch="|"
	_dstr="d"
	_estr="e"
fi

sedcmd="${AUTOPILOT}/tmp/${node}.tsklst.sed.tmp"
rm -f "$sedcmd" 2> /dev/null
echo "s/+/ /g" >> $sedcmd
echo "s/~/${_sepch}/g" >> $sedcmd
echo "s/!/\\//g" >> $sedcmd
echo "s/\\^/:/g" >> $sedcmd

crr=`pwd`
cd "$lstknd"

if [ "$lstknd" = "$AP_TSKQUE" ]; then
	srchptn="*~${ver}~${bld}~*${scr}~"
	echo "s/\\.tsk/${_sepch}${_estr}/g" >> $sedcmd
	echo "s/\\.tsd/${_sepch}${_dstr}/g" >> $sedcmd
else
	srchptn="${ver}~${bld}~${scr}~"
	echo "s/\\.tsk//g" >> $sedcmd
fi
lcnt=0
while [ -n "$plats" ]; do
	part=${plats%% *}
	[ "$part" = "$plats" ] && unset plats || plats=${plats#* }
	if [ "$outfrm" != "count" ]; then
		ls ${srchptn}${part}.ts[kd] 2> /dev/null | while read line; do
			if [ "$lng" = "true" ]; then
				_opt=`head -1 $line | crfilter`
				_opt=${_sepch}${_opt#*:*:*:}
				if [ "$lstknd" != "$AP_TSKQUE" ]; then
					plt=`cat $line | grep "^On:" | crfilter`
					stt=`cat $line | grep "^Start:" | crfilter`
					edt=`cat $line | grep "^End:" | crfilter`
					sdc=`cat $line | grep "^Suc:" | crfilter`
					[ -n "$plt" ] && _opt="${_opt}${_sepch}${plt}"
					[ -n "$stt" ] && _opt="${_opt}${_sepch}${stt}"
					[ -n "$edt" ] && _opt="${_opt}${_sepch}${edt}"
					[ -n "$sdc" ] && _opt="${_opt}${_sepch}${sdc}"
					unset plt stt edt sdc
				fi
			else
				unset _opt
			fi
			if [ "$line" != "${line#*~*~*~*~*~}" ]; then
				if [ "$ord" = "true" ]; then
					tmp=${line%~*~*}
					tmp="${tmp}:${line#*~*~*~*~}"
				else
					tmp=${line%~*~*~*}
					tmp="${tmp}~${line#*~*~*~*~}"
				fi
				line=$tmp
			fi
			a=`echo ${line} | sed -f $sedcmd`
			echo "${a}${_opt}"
		done
	fi
	cnt=`ls ${srchptn}${part}.ts[kd] 2> /dev/null | wc -l`
	let lcnt="$lcnt + $cnt"
done
if [ "$outfrm" = "norm" ]; then
	if [ $lcnt -eq 0 ]; then
		echo "No tasks."
	elif [ $lcnt -eq 1 ]; then
		echo "One task."
	else
		echo "$lcnt tasks."
	fi
elif [ "$outfrm" = "count" ]; then
	echo $lcnt
fi
rm -f "$sedcmd" 2> /dev/null
cd "$crr"


