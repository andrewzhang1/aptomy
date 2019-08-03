#!/usr/bin/ksh
#######################################################################
# svcmd.sh : Command execution on server processes
#######################################################################
# svcmd.cmd [<cmd>|-f <cmd-file>]
# HISTORY #############################################################
# 03/02/2011 YKono	First Edition

. apinc.sh

#######################################################################
disp_help()
{
	echo "Usage : svcmd.sh [-pid <pid>] <cmd> | -f <cmd-file>"
	echo "  <cmd>      : Command to execute."
	echo "  <cmd-file> : Command file."
	echo " -pid <pid>  : Client process ID."
}

# make_lock <lck-targ> <retry#>
make_lock() {
	if [ $# -ne 2 ]; then
		cnt=0
	else
		cnt=$2
		while [ $cnt -ne 0 ]; do
			lock.sh $1 $$ > /dev/null 2>&1
			if [ $? -eq 0 ]; then
				cnt=999
				break
			fi
			sleep 1
			let cnt=cnt-1
		done
	fi
	[ $cnt -ne 999 ] && echo false || echo true
}

# Post process
term_proc()
{
	[ -f "$svoutf" ] && rm -f "$svoutf" > /dev/null 2>&1
	[ -f "$svoutf" ] && rm -f "$svoutf" > /dev/null 2>&1
}

# Read parameter

unset cmdf
flg=cmd
ppid=

while [ $# -ne 0 ]; do
	case $1 in
		-f)
			if [ $# -lt 2 ]; then
				echo "No command file."
				disp_help
				exit 2
			fi
			shift
			cmdf=$1
			flg=file
			;;
		-h)
			disp_help 
			exit 0
			;;
		-pid)
			if [ $# -lt 2 ]; then
				echo "'-pid' need client PID as 2nd parameter."
				displ_help
				exit 2
			fi
			shift
			ppid=$1
			;;
		*)
			if [ -z "$cmdf" ]; then
				cmdf=$1
			else
				cmdf="$cmdf $1"
			fi
			;;
	esac
	shift
done

if [ -z "$cmdf" ]; then
	echo "No <cmd> or <cmdf> parameter."
	disp_help
	exit 1
fi
if [ "$flg" = "file" -a ! -f "$cmdf" ]; then
	echo "Couldn't find the command file($cmdf)."
	exit 3
fi

######################################################################
# Start main
######################################################################

lckfld=$AUTOPILOT/lck
monfld=$AUTOPILOT/mon

cl_lckf=$lckfld/${thisnode}.cl

# Get parent process ID.
[ -z "$ppid" ] && ppid=`ps -p $$ -f | grep -v PID | awk '{print $3}'`

lock_ping.sh $cl_lckf > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "There is no server connection on ${thisnode}."
	exit 4
fi

[ -f "$cl_lckf.lck" ] && tmp=`cat "$cl_lckf.lck" 2> /dev/null | grep " target=" | awk -F= '{print $2}'`
if [ "$ppid" != "$tmp" ]; then
	echo "Found client lock file."
	echo "But parent PID are not match."
	echo "Current PPID=$ppid. Lck PPID=$tmp"
	exit 7
fi

[ -f "$cl_lckf.lck" ] && targ=`cat "$cl_lckf.lck" 2> /dev/null | grep "^svtarg:" | awk -F: '{print $2}' | tr -d '\r'`
if [ -z "$targ" ]; then
	echo "No target is detected."
	svrelease.sh
	exit 5
fi

svcmdf=$monfld/${targ}.sv.cmd
svoutf=$monfld/${targ}.sv.out
svstsf=$monfld/${targ}.sv.sts
svbusy=$lckfld/${targ}.sv.busy

# Check server busy
lock_ping.sh $svbusy
if [ $? -eq 0 ]; then
	echo "Server($targ) is busy now."
	exit 6
fi

######################################################################
# Make command file

if [ "`make_lock $svcmdf 30`" = "false" ]; then
	echo "Failed to lock the command file($svcmdf)."
	exit 7
fi

rm -f "$svcmdf" > /dev/null 2>&1
[ "$flg" = "file" ] && cat "$cmdf" > $svcmdf || echo "$cmdf" >> $svcmdf
chmod a+w "$svcmdf"
unlock.sh "$svcmdf"

######################################################################
trap 'term_proc; echo "Break svcmd.sh";exit ' 1 2 3 15
######################################################################
cnt=60
while [ $cnt -ne 0 ]; do
	if [ ! -f "$svcmdf" ]; then
		cnt=999
		break
	fi
	sleep 1
	let cnt=cnt-1
done
if [ $cnt -ne 999 ]; then
	echo "# Time up for cmd accept."
	[ -f "$svcmdf" ] && rm -f "$svcmdf" > /dev/null 2>&1
	svrelease.sh
	exit 5
fi

######################################################################
# Dump output
prevlines=0
lines=0
while [ 1 ]; do
	lock_ping.sh $svbusy
	[ $? -ne 0 ] && break
	if [ -f "$svoutf" ]; then
		lines=`wc -l ${svoutf} 2> /dev/null`
		lines=`echo $lines | awk '{print $1}'`
		if [ $lines -ne $prevlines ]; then
			let displ="lines - prevlines"
			tail -$displ $svoutf
			prevlines=$lines
		fi
	fi
	sleep 1
done

if [ -f "$svoutf" ]; then
	lines=`wc -l ${svoutf} 2> /dev/null`
	lines=`echo $lines | awk '{print $1}'`
	if [ "$lines" -ne "$prevlines" ]; then
		let displ="lines - prevlines"
		tail -$displ $svoutf
	fi
	rm -f "$svoutf" > /dev/null 2>&1
fi


if [ -f "$svstsf" ]; then
	sts=`cat $svstsf | tr -d '\r'`
	rm -f "$svstsf" > /dev/null 2>&1
else
	sts=1
fi
exit $sts

