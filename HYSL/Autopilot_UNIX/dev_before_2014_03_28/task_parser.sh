#!/usr/bin/ksh
# task_parser.sh : Task parser for autopilot framework.
# 
# Description:
# This script parse *.tsk file and deploy each task into the queue folder.
# Task file should be located in $AUTOPILOT/tsk folder with following name:
#   User specific task file = ${LOGNAME}.tsk
#   Platform specific task file = ${`get_platform.sh`}.tsk (win32, win64...)
#   All platform task file = all.tsk
# This scrit read those files and create execute-task file under the
# $AUTOPILOT/que folder with following name format:
#   <priority>~<verion>~<build>~<test>~<plat|node>.tsk
# When create execute-task file, this script check the target task alreadu done or
# currently executing. If target task has igndone(true) option, it doesn't mind that
# that task already done or not. Those checks reference following folder:
#   Done task = $AUTOPILOT/que/done
#   Current task = $AUTOPILOT/que/crr
# Note: if there is same task in the current executing task, this script update the
# priority level of current execution to new priority in the task file.
# Reference:
# get_platform.sh	
# get_latest.sh		
# chk_para.sh		
# get_elapsetime.sh	# to get the elapse time for the platform or all task file.
# Queue file name format:
# <priority>~<verion>~<build>~<test>~<plat|node>.tsk
# <priority>	4 digits numeric. Priority level multipled by 10. i.e. priority(15) -> 0150
# <version>		Version string like "kennedy", "9.3.1.2.0"...
# <build>		Build number. When use "latest" in the task file, 
#				it will be expanded to the current latest number.
# <test>		Test script name. If a test script name has a space like 
#				"agtpjlmain.sh serial direct", a space is replaced with "+".
# <plat|node>	Platform name or node name like <user>@<machin name>. i.e. ykono@stsun12

# History:
# 04/04/2008 YKono - First edition
# 04/22/2008 YKono - Add parser information into task file.
# 05/28/2008 YKono - Add HIT build version
# 08/06/2008 YKono - Use parse_one_task.sh
# 04/09/2009 YKono - Add task order priority
# 07/06/2009 YKono - Use new read & parse lock logic.
# 05/17/2010 YKono - Remove AP_TSKORDER and implement force order.
# 08/04/2010 YKono Change task lock file location from tsk fodler to lck folder.
# 05/15/2013 YKono BUG 16571195 - PUT TASK FILES IN CLEARCASE
# 07/23/2013 YKono BUG 16356202 - ALLPLATFORMS.TSK
# 09/12/2013 YKono Bug 17438148 - CHANGE TASK PARSING TIME TO 05:00 FROM 10:00

. apinc.sh
set_vardef=
set_vardef AP_TSKFLD

##############################################
# FUNCTIONS

# Write condition to RSP file.
wrtrsp() # wrtrsp <err> <msg> <tsk>
{
	s=$3
	ver=${s%%:*}; s=${s#*:}
	bld=${s%%:*}; s=${s#*:}
	tst=${s%%:*}; s=${s#*:}
	resloc=`get_resloc.sh $ver $bld $tst -o "$s"`
	tag=${resloc##*:}; resloc=${resloc%:*}
	reltag=${resloc##*:}; resloc=${resloc%:*}
	rtf=${resloc##*:}; resloc=${resloc%:*}
	(
		echo "$1:$2"
		echo ""
		echo "  Machine : $(hostname)($plat)"
		echo "  User    : $LOGNAME"
		echo "  Version : $ver"
		echo "  Build   : $bld"
		echo "  Test    : $tst"
		echo "  AP ver  : $(apver.sh -sv)"
		echo "  CrrDate : $(date +%Y/%m/%d_%T)"
		echo ""
		if [ "$1" != "OLD_BLD" ]; then
			rplat=`realplat.sh $plat`
			cmtxt=$BUILD_ROOT/$ver/$bld/$logs/essbase_${rplat}.txt
			if [ -f "$cmtxt" ]; then
				echo "### ${cmtxt#${cmtxt%/*/*/*/*}} ###"
				cat $cmtxt
				echo ""
			fi
		fi
	) > $resloc/$rtf
	# Add record to results.wsp2
	testnametmp=`echo $tst | sed -e "s/ /_/g"`
	if [ "$1" = "OLD_BLD" ]; then
		rec="${bld}${tag} $plat error $testnametmp OLD BLD $rtf - - 0100"
	else
		rec="${bld}${tag} $plat error $testnametmp CM $1 $rtf - - 0100"
	fi
	echo $rec >> $resloc/res.rec
	echo $rec >> $resloc/results.wsp2
}

# chk_schedule $opt
chk_schedule()
{
	ret=false
	schdls=`chk_para.sh schedule "${1#*:*:*:}" | tr -d '\r'`
	if [ -n "$schdls" ]; then
		for schdl in $schdls; do
			case $schdl in
				$today|$wkday|$day|$nthwk|$biwk)
					ret=true
					break
					;;
			esac
		done
	else
		ret=true
	fi
	echo $ret
}

#############################################
# Read parameter
silent=false
vers=
ign=false
while [ $# -ne 0 ]; do
	case $1 in
		-silent)	silent=true;;
		-i)	ign=true;;
		*)	vers="$vers $1";;
	esac
	shift
done
#############################################
# MAIN START
if [ "$LANG" != "C" ]; then
	lang_save=$LANG 2> /dev/null
	export LANG=C
fi
plat=`get_platform.sh -l`
today=`date "+%m/%d/%Y"`
wkday=`date +%a`
day=`date +%d`
nthwk=`expr \`date +%e\` / 7 + 1``date +%a`
biwk=`date +%U`
biwk=`date +%a``expr 1${biwk} % 2`
[ -n "$lang_save" ] && export LANG=$lang_save 2> /dev/null
echo "## $today, `date +%T`, $wkday, $day, $nthwk, $biwk"
# Today = MM/DD/YY > 09/23/12
# Wkday = Wkd > Mon, Tue, ...
# Day   = DD > 01, 02, 23, ...
# Nthwk = #Wkd > 1Mon, 2Tue, 4Fri, ...
# Biwkd = Wkd# > Mon0, Mon1, Tue0, Tue1, ...
[ -n "$AP_TSKFILE" ] && mytsk="$AP_TSKFILE" || mytsk=${LOGNAME}.tsk
plattsk=${plat}.tsk
alltsk=all.tsk
tsktmpf=$HOME/.${node}_task_parser_$$.tmp
rm -rf $tsktmpf
unset nodelck platlck

cnt=300
if [ -f "$AP_TSKFLD/$mytsk" ]; then
	wcnt=0
	while [ $wcnt -lt 10 ]; do
		_pid=`lock.sh $AUTOPILOT/lck/${node}.read $$`
		[ $? -eq 0 ] && break
		let wcnt=wcnt+1
		sleep 1
	done
	if [ "$wcnt" -ne 10 ]; then
		wcnt=0
		while [ $wcnt -lt 10 ]; do
			_pid=`lock.sh $AUTOPILOT/lck/${node}.parse $$`
			[ $? -eq 0 ] && break
			let wcnt=wcnt+1
			sleep 1
		done
		if [ "$wcnt" -ne 10 ]; then
			nodelck=true
			fn=`basename "$mytsk"`
			cat $AP_TSKFLD/$mytsk 2> /dev/null | grep "^${node}:" | sed -e "s/^[^:]*://g" | tr -d '\r' | \
			while read line; do
				if [ -n "$line" -a `chk_schedule "$line"` = "true" ]; then
					ord=`chk_para.sh ord "${1#*:*:*:}"`
					[ -z "$ord" ] && ord=`chk_para.sh order "${1#*:*:*:}"`
					[ -n "$ord" ] && ord=${ord##* } || ord=$cnt
					echo "$node $ord $fn $line" >> $tsktmpf
					let cnt=cnt+1
				fi
			done
			cat $AP_TSKFLD/$mytsk | grep "^$thishost:" | sed -e "s/^[^:]*://g" | tr -d '\r' | \
			while read line; do
				if [ -n "$line" -a `chk_schedule "$line"` = "true" ]; then
					ord=`chk_para.sh ord "${1#*:*:*:}"`
					[ -z "$ord" ] && ord=`chk_para.sh order "${1#*:*:*:}"`
					[ -n "$ord" ] && ord=${ord##* } || ord=$cnt
					echo "$thishost $ord $fn $line" >> $tsktmpf
					let cnt=cnt+1
				fi
			done
		else
			[ "$silent" != "true" ] && echo "## Failed to lock the ${node}.parse."
			unlock.sh $AUTOPILOT/lck/${node}.read > /dev/null 2>&1
		fi
	else
		[ "$silent" != "true" ] && echo "## Failed to lock the ${node}.read."
	fi
fi

if [ "$AP_NOPLAT" = "false" ]; then
	wcnt=0
	while [ $wcnt -lt 10 ]; do
		_pid=`lock.sh $AUTOPILOT/lck/${plat}.read $$`
		[ $? -eq 0 ] && break
		let wcnt=wcnt+1
		sleep 1
	done
	if [ "$wcnt" -ne 10 ]; then
		wcnt=0
		while [ $wcnt -lt 10 ]; do
			_pid=`lock.sh $AUTOPILOT/lck/${plat}.parse $$`
			[ $? -eq 0 ] && break
			let wcnt=wcnt+1
			sleep 1
		done
		if [ $wcnt -ne 10 ]; then
			 platlck=true
		else
			if [ "$silent" != "true" ]; then
				echo "## Someone is locking ${plat}.parse."
				echo "## Skip parsing ${plat}.parse."
				cat $AUTOPILOT/lck/${plat}.parse.lck 2> /dev/null | while read line; do echo "## > $line"; done
			fi
			unlock.sh $AUTOPILOT/lck/${plat}.read > /dev/null 2>&1
		fi
	else
		[ "$silent" != "true" ] && echo "## Failed to lock the ${plat}.read"
	fi
	if [ "$platlck" = "true" ]; then
		if [ -f "$AP_TSKFLD/$plattsk" ]; then
			fn=`basename "$AP_TSKFLD/$plattsk"`
			cat "$AP_TSKFLD/$plattsk" 2> /dev/null | tr -d '\r' | grep -v "^#" | grep -v "^$" | \
			while read line; do
				if [ -n "$line" -a `chk_schedule "$line"` = "true" ]; then
					ord=`chk_para.sh ord "${1#*:*:*:}"`
					[ -z "$ord" ] && ord=`chk_para.sh order "${1#*:*:*:}"`
					[ -n "$ord" ] && ord=${ord##* } || ord=$cnt
					echo "$plat $ord $fn $line" >> $tsktmpf
					let cnt=cnt+1
				fi
			done
		fi
		if [ -f "$AP_TSKFLD/$alltsk" ]; then
			fn=`basename $alltsk`
			cat "$AP_TSKFLD/$alltsk" 2> /dev/null | tr -d '\r' | grep -v "^#" | grep -v "^$" | \
			while read line; do
				if [ -n "$line" -a `chk_schedule "$line"` = "true" ]; then
					ord=`chk_para.sh ord "${1#*:*:*:}"`
					[ -z "$ord" ] && ord=`chk_para.sh order "${1#*:*:*:}"`
					[ -n "$ord" ] && ord=${ord##* } || ord=$cnt
					echo "$plat $ord $fn $line" >> $tsktmpf
					let cnt=cnt+1
				fi
			done
		fi
	fi
fi
if [ -s "$tsktmpf" ]; then
	cat $tsktmpf 2> /dev/null | while read np ord tf line; do
		add=true
		if [ -n "$vers" ]; then
			if [ "$ign" = "true" ]; then
				add=`echo $vers | grep ${line%%:*}`
				[ -n "$add" ] && add=false || add=true
			else
				add=`echo $vers | grep ${line%%:*}`
				[ -n "$add" ] && add=true || add=false
			fi
		fi
		_ver=${line%%:*}
		s=${line#*:}
		_bld=${s%%:*}
		err=
		if [ "$add" = "true" -a "$_bld" = "latest" ]; then
			vn=`echo ${_ver##*/} | sed -e "s/\./_/g"`
			vn="latest_$vn"
			val=`eval echo \\$${vn}`
			if [ -n "$val" ]; then
				if [ "$val" = "error" ]; then
					add=false
				elif [ "$val" != "${val#!}" ]; then
					val=${val#!}; lbld=${val%%!*}
					val=${val#*!}; err=${val%%!*}
					msg=${val#*!}
					if [ "$err" != "OLD_BLD" -a "$err" != "opck_fail" ]; then
						wrtrsp "$err" "$msg" "${_ver}:${lbld}:${line#*:*:}"
						add=false
					else
						line="${_ver}:${lbld}:${line#*:*:}"
					fi
				else
					line="${_ver}:$val:${line#*:*:}"
				fi
			else
				lbld=`get_goodlatest.sh $_ver`
				sts=$?
				if [ $sts -ne 0 ]; then
					today=`date +%Y%m%d`
					export $vn="error"	
					add=false
					if [ ! -f "$AUTOPILOT/mon/rottenver_${_ver##*/}_${today}.rec" ]; then
						# rottenver_${_ver##*/}_`date +%Y%m%d`.rec
						(
							export VERSION=${_ver}
							export RETCODE=$sts
							export MSG=$lbld
							send_email.sh ev:$AUTOPILOT/form/31_CM_failure.txt
						)
						echo "$lbld" > $AUTOPILOT/mon/rottenver_${_ver##*/}_${today}.rec
						keepnth.sh "$AUTOPILOT/mon/rottenver_${_ver##*/}_[0-9]+\.rec" 3
					fi
				else	
					allowrefresh=${lbld#* }; lbld=${lbld% *}
					export $vn=$lbld
					line="$_ver:$lbld:${line#*:*:}"
					bck=`ckbld.sh $_ver $lbld`
					sts=$?
					err=
					if [ "$sts" = 7 ]; then
						err="OLD_BLD"
						msg="Older build was added($bck)"
						sts=0
					elif [ "$sts" -ne 0 ]; then
						case $sts in
							1|2|3)	# No log folder or syntax error
								err="NOBLD"
								msg="No valid build for $_ver:$lbld $plat."
								;;
							4)	# Build failure
								err="BLD_FAIL"
								msg="Build failure($bck)"
								;;
							5)	# Acceptance failure
								err="ACCX_FAIL"
								msg="Acceptance failure($bck)"
								;;
							6)	# Opack failure
								err="OPCK_FAIL"
								msg="Opack failure($bck)"
								if [ "$allowrefresh" = "true" ]; then
									err="opck_fail"
									sts=0
								fi
								;;
							*)	;;
						esac
						if [ -n "$err" -a "$sts" -ne 0 ]; then
							wrtrsp "$err" "$msg" "${line}"
							export $vn="!${lbld}!${err}!${msg}"
						fi
					fi
					[ "$sts" -ne 0 ] && add=false
				fi
			fi
		fi
		if [ "$add" = "true" ]; then
			[ "$silent" = "true" ] \
			&& parse_one_task.sh $np "$line" "using $AP_TSKFLD/$tf from task_parser.sh" order=$ord > /dev/null \
			|| parse_one_task.sh $np "$line" "using $AP_TSKFLD/$tf from task_parser.sh" order=$ord
			if [ $? -eq 0 -a -n "$err" ]; then
				wrtrsp "$err" "$msg" "${line}"
				[ -z "$val" ] && export $vn="!${lbld}!${err}!${msg}"
				if [ "$err" = "OLD_BLD" -a ! -f "$AUTOPILOT/mon/rottenver_${plat}_${_ver##*/}_${lbld}.rec" ]; then
					(
						export ROTTENHOURS=${bck##* }
						bldtm=${bck#* }
						export BLDTIME=${bldtm% *}
						export VERSION=${_ver##*/}
						export BUILD=${lbld}
						send_email.sh ev:$AUTOPILOT/form/30_rotten_bld.txt
					)
					echo "$bck" > $AUTOPILOT/mon/rottenver_${plat}_${_ver##*/}_${lbld}.rec
					keepnth.sh "$AUTOPILOT/mon/rottenver_${plat}_${_ver##*/}_[0-9]+.rec" 3
				fi
			fi
		fi
	done
fi

[ -n "$platlck" ] && unlock.sh $AUTOPILOT/lck/${plat}.parse > /dev/null 2>&1
[ -n "$platlck" ] && unlock.sh $AUTOPILOT/lck/${plat}.read > /dev/null 2>&1
[ -n "$nodelck" ] && unlock.sh $AUTOPILOT/lck/${node}.parse > /dev/null 2>&1
[ -n "$nodelck" ] && unlock.sh $AUTOPILOT/lck/${node}.read > /dev/null 2>&1

rm -rf $tsktmpf

