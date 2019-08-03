#!/usr/bin/ksh
#######################################################################
# svconnect.sh : Connect to the server service
#######################################################################
# Description:
#   This script connect to the svd.sh deamon.
# Syntax:
#   svconect.sh [-t <target>|-r|-dbg|-h]
# Option:
#   -t <target> : Connect to <target> node.
#                 <target> := <user>@<host>
#   -r          : Remote mode.
#   -dbg        : Display debug message.
#   -h          : Display help.
# HISTORY #############################################################
# 03/03/2011 YKono	First Edition

. apinc.sh

# Read parameter
me=$0
orgpar=$@
dbg=false
targ="${thisnode}"
remoteopt=
[ -n "$AP_SVTARG" ] && targ=$AP_SVTARG

while [ $# -ne 0 ]; do
	case $1 in
		-t)
			if [ $# -lt 2 ]; then
				echo "No target definition."
				disp_help
				exit 2
			fi
			shift
			targ=$1
			;;
		-h)
			display_help.sh $me
			exit 0
			;;
		-r)
			remoteopt=remote
			;;
		-dbg)
			dbg=true
			;;
		*)
			echo "Too many parameter."
			disp_help
			exit 1
			;;
	esac
	shift
done

if [ -z "$targ" ]; then
	echo "No <target> parameter."
	disp_help
	exit 1
fi

######################################################################
# Start main
######################################################################

lckfld=$AUTOPILOT/lck
monfld=$AUTOPILOT/mon

# Get parent process ID.
ppid=`ps -p $$ -f | grep -v PID | awk '{print $3}'`
[ "$dbg" = "true" ] && echo "# Parent ID = $ppid(`ps -p $ppid -f 2> /dev/null | tail -1`)"
reqf=$monfld/${targ}.sv.req
ackf=$monfld/${thisnode}.sv.ack
cl_lckf=$lckfld/${thisnode}.cl
if [ "$dbg" = "true" ]; then
	echo "# Request File    = $reqf"
	echo "# Acknowledge File= $ackf"
	echo "# Client lock File= $cl_lckf"
	if [ -f "$cl_lckf" ]; then
		echo "# Found client lock file."
		cat $cl_lckf 2> /dev/null | while read line; do
			echo "#   $line"
		done
	fi
fi

# Check previous lock exists
lock_ping.sh $cl_lckf > /dev/null 2>&1
sts=$?
[ "$dbg" = "true" ] && echo "# Check client lock ping = $sts"
if [ $sts -eq 0 ]; then
	echo "There is previous connection."
	[ -f "$cl_lckf.lck" ] && cat $cl_lckf.lck | while read line; do
		echo ">$line"
	done
	exit 2
fi

[ "$dbg" = "true" ] && echo "# Check Request file exists."
if [ -f "$reqf" ]; then
	if [ -f "$reqf.lck" ]; then
		lock_ping.sh $reqf > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "There is a lock file for the connect request file($targ)."
			[ -f "$reqf.lck" ] && cat $reqf.lck | while read line; do
				echo ">$line"
			done
			exit 3
		fi
	fi
	echo "There is another request to $targ."
	exit 3
fi

# Lock the request file.
[ "$dbg" = "true" ] && echo "# Lock request file."
cnt=60
while [ $cnt -ne 0 ]; do
	lock.sh $reqf $$ > /dev/null 2>&1
	sts=$?
	[ "$dbg" = "true" ] && echo "# $cnt:Lock $reqf sts=$sts"
	if [ $sts -eq 0 ]; then
		cnt=999
		break
	fi
	let cnt=cnt-1
	sleep 1
done
if [ $cnt -ne 999 ]; then
	echo "Failed to lock($reqf)."
	exit 4
fi

[ "$dbg" = "true" ] && echo "# Create request file."
rm -rf $ackf > /dev/null 2>&1
rm -rf $reqf > /dev/null 2>&1
echo ${thisnode} > $reqf
[ -n "$remoteopt" ] && echo "remote" >> $reqf
if [ "$dbg" = "true" ]; then
	cat $reqf | while read line; do
		echo "# > $line"
	done
fi
chmod a+w $reqf
unlock.sh $reqf

# Waiting acknowledge file($ackf)
[ "$dbg" = "true" ] && echo "# Wait for the ack file."
cnt=60
while [ $cnt -ne 0 ]; do
	[ "$dbg" = "true" ] && echo "# $cnt: Check ack file."
	if [ -f "$ackf" -a ! -f "$ackf.lck" ]; then
		cnt=999
		break
	fi
	sleep 1
	let cnt=cnt-1
done
if [ $cnt -ne 999 ]; then
	echo "# Connection request time out($targ)."
	rm -f $reqf > /dev/null 2>&1
	exit 5
fi

targ=`cat $ackf |  tr -d '\r'`
echo "# Connect to $targ."
rm -rf "$ackf" > /dev/null 2>&1

# Create client lock file."
[ "$dbg" = "true" ] && echo "# Create client lock file."
cnt=60
while [ $cnt -ne 0 ]; do
	lock.sh $cl_lckf $ppid -m "svtarg:$targ" > /dev/null 2>&1
	sts=$?
	[ "$dbg" = "true" ] && echo "# $cnt:lock.sh ${cl_lckf##*/} $ppid sts=$sts"
	if [ $sts -eq 0 ]; then
		cnt=999
		break
	fi
	let cnt=cnt-1
	sleep 1
done
if [ $cnt -ne 999 ]; then
	echo "Failed to lock the client($cl_lck)."
	exit 1
fi
exit 0
