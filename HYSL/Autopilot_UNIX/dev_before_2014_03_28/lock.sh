#!/usr/bin/ksh
######################################################################
# Filename:    lock.sh
# Author:      Yukio Kono
# Description: Lock specific file.
# Syntax:
#   lock.sh [-fq|-s <scr>|-m <mes>] <file> [<PID>]
#     -fq      : Forcebly quit parent process when unlock target
#     -s <scr> : Specify the post cleanup script <scr>
#     -m <mes> : Add <mes> to the lock file.
#     <file>   : Target file to lock.
#     <PID>    : Parent PID. When this parameter is skipped, the 
#                parent check will be skipped.
# Description:
#   This script launch the lock_keep.sh to keeping the lock status.
#   But when there is no <PID> process, the lock_keep.sh remove that
#   lock. This avoid to lock the file eternaly.
# Out:
#   0: Succeeded to lock. Display the PID for lock_keep.sh
#   1: Parameter error.
#   2: File already locked by someone
#   3: Need <scr> for -s option.
#   4: Need <mes> for -m option.
# History ############################################################
# 08/23/2010 YKono	Add -s option
# 08/24/2010 YKono	Add -m option

umask 000
. lockdef.sh
me=$0
orgpar=$@
[ "$debug" = "true" ] && dbgwrt "=== $@"

display_help()
{
	echo "lock.sh : Description: Lock specific file."
	echo "Syntax:"
  	echo "lock.sh [-fq|-s <scr>|-m <mes>] <file> [<PID>]"
    	echo "  -fq      : Forcebly quit parent process when unlock target"
    	echo "  -s <scr> : Specify the post cleanup script <scr>"
    	echo "  -m <mes> : Add <mes> to the lock file."
    	echo "  <file>   : Target file to lock."
    	echo "  <PID>    : Parent PID. When this parameter is skipped, the "
 	echo "             parent check will be skipped."
	echo "Description:"
  	echo "  This script launch the lock_keep.sh to keeping the lock status."
  	echo "  But when there is no <PID> process, the lock_keep.sh remove that"
  	echo "  lock. This avoid to lock the file eternaly."
	echo "Out:"
  	echo "  0: Succeeded to lock. Display the PID for lock_keep.sh"
  	echo "  1: Parameter error."
  	echo "  2: File already locked by someone"
  	echo "  3: Need <scr> for -s option."
  	echo "  4: Need <mes> for -m option."
}
unset target_file parent_pid force_quit post_script add_message
add_message="null"
post_script="null"
parent_pid="null"
while [ $# -ne 0 ]; do
	case $1 in
		-fq|-forcequit)
			force_quit="-forcequit"
			;;
		-post|-s|-script)
			if [ $# -lt 2 ]; then
				exit 3
			fi
			shift
			post_script=$1
			;;
		-mess|-m)
			if [ $# -lt 2 ]; then
				exit 4
			fi
			shift
			if [ "$add_message" = "null" ]; then
				add_message=$1
			else
				add_message="$add_message\n$1"
			fi
			;;
		-h|-help)
			display_help
			exit 0
			;;
		-debug)
			debug=true
			;;
		*)
			if [ -z "$target_file" ]; then
				target_file=$1
			elif [ "$parent_pid" = "null" ]; then
				parent_pid=$1
			else
				exit 1
			fi
			;;
	esac
	shift
done
if [ -f "${target_file}.lck" ]; then
	[ "$debug" = "true" ] && dbgwrt "Found ${target_file##*/}.lck"
	lock_ping.sh "${target_file}"
	if [ $? -eq 0 ]; then
		[ "$debug" = "true" ] && dbgwrt "${target_file##*/}.lck alive. exit 2"
		exit 2
	fi
fi
post_script=`echo $post_script | sed -e "s/+/{plus}/g" -e "s/ /+/g"`
add_message=`echo $add_message | sed -e "s/+/{plus}/g" -e "s/ /+/g"`
echo "${LOGNAME}@`hostname` $$" >> "${target_file}.lck"
a=`head -1 "${target_file}.lck"`
if [ "$a" != "${LOGNAME}@`hostname` $$" ]; then
	if [ "$debug" = "true" ]; then
		dbgwrt "Failed to get first position in ${target_file##*/}.lck. exit 2"
		cat ${target_file}.lck 2> /dev/null | while read _line; do
			dbgwrt "# $_line"
		done
	fi
	exit 2
fi
# rm -f "${target_file}.terminate" > /dev/null 2>&1
dbgwrt "Lock ${target_file##*/}.lck succeeded. launch keep_lock.sh then exit 0"
keep_lock.sh ${force_quit} "${target_file}" "${parent_pid}" $$ "${post_script}" "${add_message}" > /dev/null 2>&1 &
echo $!
exit 0
		
