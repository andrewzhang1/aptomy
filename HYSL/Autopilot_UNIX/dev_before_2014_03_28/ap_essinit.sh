#!/usr/bin/ksh
########################################################################
# ap_essinit.sh : Initialize ESSBASE related environment
########################################################################
# Syntax: ap_essinit.sh [-h|-force|-cfg|-o <opt>]
# Description:
#   This script initialize Essbase related environment.
# Options:
#   -h       : Display help
#   -force   : Forcibly initialize Essbase
#   -cfg     : Initialize essbase.cfg only
#   -dbg     : Display debug information
#   -o <opt> : Define task option
# Exit status:
#   0 : Initialize fine.
#   1 : Syntax error
#   2 : Failed to initialize
# External reference and task option:
#   AP_ESSINIT: Initialize mode.
#     true  : Initialize Essbase
#     false : Do not initialize
#     cfg   : Initialize essbase.cfg only
#     note: When you don't define AP_ESSINIT, this script use the value
#           in $AUTOPILOT/data/vardef.txt.
#   essInit(true|false|cfg) Same mean as AP_ESSINIT
# Setting Priority:
#   option > task option(essInit) > AP_ESSINIT
########################################################################
# History:
# 01/11/2008 YKono	First edition.
# 07/02/2008 YKono	Use version.sh for the license mode and two password mode.
# 08/01/2008 YKono	Use ver_essinit.sh instead of version.sh.
# 12/05/2008 YKono	Add AP_UNCOMMENTJVM
# 04/30/2010 YKono	Add search previous version of security file.
# 08/12/2010 YKono	Add "_DisableThreadidinlog_  TRUE" to essbase.cfg - ap_essinit.sh
# 09/18/2010 YKono	Add "AgentSecurePort" definition for temporary workaround.
# 02/23/2011 YKono	Add odbc.ini and odbcinst.ini edit.
# 10/07/2011 YKono	Add AP_RESETCFG
# 11/01/2011 YKono	Use pre-saved essbase.cfg file if this is HH/essbase.cfg
# 06/07/2012 YKono	Use AP_ESSINIT environment variable
# 06/11/2012 YKono	Support client initialization. -cl
# 07/26/2012 YKono	Fix native initialization problem.
# 11/20/2012 YKono	Add check already initiled.

. apinc.sh
me=$0
orgpar=$@
unset set_vardef; set_vardef AP_ESSINIT AP_RESETCFG AP_ESSBASECFG
initmode=
dbg=false
client=false
while [ $# -ne 0 ]; do
	case $1 in
		-hss|hss)
			export AP_BISHIPHOME=
			export AP_SECMODE=hss
			;;
		-birep|birep)
			export AP_BISHIPMODE=true
			export AP_SECMODE=rep
			;;
		-bifa|fa)
			export AP_BISHIPHOME=true
			export AP_SECMODE=fa
			;;
		-bi|bi)
			export AP_BISHIPHOME=true
			;;
		-cl|client)
			client=true
			;;
		-h)
			display_help.sh $me
			exit
			;;
		-force|force)	initmode=true ;;
		-cfg|cfg)	initmode=cfg ;;
		-dbg)	dbg=true;;
		-nodbg)	dbg=false;;
		-opt|-o)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}:'$1' need a second parameter as a task option."
				exit 1
			fi
			[ -z "$_OPTION" ] && export _OPTION="$1" || export _OPTION="$_OPTION $1"
			;;
		*)
			echo "${me##*/}:Too many parameter."
			exit 1
			;;
	esac
	shift
done

if [ -z "$initmode" ]; then
	initmode=`chk_para.sh essInit "$_OPTION"`
	initmode=${initmode##* }
	[ -z "$initmode" ] && initmode="$AP_ESSINIT"
fi	
str=`chk_para.sh bi "$_OPTION"`; str=${str##* }
[ -n "$str" ] && export AP_BISHIPMODE=$str
str=`chk_para.sh secmode "$_OPTION"`; str=${str##* }
[ -n "$str" ] && export AP_SECMODE=$str
[ "$AP_SECMODE" = "rep" -o "$AP_SECMODE" = "fa" ] && export AP_BISHIPHOME=true
[ "$dbg" = "true" ] && echo "# initmode=$initmode"
# if [ "$AP_SECMODE" = "hss" -a ! -d "$HYPERION_HOME/../user_projects" -a "$initmode" = "false" ]; then
#	initmode=true
# fi
if [ "$initmode" = "false" ]; then
	[ "$dbg" = "true" ] && echo "# Check current installation is initialized."
	case $AP_SECMODE in
	hss)	if [ ! -d "$HYPERION_HOME/../user_projects/epmsystem1/config/OPMN/opmn" ]; then
			# [ "$dbg" = "true" ] && echo "# Found HSS mode is not initlizized."
			echo "# Found HSS mode is not initlizized."
			initmode=true
		fi
		;;
	fa|rep)	if [ ! -d "$HYPERION_HOME/../instances" ]; then
			# [ "$dbg" = "true" ] && echo "# Found FA/BI mode is not initlizized."
			echo "# Found FA/BI mode is not initlizized."
			initmode=true
		fi
		;;
	*)	if [ ! -f "$ARBORPATH/bin/essbase.sec" -o ! -d "$ARBORPATH/app" ]; then
			# [ "$dbg" = "true" ] && echo "# Found Native mode is not initlizized."
			echo "# Found Native mode is not initlizized."
			initmode=true
		else
			agp=`cat $ARBORPATH/bin/essbase.cfg 2> /dev/null | egrep -i "^AgentPort[ 	]"`
			agp=`echo $agp | awk '{print $2}'`
			if [ "$agp" != "$AP_AGENTPORT" ]; then
				[ "$dbg" = "true" ] && echo "# Found essbase.cfg is not initlizized."
				initmode=cfg
			fi
		fi
		;;
	esac
fi
if [ "$initmode" = "cfg" ]; then
	echo "# AP_ESSINIT=$initmode. Initialize only essbase.cfg file."
elif [ "$initmode" = "false" ]; then
	echo "# AP_ESSINIT=$initmode. Skip initialization."
	exit 0
else
	echo "# AP_ESSINIT=$initmode"
fi

########################################################################
# General initalization
########################################################################
# Get Ver/Bld# and license moed, platform information
tmp=`get_ess_ver.sh`
[ $? -ne 0 ] && exit 2
ver=${tmp%:*}
bld=${tmp#*:}
[ "$dbg" = "true" ] && echo "# ver=$ver, bld=$bld"

# Rename if test.pl exist
test_pl=`which test`
test_plb=`echo ${test_pl##*/}`
[ "$test_plb" = "test.pl" ] && mv "$test_pl" "${test_pl}.bak"

. ver_essinit.sh $ver $bld > /dev/null 2>&1
echo "### Kill Essbase related processes."
if [ "$client" = "true" ]; then
	kill_essprocs.sh -client
else
	if [ -n "$AP_SECMODE" ]; then
		stop_service.sh
		kill_essprocs.sh -biall
	else
		kill_essprocs.sh -all
	fi
fi
wrtcrr "INITIALIZING"

# editcfg $cfgfile <definition> <value>
edittmp=$HOME/.${thisnode}.editcfg.tmp
editcfg()
{
	if [ -f "$1" ]; then
		_fnd=`cat $1 2> /dev/null | egrep -i "^$2[ 	]"`
		if [ -z "$_fnd" ]; then
			[ "$dbg" = "true" ] && echo "### Found ${1##*${thisnode}.} file but there is no $2 definition. Add \"$2 $3\" to it."
			echo "$2	$3" >> "$1"
		else
			[ "$dbg" = "true" ] && echo "### Found ${1##*${thisnode}.} file and $2 definition($_fnd). Replace $2 to $3."
			_fnd=${_fnd%%[ 	]*}
			rm -rf $edittmp 2> /dev/null
			sed -e "s/^${_fnd}[ 	][ 	]*[^ 	][^ 	]*/${_fnd}    $3/g" \
				"$1" > $edittmp
			rm -rf $1 2> /dev/null
			mv $edittmp $1
		fi
	else
		[ "$dbg" = "true" ] && echo "### No ${1##*${thisnode}.} file. Create ${1##*${thisnode}.} file with $2 definition to $3."
		echo "$2	$3" > "$1"
	fi
}

########################################################################
# Essbase initialization for hss and birep mode
########################################################################
if [ "$client" = "false" -a "$initmode" = "true" ]; then
	if [ "$AP_SECMODE" = "hss" ]; then
		ssconf.sh
		sts=$?
	elif [ "$AP_SECMODE" = "rep" -o "$AP_SECMODE" = "fa" -o "$AP_SECMODE" = "bi" ]; then
		crrdir=`pwd`
		cd ${HYPERION_HOME%/*}
		if [ -f "instances.tar" ]; then
			echo "# Found previous instance image(`pwd`/instances.tar). Extract it."
			rm -rf instances 2> /dev/null
			tar -xf instances.tar 2> /dev/null
		else
			echo "# Create initial instance backup at `pwd`(HH:$HYPERION_HOME)."
			tar -cf instances.tar instances/* 2> /dev/null
		fi
		cp -R $ESSBASEPATH/bin/wallet $ARBORPATH/bin
		start_service.sh
		# Edit opmn.xml with current ESSLANG and AP_AGENTPORT
		echo "# Edit opmn.xml file at $ARBORPATH/../../config/OPMN/opmn folder."
		cd $ARBORPATH/../../config/OPMN/opmn
		rm -rf opmn.xml.org 2> /dev/null
		cp opmn.xml opmn.xml.org
		echo "" >> opmn.xml.org
		rm -f opmn.xml 2> /dev/null
		cat opmn.xml.org \
		    | sed -e "s!<variable id=\"ESSLANG\" value=\".*\"/>!<variable id=\"ESSLANG\" value=\"$ESSLANG\"/>!g" \
		          -e "s!<data id=\"agent-port\" value=\".*\"/>!<data id=\"agent-port\" value=\"$AP_AGENTPORT\"/>!g" \
		    > opmn.xml
		# (IFS=; cat opmn.xml | while read line; do echo "# opmn.xml:$line"; done)
		cd $crrdir
		#if [ "`uname`" = "Windwos_NT" ]; then
		#	opmnprg="opmnctl.bat"
		#	starprog="StartStopServices.cmd"
		#else
		#	opmnprg="opmnctl"
		#	startprg="StartStopServices.sh"
		# fi
		# $ORACLE_INSTANCE/bifoundation/OracleBIApplication/coreapplication/$startprg start_all < \
		#	$ORACLE_INSTANCE/bifoundation/OracleBIApplication/coreapplication/pass
		# $ORACLE_INSTANCE/bin/$opmnprg stopall
		unset crrdir
	fi
fi

########################################################################
# Edit essbase.cfg
########################################################################
# Handling AP_RESETCFG
cfgf=$ARBORPATH/bin/essbase.cfg
if [ -d "$SXR_CLIENT_ARBORPATH" ]; then
	clcfgf=$SXR_CLIENT_ARBORPATH/bin/essbase.cfg
else
	unset clcfgf
fi

[ -n "$clcfgf" ] && echo "### Edit $cfgf and $clcfgf." || echo "### Edit $cfgf."
if [ "$AP_RESETCFG" = "true" ]; then
	[ "$dbg" = "true" ] && echo "### Remove current essbase.cfg by \$AP_RESETCFG=true setting."
	rm -rf $cfgf > /dev/null 2>&1
	if [ -n "$clcfgf" ]; then
		[ "$dbg" = "true" ] && echo "### Remove current client essbase.cfg by \$AP_RESETCFG=true setting."
		rm -rf $clcfgf 2> /dev/null
	fi
else
	if [ -f "$HYPERION_HOME/essbase.cfg" ]; then
		[ "$dbg" = "true" ] && echo "### Found \$HYPERION_HOME/essbase.cfg and use it as base cfg."
		cp $HYPERION_HOME/essbase.cfg $cfgf > /dev/null 2>&1
	fi
fi

# Handling AP_ESSBASECFG definition
if [ -n "$AP_ESSBASECFG" ]; then
	[ "$dbg" = "true" ] && echo "### Found \$AP_ESSBASECFG($AP_ESSBASECFG). Use it as base cfg."
	tmp=${AP_ESSBASECFG#*\$}
	[ "$tmp" != "$AP_ESSBASECFG" ] && export AP_ESSBASECFG=`eval echo $AP_ESSBASECFG`
	[ -f "$AP_ESSBASECFG" ] && cp "$AP_ESSBASECFG" "$cfgf" > /dev/null 2>&1
	[ -n "$clcfgf" ] && cp $AP_ESSBASECFG $clcfgf > /dev/null 2>&1
fi
[ -f "$cfgf" ] && chmod 777 $cfgf > /dev/null 2>&1
[ -f "$clcfgf" ] && chmod 777 $clcfgf > /dev/null 2>&1

# Un-comment JVM definition
if [ "$AP_UNCOMMENTJVM" = "true" ]; then
	[ "$dbg" = "true" ] && echo "### Found \$AP_UNCOMMENTJVM definition to true. Uncomment JvmModuleLocation."
	cmt=`cat $cfgf 2> /dev/null | grep "^; JvmModuleLocation"`
	if [ -n "$cmt" ]; then
		cmt=`cat $cfgf 2> /dev/null | grep "^JvmModuleLocation"`
		if [ -z "$cmt" ]; then
			rm -rf $HOME/.${thisnode}.essbase.cfg.bak
			sed -e "s/^; JvmModuleLocation/JvmModuleLocation/g" \
				"$cfgf" > $HOME/.${thisnode}.essbase.cfg.bak
			rm -f $cfgf
			mv $HOME/.${thisnode}.essbase.cfg.bak $cfgf
		fi
	fi
	unset cmt
fi

if [ "$client" = "false" ]; then
	# Hnadling License mode in each version/build
	# echo_ver_vars
	case "$_VER_LICMODE" in
	reg)
		[ "$initmode" = "true" ] && cp "$BUILD_ROOT/common/bin/registry.properties" \
			"$HYPERION_HOME/common/config" > /dev/null 2>&1
		;;
	none)	;;
	*)
		if [ "$initmode" = "true" ]; then
			if [ -f "$AP_DEF_LICPATH/${ver}.lic" ]; then
				cp "$AP_DEF_LICPATH/${ver}.lic" "$ARBORPATH/bin/hyslinternal.lic" > /dev/null 2>&1
			else
				cp "$BUILD_ROOT/common/bin/$_VER_LICMODE" "$ARBORPATH/bin/hyslinternal.lic" > /dev/null 2>&1
			fi
		fi
		if [ "${ver#7}" = "${ver}" ]; then
			cfgdef="PN5453"
			grepcmd="DeploymentID"
		else
			cfgdef="1"
			grepcmd="AnalyticServerId"
		fi
		[ "$dbg" = "true" ] && echo "### Add \"$cfgdef\""
		editcfg $cfgf "$grepcmd" "$cfgdef"
		;;
	esac
fi

# Editing AgentPort definition
if [ -n "$AP_AGENTPORT" ]; then
	[ "$dbg" = "true" ] && echo "### Found \$AP_AGENTPORT($AP_AGENTPORT) definition."
	editcfg $cfgf AgentPort $AP_AGENTPORT
	[ -n "$clcfgf" ] && editcfg $clcfgf AgentPort $AP_AGENTPORT
	# Temporary workaround
	if [ "$ver" = "talleyrand_sp1" -a "`cmpstr $bld 177`" = ">" ]; then
		[ "$dbg" = "true" ] && echo "### Add agentSecurePort definition."
		let sap=AP_AGENTPORT+5000 > /dev/null 2>&1
		editcfg $cfgf AgentSecurePort $sap
		[ -n "$clcfgf" ] && editcfg $clcfgf AgentSecurePort $sap
	fi
fi

# Add _DisableThreadidinlog_  TRUE
editcfg $cfgf _DisableThreadIdInLog_ TRUE
[ -n "$clcfgf" ] && editcfg $clcfgf _DisableThreadIdInLog_ TRUE
chmod 777 $cfgf > /dev/null 2>&1

########################################################################
# Essbase initialization
########################################################################
if [ "$client" = "false" -a "$initmode" = "true" ]; then
	if [ "$AP_SECMODE" != "hss" -a "$AP_SECMODE" != "rep" -a "$AP_SECMODE" != "fa" -a "$AP_SECMODE" != "bi" ]; then	# Native
		[ ! -d "$ARBORPATH/app" ] && mkddir.sh $ARBORPATH/app
		# Delete Application and Security, Log files.
		rm -rf $ARBORPATH/app/*
		rm -f $ARBORPATH/bin/essbase.sec
		if [ -f "$ARBORPATH/Essbase.log" ]; then # Old location
			rm -f $ARBORPATH/Essbase.log
		elif [ -f "$HYPERION_HOME/logs/essbase/Essbase.log" ]; then
			# This locatio is used from Kennedy 334
			rm -f $HYPERION_HOME/logs/essbase/Essbase.log
			rm -rf $HYPERION_HOME/logs/essbase/app/*
		fi
		tmpfile="$HOME/.${thisnode}.essinit.tmp"
		rm -rf $tmpfile > /dev/null 2>&1
		if [ `uname` = "Windows_NT" ]; then
			unset secf
			tarver=`ver_vernum.sh ${ver}`
			cd $AP_DEF_SECPATH
			ls ${plat}_*.sec 2> /dev/null | while read line; do
				line=${line%.*}
				echo ${line#*_}
			done | ver_vernum.sh -org | sort > $tmpfile
			prevver=
			while read line; do
				# echo "# $line : $tarver"
				sts=`cmpstr "${line%% *}" "${tarver}"`
				[ "$sts" = ">" ] && break
				prevver=${line##* }
			done < $tmpfile
			if [ -n "$prevver" ]; then
				secf="${plat}_${prevver}.sec"
				echo "Found $secf file."
			else
				secf=${plat}.sec
			fi
			unset crr tarver prevver line tmpfile sts
		
			if [ -f "$AP_DEF_SECPATH/${secf}" ]; then
				echo "# Initial SEC file :  ${secf}"
				cp "$AP_DEF_SECPATH/${secf}" "$ARBORPATH/bin/essbase.sec"
				cd "$ARBORPATH/app"
				tar -xf "$AP_DEF_DMAPP"
			else
				echo "# SEC file (${secf}) not found!"
			fi
		else
			rm -rf $tmpfile 2> /dev/null
			echo "Oracel" >> $tmpfile
			echo "essexer" >> $tmpfile
			echo "password" >> $tmpfile
			[ "$_VER_DBL_PWD" = "true" ] && echo "password" >> $tmpfile
			echo "1" >> $tmpfile
			echo "exit" >> $tmpfile
			echo "1" >> $tmpfile
			ESSBASE < $tmpfile
		fi
		rm -rf $tmpfile 2> /dev/null
		sleep 3
		# Edit ODBC related files
		if [ -f "$ODBC_HOME/odbc.ini" ]; then
			mv $ODBC_HOME/odbc.ini $ODBC_HOME/odbc.ini.org
			cat $ODBC_HOME/odbc.ini.org \
				| sed -e "s!<install_location>!$ODBC_HOME!g" \
				> $ODBC_HOME/odbc.ini 2> /dev/null
		fi
		if [ -f "$ODBC_HOME/odbcinst.ini" ]; then
			mv $ODBC_HOME/odbcinst.ini $ODBC_HOME/odbcinst.ini.org
			cat $ODBC_HOME/odbcinst.ini.org \
				| sed -e "s!<install_location>!$ODBC_HOME!g" \
				> $ODBC_HOME/odbcinst.ini 2> /dev/null
		fi
	fi
fi
if [ "$dbg" = "true" ]; then
	echo "### $cfgf ###"
	cat $cfgf | while read line; do echo "# $line"; done
	if [ -n "$clcfgf" ]; then
		echo "### $clcfgf ###"
		cat $clcfgf | while read line; do echo "# $line"; done
	fi
fi
exit 0
