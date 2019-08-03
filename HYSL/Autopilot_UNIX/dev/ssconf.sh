#!/usr/bin/ksh
# ssconf.sh : Initilize HSS
# Syntax : ssconf.sh [-h] $VER
# Description:
#     This command uses $AUTOPILOT/rsp/conf.xml replaced following variables.
# Replaced variables:
# (Shared Services)
#  %HOST%           = $(hostname) # This host name
#  %EPM_PORT%       = 7001+$AP_AGENTPORT
#  %SS_PORT%        = 28080+$AP_AGENTPORT
#  %SS_SPORT%       = 28443+$AP_AGENTPORT
#  %MIDDLEWARE_LOC% = ${HYPERION_HOME%/*}
#  %CMPCT_PORT      = 9000+$AP_AGENTPORT
#  %CMPCT_SPORT     = 9443+$AP_AGENTPORT
#  %OHS_PORT%       = 19000+$AP_AGENTPORT
# (Repository RDBMS)
#  %DB_KIND%        = ORACLE
#  %DB_NAME%        = regress
#  %DB_HOST%        = scl14152
#  %DB_URL%         = jdbc:oracle:thin:@$(hostname):1521:regress
#  %DB_PORT%        = 1521
#  %DB_USER%        = ${LOGNAME}_$(hostname)
#  %DB_PASSWORD%    = password
# (ESSBASE)
#  %AGENT_PORT%     = $AP_AGENTPORT
#  %SSL_PORT%       = 6000+$AP_AGENTPORT
#  %START_PORT%     = 32768
#  %END_PORT%       = 33768
#  %ESSLANG%        = English_UnitedStates.Latin1@Binary
#  %PASSWORD%       = password
# (EAS)
#  %EAS_PORT%       = 10080
#  %EAS_SPORT%      = 10083
# (APS)
#  %APS_PORT%       = 13080
#  %APS_SPORT%      = 13083
# NOTE1:
#   conf.xml has %MIDDLEWARE_LOC%\wlserver_10.3 for the WebLogic
#   location. When the version of WebLogic will be changed, we
#   need new conf.xml file.
# NOTE2:
#   ssconf.sh need to Essbase envrionment. So, you need execute
#   se.sh before this script.
# Exit:
#   0 : Initialized fine
#   1 : Too many parameter = syntax error.
#   2 : Envrionment variable not set.
#   3 : ssconf.sh not support this version
#   4 : Installation by refresh command
#   5 : Installation is not by autopilot framework
#   6 : No configtool.sh[.bat] under the HH/common
#   7 : Failed to get DB user (from dbreq.sh)
#   8 : Return error from configtool.
#
#######################################################################
# History:
# 03/15/2011 YK Fist edition. 

. apinc.sh

#######################################################################
# Check the Parameter (err=1)
#######################################################################
me=$0
orgpar=$@
rspf=
dbg=true
unset db_host
#######################################################################
# Variables
#######################################################################

# port will add $AP_AGENTPORT to that value
vlist=
vlist="$vlist!epm_port=7001"
vlist="$vlist!epm_user=epm_admin"
vlist="$vlist!epm_password=password123"
vlist="$vlist!ss_port=28080"
vlist="$vlist!ss_sport=28443"
vlist="$vlist!aps_port=13080"
vlist="$vlist!aps_sport=13083"
vlist="$vlist!eas_port=10080"
vlist="$vlist!eas_sport=10083"
vlist="$vlist!ohs_port=19000"
vlist="$vlist!ohs_sport=19443"
vlist="$vlist!cmpct_port=9000"
vlist="$vlist!cmpct_sport=9443"
# ESSBASE
vlist="$vlist!agent_port=0"
vlist="$vlist!ssl_port=6000"
vlist="$vlist!start_port=32768"
vlist="$vlist!end_port=33768"
vlist="$vlist!password=password"
[ -n "$ESSLANG" ] && vlist="$vlist!esslang=$ESSLANG" \
	|| vlist="$vlist!esslang=English_UnitedStates.Latin1@Binary"
vlist="$vlist!adm_user=admin"
vlist="$vlist!adm_password=password"
# etc...
vlist="$vlist!middleware_loc=${HYPERION_HOME%/*}"
vlist="$vlist!tmp=${TMP}"
vlist="$vlist!host=$(hostname)"
vlist="$vlist!"
# RDBMS
vlist="$vlist!db_kind=ORACLE!db_host=!db_port=!db_name=!db_user=!db_password=!db_url=!"

isvar()
{
	if [ "${vlist#*!${1%%=*}=}" != "$vlist" ]; then
		echo $1
	fi
}

# Set each variables
_vlist="$vlist"
while [ -n "$_vlist" ]; do
	_vlist="${_vlist#!}"
	vn="${_vlist%%=*}"
	_vlist="${_vlist#*=}"
	vl="${_vlist%%!*}"
	_vlist="${_vlist#*!}"
	export $vn="$vl"
done

while [ $# -ne 0 ]; do
	case $1 in
		`isvar $1`)
			vn=${1%%=*}
			vl=${1#*=}
			export $vn="$vl"
			;;
		-h)
			display_help.sh $me
			exit 0
			;;
		-dbg)
			dbg=true
			;;
		-dbgexit)
			dbg=exit
			;;
		-nodbg)
			dbg=false
			;;
		-rsp)
			shift
			if [ $# -eq 0 ]; then
				echo "ssconf.sh : '-rsp' parameter need the response file for 2nd parameter."
				exit 1
			fi
			if [ ! -f "$1" ]; then
				echo "ssconf.sh : Couldn't find $1 for the response file."
				exit 1
			fi
			rspf=$1
			;;
		*)
			echo "ssconf.sh : Too many parameter."
			display_help.sh $me
			echo "current parameter : $orgpar"
			exit 1
			;;
	esac
	shift
done

if [ -z "$HYPERION_HOME" -o ! -d "$HYPERION_HOME" ]; then
	echo "No \$HYPERION_HOME definition or folder."
	exit 2
fi

if [ -z "$AP_AGENTPORT" ]; then
	echo "No \$AP_AGENTPORT definition."
	exit 2
fi

[ -z "$ESSLANG" ] && export ESSLANG=English_UnitedStates.Latin1@Binary
	
# # Check installation is not refresh.
# if [ -f "$HYPERION_HOME/refresh_version.txt" ]; then
# 	echo "Current installation is refresh."
# 	exit 4
# fi

# Check HIT version text
if [ ! -f "$HYPERION_HOME/hit_version.txt" ]; then
	echo "Current installation is not installed by autopilot framework."
	exit 5
fi
hitbld=`cat $HYPERION_HOME/hit_version.txt | tr -d '\r'`
hitbld=${hitbld#*build_}
[ "$dbg" = "true" -o "$dbg" = "exit" ] && echo "# hitbld = $hitbld(`date +%D_%T`)"
if [ "`cmpstr $hitbld 6700`" = "<" ]; then
	# before talleyrand_sp1
	echo "ssconf.sh : Un-supported HIT version(hit=$hitbld)."
	exit 3
fi

# Check installed ESSBASE version
iver=`get_ess_ver.sh`
if [ -z "$iver" ]; then
	echo "# Failed to get current version. Use 11.1.2.2.000 for temporary version."
	iver=11.1.2.2.000
else
	iver=${iver%:*}
fi
echo "# Installed Essbase version = $iver"
iver=`ver_vernum.sh $iver`
echo "# Internal version number = $iver"
silentf=$HYPERION_HOME/config-silent.xml
# rm -f $silentf > /dev/null 2>&1

# Check configtool.sh exists.
cfgtool=
cfgdir=
crr=`pwd`
if [ -d "$HYPERION_HOME/common/config" ]; then
	cd $HYPERION_HOME/common/config
	_v=`ls | grep "^[0-9]" | head -1`
	cd $_v
	if [ "`uname`" = "Windows_NT" ]; then
		[ -f "startconfigtool.bat" ] && cfgtool="startconfigtool.bat" || cfgtool="configtool.bat"
	else
		cfgtool="configtool.sh"
	fi
	if [ ! -f "$cfgtool" ]; then
		cfgtool=
	else
		cfgdir=`pwd`
	fi
fi
if [ -z "$cfgtool" ]; then
	echo "There is no configtool.sh[.bat] file under $cfgdir."
	exit 6
fi
cd $crr

[ "$dbg" = "true" -o "$dbg" = "exit" ] && echo "# cfgdir=$cfgdir, cfgtool=$cfgtool(`date +%D_%T`)"

#######################################################################
# Decide the conf.xml file
#######################################################################

[ "$dbg" = "true" -o "$dbg" = "exit" ] && echo "# Decide conf.xml(`date +%D_%T`)"
if [ -z "$rspf" ]; then
	crrpwd=`pwd`
	cd $AUTOPILOT/rsp
	rsplst=`ls -1 conf_*.xml 2> /dev/null | grep -v conf.xml`
	targ=
	for one in $rsplst; do
		one=${one%.xml}
		one=${one#conf_}
		[ "$dbg" = "true" -o "$dbg" = "exit" ] && echo "#   check - conf_{$one}.xml is bigger than current($hitbld) or not(`date +%D_%T`)"
		if [ "`cmpstr $one $hitbld`" != "<" ]; then
			targ=$one
			break
		fi
	done

	if [ -n "$targ" ]; then
		rspf=$AUTOPILOT/rsp/conf_$targ.xml
	else
		rspf=$AUTOPILOT/rsp/conf.xml
	fi
	cd $crrpwd
fi

[ "$dbg" = "true" -o "$dbg" = "exit" ] && echo "#   -> $rspf(`date +%D_%T`)"
tmpf=$HOME/${thisnode}.ssconf.tmp
rm -f $tmpf > /dev/null 2>&1

#######################################################################
# Edit conf.xml
#######################################################################
[ "$dbg" = "true" -o "$dbg" = "exit" ] && echo "# Edit conf.xml(`date +%D_%T`)"
_vlist="$vlist"
if [ `cmpstr $iver 011001002002000` != "<" ]; then
	# All ports
	calcport="|epm_port|ssl_port|agent_port|"
	calcport="${calcport}start_port|end_port|"
	calcport="${calcport}ohs_port|ohs_sport|"
	calcport="${calcport}cmpct_port|cmpct_sport|"
	calcport="${calcport}ss_port|ss_sport|"
	calcport="${calcport}aps_port|aps_sport|"
	calcport="${calcport}eas_port|eas_sport|"
else
	# Essbase only When the version number is lower than 11.1.2.2.000, we only calculate agent port only.
	# calcport="|ssl_port|agent_port|start_port|end_port|"
	calcport="|agent_port|"
fi
echo "# calcport=$calcport"
while [ -n "$_vlist" ]; do
	_vlist="${_vlist#!}"
	vn="${_vlist%%=*}"
	_vlist="${_vlist#*=}"
	vl="${_vlist%%!*}"
	_vlist="${_vlist#*!}"
	vl=`eval "echo \\${$vn}"`
	_calc=`echo "$calcport" | grep "|${vn}|"`
	if [ -n "$_calc" ]; then
		let vl=vl+$AP_AGENTPORT 2> /dev/null
		export $vn="$vl"
	fi
done

if [ -z "$db_host" ]; then
	[ "$dbg" = "true" -o "$dbg" = "exit" ] && echo "# Request DB user creation.(`date +%D_%T`)"
	cnt=30
	while [ $cnt -ne 0 ]; do
		dbreq.sh > $tmpf
		if [ $? -eq 0 ]; then
			cnt=999
			break
		fi
		sleep 1
		let cnt=cnt-1
	done
	if [ $cnt -ne 999 ]; then
		echo "Failed to get the DB user from dbreq.sh($?)."
		rm -f $tmpf > /dev/null 2>&1
		exit 7
	fi
	[ "$dbg" = "true" ] && echo "# Edit DB informations.(`date +%D_%T`)"
	db_host=`grep ^host= $tmpf | tr -d '\r'`
	db_host=${db_host#*=}
	db_port=`grep ^port= $tmpf | tr -d '\r'`
	db_port=${db_port#*=}
	db_name=`grep ^dbName= $tmpf | tr -d '\r'`
	db_name=${db_name#*=}
	db_user=`grep ^userName= $tmpf | tr -d '\r'`
	db_user=${db_user#*=}
	db_password=`grep ^password= $tmpf | tr -d '\r'`
	db_password=${db_password#*=}
	db_url=`grep ^jdbcUrl= $tmpf | tr -d '\r'`
	db_url=${db_url#*=}
else
	[ -z "$db_user" ] && db_user="hssuser"
	[ -z "$db_password" ] && db_password="password"
	[ -z "$db_name" ] && db_name="regress"
	[ -z "$db_port" ] && db_port=1521
	[ -z "$db_url" ] && db_url="jdbc:oracle:thin:$db_host:$db_port:$db_name"
fi
if [ "$dbg" = "true" -o "$dbg" = "exit" ]; then
	# Display variables
	mxln=0
	_vlist="$vlist"
	while [ -n "$_vlist" ]; do
		_vlist="${_vlist#!}"
		vn="${_vlist%%=*}"
		_vlist="${_vlist#*=}"
		vl="${_vlist%%!*}"
		_vlist="${_vlist#*!}"
		len=${#vn}
		[ $len -gt $mxln ] && mxln=$len
	done
	i=0; sps=; msk=
	while [ $i -lt $mxln ]; do
		sps="$sps "
		msk="${msk}?"
		let i=i+1
	done
	_vlist="$vlist"
	while [ -n "$_vlist" ]; do
		_vlist="${_vlist#!}"
		vn="${_vlist%%=*}"
		_vlist="${_vlist#*=}"
		vl="${_vlist%%!*}"
		_vlist="${_vlist#*!}"
		vl=`eval "echo \\${$vn}"`
		vn="${vn}${sps}"
		vn=${vn%${vn#${msk}}}
		echo "# - $vn = $vl"
	done
	if [ "$dbg" = "exit" ]; then
		exit 0
	fi
	unset i mxln sps msk vn vl
fi
rm -f $tmpf > /dev/null 2>&1
_vlist="$vlist"
while [ -n "$_vlist" ]; do
	_vlist="${_vlist#!}"
	vn="${_vlist%%=*}"
	_vlist="${_vlist#*=}"
	vl="${_vlist%%!*}"
	_vlist="${_vlist#*!}"
	vl=`eval "echo \\${$vn}"`
	vn=`echo $vn | tr abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ`
	echo "s!%${vn}%!${vl}!g" >> $tmpf
	[ "$dbg" = "true" ] && echo "# sedcmd : s!%${vn}%!${vl}!g"
done

tmp2=${HOME}/${thisnode}.silent.tmp2
rm -rf $tmp2 > /dev/null
rm -rf $silentf > /dev/null
sed -f $tmpf $rspf > $tmp2
rm -f $tmpf > /dev/null 2>&1

if [ "`uname`" = "Windows_NT" ]; then
	(IFS=
	cat $tmp2 2> /dev/null | tr -d '\r' | while read line; do
		case $line in
			*"<property name=\"serverLocation\">"*| \
			*"<property name=\"filesystem.artifact.path\">"*| \
			*"<property name=\"ocmResponseFileLocation\">"*| \
			*"<property name=\"path\">"*| \
			*"<property name=\"BEA_HOME\">"*| \
			*"<property name=\"AppDirectory\">"*| \
			*"<instance>"*)
				p1="${line%%>*}>"
				line="${line#*>}"
				p2=${line%\</*}
				line="</${line#*</}"
				p2=`echo $p2 | sed -e "s!/!\\\\\\!g"`
				print -r "$p1$p2$line"
				;;
			*)
				echo "$line"
				;;
		esac
	done > $silentf
	)
else
	grep -v windows_service $tmp2 2> /dev/null > $silentf
fi
rm -rf $tmp2 2> /dev/null

[ "$dbg" = "true" ] && (IFS=; cat $silentf 2> /dev/null | while read line; do print -r "# $line"; done)

#######################################################################
# Killing HSS and opmn related processes
echo "Cleanup HSS related processes"
if [ "`uname`" = "Windows_NT" ]; then
	kill_essprocs.sh -all
else
	kill_essprocs.sh -hss
fi
# nmz.exe
[ "$dbg" = "true" ] && echo "# Killing nmz.exe(`date +%D_%T`)"
pid=`psu -all | grep nmz.exe | grep -v grep`
if [ -n "$pid" ]; then
	[ "`uname`" = "Windows_NT" ] && print -r "Kill $pid" || echo "Kill $pid"
	pid=`echo $pid | awk '{print $2}'`
	kill -9 $pid
fi

# opmn and FoundationServices
[ "$dbg" = "true" ] && echo "# Killing opmn and FoundationServices(`date +%D_%T`)"
if [ "`uname`" = "Windows_NT" ]; then
	pstree.pl -all | grep "<none>" | egrep "opmn|FoundationServices|startWebLogic" | while read pid rest; do
		print -r "Kill $pid $rest"
		pstree.pl -kill $pid
	done
else
	pstree.pl | grep "<none>" | egrep "opmn|FoundationServices|startWebLogic" | while read pid rest; do
		echo "Kill $pid $rest"
		pstree.pl -kill $pid
	done
fi

[ "$dbg" = "true" ] && echo "# Remove \$HYPERION_HOME/../user_projects folder.(`date +%D_%T`)"
rm -rf $HYPERION_HOME/../user_projects > /dev/null 2>&1

# DBG : Remove added vars
_vlist="$vlist"
while [ -n "$_vlist" ]; do
	_vlist="${_vlist#!}"
	vn="${_vlist%%=*}"
	_vlist="${_vlist#*=}"
	vl="${_vlist%%!*}"
	_vlist="${_vlist#*!}"
	unset $vn
done
unset _vlist vn vl

#######################################################################
# Lauch EPM Sytem configurator
[ "$dbg" = "true" ] && echo "# Lauch EPM Sytem configurator(`date +%D_%T`)"
cfglog=$HOME/${thisnode}.cfgtool.log
rm -rf "$cfglog" 2> /dev/null
cd $cfgdir
if [ `uname` = "Windows_NT" ]; then
	echo "# Run \"$cfgdir/$cfgtool -silent $silentf\""
	$cfgdir/$cfgtool -silent $silentf 2>&1 | tee $cfglog &
else
	echo "# Run \"$cfgdir/$cfgtool -silent $silentf\""
	$cfgdir/$cfgtool -silent $silentf 2>&1 | tee  $cfglog &
fi

_cfgpid=$!
_fail=none
[ "$dbg" = "true" ] && echo "# PID for $cfgtool=$_cfgpid.(`date +%D_%T`)"
# Wait for the user_projects will be created
[ "$dbg" = "true" ] && echo "# Wait for user_projects folder.(`date +%D_%T`)"
instance_home="$HYPERION_HOME/../user_projects"
while [ ! -d "$instance_home" -a -n "$_fail" ]; do
	_fail=`ps -p $_cfgpid 2> /dev/null | grep -v PID`
	sleep 5
done 
instance_name="epmsystem1"
cfglogf="$instance_home/$instance_name/diagnostics/logs/config"
cfgslog="configtool_summary.log"
cfgtlog="configtool.log"
if [ -n "$_fail" ]; then # Wait for the configtool_summary will be created and config output
	# Check the instance name
	_crrdir=`pwd`
	cd $instance_home 2> /dev/null
	_last_instance=`ls -1r | grep ^${instance_name} 2> /dev/null | head -1`
	[ -n "$_last_instance" ] && instance_name=$_last_instance
	cfglogf="$instance_home/$instance_name/diagnostics/logs/config"
	cd $_crrdir
	# Wait for configtool done
	[ "$dbg" = "true" ] && echo "# Wait for $cfgtool done.(`date +%D_%T`)"
	clines=0
	cclines=0
	cl=0
	l=0
	while [ -n "$_fail" ]; do
		if [ -f "$cfglogf/$cfgslog" ]; then
			l=`cat $cfglogf/$cfgslog 2> /dev/null | wc -l`
			let l=l
			if [ "$clines" != "$l" ]; then
				let n=l-clines
				(IFS=
				tail -$n $cfglogf/$cfgslog 2> /dev/null | while read line; do echo "SUM:$line"; done
				)
				clines=$l
			fi
			f=`grep "Total summary$" "$cfglogf/$cfgslog" 2> /dev/null`
			[ -n "$f" ] && break
		fi
		if [ -f "$cfglog" ]; then
			cl=`cat $cfglog 2> /dev/null | wc -l`
			let cl=cl
			if [ "$cclines" != "$cl" ]; then
				let n=cl-cclines
				(IFS=; tail -$n $cfglog 2> /dev/null | while read -r line; do print -r "CFG:$line"; done)
				cclines=$cl
			fi
			f=`grep "Configuration Failed" "$cfglog" 2> /dev/null`
			[ -n "$f" ] && break
		fi
	 	_fail=`ps -p $_cfgpid 2> /dev/null | grep -v PID`
		[ -z "$_fail" ] && f="Pass"
	 	sleep 5
	done
	sts=`echo $f | grep "Pass"`
	if [ -z "$sts" ]; then
		_fail="Configuration Failed"
	else
		unset _fail
	fi
else
	_fail="$cfgtool done without creating user_projects"
fi
if [ -n "$_fail" ]; then
	echo "Failed to configure ($_fail)." | tee -a $cfglog
	if [ -f "$cfglogf/$cfgslog" ]; then
		echo "# Summary contents($cfgslog):" | tee -a $cfglog
		cat $cfglog/$cfgslog 2> /dev/null | while read line; do
			echo "#   $line" | tee -a $cfglog
		done
	fi
	echo "Please check the log files under \$cfglogf folder." | tee -a $cfglog
	ls -l $cfglogf 2> /dev/null >> $cfglog
	echo "# cfgdir =$cfgdir" | tee -a $cfglog
	echo "# cfgtool=$cfgtool" | tee -a $cfglog
	echo "# cfglog =$cfglog" | tee -a $cfglog
	echo "# rspf   =$rspf" | tee -a $cfglog
	echo "# silentf=$silentf" | tee -a $cfglog
	echo "# cfglogf=$cfglogf" | tee -a $cfglog
	echo "# cfgslog=$cfgslog" | tee -a $cfglog
	echo "# cfgtlog=$cfgtlog" | tee -a $cfglog
	echo "# command=$cfgdir/$cfgtool -silent $silentf" | tee -a $cfglog
	# rm -f $silentf > /dev/null 2>&1
	# rm -f $cfglog > /dev/null 2>&1
	exit 8
else
	# Start/stop HSS and Essbase to register Essbase to HSS
	ORACLE_INSTANCE="$instance_home/$instance_name"
	### [ "`uname`" = "Windows_NT" ] && ext="bat" || ext="sh"
	### if [ -f "$ORACLE_INSTANCE/bin/startEPMServer.${ext}" ]; then
	### 	stprg="$ORACLE_INSTANCE/bin/startEPMServer.${ext}"
	### 	edprg="$ORACLE_INSTANCE/bin/stopEPMServer.${ext}"
	### elif [ -f "$ORACLE_INSTANCE/bin/startFoundationServices.${ext}" ]; then
	### 	stprg="$ORACLE_INSTANCE/bin/startFoundationServices.${ext}"
	### 	edprg="$ORACLE_INSTANCE/bin/stopFoundationServices.${ext}"
	### else
	### 	unset stprg edprg
	### fi
	echo "# Start HSS and Essbase related serivces."
	start_service.sh
	### [ -f "$stprg" ] && $stprg
	$ORACLE_INSTANCE/bin/opmnctl startall
	echo "# Stop HSS and Essbase related serivces."
	$ORACLE_INSTANCE/bin/opmnctl stopall
	### [ -f "$edprg" ] && $edprg
	stop_service.sh

	# Set the Provider information
	echo "# Add provider information from $AUTOPILOT/data/css.xml."
	cssprov.sh $AUTOPILOT/data/css.xml
	cssprov.sh
	# Start HSS and Essbase to register Essbase to HSS
	echo "# Start HSS($stprg) and Essbase related serivces."
	### [ -f "$stprg" ] && $stprg
	start_service.sh
	$ORACLE_INSTANCE/bin/opmnctl startall
	echo "# Stop Essbase related serivces.(Keep HSS running)"
	$ORACLE_INSTANCE/bin/opmnctl stopall
	### # [ "`uname`" = "Windows_NT" ] \
	### #	&& $ORACLE_INSTANCE/bin/stopEPMServer.bat \
	### #	|| $ORACLE_INSTANCE/bin/stopEPMServer.sh
fi
# rm -f $silentf > /dev/null 2>&1
rm -f $cfglog > /dev/null 2>&1
exit 0
