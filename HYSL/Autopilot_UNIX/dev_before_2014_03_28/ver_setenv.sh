#!/usr/bin/ksh
# ver_setenv.sh : Set variables for regression running envrionemnt.
# 
# DESCRIPTION:
# Set following variables which are required for seting up the environment.
# _ESSDIR        : ARBORPATH location from HYPERION_HOME
# _ESSCDIR       : EssbaseClient location from HYPERION_HOME
#                  If $ver doesn't have the client folder, keep this empty
# _SXR_HOME      : The latest location of the ClearCase snapshot folder.
# _HYPERION_HOME : Additional hyperion home name from installation point.
# _LIB           : define libraries which Essbase needed
# _PATH          : Define path which Essbase required
# _DUPCHK_LIST   : Duplication check list for the opack instation.
# _IGNBIN_LIST   : Ignore files list for binary file comparison between refresh and opack
# _IGNORE_OPACK : Ignore opack modules in rtc,client/server
# _SXR_CLIENT_ARBORPATH : SXR client path
#
# SYNTAX:
# ver_setenv.sh <ver#>
# <ver#> : Version number in fulll/short format.
#
# RETURN:
# = 0 : Normal
# = 1 : Wrong parameter counts.
#
# CALL FROM:
# setchk_env.sh:
#
# HISTORY:
# 08/01/2008 YK - First Edition.
# 11/05/2008 YK - Add Dickens
# 01/30/2009 YK - Add Talleyrand
# 03/20/2009 YK - Add Zola
# 08/16/2010 YK - Change Talleyrand PS1 definition
# 08/17/2010 YK - Add _EXTRA_PATH
# 05/10/2011 YK - Add 11.1.2.2.000
# 06/07/2011 YK - Use AP_SNAPROOT
# 07/20/2011 YK Add duplicate check in the ARBORPATH/bin,
#               HYPERION_HOME/common/EssbaseRTC(-64)/<ver>/bin and HYPERION_HOME/lib(bin)
# 08/31/2011 YK Add _SXR_CLIENT_ARBORPATH
# 12/12/2011 YK Add _IGNORE_OPACK
# 03/23/2012 YK Add 11.1.2.2.001 (qacleanup)
# 05/15/2012 YK Support HSS configuration
# 2012/07/25 YK Remove RTC path from $PATH by Yuki Hashimoto
# 2012/12/08 YK Addd weblogic_10.3 into 11.1.2.2.200, 500, 11.1.2.3.000
# 2012/12/11 YK Add _EXTRA_SETENVVARS definition
# 2013/01/07 YK Change snapshot assignments.
#               Remove qacleanup
#               11121x   11.1.2.1.1x PSUs
#               11122x   11.1.2.2.1x PSUs
#               11122200 11.1.2.2.200
#               mainline 11.1.2.3.000, 11.1.2.3.100
# 2013/08/02 YK Bug 17263272 - CHANGE BASE SNAPSHOT FOR 11.1.2.3.X AND 11.1.2.6.X.
#               mainline 11.1.2.4.000, 11.1.2.6.000
#               11123x   11.1.2.3.*

if [ -n "$AP_SNAPROOT" -a -d "$AP_SNAPROOT" ]; then
	_ap_snaproot=$AP_SNAPROOT
elif [ -d "${AUTOPILOT%/*/*}/snapshots" ]; then
	_ap_snaproot="${AUTOPILOT%/*/*}/snapshots"
	mainlinename=11xmain
else
	_ap_snaproot="${AUTOPILOT%/*/*}"
	mainlinename=mainline
fi
if [ -d "$_ap_snaproot/11xmain" ]; then
	mainlinename=11xmain
else
	mainlinename=mainline
fi
unset _ESSCDIR
unset _HYPERION_HOME
unset _ARBORPATH
unset _INSTANCE_LOC
unset _LIB
unset _PATH
unset _ESSDIR
unset _DUPCHK_LIST
unset _IGNBIN_LIST
unset _SXR_CLIENT_ARBORPATH
unset _IGNORE_OPACK
_EXTRA_SETENVVARS="SXR_STA_ACCUMULATED"
_SXR_STA_ACCUMULATED=1

case $1 in

11xmain|11.1.2.4.000|11.1.2.6.000)
	if [ "$AP_BISHIPHOME" = "true" ]; then
		_HYPERION_HOME=Oracle_BI1
		_INSTANCE_LOC="../instances/instance<#>"
		_ARBORPATH="\$_INSTANCE_LOC/Essbase/essbaseserver1"
		_SXR_CLIENT_ARBORPATH="clients/epm/Essbase/EssbaseRTC"
		_PATH="$_PATH \$ORACLE_INSTANCE/bin"
		# [ "$AP_SECMODE" = "fa" -o "$AP_SECMODE" = "rep" -o "$AP_SECMODE" = "bi" ] \
	# 		&& _PATH="$_PATH \$HYPERION_HOME/../wlserver_10.3/common/bin"
		_EXTRA_SETENVVARS="$_EXTRA_SETENVVARS WEBLOGIC_SERVER WL_HOME WEBLOGIC_USER WEBLOGIC_PASSWORD"
		_WEBLOGIC_SERVER="$(hostname):7001"
		_WEBLOGIC_USER="weblogic"
		_WEBLOGIC_PASSWORD="welcome1"
		_WL_HOME="\${HYPERION_HOME%/*}/wlserver_10.3"
	else
		_HYPERION_HOME=EPMSystem11R1
		_INSTANCE_LOC="../user_projects/epmsystem<#>"
		_ARBORPATH="\$_INSTANCE_LOC/EssbaseServer/essbaseserver1"
		_ESSCDIR="products/Essbase/EssbaseClient<plat32>"
		_SXR_CLIENT_ARBORPATH="common/EssbaseRTC<rtc64>/11.1.2.0"
	fi
	_DUPCHK_LIST="$_DUPCHK_LIST \$ESSBASEPATH/bin"
	_DUPCHK_LIST="$_DUPCHK_LIST \$SXR_CLIENT_ARBORPATH/bin"
	_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/bin"
	_ESSDIR="products/Essbase/EssbaseServer<plat32>"
	_SXR_HOME="$_ap_snaproot/$mainlinename/vobs/essexer/latest"
	# 2012/07/25 remove RTC path from $PATH by Yuki Hashimoto
	_PATH="$_PATH \$ARBORPATH/bin"
	_PATH="$_PATH \$ESSBASEPATH/bin"
	_PATH="$_PATH \$SXR_CLIENT_ARBORPATH/bin"
	# _PATH="$_PATH \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
	_PATH="$_PATH \$ORACLE_INSTANCE/bin"
	_PATH="$_PATH \$HYPERION_HOME/common/bin"
	_PATH="$_PATH \$HYPERION_HOME/../oracle_common/bin"	# for wlst.sh agsfmain.sh
	_LIB="$_LIB \$SXR_CLIENT_ARBORPATH/bin"
	_LIB="$_LIB \$ESSBASEPATH/bin"
	_LIB="$_LIB \$ARBORPATH/bin"
	_LIB="$_LIB \$HYPERION_HOME/../ohs/opmn/lib"
	_LIB="$_LIB \$HYPERION_HOME/opmn/lib"	# by BI 11.1.1.7 installation
	if [ `uname` = "Windows_NT" ]; then
		_PATH="\$HYPERION_HOME/bin $_PATH"
		unset _LIB
		_IGNORE_OPACK=client
	else
		_LIB="\$HYPERION_HOME/lib $_LIB"
	fi
	_IGNBIN_LIST="ESSCMDQ|ESSCMDG|ESSTESTCREDSTORE|essmove|stack|register|setbrows|EssStagingTool|startEssbase|cwallet|ewallet"
	;;
11.1.2.2.500|11.1.2.3.*)
	if [ "$AP_BISHIPHOME" = "true" ]; then
		_HYPERION_HOME=Oracle_BI1
		_INSTANCE_LOC="../instances/instance<#>"
		_ARBORPATH="\$_INSTANCE_LOC/Essbase/essbaseserver1"
		_SXR_CLIENT_ARBORPATH="clients/epm/Essbase/EssbaseRTC"
		_PATH="$_PATH \$ORACLE_INSTANCE/bin"
		# [ "$AP_SECMODE" = "fa" -o "$AP_SECMODE" = "rep" -o "$AP_SECMODE" = "bi" ] \
	# 		&& _PATH="$_PATH \$HYPERION_HOME/../wlserver_10.3/common/bin"
		_EXTRA_SETENVVARS="$_EXTRA_SETENVVARS WEBLOGIC_SERVER WL_HOME WEBLOGIC_USER WEBLOGIC_PASSWORD"
		_WEBLOGIC_SERVER="$(hostname):7001"
		_WEBLOGIC_USER="weblogic"
		_WEBLOGIC_PASSWORD="welcome1"
		_WL_HOME="\${HYPERION_HOME%/*}/wlserver_10.3"
	else
		_HYPERION_HOME=EPMSystem11R1
		_INSTANCE_LOC="../user_projects/epmsystem<#>"
		_ARBORPATH="\$_INSTANCE_LOC/EssbaseServer/essbaseserver1"
		_ESSCDIR="products/Essbase/EssbaseClient<plat32>"
		_SXR_CLIENT_ARBORPATH="common/EssbaseRTC<rtc64>/11.1.2.0"
	fi
	_DUPCHK_LIST="$_DUPCHK_LIST \$ESSBASEPATH/bin"
	_DUPCHK_LIST="$_DUPCHK_LIST \$SXR_CLIENT_ARBORPATH/bin"
	_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/bin"
	_ESSDIR="products/Essbase/EssbaseServer<plat32>"
	_SXR_HOME="$_ap_snaproot/11123x/vobs/essexer/latest"
	# 2012/07/25 remove RTC path from $PATH by Yuki Hashimoto
	_PATH="$_PATH \$ARBORPATH/bin"
	_PATH="$_PATH \$ESSBASEPATH/bin"
	_PATH="$_PATH \$SXR_CLIENT_ARBORPATH/bin"
	# _PATH="$_PATH \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
	_PATH="$_PATH \$ORACLE_INSTANCE/bin"
	_PATH="$_PATH \$HYPERION_HOME/common/bin"
	_PATH="$_PATH \$HYPERION_HOME/../oracle_common/bin"	# for wlst.sh agsfmain.sh
	_LIB="$_LIB \$SXR_CLIENT_ARBORPATH/bin"
	_LIB="$_LIB \$ESSBASEPATH/bin"
	_LIB="$_LIB \$ARBORPATH/bin"
	_LIB="$_LIB \$HYPERION_HOME/../ohs/opmn/lib"
	_LIB="$_LIB \$HYPERION_HOME/opmn/lib"	# by BI 11.1.1.7 installation
	if [ `uname` = "Windows_NT" ]; then
		_PATH="\$HYPERION_HOME/bin $_PATH"
		unset _LIB
		_IGNORE_OPACK=client
	else
		_LIB="\$HYPERION_HOME/lib $_LIB"
	fi
	_IGNBIN_LIST="ESSCMDQ|ESSCMDG|ESSTESTCREDSTORE|essmove|stack|register|setbrows|EssStagingTool|startEssbase|cwallet|ewallet"
	;;
11.1.2.2.200)
	if [ "$AP_BISHIPHOME" = "true" ]; then
		_HYPERION_HOME=Oracle_BI1
		_INSTANCE_LOC="../instances/instance<#>"
		_ARBORPATH="\$_INSTANCE_LOC/Essbase/essbaseserver1"
		_SXR_CLIENT_ARBORPATH="clients/epm/Essbase/EssbaseRTC"
		_PATH="$_PATH \$ORACLE_INSTANCE/bin"
		[ "$AP_SECMODE" = "fa" -o "$AP_SECMODE" = "rep" -o "$AP_SECMODE" = "bi" ] \
			&& _PATH="$_PATH \$HYPERION_HOME/../wlserver_10.3/common/bin"
		_EXTRA_SETENVVARS="$_EXTRA_SETENVVARS WEBLOGIC_SERVER WL_HOME"
		_WEBLOGIC_SERVER="$(hostname):7001"
		_WL_HOME="\${HYPERION_HOME%/*}/wlserver_10.3"
	else
		_HYPERION_HOME=EPMSystem11R1
		_INSTANCE_LOC="../user_projects/epmsystem<#>"
		_ARBORPATH="\$_INSTANCE_LOC/EssbaseServer/essbaseserver1"
		_ESSCDIR="products/Essbase/EssbaseClient<plat32>"
		_SXR_CLIENT_ARBORPATH="common/EssbaseRTC<rtc64>/11.1.2.0"
	fi
	_DUPCHK_LIST="$_DUPCHK_LIST \$ESSBASEPATH/bin"
	_DUPCHK_LIST="$_DUPCHK_LIST \$SXR_CLIENT_ARBORPATH/bin"
	_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/bin"
	_ESSDIR="products/Essbase/EssbaseServer<plat32>"
	_SXR_HOME="$_ap_snaproot/11122200/vobs/essexer/latest"
	# 2012/07/25 remove RTC path from $PATH by Yuki Hashimoto
	_PATH="$_PATH \$SXR_CLIENT_ARBORPATH/bin"
	_PATH="$_PATH \$ARBORPATH/bin"
	_PATH="$_PATH \$ESSBASEPATH/bin"
	# _PATH="$_PATH \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
	_PATH="$_PATH \$ORACLE_INSTANCE/bin"
	_LIB="$_LIB \$SXR_CLIENT_ARBORPATH/bin"
	_LIB="$_LIB \$ESSBASEPATH/bin"
	_LIB="$_LIB \$ARBORPATH/bin"
	_LIB="$_LIB \$HYPERION_HOME/../ohs/opmn/lib"
	_LIB="$_LIB \$HYPERION_HOME/opmn/lib"	# by BI 11.1.1.7 installation
	if [ `uname` = "Windows_NT" ]; then
		_PATH="\$HYPERION_HOME/bin $_PATH"
		unset _LIB
		_IGNORE_OPACK=client
	else
		_LIB="\$HYPERION_HOME/lib $_LIB"
	fi
	_IGNBIN_LIST="ESSCMDQ|ESSCMDG|ESSTESTCREDSTORE|essmove|stack|register|setbrows|EssStagingTool|startEssbase|cwallet|ewallet"
	;;
11.1.2.2.*)
	if [ "$AP_BISHIPHOME" = "true" ]; then
		_HYPERION_HOME=Oracle_BI1
		_INSTANCE_LOC="../instances/instance<#>"
		_ARBORPATH="\$_INSTANCE_LOC/Essbase/essbaseserver1"
		_SXR_CLIENT_ARBORPATH="clients/epm/Essbase/EssbaseRTC"
		_PATH="$_PATH \$ORACLE_INSTANCE/bin"
	# 	[ "$AP_SECMODE" = "fa" -o "$AP_SECMODE" = "rep" -o "$AP_SECMODE" = "bi" ] \
	# 		&& _PATH="$_PATH \$HYPERION_HOME/../wlserver_10.3/common/bin"
		_EXTRA_SETENVVARS="$_EXTRA_SETENVVARS WEBLOGIC_SERVER WL_HOME"
		_WEBLOGIC_SERVER="$(hostname):7001"
		_WL_HOME="\${HYPERION_HOME%/*}/wlserver_10.3"
	else
		_HYPERION_HOME=EPMSystem11R1
		_INSTANCE_LOC="../user_projects/epmsystem<#>"
		_ARBORPATH="\$_INSTANCE_LOC/EssbaseServer/essbaseserver1"
		_ESSCDIR="products/Essbase/EssbaseClient<plat32>"
		_SXR_CLIENT_ARBORPATH="common/EssbaseRTC<rtc64>/11.1.2.0"
	fi
	_DUPCHK_LIST="$_DUPCHK_LIST \$ESSBASEPATH/bin"
	_DUPCHK_LIST="$_DUPCHK_LIST \$SXR_CLIENT_ARBORPATH/bin"
	_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/bin"
	_ESSDIR="products/Essbase/EssbaseServer<plat32>"
	_SXR_HOME="$_ap_snaproot/11122x/vobs/essexer/latest"
	# 2012/07/25 remove RTC path from $PATH by Yuki Hashimoto
	_PATH="$_PATH \$ARBORPATH/bin"
	_PATH="$_PATH \$ESSBASEPATH/bin"
	_PATH="$_PATH \$SXR_CLIENT_ARBORPATH/bin"
	# _PATH="$_PATH \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
	_PATH="$_PATH \$ORACLE_INSTANCE/bin"
	_PATH="$_PATH \$HYPERION_HOME/../oracle_common/bin"	# for wlst.sh agsfmain.sh
	_LIB="$_LIB \$ESSBASEPATH/bin"
	_LIB="$_LIB \$ARBORPATH/bin"
	_LIB="$_LIB \$SXR_CLIENT_ARBORPATH/bin"
	_LIB="$_LIB \$HYPERION_HOME/../ohs/opmn/lib"
	if [ `uname` = "Windows_NT" ]; then
		_PATH="\$HYPERION_HOME/bin $_PATH"
		unset _LIB
		_IGNORE_OPACK=client
	else
		_LIB="\$HYPERION_HOME/lib $_LIB"
	fi
	_IGNBIN_LIST="ESSCMDQ|ESSCMDG|ESSTESTCREDSTORE|essmove|stack|register|setbrows|EssStagingTool|startEssbase|cwallet|ewallet"
	;;
11.1.2.1.*)
	if [ "$AP_BISHIPHOME" = "true" ]; then
		_HYPERION_HOME=Oracle_BI1
		_INSTANCE_LOC="../instances/instance<#>"
		_ARBORPATH="\$_INSTANCE_LOC/Essbase/essbaseserver1"
		_SXR_CLIENT_ARBORPATH="clients/epm/Essbase/EssbaseRTC"
		_PATH="$_PATH \$ORACLE_INSTANCE/bin"
		[ "$AP_SECMODE" = "fa" -o "$AP_SECMODE" = "rep" -o "$AP_SECMODE" = "bi" ] \
			&& _PATH="$_PATH \$HYPERION_HOME/../wlserver_10.3/common/bin"
		_EXTRA_SETENVVARS="$_EXTRA_SETENVVARS WEBLOGIC_SERVER WL_HOME"
		_WEBLOGIC_SERVER="$(hostname):7001"
		_WL_HOME="\${HYPERION_HOME%/*}/wlserver_10.3"
	else
		_HYPERION_HOME=EPMSystem11R1
		_INSTANCE_LOC="../user_projects/epmsystem<#>"
		_ARBORPATH="\$_INSTANCE_LOC/EssbaseServer/essbaseserver1"
		_ESSCDIR="products/Essbase/EssbaseClient<plat32>"
		_SXR_CLIENT_ARBORPATH="common/EssbaseRTC<rtc64>/11.1.2.0"
	fi
	_DUPCHK_LIST="$_DUPCHK_LIST \$ESSBASEPATH/bin"
	_DUPCHK_LIST="$_DUPCHK_LIST \$SXR_CLIENT_ARBORPATH/bin"
	_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/bin"
	_ESSDIR="products/Essbase/EssbaseServer<plat32>"
	_SXR_HOME="$_ap_snaproot/11121x/vobs/essexer/latest"
	# 2012/07/25 remove RTC path from $PATH by Yuki Hashimoto
	_PATH="$_PATH \$ARBORPATH/bin"
	_PATH="$_PATH \$ESSBASEPATH/bin"
	# _PATH="$_PATH \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
	_PATH="$_PATH \$SXR_CLIENT_ARBORPATH/bin"
	_PATH="$_PATH \$ORACLE_INSTANCE/bin"
	_LIB="$_LIB \$SXR_CLIENT_ARBORPATH/bin"
	_LIB="$_LIB \$ESSBASEPATH/bin"
	_LIB="$_LIB \$ARBORPATH/bin"
	_LIB="$_LIB \$HYPERION_HOME/../ohs/opmn/lib"
	if [ `uname` = "Windows_NT" ]; then
		_PATH="\$HYPERION_HOME/bin $_PATH"
		unset _LIB
		_IGNORE_OPACK=client
	else
		_LIB="\$HYPERION_HOME/lib $_LIB"
	fi
	_IGNBIN_LIST="ESSCMDQ|ESSCMDG|ESSTESTCREDSTORE|essmove|stack|register|setbrows|EssStagingTool|startEssbase|cwallet|ewallet"
	;;
11.1.2.2.001)
	if [ "$AP_BISHIPHOME" = "true" ]; then
		_HYPERION_HOME=Oracle_BI1
		_INSTANCE_LOC="../instances/instance1"
		_ARBORPATH="$_INSTANCE_LOC/Essbase/essbaseserver1"
		_SXR_CLIENT_ARBORPATH="clients/epm/Essbase/EssbaseRTC"
		_DUPCHK_LIST="$_DUPCHK_LIST \$ESSBASEPATH/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$SXR_CLIENT_ARBORPATH/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/bin"
	else
		_HYPERION_HOME=EPMSystem11R1
		_INSTANCE_LOC="../user_projects/epmsystem1"
		_ARBORPATH="$_INSTANCE_LOC/EssbaseServer/essbaseserver1"
		_ESSCDIR="products/Essbase/EssbaseClient<plat32>"
		_SXR_CLIENT_ARBORPATH="common/EssbaseRTC<rtc64>/11.1.2.0"
		_DUPCHK_LIST="$_DUPCHK_LIST \$ESSBASEPATH/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$SXR_CLIENT_ARBORPATH/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/bin"
	fi
	_ESSDIR="products/Essbase/EssbaseServer<plat32>"
	_SXR_HOME="$_ap_snaproot/11122x/vobs/essexer/latest"
	_PATH="$_PATH \$ESSBASEPATH/bin \$ARBORPATH/bin"
	_PATH="$_PATH \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
	_LIB="$_LIB \$ESSBASEPATH/bin \$ARBORPATH/bin"
	_LIB="$_LIB \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
	if [ `uname` = "Windows_NT" ]; then
		_PATH="\$HYPERION_HOME/bin $_PATH"
		unset _LIB
		_IGNORE_OPACK=client
	else
		_LIB="\$HYPERION_HOME/lib $_LIB"
	fi
	_IGNBIN_LIST="ESSCMDQ|ESSCMDG|ESSTESTCREDSTORE|essmove|stack|register|setbrows|EssStagingTool|startEssbase|cwallet|ewallet"
	;;
11.1.2.2.100)
	if [ "$AP_BISHIPHOME" = "true" ]; then
		_HYPERION_HOME=Oracle_BI1
		_INSTANCE_LOC="../instances/instance1"
		_ARBORPATH="$_INSTANCE_LOC/Essbase/essbaseserver1"
		_SXR_CLIENT_ARBORPATH="clients/epm/Essbase/EssbaseRTC"
		_PATH="$_PATH \$ORACLE_INSTANCE/bin"
	else
		_HYPERION_HOME=EPMSystem11R1
		_INSTANCE_LOC="../user_projects/epmsystem1"
		_ARBORPATH="$_INSTANCE_LOC/EssbaseServer/essbaseserver1"
		_ESSCDIR="products/Essbase/EssbaseClient<plat32>"
		_SXR_CLIENT_ARBORPATH="common/EssbaseRTC<rtc64>/11.1.2.0"
	fi
	_ESSDIR="products/Essbase/EssbaseServer<plat32>"
	_SXR_HOME="$_ap_snaproot/11122x/vobs/essexer/latest"
	_PATH="$_PATH \$ESSBASEPATH/bin \$ARBORPATH/bin"
	_PATH="$_PATH \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
	_LIB="$_LIB \$ESSBASEPATH/bin \$ARBORPATH/bin"
	_LIB="$_LIB \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
	if [ `uname` = "Windows_NT" ]; then
		_PATH="\$HYPERION_HOME/bin $_PATH"
		unset _LIB
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/bin"
		_IGNORE_OPACK=client
	else
		_LIB="\$HYPERION_HOME/lib $_LIB"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/lib"
	fi
	_IGNBIN_LIST="ESSCMDQ|ESSCMDG|ESSTESTCREDSTORE|essmove|stack|register|setbrows|EssStagingTool|startEssbase|cwallet|ewallet"
	;;

11.1.2.1.103)
	_ESSDIR="products/Essbase/EssbaseServer<plat32>"
	_ESSCDIR="products/Essbase/EssbaseClient<plat32>"
	_SXR_HOME="$_ap_snaproot/11121x/vobs/essexer/latest"
	_HYPERION_HOME=EPMSystem11R1
	_PATH="$_PATH \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
	_PATH="$_PATH \$ESSBASEPATH/bin \$ARBORPATH/bin"
	_PATH="$_PATH \$HYPERION_HOME/products/Essbase/EssbaseClient<plat32>/bin"
	_LIB="$_LIB \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
	_LIB="$_LIB \$ESSBASEPATH/bin \$ARBORPATH/bin"
	_LIB="$_LIB \$HYPERION_HOME/products/Essbase/EssbaseClient<plat32>/bin"
	if [ `uname` = "Windows_NT" ]; then
		_PATH="\$HYPERION_HOME/bin $_PATH"
		unset _LIB
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/bin"
	else
		_LIB="\$HYPERION_HOME/lib $_LIB"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/lib"
	fi
	_IGNBIN_LIST="ESSCMDQ|ESSCMDG|ESSTESTCREDSTORE|essmove|stack|register|setbrows|EssStagingTool|startEssbase"
	# _SXR_CLIENT_ARBORPATH="\$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0"
	;;

11.1.2.1.*) # 105,106...
	if [ "$AP_BISHIPHOME" = "true" ]; then
		_HYPERION_HOME=Oracle_BI1
		_INSTANCE_LOC="../instances/instance<#>"
		_ARBORPATH="$_INSTANCE_LOC/Essbase/essbaseserver1"
		_SXR_CLIENT_ARBORPATH="clients/epm/Essbase/EssbaseRTC"
		_PATH="$_PATH \$ORACLE_INSTANCE/bin"
	else
		_HYPERION_HOME=EPMSystem11R1
		_INSTANCE_LOC="../user_projects/epmsystem<#>"
		_ARBORPATH="\$_INSTANCE_LOC/EssbaseServer/essbaseserver1"
		_ESSCDIR="products/Essbase/EssbaseClient<plat32>"
		_SXR_CLIENT_ARBORPATH="common/EssbaseRTC<rtc64>/11.1.2.0"
		_PATH="$_PATH \$ORACLE_INSTANCE/bin"
	fi
	_ESSDIR="products/Essbase/EssbaseServer<plat32>"
	_ESSCDIR="products/Essbase/EssbaseClient<plat32>"
	_SXR_HOME="$_ap_snaproot/11121x/vobs/essexer/latest"
	_HYPERION_HOME=EPMSystem11R1
	_PATH="$_PATH \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
	_PATH="$_PATH \$ESSBASEPATH/bin \$ARBORPATH/bin"
	# _PATH="$_PATH \$HYPERION_HOME/products/Essbase/EssbaseClient<plat32>/bin"
	_LIB="$_LIB \$ESSBASEPATH/bin \$ARBORPATH/bin"
	# _LIB="$_LIB \$HYPERION_HOME/products/Essbase/EssbaseClient<plat32>/bin"
	_LIB="$_LIB \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
	if [ `uname` = "Windows_NT" ]; then
		_PATH="\$HYPERION_HOME/bin $_PATH"
		unset _LIB
		# There is a posibility to define HYPERION_HOME only
		# So, we can not use ARBORPATH or ESSBASEPATH on this definition
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/bin"
	else
		_LIB="\$HYPERION_HOME/lib $_LIB"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/lib"
	fi
	_IGNBIN_LIST="ESSCMDQ|ESSCMDG|ESSTESTCREDSTORE|essmove|stack|register|setbrows|EssStagingTool|startEssbase|cwallet|ewallet"
	;;

talleyrand_sp1_269a|talleyrand_sp1|11.1.2.1.*)
	_ESSDIR="products/Essbase/EssbaseServer<plat32>"
	_ESSCDIR="products/Essbase/EssbaseClient<plat32>"
	_SXR_HOME="$_ap_snaproot/11121x/vobs/essexer/latest"
	_HYPERION_HOME=EPMSystem11R1
	_PATH="$_PATH \$ESSBASEPATH/bin \$ARBORPATH/bin"
	_PATH="$_PATH \$HYPERION_HOME/products/Essbase/EssbaseClient<plat32>/bin"
	_PATH="$_PATH \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
	_LIB="$_LIB \$ESSBASEPATH/bin \$ARBORPATH/bin"
	_LIB="$_LIB \$HYPERION_HOME/products/Essbase/EssbaseClient<plat32>/bin"
	_LIB="$_LIB \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
	if [ `uname` = "Windows_NT" ]; then
		_PATH="\$HYPERION_HOME/bin $_PATH"
		unset _LIB
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/bin"
	else
		_LIB="\$HYPERION_HOME/lib $_LIB"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/lib"
	fi
	_IGNBIN_LIST="ESSCMDQ|ESSCMDG|ESSTESTCREDSTORE|essmove|stack|register|setbrows|EssStagingTool|startEssbase"
	# _SXR_CLIENT_ARBORPATH="\$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0"
	;;

talleyrand|11.1.2.0.*|11.1.1.5.*)
	_ESSDIR="products/Essbase/EssbaseServer<plat32>"
	_ESSCDIR="products/Essbase/EssbaseClient<plat32>"
	_SXR_HOME="$_ap_snaproot/talleyrand/vobs/essexer/latest"
	_HYPERION_HOME=EPMSystem11R1
	_PATH="\$ESSBASEPATH/bin \$ARBORPATH/bin"
	_PATH="$_PATH \$HYPERION_HOME/products/Essbase/EssbaseClient<plat32>/bin"
	_LIB="$_LIB \$ESSBASEPATH/bin \$ARBORPATH/bin"
	_LIB="$_LIB \$HYPERION_HOME/products/Essbase/EssbaseClient<plat32>/bin"
	if [ `uname` = "Windows_NT" ]; then
		_PATH="$_PATH \$HYPERION_HOME/bin"
		unset _LIB
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/common/EssbaseRTC<rtc64>/11.1.2.0/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/bin"
	else
		_LIB="$_LIB \$HYPERION_HOME/lib"
	fi
	_IGNBIN_LIST="ESSCMDQ|ESSCMDG|ESSTESTCREDSTORE|essmove|EssStagingTool|startEssbase"
	;;

zola_staging)
	_ESSDIR="products/Essbase/EssbaseServer"
	_ESSCDIR="products/Essbase/EssbaseClient"
	_SXR_HOME="$_ap_snaproot/zola/vobs/essexer/latest"
	_PATH="\$ESSBASEPATH/bin \$ARBORPATH/bin"
	_PATH="$_PATH \$HYPERION_HOME/products/Essbase/EssbaseClient/bin"
	_LIB="\$ESSBASEPATH/bin \$ARBORPATH/bin"
	_LIB="$_LIB \$HYPERION_HOME/products/Essbase/EssbaseClient/bin"
	if [ `uname` = "Windows_NT" ]; then
		_PATH="$_PATH \$HYPERION_HOME/bin"
		unset _LIB
	else
		_LIB="$_LIB \$HYPERION_HOME/lib"
	fi
	;;

11.1.1.2.3|11.1.1.2.7)
	_ESSDIR=products/Essbase/EssbaseServer
	_ESSCDIR=products/Essbase/EssbaseClient
	_SXR_HOME="$_ap_snaproot/zola/vobs/essexer/latest"
	_PATH="\$ESSBASEPATH/bin \$ARBORPATH/bin"
	_PATH="$_PATH \$HYPERION_HOME/products/Essbase/EssbaseClient/bin"
	_LIB="\$ESSBASEPATH/bin \$ARBORPATH/bin"
	_LIB="$_LIB \$HYPERION_HOME/products/Essbase/EssbaseClient/bin"
	[ `uname` = "Windows_NT" ] && unset _LIB
	;;

dickens|11.1.1.2.*)
	_ESSDIR=products/Essbase/EssbaseServer
	_ESSCDIR=products/Essbase/EssbaseClient
	# _SXR_HOME="$AUTOPILOT/../../kennedy/vobs/essexer/latest"
	_SXR_HOME="$_ap_snaproot/dickens/vobs/essexer/latest"
	_PATH="\$ESSBASEPATH/bin \$ARBORPATH/bin"
	_PATH="$_PATH \$HYPERION_HOME/products/Essbase/EssbaseClient/bin"
	_LIB="\$ESSBASEPATH/bin \$ARBORPATH/bin"
	_LIB="$_LIB \$HYPERION_HOME/products/Essbase/EssbaseClient/bin"
	[ `uname` = "Windows_NT" ] && unset _LIB
	if [ `uname` = "Windows_NT" ]; then
		unset _LIB
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/products/Essbase/EssbaseClient<plat32>/bin"
	else
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/products/Essbase/EssbaseClient<plat32>/bin"
	fi
	_IGNBIN_LIST="ESSCMDQ|ESSCMDG|ESSTESTCREDSTORE|essmove|stack|register|setbrows|EssStagingTool|startEssbase"
	;;

11.1.1.1.*) # Kennedy2 OPATCH
	_ESSDIR=products/Essbase/EssbaseServer
	_ESSCDIR=products/Essbase/EssbaseClient
	# _SXR_HOME="$_ap_snaproot/kennedy/vobs/essexer/latest"
	_SXR_HOME="$_ap_snaproot/zola/vobs/essexer/latest"
	_PATH="\$ESSBASEPATH/bin \$ARBORPATH/bin"
	_PATH="$_PATH \$HYPERION_HOME/products/Essbase/EssbaseClient/bin"
	_LIB="\$ESSBASEPATH/bin \$ARBORPATH/bin"
	_LIB="$_LIB \$HYPERION_HOME/products/Essbase/EssbaseClient/bin"
	[ `uname` = "Windows_NT" ] && unset _LIB
	;;

kennedy2|11.1.1.1.0)
	_ESSDIR=products/Essbase/EssbaseServer
	_ESSCDIR=products/Essbase/EssbaseClient
	# _SXR_HOME="$_ap_snaproot/kennedy/vobs/essexer/latest"
	_SXR_HOME="$_ap_snaproot/zola/vobs/essexer/latest"
	_PATH="\$ARBORPATH/bin"
	_PATH="$_PATH \$HYPERION_HOME/products/Essbase/EssbaseClient/bin"
	_LIB="\$ESSBASEPATH/bin \$ARBORPATH/bin"
	_LIB="$_LIB \$HYPERION_HOME/products/Essbase/EssbaseClient/bin"
	[ `uname` = "Windows_NT" ] && unset _LIB
	;;

kennedy|9.5*|11.1.1.0.0)
	_ESSDIR=products/Essbase/EssbaseServer
	_ESSCDIR=products/Essbase/EssbaseClient
	# _SXR_HOME="$_ap_snaproot/kennedy/vobs/essexer/latest"
	_SXR_HOME="$_ap_snaproot/zola/vobs/essexer/latest"
	_PATH="\$ARBORPATH/bin"
	_PATH="$_PATH \$HYPERION_HOME/products/Essbase/EssbaseClient/bin"
	_LIB="\$ESSBASEPATH/bin \$ARBORPATH/bin"
	_LIB="$_LIB \$HYPERION_HOME/products/Essbase/EssbaseClient/bin"
	[ `uname` = "Windows_NT" ] && unset _LIB
	;;

zola|11.1.1.*)
	_ESSDIR="products/Essbase/EssbaseServer"
	_ESSCDIR="products/Essbase/EssbaseClient"
	_SXR_HOME="$_ap_snaproot/zola/vobs/essexer/latest"
	_PATH="\$ESSBASEPATH/bin \$ARBORPATH/bin"
	_PATH="$_PATH \$HYPERION_HOME/products/Essbase/EssbaseClient/bin"
	_PATH="$_PATH \$HYPERION_HOME/common/EssbaseRTC<rtc64>/9.5.0.0/bin"
		_SXR_CLIENT_ARBORPATH="common/EssbaseRTC<rtc64>/9.5.0.0"
	_LIB="\$ESSBASEPATH/bin \$ARBORPATH/bin"
	_LIB="$_LIB \$HYPERION_HOME/products/Essbase/EssbaseClient/bin"
	if [ `uname` = "Windows_NT" ]; then
		_PATH="$_PATH \$HYPERION_HOME/bin"
		unset _LIB
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/products/Essbase/EssbaseClient<plat32>/bin"
	else
		_LIB="$_LIB \$HYPERION_HOME/lib"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/products/Essbase/EssbaseServer<plat32>/bin"
		_DUPCHK_LIST="$_DUPCHK_LIST \$HYPERION_HOME/products/Essbase/EssbaseClient<plat32>/bin"
	fi
	;;

9.3|9.3.0*|beckett) # Beckett - 9.3.0
	_ESSDIR=AnalyticServices
	_SXR_HOME="$_ap_snaproot/beckett/vobs/essexer/latest"
	_PATH="\$ARBORPATH/bin"
	_LIB="\$ARBORPATH/bin"
	[ `uname` = "Windows_NT" ] && unset _LIB
	;;

9.3.1.3.0|9.3.1.3.1|9.3.1*)
	_ESSDIR=AnalyticServices
	_SXR_HOME="$_ap_snaproot/barnes/vobs/essexer/latest"
	_PATH="\$ARBORPATH/bin"
	_LIB="\$ARBORPATH/bin"
	[ `uname` = "Windows_NT" ] && unset _LIB
	;;

9.3.3.0.0|9.3.3*)
	_ESSDIR=AnalyticServices
	_SXR_HOME="$_ap_snaproot/barnes/vobs/essexer/latest"
	_PATH="\$ARBORPATH/bin"
	_LIB="\$ARBORPATH/bin"
	[ `uname` = "Windows_NT" ] && unset _LIB
	;;

9.2.1*|9.2/9.2.1*)
	_ESSDIR=AnalyticServices
	_SXR_HOME="$_ap_snaproot/joyce/vobs/essexer/latest"
	_PATH="\$ARBORPATH/bin"
	_LIB="\$ARBORPATH/bin"
	[ `uname` = "Windows_NT" ] && unset _LIB
	;;

9.2.0*|9.2/9.2.0*) # Conrad
	_ESSDIR=AnalyticServices
	_SXR_HOME="$_ap_snaproot/joyce/vobs/essexer/latest"
	_PATH="\$ARBORPATH/bin"
	_LIB="\$ARBORPATH/bin"
	[ `uname` = "Windows_NT" ] && unset _LIB
	;;

7.1*)
	_ESSDIR=essbase
	_SXR_HOME="$_ap_snaproot/joyce/vobs/essexer/latest"
	_PATH="\$ARBORPATH/bin"
	_LIB="\$ARBORPATH/bin"
	[ `uname` = "Windows_NT" ] && unset _LIB
	;;

*)
	_ESSDIR=products/Essbase/EssbaseServer
	_SXR_HOME=
	_PATH="\$ARBORPATH/bin"
	_LIB="\$ARBORPATH/bin"
	[ `uname` = "Windows_NT" ] && unset _LIB
	;;
esac

