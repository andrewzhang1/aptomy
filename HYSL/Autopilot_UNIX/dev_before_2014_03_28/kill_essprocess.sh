#!/usr/bin/ksh

. apinc.sh

echo "Killing Essbase Processes"
psucmd="psu"

killcmd()
{
	cmds=
	for i in $@; do
		[ -z "$cmds" ] && cmds=$i || cmds="$cmds|$i"
	done
	while [ -n "$cmds" -a `${psucmd} -c 2> /dev/null | grep -v "grep" | egrep -i "$cmds" | wc -l` -ne 0 ]; do
		for i in $@; do
			${psucmd} -c 2> /dev/null | grep -i $i | while read pid data; do
				echo "$pid $data"
				kill -9 $pid
				sleep 1
			done
		done
	done
}

# envfile="$AUTOPILOT/mon/${LOGNAME}@`hostname`.env"
# if [ -f "$envfile" ]; then
# 	for var in HYPERION_HOME BUILD_ROOT ARBORPATH VIEW_PATH \
# 		ESSBASEPATH ESSLANG PATH SHLIB_PATH LD_LIBRARY_PATH LIBPATH
# 	do
# 		_tmp_=`grep "^${var}=" "$envfile" 2> /dev/null`
# 		if [ -n "$_tmp_" ]; then
# 			_tmp_=${_tmp_#${var}=}
# 			if [ "${_tmp_#\"}" != "${_tmp_}" ]; then
# 				_tmp_=${_tmp_#?}; _tmp_=${_tmp_%?}
# 			fi
# 			export $var="$_tmp_"
# 		fi
# 	done
# 
# 	crrdir=`pwd`
# 	output_file="killessprc_$$.log"
# 	shutdown_scr="killessprc_$$.scr"
# 	cd $VIEW_PATH
# 	sed -e "s!%HOST!localhost!g" -e "s!%USR!essexer!g" \
# 		-e "s!%PWD!password!g" -e "s!%OUTF!$output_file!g" \
# 		$AUTOPILOT/acc/shutdown.scr > $shutdown_scr
# 	ESSCMD $shutdown_scr > /dev/null 2>&1
# 	sts=$?
# 	if [ $sts -eq 0 ]; then
# 		echo "Killed the Essbase agent from ESSCMD."
# 	else
# 		echo "Failed to kill the Essbase agent from ESSCMD ($sts)."
# 	fi
# 	rm -f $output_file
# 	rm -f $shutdown_scr
# 	cd $crrdir
# fi

killcmd essmsh esscmd esssvr essbase
echo "Essbase Stopped"
