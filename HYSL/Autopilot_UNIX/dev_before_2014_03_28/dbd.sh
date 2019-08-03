#!/usr/bin/ksh
#######################################################################
# dbd.sh : Database deamon
# Description:
#   This script run as service and accept new user creation request
#   from regression machine. Also provide RCU creation.
#
# Syntax: dbd.sh [-h|-l <logf>|-pid <pid>|-own|-pwd <pwd>]
# Options:
#  -h         : display help"
#  -l <logf>  : Write output to <logf>."
#  -pid <pid> : Audit process id."
#  -own       : Check own request only
#  -pwd <pwd> : Set default password
# Request file:
# Line 1: Requested node
# Line 2: Name to create
#         If "Name to create" is "RCU7:..." or "RCU6:...",
#         this program run RCU and return prefix
#         RCU7:<name>
#         When <name> is blank, This tool create A### prefix
#
# You need to create $HOME/vardef.txt with following contents
# vardef.txt variable:
#   AP_HSSCONSTR=<db-kind>:<db-host>:<db-port>:<sid>:<sys-usr>:<sys-pwd>
#   AP_BICONSTR=<db-kind>:<db-host>:<db-port>:<sid>:<sys-usr>:<sys-pwd>:<role>:<rec-fnm>:<method>
#   RCU6=<rcu6-tool-abusolute-path>
#   RCU7=<rcu7-tool-abusolute-path>
#   <db-kind> : Database kind. ora=Oracle, sql=MS SQL Server, db2=IBM DB2...
#   <db-host> : Hostname or IP address for RDBMS machine.
#   <db-port> : Port value to connect.
#   <sys-usr> : System user name or user name which has DBA role
#   <sys-pwd> : Password for <sys-usr>
#   <role>    : DB role of <sys-usr>
#   <rec-fnm> : Crated record file name.
#   <method>  : Method to handle <rec-fnm>.
#               =line : Each line has a node name and use that line number as prefix
#               =incr : Use maxmum line number for prefix
#   Sample:
#     AP_HSSCONSTR=ora:10.148.218.133:1521:reg:regress:password
#     AP_BICONSTR=ora:10.148.218.133:1521:regbi:SYS:password:SYSDBA:my_bilist:incr
#     RCU6=C:/Users/regryk1/rcu6/BIN/rcu.bat
#     RCU7=C:/Users/regryk1/rcu7/BIN/rcu.bat
# HISTORY: #############################################################
# 03/09/2011 YKono	First Edition
# 03/11/2011 YKono	Add wait_my_req mode and new name handling.
# 06/05/2013 YKono	Support execute RCU
#     			Bug 16908191 - AUTOPILOT SUPPORT REPOSITORY CREATION SERVICE AS DEAMON.

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
dbg=false
defpwd="password"
set_vardef AP_HSSCONSTR AP_BICONSTR RCU7 RCU6
monfld=$AUTOPILOT/mon	# Monitor files location
lckfld=$AUTOPILOT/lck	# Lock files location
logfile=		# Logfile

# Each request file names and read lock file names
#   local request
req="$monfld/db.req"
rlck="$lckfld/db.req.read"
myreq="$monfld/${thisnode}.db.req"
mrlck="$lckfld/${thisnode}.db.req.read"

# Interface files
mysts="$monfld/${thisnode}.db.sts"
mymode="$monfld/${thisnode}.db.mode"

# Lock file for this program - for StayAliveCheck
mylock="$lckfld/${thisnode}.db"

#######################################################################
# Read parameter
myreqonly="false"
while [ $# -ne 0 ]; do
	case $1 in
		+d|-dbg)	dbg=true;;
		-d|-nodbg)	dbg=false;;
		-h)	display_help.sh $me; exit 0;;
		-l)	
			if [ $# -lt 2 ]; then
				echo "'-l' option need log file name as 2nd parameter."
				exit 1
			fi
			shift
			logfile=$1
			;;
		-own)	myreqonly="true" ;;
		-p|-pwd|-defpwd)
			if [ $# -lt 2 ]; then
				echo "'-pid' need 2nd parameter as default password."
				exit 1
			fi
			shift
			defpwd=$1
			;;
		-pid)
			if [ $# -lt 2 ]; then
				echo "'-pid' need 2nd parameter as audit process id."
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
[ "$dbg" = "true" ] && echo "# Org AP_BICONSTR=$AP_BICONSTR"
case $AP_BICONSTR in
	*:*:*:*:*:*:*:*:*)
		[ "$dbg" = "true" ] && echo "# Full definition."
		;;
	*:*:*:*:*:*:*:*)	# Skip <rec-fnm> or <method>
		[ "$dbg" = "true" ] && echo "# Skip <rec-fnm> or <method>"
		lastone=${AP_BICONSTR##*:}
		if [ "$lastone" = "incr" -o "$lastone" = "line" ]; then
			# Add default <rec-fnm>
			export AP_BICONSTR="${AP_BICONSTR%:*}:$(hostname):$lastone"
		else
			# Add default <method> (incr)
			export AP_BICONSTR="${AP_BICONSTR}:incr"
		fi
		;;
	*:*:*:*:*:*:*)		# Skip <rec-fnm> and <method>
		[ "$dbg" = "true" ] && echo "# Skip <rec-fnm> and <method>"
		export AP_BICONSTR="${AP_BICONSTR}:$(hostname):incr"
		;;
	*)
		[ "$dbg" = "true" ] && echo "# Other definition."
		;;
esac
unset bi_kind bi_host bi_port bi_sid bi_usr bi_pwd bi_role bi_recf bi_method
unset hss_kind hss_host hss_port hss_sid hss_usr hss_pwd
s=$AP_HSSCONSTR
hss_kind=${s%%:*}; s=${s#*:}
hss_host=${s%%:*}; s=${s#*:}
hss_port=${s%%:*}; s=${s#*:}
hss_sid=${s%%:*}; s=${s#*:}
hss_usr=${s%%:*}; s=${s#*:}
hss_pwd=$s
s=$AP_BICONSTR
bi_kind=${s%%:*}; s=${s#*:}
bi_host=${s%%:*}; s=${s#*:}
bi_port=${s%%:*}; s=${s#*:}
bi_sid=${s%%:*}; s=${s#*:}
bi_usr=${s%%:*}; s=${s#*:}
bi_pwd=${s%%:*}; s=${s#*:}
bi_role=${s%%:*}; s=${s#*:}
bi_recf=${s%%:*}; s=${s#*:}
bi_method=$s

hss_okind=$hss_kind
bi_okind=$bi_kind
case $hss_kind in
	ora)	hss_kind=oracle;;
	sql)	hss_kind=mssql;;
	db2)	hss_kind=db2;;
esac
case $bi_kind in
	ora|oracle)	bi_kind="Oracle Database";;
	sql|mssql)	bi_kind="Microsoft SQL Server";;
	db2|ibm)	bi_kind="IBM DB2";;
esac
if [ "$dbg" = "true" ]; then
	echo "# ${me##*/} $orgpar"
	echo "# ppid=$ppid"
	echo "# logfile=$logfile"
	echo "# myreqonly=$myreqonly"
	echo "# hss_kind=$hss_kind"
	echo "# hss_host=$hss_host"
	echo "# hss_port=$hss_port"
	echo "# hss_sid=$hss_sid"
	echo "# hss_usr=$hss_usr"
	echo "# hss_pwd=$hss_pwd"
	echo "# bi_kind=$bi_kind"
	echo "# bi_host=$bi_host"
	echo "# bi_port=$bi_port"
	echo "# bi_sid=$bi_sid"
	echo "# bi_usr=$bi_usr"
	echo "# bi_pwd=$bi_pwd"
	echo "# bi_role=$bi_role"
	echo "# bi_recf=$bi_recf"
	echo "# bi_method=$bi_method"
	echo "# AP_HSSCONSTR=$AP_HSSCONSTR"
	echo "# AP_BICONSTR=$AP_BICONSTR"
	echo "# RCU6=$RCU6"
	echo "# RCU7=$RCU7"
	echo "# req=$req"
	echo "# rlck=$rlck"
	echo "# myreq=$myreq"
	echo "# mrlck=$mrlck"
	echo "# mysts=$mysts"
	echo "# mymode=$mymode"
	echo "# mylock=$mylock"
	echo "# defpwd=$defpwd"
fi

# Check another dbd.sh exists on this machine
lock_ping.sh $mylock > /dev/null
if [ $? -eq 0 ]; then
	echo "There is another dbd.sh on ${thisnode}."
	[ -f "$mylock.lck" ] && (IFS= ; cat "$mylock.lck" | while read line; do echo "> $line"; done)
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
msg "dbd.sh start on ${thisnode}($$)."

while [ 1 ]; do
	# Parent check
	ppidchk=`ps -p $ppid | grep -v PID`
	if [ -z "$ppidchk" ]; then
		msg "Missing audit processes($ppid). Terminate this program."
		break
	fi
	case $mode in
		check_my_req|check_req)
			case $mode in
				check_my_req)	reqf=$myreq; lckf=$mrlck;;
				check_req)	reqf=$req; lckf=$rlck;;
			esac
			[ "$mode" = "check_my_req" -a "$myreqonly" = "false" ] && mode=check_req || mode=wait
			if [ -f "$reqf" -a ! -f "$reqf.lck" ]; then
				lock.sh $lckf $$ > /dev/null 2>&1	# Start to read request
				if [ $? -eq 0 ]; then
					reqnode=`head -1 $reqf | tr -d '\r'`
					reqname=`head -2 $reqf | tail -1 | tr -d '\r'`
					msg "Found my request(${reqf##*/}) from ${reqnode}."
					do_req=true
					if [ "${reqname#RCU7:}" != "$reqname" -a ! -x "$RCU7" ]; then
						do_req=false
					elif [ "${reqname#RCU6:}" != "$reqname" -a ! -x "$RCU6" ]; then
						do_req=false
					fi
					if [ "$do_req" = "true" ]; then
						ack=$monfld/${reqnode}.db.ack
						clientl=$lckfld/${reqnode}.db.cl
						lock.sh $ack $$ > /dev/null 2>&1
						if [ $? -eq 0 ]; then
							### Create ACK file
							rm -rf $ack > /dev/null 2>&1
							touch $ack > /dev/null 2>&1
							chmod a+w $ack > /dev/null 2>&1
							echo ${thisnode} >> $ack
							rm -f $reqf > /dev/null 2>&1
							mode=wait_client_lock
							echo $mode > $mymode
							cnt=60
							unlock.sh $ack
						else
							msg "Failed to lock ACK($ack) file."
						fi
						unlock.sh $lckf
					else
						msg "Cannot run ${reqname%%:*} on this machine."
						unlock.sh $lckf
						sleep 10	# Expect other machine can get it.
					fi
				else
					msg "Failed to lock read request($lckf)."
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
				lock_ping.sh $clientl 2> /dev/null
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
				if [ "${reqname#RCU?:}" != "$reqname" ]; then
					rcuver=${reqname%%:*}
					prf=${reqname##*:}
					msg "RCU Version=$rcuver"
					msg "Prefix=<$prf>"
					prg=
					case $rcuver in
						RCU6)	prg=$RCU6; px=A;;
						RCU7)	prg=$RCU7; px=B;;
					esac
					sts=9
					if [ -x "$prg" ]; then
						if [ -z "$prf" ]; then
							if [ "$bi_method" = "line" ]; then
								prf=`grep -n "$reqnode" $HOME/${bi_recf}_${rcuver}.txt \
									2> /dev/null | tail -1`
								if [ -z "$prf" ]; then
									echo "$reqnode" >> $HOME/${bi_recf}_${rcuver}.txt 2> /dev/null
									prf=`grep -n "$reqnode" $HOME/${bi_recf}_${rcuver}.txt | tail -1`
								fi
								prf=${prf%%:*}
							else
								prf=`wc -l $HOME/${bi_recf}_${rcuver}.txt 2> /dev/null | awk '{print $1}'`
								let prf=prf+1
								echo "$reqnode" >> $HOME/${bi_recf}_${rcuver}.txt 2> /dev/null
							fi
							prf="0000${prf}"
							prf="${px}${prf#${prf%???}}"
							msg "New Prefix=<$prf>"
						fi
						msg "### Drop previous Repository($bi_usr) ###"
						echo $bi_pwd | $prg -silent -dropRepository \
							-connectString "${bi_host}:${bi_port}:${bi_sid}" \
							-dbRole $bi_role \
							-dbUser $bi_usr \
							-schemaPrefix $prf \
							-component BIPLATFORM \
							-component MDS
						msg "- DropRpository sts=$?"
						msg "### Create new Repository($bi_usr) ###"
						(echo $bi_pwd; echo $defpwd; echo $defpwd) | $prg -silent -createRepository \
							-connectString "${bi_host}:${bi_port}:${bi_sid}" \
							-dbRole $bi_role \
							-dbUser $bi_usr \
							-schemaPrefix $prf \
							-component BIPLATFORM \
							-component MDS 
						sts=$?
						msg "- CreateRepository sts=$sts"
					fi
					rm -f $ack > /dev/null 2>&1
					touch $ack
					chmod a+w $ack
					if [ "$sts" -eq "0" ]; then
						echo "constr=${bi_okind}:${bi_host}:${bi_port}:${bi_sid}" >> $ack
						echo "bi=${prf}_BIPLATFORM" >> $ack
						echo "mds=${prf}_MDS" >> $ack
						echo "pwd=${defpwd}" >> $ack
						echo "DATABASE_CONNECTION_STRING_BI=${bi_host}:${bi_port}:${bi_sid}" >> $ack
						echo "DATABASE_TYPE_BI=${bi_kind}" >> $ack
						echo "DATABASE_SCHEMA_USER_NAME_BI=${prf}_BIPLATFORM" >> $ack
						echo "DATABASE_SCHEMA_PASSWORD_BI=${defpwd}" >> $ack
						echo "DATABASE_CONNECTION_STRING_MDS=${bi_host}:${bi_port}:${bi_sid}" >> $ack
						echo "DATABASE_TYPE_MDS=${bi_kind}" >> $ack
						echo "DATABASE_SCHEMA_USER_NAME_MDS=${prf}_MDS" >> $ack
						echo "DATABASE_SCHEMA_PASSWORD_MDS=${defpwd}" >> $ack

					fi
					echo "sts=$sts" >> $ack
				else
					sqlf=$HOME/.dbd.$$.tmp.sql
					rm -f $sqlf > /dev/null 2>&1
					echo "DROP USER ${reqname} CASCADE;" > $sqlf
					echo "CREATE USER ${reqname} IDENTIFIED BY $defpwd;" >> $sqlf
					echo "GRANT DBA, CONNECT TO ${reqname} WITH ADMIN OPTION;" >> $sqlf
					echo "QUIT;" >> $sqlf
					cat $sqlf | msg
					echo "$hss_usr" > pwd
					echo "$hss_pwd" >> pwd
					sqlplus $hss_usr/$hss_pwd@$hss_sid @${sqlf} < pwd
					sts=$?
					rm -f $sqlf > /dev/null 2>&1
					rm -f $ack > /dev/null 2>&1
					touch $ack
					chmod a+w $ack
					echo "jdbcUrl=jdbc:$hss_kind:thin:$hss_host:$hss_port:$hss_sid" > $ack
					echo "host=$hss_host" >> $ack
					echo "port=$hss_port" >> $ack
					echo "dbName=$hss_sid" >> $ack
					echo "userName=${reqname}" >> $ack
					echo "password=$defpwd" >> $ack
					echo "sts=$sts" >> $ack
				fi
				unlock.sh $ack
				msg "Done creation ${reqname} for ${reqnode} - move to wait_client_leave mode."
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
	esac
done
exit 0
