#!/usr/bin/ksh
# File : sv_hang_test.sh
# Auther : Yukio Kono
#
# History :
# 2010/09/24 YKono	First Edition
# 2014/03/13 YKono	Bug 18383946 - REGRESSION MONITOR SHOULD RE-TRY THE AGENT/SERVER HANGING-UP TEST

. apinc.sh

orgpar=$@
unset ver app
while [ $# -ne 0 ]; do
	case $1 in
		-a)
			if [ $# -lt 2 ]; then
				echo "-a need <app> parameter."
				exit 1
			fi
			shift
			app=$1
			;;
		*)
			if [ -n "$ver" ]; then
				echo "Too many parameter."
				exit 1
			fi
			ver=$1
			;;
	esac
	shift
done

if [ -z "$ver" ]; then
	echo "No <ver> parameter"
	exit 2
fi
		
. se.sh $ver -nomkdir > /dev/null 2>&1

if [ ! -d "$ARBORPATH" ]; then
	echo "No \$ARBORPATH folder."
	exit 3
fi
apid=${app#*:}
app=${app%:*}
retrycnt=3
unset svruser svrhost svrpwd
svruser=$SXR_USER
svrpwd=$SXR_PASSWORD
svrhost=$SXR_DBHOST
[ -z "$svruser" ] && svruser=essexer
[ -z "$svrhost" ] && svrhost=$(hostname)
[ -z "$svrpwd" ] && svrpwd=password

dt=`date +%m%d%y-%H%M%S`
log="$sxr_work/healthcheck-$dt.log"
scr="$sxr_work/healthcheck-$dt.scr"
rm -rf $log > /dev/null 2>&1
rm -rf $scr > /dev/null 2>&1

echo "Login \"$svrhost\" \"$svruser\" \"$svrpwd\";" >> "$scr"
[ -n "$app" ] && echo "qGetAppInfo \"${app}\";" >> "$scr"
echo "Exit;" >> "$scr"

# Get netdelay and netretry count from server
timeout=`sv_get_timeout.sh`
while [ $retrycnt -ne 0 ]; do
	hang=false
	if [ -n "`ps -p $apid 2> /dev/null | grep -v PID`" ]; then
		sttime=`crr_sec`
		let limit=sttime+timeout
		ESSCMDQ "$scr" > "$log" &
		pid=$!
		while [ 1 ]; do
			q=`ps -p $pid 2> /dev/null | grep -v PID`
			if [ -z "$q" ]; then
				break
			fi
			crrtime=`crr_sec`
			if [ $crrtime -gt $limit ]; then
				kill -9 $pid > /dev/null 2>&1
				hang=agent
				break
			fi
			sleep 1
		done
		if [ "$hang" = "false" ]; then
			if [ -f "$log" ]; then
				l=`grep "^Network error" "$log"`
				[ -z "$l" ] && l=`grep "^Login fails" "$log"`
				if [ -n "$l" ]; then
					hang=login
				elif [ -n "$app" ]; then
					a=`grep "^Name            : $app" "$log"`
					[ -z "$a" ] && hang=app
				fi	
			else
				hang=CMDQ
			fi
		else
			if [ -f "$log" ]; then
				fsz=`ls -l "$log" | awk '{print $5}'`
				[ "$fsz" != "0" ] && hang=true
			fi
		fi
	fi
	if [ "$hang" = "false" ]; then
		retrycnt=0
	else
		let retrycnt=retrycnt-1
		sleep 120
	fi
done
echo "$hang"
if [ "$hang" = "false" ]; then
	rm -rf "$log" > /dev/null 2>&1
	rm -rf "$scr" > /dev/null 2>&1
	# mv $log $log.ok
	# mv $scr $scr.ok
fi

# Exit values:
# false = no hang
# agent = Agent hang
# true  = APP hang
# app   = app problem
# login = login failure
# CMDQ  = Failed to launch ESSCMDQ

############
### DATA ###
############

# Success Case ------------------------------
#:::[0]->login localhost essexer password
#Login:
#
#
#[Fri Sep 24 18:40:49 2010]Local////Info(1051034)
#Logging in user [essexer]
#
#
#[Fri Sep 24 18:40:49 2010]Local////Info(1051035)
#Last login on Friday, September 24, 2010 6:40:49 PM
#
#
#Available Application Database:
#Microacc                      ==> Basic
#Dmccalis                      ==> Dmccalis
#Dmpckapp                      ==> Basic
#Ddxi2GIG                      ==> Ddxi2GIG
#Ddxi2GIG                      ==> Sample
#Dmccpf                        ==> Dmccpf
#
#
#localhost:::essexer[1]->

#qGetAppInfo:
#
#
#-------Application Info-------
#
#Name            : Dxmdxlv1
#Server Name     : issol13
#Status          : Loaded
#Elapsed App Time: 00:00:04:31
#Users Connected : 1
#Number of DBs   : 1
#App Type        : non-Unicode
#App Locale      : Japanese_Japan.MS932@Binary
#
#--List of Databases--
#
#Database (0)    : Dxmdxlv1

# APP hang case -------------------------------
#$ rm $HOME/hangtest.*;sv_hang_test.sh talleyrand_sp1 -a Dxmdxlv1; cat ~/hangtest*log
#true
#
#Available Application Database:
#Dxmdxlv1                      ==> Dxmdxlv1
#Dxmdxlv2                      ==> Dxmdxlv2
#

# AGENT hang case (login faulure) --------------
#$ rm $HOME/hangtest.*;sv_hang_test.sh talleyrand_sp1 -a Dxmdxlv1; cat ~/hangtest*log
#true
#$ ls -l ~
#total 8
#-rw-r--r--   1 ykono    sxrdev         0 Sep 28 15:54 hangtest.0000.log
#-rw-r--r--   1 ykono    sxrdev        68 Sep 28 15:54 hangtest.0000.scr
#

# Each commands Fail case ----------------------
#:::[0]->login  asdfasf essexer password
#Login:
#
#[Fri Sep 24 18:17:08 2010]Local////Error(1042032)
#Network Error: Unable to detect ESSBASE server listening on IPv4 or IPv6 network protocols on hostname - [asdfasf]
#
#Command Failed. Return Status = 1042032

#:::[0]->login localhost yukio mokeke
#Login:
#
#
#[Fri Sep 24 18:18:30 2010]Local////Error(1051293)
#Login fails due to invalid login credentials
#
#Command Failed. Return Status = 1051293

#:::[0]->login localhost:2222 essexer password
#Login:
#
#
#[Fri Sep 24 18:30:24 2010]Local////Error(1042006)
#Network error [10061]: Unable to connect to [localhost:2222].  The client timed out waiting to connect to Essbase Agent using TCP/IP.
#Check your network connections. Also make sure that server and port values are correct
#
#Command Failed. Return Status = 1042006

#qGetAppInfo:
#
#
#[Thu Sep 23 11:29:32 2010]issol13///essexer/Error(1051030)
#Application Dxmdxlv3 does not exist
#
#Command Failed. Return Status = 1051030

# 1) Hanging up
#    1-1) if log file is not created, can assume ESSCMDQ failed to start
#    1-2) if log file size is 0, can assume login is hanging up.
#    1-3) Otherwise, can assume APP(gGetAppInfo) is hannging up.
# 2) Login failure
#    2-1) if log file contain "^Network error" or "^Login fails", can assume login failure.
#    2-2) otherwise, login worked fine.
# 3) GetAppInfo failure
#    3-1) if log file contain "^Name            : ${app}", can assume APP works fine.
#    3-2) otherwise, can assume APP has problem.

