#!/usr/bin/ksh
#########################################################################
# Filename:    recover_crrtsk.sh
# Author:      Yukio Kono
# Description: Recover current running task to the queue
# History ###############################################################
# 08/20/2010 YKono	First Edition

. apinc.sh

display_help()
{
	echo "recover_crrtsk.sh : Recover current running task to the queue"
	echo "Syntax:"
	echo "  recover_crrtsk.sh [-s|-h|-n <node>|-m <mess>]"
	echo "Options:"
	echo "  -s        : Recover current task as skipped task."
	echo "  -h        : Display help."
	echo "  -n <node> : target node."
	echo "  -m <mess> : Message."
	echo "Sample)"
	echo "  $ recover_crrtsk.sh"
	echo "  $ recover_crrtsk.sh -n regrrk1@stiahp3"
}

skiptsk=false
tarnode=${LOGNAME}@$(hostname)
msg="recover_crrtsk.sh"
while [ $# -ne 0 ]; do
	case $1 in
		-s|-skip|-skiptask)
			skiptsk=true
			;;
		-h|-help)
			display_help
			exit 0
			;;
		-n|-node|-tarnode)
			shift
			tarnode=$1
			;;
		*)
			;;
	esac
	shift
done

[ -z "$LOGNAME" -a `uname` = "Windows_NT" ] && export LOGNAME=$USERNAME
# Get current execution task
cd $AUTOPILOT/que/crr
grep "On:${tarnode}" *.tsk | while read one; do
	one=${one%%:*}
	fn=`head -3 $one | tail -1 | tr -d '\r'`
	if [ "$skiptsk" = "true" ]; then
		echo "Skipping $fn task."
	else
		echo "Recovering $fn task."
	fi
	cat $one | while read line; do
		echo "## $line"
	done
	if [ "$skiptsk" = "false" ]; then
		head -2 $one > $AUTOPILOT/que/${fn}
		echo "`date +%D_%T` $mynode:This task was recoverd by ${mess}." >> $AUTOPILOT/que/$fn
	else
		head -2 $one > $AUTOPILOT/que/${fn}.skipped
		echo "`date +%D_%T` $mynode:This task was skipped by ${mess}." >> $AUTOPILOT/que/${fn}.skipped
		# Write skip information to the wsp2
		_OPT=`head -1 $one`
		[ -z "$_OPTION" ] && export _OPTION="$_OPT" || export _OPTION="$_OPTION $_OPT"
		TAG=`chk_para.sh tag "$_OPTION"`
		CRRPRIORITY=`echo $fn | awk -F~ '{print $1}'`
		VERSION=`echo $fn | awk -F~ '{print $2}'`
		BUILD=`echo $fn | awk -F~ '{print $3}'`
		a=${fn%~*}
		TEST=${a##*~}
		TEST=`echo $TEST | sed -e "s/+/ /g" -e "s/\^/:/g" -e "s/!/\//g"`
		testtmp=`echo $TEST | sed -e "s/ /_/g"`
		########################################################################
		# Decide result save location
		RESLOC="$AP_DEF_RESLOC"
		if [ -n "$AP_RESFOLDER" ]; then
			RESDIR=$VERSION/$AP_RESFOLDER
		else
			_i18n=`echo $TEST | grep ^i18n_`
			if ( test -n "$_i18n" -o -n "$AP_I18N" )
			then
				RESDIR=$VERSION/i18n/essbase
			elif ( test "$TEST" = "xprobmain.sh" )
			then
				RESDIR=$VERSION/i18n/essbase
			else
				RESDIR=$VERSION/essbase
			fi
		fi
		[ -d "$RESLOC/$RESDIR" ] || mkddir.sh "$RESLOC/$RESDIR"
		echo "${BUILD}${TAG} $(get_platform.sh) skipped $testtmp 0 0 no_rtf - - $CRRPRIORITY" \
			 >> "$RESLOC/$RESDIR/results.wsp2"
		chmod 666 $RESLOC/$RESDIR/results.wsp2 > /dev/null 2>&1
		echo "${BUILD}${TAG} $(get_platform.sh) skipped $testtmp 0 0 no_rtf - - $CRRPRIORITY" \
			 >> "$RESLOC/$RESDIR/res.rec"
		chmod 666 $RESLOC/$RESDIR/res.rec > /dev/null 2>&1
	fi
	rm -rf $one > /dev/null 2>&1
done
