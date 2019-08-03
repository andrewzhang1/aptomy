#!/usr/bin/ksh
# REGMON.SH : Regression monitor
# 
# EXTERNAL REFERENCE
# get_elapsetime.sh
# $VIEW_PATH
# $LOGNAME
# $AP_REGMON_INTERVAL = check interval (default 600 sec = 10 min)
# $AP_REGMON_DEBUG = Debug mode
# $AP_REGMON_CRRSTS_INTERVAL = The interval for creation of current status. (default 30 sec)
#
# HISTORY:
# 08/17/2007	ykono	First edition
# 03/21/2008	YKono	Add making current status file.
# 05/07/2008	ykono	Add sub-script time stamp to crr file.
# Jul. 16, 2008 Ykono - Add "trap 2" for support linux platform.
# 12/24/2008	ykono - Add diff count notification.
# 09/24/2010	YKono	Re-write using new detection method.
# 10/07/2010	YKono	Add check sub-script elapsed time.
# 10/27/2011	YKono	Fix windows mailx to smtpmail
# 03/12/2012	YKono	Add clto_cnt for avoid client_timeout-script_timeout loop
# 03/20/2012	YKono	Wait 30 secs before killing some processes to avoid emtry .xcp fie.
# 2012/10/18    YKono   Implement Bug 14780983 - SUPPORT AIME* USER IN THE E-MAIL TARGET.
# 2012/10/18	YKono	Implement Bug 14781172 - ADD KILLED KIND TO THE SUBJECT OF HANGING UP NOTIFICATION.

trap 'echo "ctrl+C (regmon.sh)"' 2
. apinc.sh

#######################################################################
### FUNCTIONS
#######################################################################

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
		echo "`date +%D_%T`:$@" >> $rglog
		#while [ $# -ne 0 ]; do
		#	echo "`date +%D_%T`:$1" >> $rglog
		#	shift
		#done
	else
		while read _data_; do
			echo "`date +%D_%T`:$_data_" >> $rglog
		done
	fi
}

#######################################################################
# Get mail address for specific user
# If there is no address for loguser, use Admin instead of it
# get_emailaddr <user> <user>...
get_emailaddr ()
{
	_addrlist=
	for _item in $@; do
		if [ "${_item}" = "${_item#*\@}" ]; then
			[ "${_item#aime}" != "$_item" ] && _item="${_item}@`get_platform.sh -l`"
			_targline=`cat "$AP_EMAILLIST" | grep -v "^#" | grep "^${_item}[ 	]" |  tail -1`
			if [ -n "$_targline" ]; then
				_item=`echo "$_targline" | sed -e s/^${_item}//g -e s/#.*$//g \
						-e "s/^[ 	]*//g" -e "s/[ 	]*$//g" -e "s/[ 	][ 	]*/ /g" \
						| tr -d '\r'`
			else
				unset _item
			fi
		fi
		if [ -n "$_item" ]; then
			[ -z "$_addrlist" ] \
				&& _addrlist=$_item \
				|| _addrlist="$_addrlist $_item"
		fi
	done
	if [ -z "$_addrlist" ]; then
		_item=`cat "$AP_EMAILLIST" | grep -v "^#" | grep "^Admin"`
		_addrlist=`echo "$_item" | sed -e s/^Admin//g -e s/#.*$//g \
					-e "s/^[ 	]*//g" -e "s/[ 	]*$//g" -e "s/[ 	][ 	]*/ /g"`
	fi
	echo $_addrlist
}


#######################################################################
# Send e-mail 
# send_email $tmpfile
#   tmpfile format:
#     Line 1: To addresses
#     Line 2: Subject
#     Line 3- Contents
# This routine delete the tmp file. If there is no tmp file, ignore.
send_email()
{
	if [ $# -eq 1 -a -f $1 ]; then
#echo "send_email($1):"
#cat $1 | while read line; do
#	echo "> $line"
#done
		addrs=`head -1 $1 | tr -d '\r'`
		sbj=`head -2 $1 | tail -1 | tr -d '\r'`
		lines=`cat $1 | wc -l`
		let lines=lines-2
		if [ `uname` = "Windows_NT" ]; then
			sndr=`get_emailaddr $LOGNAME`
			tail -${lines} $1 \
				| smtpmail -s "$sbj" -h internal-mail-router.oracle.com -f ${sndr} ${addrs}
		else
			tail -${lines} $1 | mailx -s "$sbj" ${addrs}
		fi
		rm -f $1 > /dev/null 2>&1
	else
		msg "send_email($1):No target file."
	fi
}

#######################################################################
# Post cleaning
post_proc()
{
	unlock.sh $rglck
	psu -ess | egrep -i "esscmd|essmsh" | while read pid cmd; do
		msg "Kill client$(psu | grep ^${pid})"
		kill -9 $pid > /dev/null 2>&1
	done
	kill_essprocs.sh -agtsvr | msg
}

#######################################################################
# Check parent process is exist
ck_parent()
{
	n=`ps -p $ppid -f | grep -v PID`
	if [ -z "$n" ]; then
		msg "Parent($ppid) not found - exit monitor."
		post_proc
		exit 0
	fi
}

#######################################################################
# Kill parent tree (start_regress.sh)
kill_parent()
{
	set_sts KILLING
	pstree.pl -kill $ppid -i $$ | msg
	post_proc
	set_sts KILLED
}

#######################################################################
# Check terminate
ck_terminate()
{
	if [ -f "${rglck}.terminate" ]; then
		msg "Found ${rglck}.terminate file - exit monitor."
		kill_parent
		exit 0
	fi
	if [ "$loop" = "true" -a ! -f "${VIEW_PATH}/autoregress/.sxrrc" ]; then
		msg "Missing .sxrrc file - exit monitor."
		exit 0
	fi
}

#######################################################################
# Check FLAG file.
ck_flag()
{
	f=`get_flag`
	if [ "$f" != "${f#KILL}" ]; then
		msg "Got $f flag - exit monitor."
		kill_parent
		exit 0
	fi
}

#######################################################################
# Get current script hierarchy from .sta file
get_crrscr()
{
	statmp=$HOME/$$.sta.tmp
	rm -rf $statmp 2> /dev/null
	egrep "^\+\+* .*.[sh|ksh]" $target_sta > $statmp
	_crrscr=
	while read mark scr dmy_tm dt_el dmy; do
		if [ "$dt_el" != "Elapsed" ]; then
			_crrscr="$_crrscr/$scr"
		else
			_crrscr=${_crrscr%/*}
		fi
	done < $statmp
	rm -rf $statmp 2> /dev/null
	echo $_crrscr
}

#######################################################################
# Check the elapsed time of the current script from .sta file
# +++ dctp11_aso.sh 280:01:26:50 10_10_07
chk_scr_elapstime()
{
	statmp=$HOME/$$.sta.tmp
	rm -rf $statmp 2> /dev/null
	egrep "^\+\+* .*.[sh|ksh]" $target_sta > $statmp
	_crrscr=
	while read mark scr dmy_tm dt_el dmy; do
		if [ "$dt_el" != "Elapsed" ]; then
			_crrscr="$_crrscr/$scr $dmy_tm $dt_el"
		else
			_crrscr=${_crrscr%/*}
		fi
	done < $statmp
	rm -rf $statmp 2> /dev/null
	sc=`echo $_crrscr | awk '{print $1}'`
	tm=`echo $_crrscr | awk '{print $2}'`
	dt=`echo $_crrscr | awk '{print $3}'`
	secs=`timediff.sh -s "${dt#*_}_${dt%%_*} ${tm#*:}" "$(date +%m_%d_%y\ %T)"`
	if [ "$sec" -gt "$AP_SCRIPT_TIMEOUT" ]; then
		echo "$sc $secs/$AP_SCRIPT_TIMEOUT"
	fi
}

#######################################################################
# Send killed notification
# killnotify <kind> <scr> [ <mess> ]
killnotify()
{
	knd=$1
	shift
	addrs=`get_emailaddr $LOGNAME KilledNotify`
	crr_host=`echo ${reginfo} | awk -F~ '{print $1}'`
	crr_plat=`echo ${reginfo} | awk -F~ '{print $3}'`
	crr_test=`echo ${reginfo} | awk -F~ '{print $5}'`
	rm -rf "$notify_mail" > /dev/null 2>&1
	echo "$addrs"	> "$notify_mail"
	echo "Autopilot Notification (Hangup:$knd) - $ver $bld - $crr_host:$crr_plat $crr_test"	>> "$notify_mail"
	echo "Process Killed notification by hang-up."	>> "$notify_mail"
	echo "  Machine       = $crr_host:$crr_plat"	>> "$notify_mail"
	echo "  Login User    = $LOGNAME"	>> "$notify_mail"
	echo "  Version:Build = $verbld"	>> "$notify_mail"
	echo "  Test Script   = $crr_test"	>> "$notify_mail"
	echo "  Target Script = $1"	>> "$notify_mail"
	echo "  Data/Time     = `date +%D_%T`"	>> "$notify_mail"
	echo "" >> "$notify_mail"
	shift
	while [ $# -ne 0 ]; do
		echo "  $1" >> "$notify_mail"
		shift
	done
	echo "Killed History:"	>> "$notify_mail"
	tail $killrec >> "$notify_mail"
	send_email "$notify_mail"
}

#######################################################################
### START
#######################################################################

loop=false
# DEBUG
echo "debug(START regmon.sh)"
set_vardef AP_REGMON_INTERVAL AP_CRR_INTERVAL AP_CLIENT_TIMEOUT AP_EMAILLIST AP_SCRIPTLIST AP_SCRIPT_TIMEOUT
echo "debug(stg contents)"
cat $AUTOPILOT/mon/$LOGNAME@$(hostname).stg

rgnode=${LOGNAME}@$(hostname)
paramf=$AUTOPILOT/mon/${rgnode}.mon.par					# Parameter file
rglck=$AUTOPILOT/lck/${rgnode}.mon						# Monitor lock target
rglog=$AUTOPILOT/mon/${rgnode}.mon.log					# Monitor LOG
crrfile=$AUTOPILOT/mon/$(hostname)_${LOGNAME}.crr		# Current status file
envfile=$AUTOPILOT/mon/${rgnode}.env					# SXR environment
killrec=$AUTOPILOT/mon/${rgnode}.mon.kill.rec			# Killed record
notify_mail="$AUTOPILOT/tmp/${rgnode}.diffnotify.tmp"	# send e-mail tmp

rm -rf "$rglog" > /dev/null 2>&1
rm -rf "$killrec" > /dev/null 2>&1

msg "### Regression monitor start ###"
msg "rgnode =$rgnode"
msg "rglog  =$rglog"
msg "paramf = $paramf"
msg ".kill.rec =$killrec"
msg ".crr file =$crrfile"
msg ".env file =$envfile"
msg "Mail tmp  =$notify_mail"

#######################################################################
# Lock
ppid=`ps -p $$ -f | tail -1 | awk '{print $3}'`
i=5
mylck=`lock.sh $rglck $$`
sts=$?
while [ $sts -ne 0 -a $i -ne 0 ]; do
	msg "Failed to lock($rglck)=$sts($i)."
	let i=i-1
	sleep 1
	mylck=`lock.sh $rglck $$`
	sts=$?
done

#######################################################################
# Check the AP_DIFFCNT_NOTIFY definition
unset diffcnt
if [ -n "$AP_DIFFCNT_NOTIFY" ]; then
	msg "Found AP_DIFFCNT_NOTIFY"
	[ -f "$notify_mail" ] && rm -f "$notify_mail"
	diffcnt=${AP_DIFFCNT_NOTIFY%% *}
	tmp=${AP_DIFFCNT_NOTIFY#* }
	addrlist=`get_emailaddr $tmp`
	msg " diffcnt=$diffcnt"
	msg " addrlist=$addrlist"
fi

#######################################################################
# Check HP-UX platform. We should enable the XPG4 option for ps command.
if [ `uname` = "HP-UX" ]; then
	# Enable XPG4 options for ps command
	export UNIX95=
	export PATH=/usr/bin/xpg4:$PATH
elif [ `uname` = "AIX" ]; then
	export LC_ALL=C
fi

#######################################################################
# Wait for the regression test started
# Parent process need following steps:
# 1) Delete paramf
# 2) Start monitor
# 3) Wait for regmon lck
# 3) Prepare environment
# 4) Clear $SXR_WORK folder (delete .sog file)
# 5) Create paramf
# 6) Wait for deleting paramf
# 7) Start test
msg "Waiting parameter file($paramf)."
while [ 1 ]; do
	if [ -f "$paramf" ]; then
		lock_ping.sh "$paramf"
		[ $? -ne 0 ] && break
	fi
	ck_parent
	ck_terminate
	ck_flag
	sleep 1
done
msg "Found $paramf."

#######################################################################
# Reading parameter file.
# Line 1:regression info - crr base.
#     1      2     3      4           5      6           7
#    <host>~<usr>~<plat>~<view-path>~<test>~<ver>:<bld>~<st-dttim>
# Line 2:Limit time.
reginfo=`head -1 $paramf`			# Get regression info
timeout=`head -2 $paramf | tail -1`	# Get limitation sec (Got from get_timeout.sh)
rm -rf "$paramf" > /dev/null 2>&1
tartest=`echo $reginfo | awk -F~ '{print $5}'`
verbld=`echo $reginfo | awk -F~ '{print $6}'`
ver=${verbld%:*}
bld=${verbld#*:}
msg "reginfo =$reginfo"
msg "timeout =$timeout"
msg "tartest =$tartest"
msg "verbld  =$verbld"

#######################################################################
# Read env file
msg "Waiting env($envfile) file ready."
while [ ! -f "$envfile" ]; do
	ck_parent
	ck_terminate
	ck_flag
	sleep 1
done
msg "Read env($envfile) file."
unset sxr_work
while read line; do
	var=${line%=*}
	val=${line#*=}
	case $var in
		SXR_WORK)
			sxr_work="$(eval echo $val)"
			;;
	esac
done < "$envfile"
target_sog=$sxr_work/${tartest%%.*}.sog
target_sta=$sxr_work/${tartest%%.*}.sta
msg "SXR_WORK is set to $sxr_work."


#######################################################################
# Waiting .sog is created.
msg "Waiting $target_sog file."
while [ ! -f "$target_sog" ]; do
	ck_parent
	ck_terminate
	ck_flag
	sleep 1
done
msg "Found $target_sog."

#######################################################################
### START MONITORING
msg "### Start monitoring..."
msg "My node       =$rgnode"
msg "Lock file     =$rglck"
msg "timeout       =$timeout"
msg ".crr base     =$reginfo"
msg ".crr file     =$crrfile"
msg ".env file     =$envfile"
msg "Killed Record =$killrec"
msg "Mail tmp      =$notify_mail"
msg "Parent pid    =$ppid"
msg "Version       =$ver"
msg "Build         =$bld"
msg "Target .sog   =$target_sog"
msg "Target .sta   =$target_sta"
msg "DiffCntNotify =$diffcnt"
msg "Hang interval =$AP_REGMON_INTERVAL"
msg "Client timeout=$AP_CLIENT_TIMEOUT"
msg "Script timeout=$AP_SCRIPT_TIMEOUT"
msg "Crr interval  =$AP_CRR_INTERVAL"
msg "#######################################################################"

clto_cnt=0
loop=true
act=check
while [ "$loop" = "true" ]; do
	ck_parent
	ck_terminate
	ck_flag
	case $act in
		check)	# Elapse time check
			etime=`get_elapsetime.sh $target_sog`
			if [ $etime -gt $AP_CLIENT_TIMEOUT ]; then
				act=client_timeout
			elif [ $etime -gt $timeout ]; then
				act=hang_test
			else
				act=wait
			fi
			;;
	
		hang_test)
			msg "Hanging test.(elap:$etime,timeout:$timeout)."
			sts=false
			crrscr=`get_crrscr`
			msg "Current script:$crrscr"
			apps=`sv_crrapp.sh`
			msg "Apps:" $apps
			if [ -n "$apps" ]; then
				act=wait
				msg "Doing app hang test."
				for app in $apps; do
					# msg "Test $app"
					sts=`sv_hang_test.sh $ver -a $app`
					if [ "$sts" = "agent" -o "$sts" = "login" ]; then
						msg "Found agent hang($sts) at app($app) test."
						act=agent_hang_proc
						break
					elif [ "$sts" != "false" ]; then
						msg "<$app> - hang."
						sleep 30
						kill_essprocs.sh $app | msg
						echo "`date +%D_%T`:$crrscr/<$app>" >> "$killrec"
						killnotify "APP:$app" $crrscr "Killed application:$app"
						cnt=`grep "^../../.._..:..:..:$crrscr/<$app>\$" "$killrec" 2> /dev/null | wc -l`
						let cnt=cnt
						msg " $app killed count=$cnt"
						[ $cnt -ge 3 ] && act=agent_hang_test || act=check
						break
					else
						msg "<$app> - alive."
					fi
				done
			else
				act=agent_hang_test
			fi
			;;
	
		agent_hang_test|agent_hang_proc)
			if [ "$act" = "agent_hang_test" ]; then
				agt=`sv_crragt.sh`
				if [ -n "$agt" ]; then
					msg "Agent hang test ($agt)"
					sts=`sv_hang_test.sh $ver`
				fi
			fi
			act=wait
			if [ "$sts" != "false" ]; then
				msg "- Failed to login."
				sleep 30
				kill_essprocs.sh -agtsvr | msg
				echo "`date +%D_%T`:$crrscr/[agent]" >> "$killrec"
				cnt=`grep "^../../.._..:..:..:$crrscr/\[agent\]\$" "$killrec" 2> /dev/null | wc -l`
				let cnt=cnt
				msg "Agent killed count=$cnt"
				[ $cnt -ge 3 ] && act=client_timeout || act=check
				killnotify "AGENT" $crrscr "Found agent hang-up and killed agent." "Agent killed count=$cnt" "Next act=$act"
			fi
			;;
	
		client_timeout)
			let clto_cnt=clto_cnt+1
			msg "Client timeout.(elap:$etime,timeout:$AP_CLIENT_TIMEOUT)."
			act=wait
			psu -ess | egrep -i "esscmd|essmsh" | while read pid cli; do
				klltrg=`psu | grep ^$pid`
				msg "Killing $pid:$cli:$klltrg"
				sleep 30
				kill -9 $pid > /dev/null 2>&1
				echo "`date +%D_%T`:$crrscr/[client] $pid:$cli:$klltrg" >> "$killrec"
				cnt=`grep "^../../.._..:..:..:$crrscr/\[client\]" "$killrec" 2> /dev/null | wc -l`
				let cnt=cnt
				msg "Cleint killed count=$cnt"
				killnotify "CLI:$cli" $crrscr "killtarget=$pid:$cli:$klltrg" "elapsed time=$etime($AP_CLIENT_TIMEOUT)" "Killed count=$cnt"
				if [ $cnt -ge 3 ]; then
					break
				fi
			done
			cnt=`grep "^../../.._..:..:..:$crrscr/\[client\]" "$killrec" 2> /dev/null | wc -l`
			let cnt=cnt
			if [ $clto_cnt -gt 3 ]; then
				act=script_timeout
				skeep 30
				kill_essprocs.sh -agtsvr | msg
			else
				act=check
			fi
			;;
	
		script_timeout)
			clto_cnt=0
			act=check
			while [ 1 ]; do
				cnt=`grep "^../../.._..:..:..:$crrscr\$" "$killrec" 2> /dev/null | wc -l`
				let cnt=cnt
				msg "$crrscr killed count=$cnt"
				if [ $cnt -lt 3 ]; then
					msg "Killing script $crrscr."
					scrpid=`pstree.pl $ppid | grep "sxr sh" | grep ${crrscr##*/}`
					if [ -n "$scrpid" ]; then
						killpid=`echo $scrpid | awk '{print $1}'`
						sleep 30
						pstree.pl -kill $killpid | msg
						echo "`date +%D_%T`:$crrscr" >> "$killrec"
						killnotify "SCR:${crrscr##*/}" $crrscr "Target : $scrpid"
						break
					fi
				fi
				crrscr=${crrscr%/*}
				if [ -z "$crrscr" ]; then
					msg "Killing script start_regress.sh."
					sleep 60
					kill_parent
					echo "`date +%D_%T`:start_regress.sh" >> "$killrec"
					killnotify "SCR:start_regress.sh" $crrscr "Terminate the root test."
					exit 0
				fi
			done
			;;
	
		wait)	# Waiting loop for the next check (AP_REGMON_INTERVAL)
			act=check
			crrtime=`crr_sec`
			snaptime=$crrtime
			inttime=`expr $crrtime + $AP_REGMON_INTERVAL 2> /dev/null`
			while [ "$crrtime" -lt "$inttime" ]; do
				if [ ! -f "$sxr_work/../.sxrrc" ]; then
					msg "Found .sxrrc is missing. Test might be done - exit monitoring loop."
					loop=false
					break
				fi
				ck_parent
				ck_terminate
				ck_flag
				# Create current status file
				if [ "$crrtime" -ge "$snaptime" ]; then
					snaptime=`expr $crrtime + $AP_CRR_INTERVAL`
					if [ -f "$target_sta" ]; then
						ts=`date '+%m_%d_%y %H:%M:%S'`
						subl=`egrep "^\+\+* .*.[sh|ksh]" ${target_sta} | grep -v "Elapsed" | tail -1`
						subs=`echo $subl | awk '{print $2}'`
						stm=`echo $subl | awk '{print $3}'`
						sdt=`echo $subl | awk '{print $4}'`
						stm=${stm#*:}
						sdt=`echo $sdt | awk -F_ '{print $2"_"$3"_"$1}'`
						subts="${sdt} ${stm}"
						difc=`ls $sxr_work/*.dif 2> /dev/null | wc -l | sed -e "s/ //g"`
						succ=`ls $sxr_work/*.suc 2> /dev/null | wc -l | sed -e "s/ //g"`
						echo "${reginfo}~${subs}~${succ}~${difc}~${ts}~${subts}" > "$crrfile"
						if [ -n "$diffcnt" -a "$difc" -gt "$diffcnt" ]; then
							crr_host=`echo ${reginfo} | awk -F~ '{print $1}'`
							crr_plat=`echo ${reginfo} | awk -F~ '{print $3}'`
							crr_verbld=`echo ${reginfo} | awk -F~ '{print $6}'`
							crr_test=`echo ${reginfo} | awk -F~ '{print $5}'`
							crr_ver=${crr_verbld%:*}
							crr_bld=${crr_verbld#*:}
							echo "$addrlist" > "$notify_mail"
							echo "Autopilot Notification (DiffCnt over) - $crr_ver $crr_bld - $crr_host:$crr_plat $crr_test" >> "$notify_mail"
							echo "Total diff count exceeded on following test."		>> "$notify_mail"
							echo "  Machine         = $crr_host:$crr_plat"	>> "$notify_mail"
							echo "  Login User      = $LOGNAME"					>> "$notify_mail"
							echo "  Version:Build   = $crr_verbld"			>> "$notify_mail"
							echo "  Test Script     = $crr_test"					>> "$notify_mail"
							echo "  Sub Script      = $subs"					>> "$notify_mail"
							echo "  Suc/Dif count   = $succ/$difc (threshold:$diffcnt)" >> "$notify_mail"
							echo "  Data/Time       = `date +%D_%T`" >> "$notify_mail"
							send_email "$notify_mail"
							unset diffcnt addrlist
						fi
					fi
				fi
				sleep 15
				crrtime=`crr_sec`
			done
			;;
		*)
			msg "Wrong action($act)."
			;;
	esac
	sleep 5
done

#######################################################################
# Waiting start_regress.sh done
msg "Waiting for done start_regress.sh."
while [ 1 ]; do
	ck_parent
	ck_terminate
	ck_flag
	sleep 1
done

