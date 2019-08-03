#!/usr/bin/ksh
#######################################################################
# svd.sh : Essbase server deamon
# HISTORY #############################################################
# 03/02/2011 YKono	First Edition

. apinc.sh

#######################################################################
# Log message
msg()
{
	if [ -n "$logfile" ]; then
		[ $# -ne 0 ] && echo "`date +%D_%T`:$@" >> $logfile \
			|| while read _data_; do 
				echo "`date +%D_%T`:$_data_"
		   	done >> $logfile
	else
		[ $# -ne 0 ] && echo "`date +%D_%T`:$@" \
			|| while read _data_; do 
				echo "`date +%D_%T`:$_data_"
		   	done
	fi
}

#######################################################################
# Display help
display_help()
{
	echo "svd.sh : Server service deamon."
	echo "Syntax: svd.sh [-a|-p|-n|-l <logf>|-pid <pid>]"
	echo "Options:"
	echo " -h         : display help"
	echo " -n         : Check own node request."
	echo " -p         : Check platform request."
	echo " -a         : Check anonymous request."
	echo " -l <logf>  : Write output to <logf>."
	echo " -pid <pid> : Audit process id."
}

#######################################################################
# Initial value

monfld=$AUTOPILOT/mon	# Monitor files location
lckfld=$AUTOPILOT/lck	# Lock files location

reqlevel=anonymous	# own, platform, anonymous
logfile=		# Logfile

# Each request file names and read lock file names
#   local request
myreq="$monfld/${thisnode}.sv.req"
mrlck="$lckfld/${thisnode}.sv.req.read"

#   platform request
platreq="$monfld/${LOGNAME}@${thisplat}.sv.req"
prlck="$lckfld/${LOGNAME}@${thisplat}.sv.req.read"

#   anonymous requst
anyreq="$monfld/${LOGNAME}.sv.req"
arlck="$lckfld/${LOGNAME}.sv.req.read"

# Interface files
mysts="$monfld/${thisnode}.sv.sts"
mycmd="$monfld/${thisnode}.sv.cmd"
myout="$monfld/${thisnode}.sv.out"
busy="$lckfld/${thisnode}.sv.busy"
mymode="$monfld/${thisnode}.sv.mode"
cmdf="$HOME/.$$.cmd"
stsf="$HOME/.$$.sts"
# Lock file for this program - for StayAliveCheck
mylock="$lckfld/${thisnode}.sv"

#######################################################################
# Read parameter
while [ $# -ne 0 ]; do
	case $1 in
		-h)	display_help; exit 0;;
		-a)	reqlevel=anonymous;;
		-n)	reqlevel=own;;
		-p)	reqlevel=platform;;
		-l)	
			if [ $# -lt 2 ]; then
				echo "'-l' option need log file name as 2nd parameter."
				display_help
				exit 1
			fi
			shift
			logfile=$1
			;;
		-pid)
			if [ $# -lt 2 ]; then
				echo "'-pid' need 2nd parameter as audit process id."
				display_help
				exit 1
			fi
			shift
			ppid=$1
			exist=`ps -p $ppid 2> /dev/null | grep -v PID`
			if [ -z "$exist" ]; then
				echo "$ppid is not exist."
				exit 2
			fi
			;;
		*)
			;;
	esac
	shift
done

# Check another svd.sh exists
lock_ping.sh ${mylock} > /dev/null
if [ $? -eq 0 ]; then
	echo "There is another svd.sh($?:${mylock}) for ${thisnode}."
	[ -f "${mylock}.lck" ] && cat "${mylock}.lck" | while read line; do
		echo "> $line"
	done
	exit 1
fi

# Delete log file
[ -n "$logfile" ] && rm -rf $logfile > /dev/null 2>&1

# Get parent PID
[ -z "$ppid" ] && ppid=`ps -p $$ -f | grep -v PID | awk '{print $3}'`

# Post process and signal trap
trap 'unlock.sh "$mylock" > /dev/null 2>&1 ; rm -f $mymode > /dev/null 2>&1 ; echo "svd.sh exit"' exit

# Create svd lock file.
cnt=60
while [ $cnt -ne 0 ]; do
	## lock.sh $mylock $ppid > /dev/null 2>&1
	lock.sh $mylock $$ > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		cnt=999
		break
	fi
	sleep 5
done
if [ $cnt -ne 999 ]; then
	echo "Failed to lock $mylock."
	echo "Please check there is another svd.sh is running on this machine and user."
	exit 1
fi

#######################################################################
# MAIN LOOP
#######################################################################
mode=check_personal_req
rm -f $mymode > /dev/null 2>&1
echo $mode > $mymode
cnt=0
msg "svd.sh start on ${thisnode}($$) parent($ppid)."

while [ 1 ]; do 

# Parent check
ppidchk=`ps -p $ppid | grep -v PID`
if [ -z "$ppidchk" ]; then
	msg "Missing audit processes($ppid). Terminate this program."
	break
fi

################
# EACH COMMAND #
################
case $mode in

check_personal_req)
[ "$reqlevel" = "own" ] && mode=wait || mode=check_platform_req
if [ -f "$myreq" -a ! -f "$myreq.lck" ]; then
	lock.sh $mrlck $$ > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		reqnode=`head -1 $myreq | tr -d '\r'`
		reqopt=
		ack=$monfld/${reqnode}.sv.ack
		clientl=$lckfld/${reqnode}.cl
		lock.sh $ack $$ > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			rm -rf $ack > /dev/null 2>&1
			touch $ack > /dev/null 2>&1
			chmod a+w $ack > /dev/null 2>&1
			echo ${thisnode} >> $ack
			rm -f $myreq > /dev/null 2>&1
			mode=wait_client_lock
			cnt=45
			unlock.sh $ack
			msg "Found request from ${reqnode}."
		else
			msg "Failed to lock ACK($ack) file."
		fi
		unlock.sh $mrlck
	else
		msg "Failed to lock read request($mrlck)."
	fi
fi
;;

check_platform_req)
[ "$reqlevel" = "platform" ] && mode=wait || mode=check_anonymous_req
if [ -f "$platreq" -a ! -f "$platreq.lck" ]; then
	lock.sh $prlck $$ > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		reqnode=`head -1 $platreq | tr -d '\r'`
		reqopt=`head -2 $platreq | tail -1 | tr -d '\r'`
		if [ "$reqopt" = "remote" -a "$reqnode" = "$thisnode" ]; then
			msg "Found platform request from ${reqnode}. But with remote option. Skip this request."
		else
			ack=$monfld/${reqnode}.sv.ack
			clientl=$lckfld/${reqnode}.cl
			lock.sh $ack $$ > /dev/null 2>&1
			if [ $? -eq 0 ]; then
				rm -rf $ack > /dev/null 2>&1
				touch $ack > /dev/null 2>&1
				chmod a+w $ack > /dev/null 2>&1
				echo ${thisnode} >> $ack
				rm -f $platreq > /dev/null 2>&1
				mode=wait_client_lock
				cnt=45
				unlock.sh $ack
				msg "Found platform request from ${reqnode}."
			else
				msg "Failed to lock ACK($ack) file."
			fi
		fi
		unlock.sh $prlck
	else
		msg "Failed to lock platform read($prlck)."
	fi
fi
;;

check_anonymous_req)
mode=wait
if [ -f "$anyreq" -a ! -f "$anyreq.lck" ]; then
	lock.sh $arlck $$ > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		reqnode=`head -1 $anyreq | tr -d '\r'`
		reqopt=`head -2 $anyreq | tail -1 | tr -d '\r'`
		if [ "$reqopt" = "remote" -a "$reqnode" = "$thisnode" ]; then
			msg "Found anonymous request from ${reqnode}. But with remote option. Skip this request."
		else
			ack=$monfld/${reqnode}.sv.ack
			clientl=$lckfld/${reqnode}.cl
			lock.sh $ack $$ > /dev/null 2>&1
			if [ $? -eq 0 ]; then
				rm -rf $ack > /dev/null 2>&1
				touch $ack > /dev/null 2>&1
				chmod a+w $ack > /dev/null 2>&1
				echo ${thisnode} >> $ack
				rm -f $anyreq > /dev/null 2>&1
				mode=wait_client_lock
				cnt=45
				unlock.sh $ack
				msg "Found anonymous request from ${reqnode}."
			else
				msg "Failed to lock ACK($ack) file."
			fi
		fi
		unlock.sh $arlck
	else
		msg "Failed to lock anonymous read ($arlck)."
	fi
fi
;;


wait)
sleep 1
mode=check_personal_req
;;

wait_client_lock)
msg "# wait_client_lock($cnt:$clientl)"
if [ $cnt -eq 0 ]; then
	msg "Client($clientl) not respond. Move to wait mode."
	mode=check_personal_req
else
	lock_ping.sh $clientl
	if [ $? -eq 0 ]; then	# Client start
		rm -f $monfld/${thisnode}.sv.env > /dev/null 2>&1
		msg "Start server service mode for ${reqnode}."
		mode=serving
		echo "$mode to $reqnode" > $mymode
	else
		sleep 1
		let cnt=cnt-1
	fi
fi
;;

serving)
if [ -f "$mycmd" -a ! -f "$mycmd.lck" ]; then
	lock.sh $busy $$ > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		msg "Got request."
		rm -f $myout > /dev/null 2>&1
		rm -f $mysts > /dev/null 2>&1
		rm -f $cmdf > /dev/null 2>&1
		rm -f $stsf > /dev/null 2>&1
		if [ -f "$monfld/${thisnode}.sv.env" ]; then
			cat $monfld/${thisnode}.sv.env | while read -r line; do
				echo $line | tr -d '\r' >> $cmdf
				msg "env> $line"
			done
		fi
		cat $mycmd | while read -r line; do
			line=`echo $line | tr -d '\r'`
			echo $line >> $cmdf
			msg " > $line"
		done
		rm -f $mycmd > /dev/null 2>&1
		chmod +x $cmdf
		$( \
			ksh $cmdf > $myout 2>&1; \
			echo $? > $mysts ; \
			chmod a+w $myout ; \
			chmod a+w $mysts ; \
			rm -f $cmdf \
		) > /dev/null 2>&1 &
		pid=$!
		mode=executing
		echo $mode > $mymode
	else
		msg "# Failed to lock busy($busy)."
		cat ${busy}.lck 2> /dev/null | while read line; do
			msg "> $line"
		done
		lock_ping.sh $busy
	fi
else
	lock_ping.sh $clientl
	if [ $? -ne 0 ]; then
		tmpc=5
		while [ $tmpc -ne 0 ]; do
			lock_ping.sh $clientl
			if [ $? -eq 0 ]; then
				tmpc=999
				break
			fi
			let tmpc=tmpc-1
			sleep 1
		done
		if [ $tmpc -ne 999 ]; then
			msg "Client not exist. Move to wait mode."
			mode=wait
			rm -f $monfld/${thisnode}.sv.env > /dev/null 2>&1
			echo $mode > $mymode
		fi
	fi
	sleep 1
fi
;;

executing)
if [ -n "$pid" ]; then
	sts=`ps -p $pid 2> /dev/null | grep -v PID`
	if [ -z "$sts" ]; then
		unlock.sh $busy
	#	msg "Requested process done. Move back serving mode."
		mode=serving
		echo "$mode to $reqnode" > $mymode
		unset pid
	else
		lock_ping.sh $clientl
		if [ $? -ne 0 ]; then	# No client waiting
			tmpc=5
			while [ $tmpc -ne 0 ]; do
				lock_ping.sh $clientl
				if [ $? -eq 0 ]; then
					tmpc=999
					break
				fi
				let tmpc=tmpc-1
				sleep 1
			done
			if [ $tmpc -ne 999 ]; then
				msg "Client not exist. Kill target process and Move wait mode."
				pstree.pl -kill $pid | msg
				unlock.sh $busy
				mode=wait
				rm -f $monfld/${thisnode}.sv.env > /dev/null 2>&1
				echo $mode > $mymode
			fi
		fi
	fi
else
	unlock.sh $busy
	mode=serving
	echo "$mode to $reqnode" > $mymode
fi
;;

*)
msg "# ?? ($mode)"
mode=check_personal_req
;;

############
# END LOOP #
############
esac; done
exit 0
