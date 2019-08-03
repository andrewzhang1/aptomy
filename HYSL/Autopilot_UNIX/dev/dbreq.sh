#!/usr/bin/ksh
#######################################################################
# dbreq.sh : Request to create the user for current machine and user.
#######################################################################
# Syntax: dbreq.sh [<trg-host>] [-h|-n <user>]"
# Parameter:
#  <trg-host> : Target host node. When you skip this parameter,"
#               Any dbd.sh may receive your request."
#  -h         : Display this."
#  -n <user>  : The user name to create/initialize."
#               When you skip this parameter, dbreq.sh will uses"
#               current user and host name($accnt)."
# If you want to create BI repository databse with RCU, please define
# <user> with "RCU6:" or "RCU7:" prefix.
#
# HISTORY: #############################################################
# 03/09/2011 YKono	First Edition
# 03/11/2011 YKono	Add <trg-host> and -n option.
# 09/17/2012 YKono      Fix when hostname command return full hostname
#                       with domain name. It causes creating user with
#                       period character and fail to create it.
# 06/05/2013 YKono	Bug 16908191 - AUTOPILOT SUPPORT REPOSITORY CREATION SERVICE AS DEAMON.

. apinc.sh

#######################################################################
# Log message
# msg "xxxx"
# echo "xxx" | msg
# cat file | msg
# (echo 1; echo 2; echo 3) | msg
# ls | msg

msg()
{
        if [ $# -ne 0 ]; then
                echo "`date +%D_%T`:$@"
        else
                while read _data_; do
                        echo "`date +%D_%T`:$_data_"
                done
        fi
}


######################################################################
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


######################################################################
# Post process
term_proc()
{
	unlock.sh $cl_lckf > /dev/null 2>&1
	[ -f "$ack" ] && rm -f "$ack" > /dev/null 2>&1
}


######################################################################
# Read parameter
######################################################################
me=$0
orgpar=$@
targ=
accnt=`echo ${thisnode} | sed -e "s/@/_/g"`
accnt=${accnt%%.*}
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			exit 0
			;;
		-n)
			if [ $# -lt 2 ]; then
				echo "'-n' need 2nd parameter as user name to creating."
				display_help
				exit 1
			fi
			shift
			accnt=$1
			;;
		*)
			if [ -z "$targ" ]; then
				targ=$1
			else
				echo "Too many parameter."
				display_help
				exit 1
			fi
			;;
	esac
	shift
done


######################################################################
# Start main
######################################################################

lckfld=$AUTOPILOT/lck
monfld=$AUTOPILOT/mon

[ -n "$targ" ] && reqf=$monfld/${targ}.db.req || reqf=$monfld/db.req
ackf=$monfld/${thisnode}.db.ack
cl_lck=$lckfld/${thisnode}.db.cl

if [ "`make_lock $reqf 60`" = "false" ]; then
	echo "Lock the request($reqf) file failed."
	exit 1
fi

rm -rf $ackf > /dev/null 2>&1
rm -f $reqf > /dev/null 2>&1
echo ${thisnode} > $reqf	# This node indicator
echo ${accnt} >> $reqf		# User name to create/initialize
chmod a+w $reqf
unlock.sh $reqf

# Wait ACK return
cnt=60
while [ $cnt -ne 0 ]; do
	if ( test -f "$ackf" -a ! -f "$ackf.lck" ); then
			cnt=999
			break
	fi
	sleep 1
	let cnt=cnt-1
done
if [ $cnt -ne 999 ]; then
	echo "# Connection request time out."
	rm -f $reqf > /dev/null 2>&1
	exit 2
fi

targ=`cat $ackf | tr -d '\r'`
echo "# Connect to $targ."
mode=$monfld/${targ}.db.mode
sv_lck=$lckfld/${targ}.db
rm -rf "$ackf" > /dev/null 2>&1

# msg "# Create client lock file."
if [ "`make_lock $cl_lck 20`" = "false" ]; then
	echo "# Failed to lock client($cl_lck)"
	exit 3
fi

# Wait Results ACK return
cnt=360
while [ $cnt -ne 0 ]; do
	if ( test -f "$ackf" -a ! -f "$ackf.lck" ); then
			cnt=999
			break
	fi
	if [ -f "$mode" ]; then
		crrmode=`head -1 $mode | tr -d '\r'`
		if [ "$crrmode" = "wait" ]; then
			echo "# Server move to wait mode."
			cnt=1
			break
		fi
	else
		lock_ping.sh $sv_lck
		if [ $? -ne 0 ]; then
			echo "# Missing server lock($sv_lck:$?)."
			cnt=1
			break
		fi
	fi
	sleep 1
	let cnt=cnt-1
done
if [ $cnt -ne 999 ]; then
	echo "# Request time out."
	rm -f $reqf > /dev/null 2>&1
	exit 4
fi

if [ -f "$ackf" ]; then
	cat $ackf | while read line; do
		line=`echo $line | tr -d '\r'`
		echo $line
	done
	rm -f $ackf > /dev/null 2>&1
else
	echo "# Failed to read ACK($ackf) file."
	exit 5
fi

unlock.sh $cl_lck

exit 0
