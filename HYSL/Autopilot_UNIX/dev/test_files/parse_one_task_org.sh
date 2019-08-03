#!/usr/bin/ksh
#######################################################################
# parse_one_task.sh : Parse one task and put it to queue
# SYNTAX:
# parse_one_task.sh <plat|node> <task string> <Source-str> [ <additional option> ]
# $1 = Task platform or node (<user>@<hostname>)
# $2 = Task define string <f-ver>:<m-bld>:<test>[:<task options>...]
# $3 = Source message which is added to task-queue file
# $4 = Additional task option.
# RETURN:
#  = 0 : Added task to the task queue.
#  = 1 : Parameter error.
#  = 2 : Failed to normalize build number from given ver# and bld#
#  = 3 : Already exist in the queue
#  = 4 : Running now
#  = 5 : Already done
#######################################################################
# History:
# 04/08/2008 YKono - First edition
# 05/17/2010 YKono - Add offset parameter to create script priority in the task list
# 06/16/2010 YKono - Add history writing.
# 07/14/2010 YKono - Add check a result of the CM acceptance
# 07/28/2010 YKono - If the build is latest and validation of it failed, skip to add.
#                    If the validation of build number failed, but it is Essbase build
#                    number, this script focebly put task for adding specific build
#                    which already installed but not in the pre_rel location.
#                    But that change caused <ver>_latest.tsk file. This change fix it.
# 08/04/2010 YKono - Check build number error and if it is CM Failure, add the CMFAIL
#                    record into .wsp2 file.

. apinc.sh

#######################################################################
# Subs
#######################################################################

#######################################################################
# Display help

display_help()
{
#          0         1         2         3         4         5         6         7
#          01234567890123456789012345678901234567890123456789012345678901234567890123456789
	echo "parse_one_task.sh [<options>] <plnd> <tskstr> <message> [ <addopt>... ]"
	echo " <options> = order=<order> | -d"
	echo "   order=  : Script order.Use <order> as a script order."
	echo "   -d      : Add this task as disable."
	echo " <plnd>    : Platform or node definition."
	echo "  platform : solaris, solaris64, solaris.x64, aix, aix64..."
	echo "      node : ${LOGNAME}@$(HOSTNAME), regrrk1@stiahp3, regrhv@emc-sun2..."
	echo " <tskstr>  : Task definition string like below format:"
	echo "             <version>:<build>:<test name>[:<tsktopt>...]"
	echo " <message> : Task explanation."
	echo " <addopt>  : Additional task option."
}

#######################################################################
# Write to wsp2 file.
wrtwsp2()
{
	########################################################################
	# Decide result save location
	ver=${ver##*/}
	RESLOC="$AP_DEF_RESLOC"
	if [ -n "$AP_RESFOLDER" ]; then
		RESDIR=$ver/$AP_RESFOLDER
	else
		_i18n=`echo $tst | grep ^i18n_`
		if ( test -n "$_i18n" -o -n "$AP_I18N" )
		then
			RESDIR=$ver/i18n/essbase
		elif ( test "$tst" = "xprobmain.sh" )
		then
			RESDIR=$ver/i18n/essbase
		else
			RESDIR=$ver/essbase
		fi
	fi
	[ -d "$RESLOC/$RESDIR" ] || mkddir.sh "$RESLOC/$RESDIR"

	########################################################################
	# Add record to results.wsp2
	testnametmp=`echo $tst | sed -e "s/ /_/g"`
	TAG=`chk_para.sh tag "$_OPTION"`
	echo "${bld}${TAG} $(get_platform.sh) error $testnametmp ERR CMFAIL no_rtf - - $pri" \
		 >> "$RESLOC/$RESDIR/results.wsp2"
	chmod 666 $RESLOC/$RESDIR/results.wsp2
	echo "${bld}${TAG} $(get_platform.sh) error $testnametmp ERR CMFAIL no_rtf - - $pri" \
		 >> "$RESLOC/$RESDIR/res.rec"
	chmod 666 $RESLOC/$RESDIR/res.rec > /dev/null 2>&1
	unset testnametmp
}

#######################################################################
### Main
#######################################################################

allpara=$@
unset plnd str msg addopt ofscnt
mode="tsk"
ofscnt=
while [ $# -ne 0 ]; do
	case $1 in
		order=*)
			ofscnt=${1#order=}
			;;
		-h)
			display_help
			exit 0
			;;
		-d)
			mode="tsd"
			;;
		*)
			if [ -z "$plnd" ]; then
				plnd=$1
			elif [ -z "$str" ]; then
				str=${1%%#*}
			elif [ -z "$msg" ]; then
				msg=$1
			else
				[ -z "$addopt" ] && addopt=$1 || addopt="$addopt $1"
			fi
			;;
	esac
	shift
done


if [ -z "$plnd" -o -z "$str" ]; then
	echo "Null platform($plnd) or task definition string($str)."
	echo "params:$allpara"
	display_help
	exit 2
fi

str=`echo $str | sed -e "s/+/ /g"`
ver=`echo $str | awk -F: '{print $1}' | sed -e "s/!/\//g"`
bld=`echo $str | awk -F: '{print $2}'`
tst=`echo $str | awk -F: '{print $3}'`
opt=`echo ${str#*:*:*:} | crfilter`
[ "$opt" = "$str" ] && opt=
if [ -n "$addopt" ]; then
	[ -z "$opt" ] && opt="$addopt" || opt="$opt $addopt"
fi
icm=`chk_para.sh ignCM "$opt"`
icm=${icm##* }
[ "$icm" = "true" ] && icm="-icm" || icm=
pri=`chk_para.sh priority "$opt"`
pri=${pri##* }
igndone=`chk_para.sh igndone "$opt"`
igndone=${igndone## *}
ofs=`chk_para.sh order "$opt"`
[ -n "$ofs" ] && ofscnt=${ofs##* }
obld=$bld
case $plnd in
	win32|wina64|winamd64|hpux|hpux64|aix|aix64|solaris|solaris64|solaris.x64|linux|linuxamd64|linux64)
		bld=`normbld.sh $icm -w $ver $bld -p $plnd`;;
	*)
		bld=`normbld.sh $icm -w $ver $bld`;;
esac
if [ $? -ne 0 ]; then
	sts=$?
	# 1 Parameter error
	# 2 No BUILD_ROOT
	# 3 No HIT_ROOT
	# 4 Invalid build number. No build folder under pre_rel
	#   #BLD
	#   No build folder($ver/$bld/$plat) in pre_rel.
	# 5 Failed CM acceptance.
	#   #BLD
	#   CM Acceptance was failed for $ver/$bld/$plat.
	echo "parse_one_task.sh(bld=$obld) : $bld"
	### When the build is pre_rel build,
	### but got CM error from pre_rel, it forcebly
	### store task. Beacuse, refresh command may
	### works well.
	if [ $sts -eq 5 ]; then
		bld=${bld#*/}
		bld=${bld%/*}
		wrtwsp2
		exit 2
	fi
	bld=`chk_para.sh hit "$obld"`
	if [ -z "$bld" ]; then
		bld=${obld#hit_}
		if [ "$bld" = "obld" ]; then
			unset bld
		fi
	fi
	if [ -z "$bld" -a "$obld" != "latest" ]; then
		bld=$obld
	else
		exit 2
	fi
fi
hit=${bld#*_}
[ "$hit" = "$bld" ] && unset hit
bld=${bld%%_*}
[ -z "$hit" ] && tsk="${ver}:${bld}:${tst}:${opt}" \
	|| tsk="${ver}:hit(${hit}):${tst}:${opt}"
tst=`echo $tst | sed -e "s/\^/:/g"`
[ "$bld" != "$obld" ] \
	&& dtsk="${plnd}:${ver}:${obld}/${bld}:${tst}" \
	|| dtsk="${plnd}:${ver}:${bld}:${tst}"
[ -z "$pri" ] && pri=100 || let pri="$pri * 10"
pri="000${pri}"
pri=${pri#${pri%????}}
if [ -n "$ofscnt" ]; then
	ofscnt="000${ofscnt}"
	ofscnt="${ofscnt#${ofscnt%???}}~"
fi
tst=`echo $tst | sed -e "s/ /+/g" -e "s/:/\^/g"`
ver=`echo $ver | sed -e "s/\//!/g"`
tskname="${pri}~${ver}~${bld}~${ofscnt}${tst}~${plnd}.${mode}"
donename="${ver}~${bld}~${tst}~${plnd}.tsk"
tskmask="*~${ver}~${bld}~*${tst}~${plnd}.ts[dk]"

# echo "# tst=$tst"
##  echo "# ver=$ver"
# echo "# tskname=$tskname"
# echo "# donename=$donename"
# echo "# tskmask=$tskmask"
# echo "# AP_TSKQUE=$AP_TSKQUE"
cd $AP_TSKQUE
if [ "$pri" = "9990" ]; then
	# Case of time-consuming task
	tskmask="9990~${ver}~*~*${tst}~${plnd}.ts[dk]"
	tmp=`ls ${tskmask} 2> /dev/null`
	if [ -n "$tmp" ]; then
		for one in $tmp; do
			echo "Remove $one."
			rm -rf $one 2> /dev/null
		done
	fi
else
	tmp=`ls ${tskmask} 2> /dev/null | grep -v "^9990~"`
	if [ -n "$tmp" ]; then
		if [ "$tmp" != "$tskname" ]; then
			echo "task <$dtsk> for ${plnd} already exist with different priority level. Change the priority level."
			rm -f "$tmp" 2> /dev/null
		else
			echo "task <$dtsk> for ${plnd} already exist."
			putque=false
			exit 3
		fi
	fi
fi

if [ "$igndone" != "true" -a -f "$AP_CRRTSK/${donename}" ]; then
	nm=`grep "^On:" "$AP_CRRTSK/${donename}" | sed -e "s/On://g"`
	[ -z "$nm" ] && nm="another platform"
	echo "task <$dtsk> is running now on $nm."
	exit 4
fi

if [ "$igndone" != "true" -a -f "$AP_TSKDONE/${donename}" ]; then
	nm=`grep "^On:" "$AP_TSKDONE/${donename}" | sed -e "s/On://g" | crfilter`
	[ -z "$nm" ] && nm="another platform"
# echo "allpara=$allpara"
# echo "igndone=$igndone"
# echo "dtsk=\"$dtsk\""
	echo "task <$dtsk> is already done by $nm."
	exit 5
fi

if [ "$obld" != "$bld" ]; then
	if [ -z "$hit" ]; then
		obld=" $obld/$bld"
	else
		obld=" $obld/hit($hit)/$bld"
	fi
else
	unset obld
fi

cd $AP_TSKQUE
# echo "AP_TSKQUE : `pwd`"
while [ 1 ]; do
	rm -f $tskname 2> /dev/null
	echo $tsk > "$tskname"
	echo "Parsed by ${node} at `date '+%D_%T'` ${msg}${obld}" >> "$tskname"
	chmod 777 $tskname > /dev/null 2>&1
	lc=`cat $tskname | wc -l`
	let lc=lc+0
	if [ $lc -eq 2 ]; then
		break
	fi
done
echo "## Store $dtsk"

echo "`date +%D_%T` $LOGNAME@$(hostname) : ADD TASK $tskname." >> $aphis
exit 0
