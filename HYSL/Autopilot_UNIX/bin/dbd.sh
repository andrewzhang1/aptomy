#!/usr/bin/ksh
#######################################################################
# dbd.sh : Database deamon
# Description:
#   This script run as service and accept new user creation request
#   from regression machine.
#
# HISTORY #############################################################
# 03/09/2011 YKono	First Edition
# 03/11/2011 YKono	Add wait_my_req mode and new name handling.

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
	echo "dbd.sh : Database creation user service deamon."
	echo "Syntax: dbd.sh [-h|-l <logf>|-pid <pid>]"
	echo "Options:"
	echo " -h         : display help"
	echo " -l <logf>  : Write output to <logf>."
	echo " -pid <pid> : Audit process id."
}

#######################################################################
# Post process
post_proc()
{
	unlock.sh "$mylock" > /dev/null 2>&1 
	rm -f $mymode > /dev/null 2>&1
	echo "dbd.sh exit"
}

#######################################################################
# Initial value

me=$0
orgpar=$@

monfld=$AUTOPILOT/mon	# Monitor files location
lckfld=$AUTOPILOT/lck	# Lock files location
logfile=				# Logfile

# Each request file names and read lock file names
#   local request
req="$monfld/db.req"
rlck="$lckfld/db.req.read"
myreq="$monfld/${thishost}.db.req"
mrlck="$lckfld/${thishost}.db.req.read"

# Interface files
mysts="$monfld/${thisnode}.db.sts"
mymode="$monfld/${thisnode}.db.mode"

# Lock file for this program - for StayAliveCheck
mylock="$lckfld/${thisnode}.db"

#######################################################################
# Read parameter
while [ $# -ne 0 ]; do
	case $1 in
		-h)	display_help.sh $me; exit 0;;
		-l)	
			if [ $# -lt 2 ]; then
				echo "'-l' option need log file name as 2nd parameter."
				display_help.sh $me
				exit 1
			fi
			shift
			logfile=$1
			;;
		-pid)
			if [ $# -lt 2 ]; then
				echo "'-pid' need 2nd parameter as audit process id."
				display_help.sh $me
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
			echo "Too many parameter."
			display_help.sh $me
			exit 2
			;;
	esac
	shift
done

# Check another dbd.sh exists on this machine
lock_ping.sh $mylock > /dev/null
if [ $? -eq 0 ]; then
	echo "There is another dbd.sh on ${thisnode}."
	[ -f "$mylock.lck" ] && cat "$mylock.lck" | while read line; do
		echo "> $line"
	done
	exit 3
fi

# Delete log file
[ -n "$logfile" ] && rm -rf $logfile > /dev/null 2>&1

# Get parent PID
#[ -z "$ppid" ] && ppid=`ps -p $$ -f | grep -v PID | awk '{print $3}'`
[ -z "$ppid" ] && ppid=$$

# Post process and signal trap
trap 'post_proc' exit

# Create dbd lock file.
cnt=60
while [ $cnt -ne 0 ]; do
	lock.sh $mylock $ppid > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		cnt=999
		break
	fi
	sleep 5
done
if [ $cnt -ne 999 ]; then
	echo "Failed to lock $mylock."
	echo "Please check there is another dbd.sh is running on this machine and user."
	exit 1
fi

#######################################################################
# MAIN LOOP
#######################################################################
mode=wait
rm -f $mymode > /dev/null 2>&1
echo $mode > $mymode
cnt=0
lckcnt=0
msg "dvd.sh start on ${thisnode}($$)."

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

check_my_req)
mode=check_req
if [ -f "$myreq" -a ! -f "$myreq.lck" ]; then
	lock.sh $mrlck $$ > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		reqnode=`head -1 $myreq | tr -d '\r'`
		reqname=`head -2 $myreq | tail -1 | tr -d '\r'`
		ack=$monfld/${reqnode}.db.ack
		clientl=$lckfld/${reqnode}.db.cl
		lock.sh $ack $$ > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			rm -rf $ack > /dev/null 2>&1
			touch $ack > /dev/null 2>&1
			chmod a+w $ack > /dev/null 2>&1
			echo ${thisnode} >> $ack
			rm -f $myreq > /dev/null 2>&1
			mode=wait_client_lock
			echo $mode > $mymode
			cnt=45
			unlock.sh $ack
			msg "Found my request from ${reqnode}."
		else
			msg "Failed to lock ACK($ack) file."
		fi
		unlock.sh $mrlck
	else
		msg "Failed to lock read request($mrlck)."
	fi
fi
;;

check_req)
mode=wait
if [ -f "$req" -a ! -f "$req.lck" ]; then
	lock.sh $rlck $$ > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		reqnode=`head -1 $req | tr -d '\r'`
		reqname=`head -2 $req | tail -1 | tr -d '\r'`
		ack=$monfld/${reqnode}.db.ack
		clientl=$lckfld/${reqnode}.db.cl
		lock.sh $ack $$ > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			rm -rf $ack > /dev/null 2>&1
			touch $ack > /dev/null 2>&1
			chmod a+w $ack > /dev/null 2>&1
			echo ${thisnode} >> $ack
			rm -f $req > /dev/null 2>&1
			mode=wait_client_lock
			echo $mode > $mymode
			cnt=45
			unlock.sh $ack
			msg "Found request from ${reqnode}."
		else
			msg "Failed to lock ACK($ack) file."
		fi
		unlock.sh $rlck
	else
		msg "Failed to lock read request($mrlck)."
	fi
fi
;;


wait)
sleep 1
mode=check_my_req
;;

wait_client_lock)
msg "# wait_client_lock($cnt:$clientl)"
if [ $cnt -eq 0 ]; then
	msg "Client($clientl) not respond. Move to wait mode."
	mode=wait
	echo $mode > $mymode
else
	lock_ping.sh $clientl
	if [ $? -eq 0 ]; then	# Client start
		mode=serving
		echo "$mode for ${reqnode}" > $mymode
		msg "Found lock for ${reqnode}."
		lckcnt=60
	else
		sleep 1
		let cnt=cnt-1
	fi
fi
;;

wait_client_leave)
msg "# wait_client_leave($cnt:$clientl)"
if [ $cnt -eq 0 ]; then
	msg "No client response - move to wait mode."
	mode=wait
	echo $mode > $mymode
else
	lock_ping.sh $clientl
	if [ $? -ne 0 ]; then	# Client start
		msg "Client gone - move to wait mode."
		mode=wait
		echo $mode > $mymode
	else
		sleep 1
		let cnt=cnt-1
	fi
fi
;;

serving)
lock.sh $ack $$ > /dev/null 2>&1
if [ $? -eq 0 ]; then
	msg "Creating ${reqnode} user."
	sqlf=$HOME/.dbd.$$.tmp.sql
	rm -f $sqlf > /dev/null 2>&1
	echo "DROP USER ${reqname} CASCADE;" > $sqlf
	echo "CREATE USER ${reqname} IDENTIFIED BY password;" >> $sqlf
	echo "GRANT DBA, CONNECT TO ${reqname} WITH ADMIN OPTION;" >> $sqlf
	echo "QUIT;" >> $sqlf
	echo "regress" > pwd
	echo "password" >> pwd
	sqlplus regress/password@regress @${sqlf} < pwd
	sts=$?
	rm -f $sqlf > /dev/null 2>&1
	rm -f $ack > /dev/null 2>&1
	touch $ack
	chmod a+w $ack
	echo "jdbcUrl=jdbc:oracle:thin:@$(hostname):1521:regress" > $ack
	echo "host=$(hostname)" >> $ack
	echo "port=1521" >> $ack
	echo "dbName=regress" >> $ack
	echo "userName=${reqname}" >> $ack
	echo "password=password" >> $ack
	unlock.sh $ack
	msg "Done creation for ${reqnode} - move to wait_client_leave mode."
	mode=wait_client_leave
	cnt=60
	echo $mode > $mymode
else
	sleep 1
	let lckcnt=lckcnt-1
	if [ $lckcnt -eq 0 ]; then
		msg "Lock ACK failed($ack).".
		msg "Move back to wait mode."
		mode=wait
		echo $mode > $mymode
	fi
fi
;;

*)
msg "# ?? ($mode)"
mode=wait
;;

############
# END LOOP #
############
esac; done
exit 0
