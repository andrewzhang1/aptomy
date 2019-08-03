#!/usr/bin/ksh
# aplog.sh : Dump autopilot log files.
# HISTORY ############################################################################
# 07/29/2009 YK - First Edition
# 04/30/2010 YK - Change -e to environment file and -x to extension.
# 05/16/2012 YK - Add AP_LOGTO check

display_help()
{
	echo "Dump log file."
	echo "aplog.sh [-h|-a|-s|-e|-l|-w|-v|-n <node>|-x <extn>] [<file>]"
	echo " <file>   : The target dump file."
	echo "            If you define <file> without folder name, this command will add"
	echo "            \$AUTOPILOT/mon before <file> name and dump it."
	echo "            ex.)"
	echo "              \$> aplog.sh regrrk1@stiahp3"
	echo "              In this case, this command dump \$AUTOPILOT/mon/regrrk1@stiahp3.log"
	echo "              file."
	echo "            When you add the folder name of the \$AUTOPILOT folder, like"
	echo "            'mon', 'data'...,  this command just add \$AUTOPILOT before "
	echo "            <file> name."
	echo "            ex.)"
	echo "              \$> aplog.sh tmp/regrrk1@stiahp3.memusage.txt"
	echo "              In this case, this command dump "
	echo "              \$AUTOPILOT/tmp/regrrk1@stiahp3.memusage.txt."
	echo "            If you skip this, this command will use '<usr>@<machien>.log'."
	echo " -h       : Display this."
	echo " -l       : Dump <usr>@<machine>.log file under mon folder."
	echo "            This is the log file for the start_regress.sh."
	echo "            You can see the similar output as \*.sog file."
	echo " -a       : Dump <usr>@<machine>.ap.log file under mon folder."
	echo "            This is the log file for the autopilot.sh."
	echo "            You can see the autopilot.sh and task_parser.sh messages."
	echo " -s       : Dump <usr>@<machine>.stg file under mon folder."
	echo "            This is current stage of the start_regress.sh."
	echo " -m       : Dump <usr>@<machine>.mon.log file under mon folder."
	echo " -k       : Dump <usr>@<machine>.kill.rec file under mon folder."
	echo " -e       : Dump <usr>@<machine>.env file under mon folder."
	echo "            This is current environment dump of the start_regress.sh."
	echo " -w       : Wait for creating target file if there isn't."
	echo " -v       : Open target file using vi view mode."
	echo " -n <node>: Use <node> for the dump target."
	echo "            ex.) If you want to dump the regrrk1 user's on stiahp3 mahcine,"
	echo "              \$> aplog.sh -n regrrk1@stiahp3"
	echo " -x <extn>: Use <extn> as extention of the target file."
	echo "            ex.) when you use regrrk1 user on stiahp3 machine."
	echo "              Below example dump \$AUTOPILOT/mon/regrrk1@stiahp3.memusage.txt."
	echo "                \$> aplog.sh -e .memusage.txt"
	echo "              Following example dump \$AUTOPILOT/tmp/regrrk1@stiahp3_error.sts."
	echo "                \$> aplog.sh -e tmp/_error.sts"
}

. apinc.sh
set_vardef AP_LOGTO

# ext=true
# target=".log"
wait=false
usevi=false
trgnode=${LOGNAME}@`hostname`
target=$AP_LOGTO
ext=false
while [ $# -ne 0 ]; do
	case $1 in
		-l)		target=".log"; ext=true;;
		-s)		target=".stg"; ext=true;;
		-m)		target=".mon.log"; ext=true;;
		-k)		target=".kill.rec"; ext=true;;
		-a)		target=".ap.log"; ext=true;;
		-e)		target=".env"; ext=true;;
		-w|-wait|wait)	wait=true;;
		-h|-help|help)	display_help; exit 0;;
		-x)		ext=true; shift; target=$1;;
		-v)		usevi=true;;
		-n)		shift; trgnode=$1;;
		*)		ext=false; target=$1;;
	esac
	shift
done

if [ "$target" = "false" ]; then
	echo "The AP_LOGTO is set to \"false\"."
	echo "And it isn't using log output. aplog.sh cannot display the log file."
	exit 0
fi

if [ "${target#/}" = "$target" -a "${target#?:}" = "$target" \
	-a "${target#./}" = "$target" -a "${target#../}" = "$target" -a "$target" != "false" ]; then
	if [ "${target#*/}" = "$target" ]; then # Not include folder name.
		target="$AUTOPILOT/mon/$target"
	else
		target="$AUTOPILOT/$target"
	fi
fi
if [ "$ext" = "true" ]; then
	lstpart=${target##*/}
	pthpart=${target%/*}
	target="${pthpart}/${trgnode}${lstpart}"
fi

if [ ! -f "$target" ]; then
	if [ "$wait" = "false" ]; then
		echo "$target not found."
		exit 2
	else
		echo "Waiting for $target file."
		while [ ! -f "$target" ]; do
			sleep 10
		done
		echo ""
	fi
fi

if [ "$usevi" = "true" ]; then
	vi -R $target
else
	prevlcnt=0
	while [ -f "$target" ]; do
		lcnt=`cat $target | wc -l`
		if [ "$lcnt" -ne "$prevlcnt" ]; then
			ldif=`expr $lcnt - $prevlcnt`
			[ $prevlcnt -eq 0 -a $ldif -gt 100 ] && ldif=30
			[ $ldif -gt 0 ] && tail -${ldif} $target
			prevlcnt=$lcnt
		else
			sleep 5
		fi
	done
fi

echo "*** DONE ***"

