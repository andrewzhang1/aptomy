#!/usr/bin/ksh

#########################################################################
# Filename:    keep_lock.sh
# Author:      Yukio Kono
# Description: Keep lock status for specific file.
# Syntax:
#   keep_lock.sh [-fq] <trg> <ppid> <calpid> <scr> <mes>
#     -fq      : Forcebly quit parent process when unlock target
# Out:
#   0 : normal end
#   1 : syntax error -> too many  parameter
# History ###############################################################
# 08/19/2009 YKono	First Edition
# 03/02/2011 YKono	Change pin file format.
# 03/27/2012 YKono	Use umask

umask 000
. lockdef.sh
me=$0
orgpar=$@
[ "$debug" = "true" ] && dbgwrt "=== $@"

unset target_file parent_pid force_quit caller_pid post_script add_message
while [ $# -ne 0 ]; do
	case $1 in
		-fq|-forcequit)
			force_quit="-forcequit"
			;;
		*)
			if [ -z "$target_file" ]; then
				target_file=$1
			elif [ -z "$parent_pid" ]; then
				parent_pid=$1
			elif [ -z "$caller_pid" ]; then
				caller_pid=$1
			elif [ -z "$post_script" ]; then
				post_script=$1
			elif [ -z "$add_message" ]; then
				add_message=$1
			else
				add_message="$add_message $1"
			fi
			;;
	esac
	shift
done

# echo "target_file=$target_file" > $HOME/keep_lock.log
# echo "parent_pid=$parent_pid" >> $HOME/keep_lock.log
# echo "caller_pid=$caller_pid" >> $HOME/keep_lock.log
# echo "add_message=$add_message" >> $HOME/keep_lock.log
# echo "post_script=$post_script" >> $HOME/keep_lock.log
[ "$post_script" = "null" ] && unset post_script
[ "$add_message" = "null" ] && unset add_message
[ -n "$post_script" ] && post_script=`echo "$post_script" | sed -e "s/+/ /g" -e "s/{plus}/+/g"`
[ -n "$add_message" ] && add_message=`echo "$add_message" | sed -e "s/+/ /g" -e "s/{plus}/+/g"`
trap '' 1 2 3 15
wktime=`date +%D_%T`
echo "${wktime} target=${parent_pid}" >> "${target_file}.lck"
echo "keep_lock_pid:$$" >> "${target_file}.lck"
[ -n "$add_message" ] && echo "$add_message" >> "${target_file}.lck"
[ -n "$post_script" ] && echo "post_script:$post_script" >> "${target_file}.lck"
rm -f "${target_file}.pin" > /dev/null 2>&1
rm -f "${target_file}.terminate" > /dev/null 2>&1
rm -f "${target_file}.term_lock" > /dev/null 2>&1
[ "$debug" = "true" ] && dbgwrt " Start loop. $target_file"
while [ 1 ]; do
	# check parent working
	if [ "$parent_pid" != "null" -a "`ps -p ${parent_pid} 2> /dev/null | grep -v PID`" = "" ]; then
		[ "$debug" = "true" ] && dbgwrt "No parent($parent_pid). Quit."
		break;
	elif [ -f "${target_file}.term_lock" ]; then
		[ "$debug" = "true" ] && dbgwrt "Found ${target_file##*/}.term_lock. Quit."
		break
	elif [ -f "${target_file}.kill" ]; then
		[ "$debug" = "true" ] && dbgwrt "Found ${target_file##*/}.kill. Force Quit."
		force_quit=true
		break
	elif [ ! -f "${target_file}.lck" ]; then 
		# Recreate lck file.
		[ "$debug" = "true" ] && dbgwrt "Found no ${target_file##*/}.lck. Re-create it."
		echo "${LOGNAME}@$(hostname) ${caller_pid}" > "${target_file}.lck"
		echo "${wktime}(rst:`date +%D_%T`) target=${parent_pid}" >> "${target_file}.lck"
		[ -n "$add_message" ] && echo "$add_message" >> "${target_file}.lck"
		[ -n "$post_script" ] && echo "post_script:$post_script" >> "${target_file}.lck"
	else
		ls ${target_file}.*pin > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			af=`ls ${target_file}.*pin 2> /dev/null | head -1`
			[ "$debug" = "true" ] && dbgwrt "Found ${af##*/}. Delete it."
			rm -f ${af} > /dev/null 2>&1
		else
			sleep 1
		fi
	fi
done
if [ -n "${force_quit}" ]; then
	if [ "$parent_pid" != "null" -a "`ps -p $parent_pid 2> /dev/null | grep -v PID`" != "" ]; then
		pstree.pl -kill ${parent_pid} > /dev/null 2>&1
	fi
fi
if [ -n "$post_script" ]; then
	$post_script "fq:$force_quit"
fi
rm -f "${target_file}.term_lock" > /dev/null 2>&1
rm -f ${target_file}.*pin > /dev/null 2>&1
rm -f "${target_file}.lck" > /dev/null 2>&1
rm -f "${target_file}.kill" > /dev/null 2>&1
[ "$debug" = "true" ] && dbgwrt "Exit ${target_file##*/}.lck."
exit 0
