#!/usr/bin/ksh
#########################################################################
# Filename: 	start_regress.sh
# Author:	Yukio Kono
#########################################################################
# SYNTAX:
# start_regress.sh [ -opt <opt> ] <ver> <bld> <script> [ <test opt> ]
# <ver>      : Full version string. (pre_rel version structure)
#              kennedy, 9.3.1.3.0, 9.2/9.2.1.3.0
# <bld>      : Build number.
#              019, latest, hit[013], hit[latest]
# <script>   : Test script name.
# <test opt> : Test script options.
#              agtpjlmain.sh parallel direct
# -opt <opt> : Task option 
#########################################################################
# Return code:
# - move current task to done
# exit 0	Regression done > go to done
# exit 1	Regression done with verbose(false) mode > go to done
# exit 2	FLAG != START > go to done
# - move back current task to que
# exit 10	not enough free -> pause / move back to que
# exit 11	Regression failed with 0 dif/suc -> pause / move back to que
# exit 12	SXR_INVIEW is not empty. -> pause / move back to que
# exit 13	parameter error -> pause
# exit 14   AIX: too small ncargs parameter -> pause
# - delete current task file (Those may re-create next task parse)
# exit 20	install error -> skip tsk -> delete
# exit 21	alter setup error -> skip tsk -> delete
# exit 22	Regression Killed/Terminated -> delete
# exit 23   Invalid ver or bld number -> skip tsk
# exit 24   Test script not found -> skip tsk
# STOP with ctl+C -> move back to que (controled by apmon.sh)
#########################################################################
# History:
# 06/20/2007 YK	First Edition
# 06/25/2007 YK	Add task file option check
# 07/18/2007 YK Add e-mail notify level
# 08/17/2007 YK Add "kennedy" check on version check
# 05/07/2008 YK Change the results name to <plat>_<ver>_<bld>_<test>
# 07/03/2008 YK Add dynamic/snapshot view check on creating VIEW file.
# 08/06/2008 YK Add resfolder(), resscript(), altsetup(), altsetenv()
#               options and environment variables.
# 09/18/2008 YK Change ls command to find command to avoid the ls failing
#               problem when a count of files over 2000 on AIX platform.
# 09/30/2008 YK Add ncarg check on AIX platform. -> Pause
# 09/30/2008 YK Add ESSLANG=English_UnitedStates.US-ASCII@Binary check.
# 10/28/2008 YK Add Clean up notify to "CleanupNotify" user.
# 11/13/2008 YK Add setenv() and setenv2() task option.
#                   setenv() is executed before the installation.
#                   setenc() is executed after Inst/SetEnv steps.
# 11/14/2008 YK Add snapshot() for SXR_HOME location.
#                   snapshot(<ss>) -> Use specific snapshot from below:
#                           $AUTOPILOT/../../<ss>/vobs/essexer/latest
# 11/14/2008 YK Modify the parameter interface.
# 12/05/2008 YK - Add AP_UNCOMMENTJVM
# 12/12/2008 YK Fix the e-mail overwrite problem on Windows platform.
# 12/24/2008 YK Add diffCntNotify() task option.
# 01/14/2009 YK Add test for the ver#, bld# and test script.
# 01/20/2009 YK Clean up sxrview folder before running regression.
# 02/05/2009 YK Put analyzed dif record into .rtf file.
# 02/26/2009 YK Add Cosecutive diff notification
# 05/05/2009 YK Add memory monitor call.
# 05/05/2009 YK Add environment setting output to env folder.
#
#######################################################################

. apinc.sh

# CONSTANT DEFINITION AND CHECK OVERRIDE BY ENV-VAR

sxrfiles="log sta sog suc dif dna xcp lastcfg" # SXR FRAMEWORK FILES

[ -n "$AP_EMAILLIST" -a -f "$AP_EMAILLIST" ] \
	&& export EMAIL_LIST="$AP_EMAILLIST" \
	|| export EMAIL_LIST="$AP_DEF_EMAILLIST"

[ -n "$AP_SCRIPTLIST" -a -f "$AP_SCRIPTLIST" ] \
	&& export SCRIPT_LIST="$AP_SCRIPTLIST" \
	|| export SCRIPT_LIST="$AP_DEF_SCRIPTLIST"

#######################################################################
# Clean tmp directory

clean_tmp ()
{
	echo "Trying to Clean up Temp Space"

	if [ `uname` = "Windows_NT" ]; then
		echo "No Need to Clean Temp Space"
	elif [ `uname` = "AIX" ]; then
		find /tmp | grep -i $LOGNAME | while read line; do
			MYTMP=`echo $line | awk '{print $9}'`
			chmod -R 0777 /tmp/$MYTMP > /dev/null 2>&1
			rm -rf /tmp/$MYTMP  > /dev/null 2>&1
		done	
	else
		find /var/tmp | grep -i $LOGNAME | while read line; do
			MYTMP=`echo $line | awk '{print $9}'`
			chmod -R 0777 /var/tmp/$MYTMP > /dev/null 2>&1
			rm -rf /var/tmp/$MYTMP > /dev/null 2>&1
		done
	fi
	sleep 5
}


#######################################################################
# Get mail address for specific user
# If there is no address for loguser, use Admin instead of it
# get_emailaddr <user> <user>...
get_emailaddr ()
{
	_addrlist=
	for _onename in $@; do
		_pre_at=${_onename%@*}
		_post_at=${_onename#*@}
		if [ "$_pre_at" = "$_post_at" ]; then
			_targline=`cat "$EMAIL_LIST" | grep "^${_onename}[ 	]" | grep -v "^#" | tail -1`
			if [ -n "$_targline" ]; then
				_oneaddr=`echo "$_targline" | sed -e s/^${_onename}//g -e s/#.*$//g \
							-e "s/^[ 	]*//g" -e "s/[ 	]*$//g" -e "s/[ 	][ 	]*/ /g"`
			else
				_oneaddr=
			fi
		else
			_oneaddr=$_onename
		fi
		if [ -n "$_oneaddr" ]; then
			[ -z "$_addrlist" ] \
				&& _addrlist=$_oneaddr \
				|| _addrlist="$_addrlist $_oneaddr"
		fi
	done
	if [ -z "$_addrlist" ]; then
		_oneaddr=`cat "$EMAIL_LIST" | grep "^Admin" | grep -v "^#"`
		_addrlist=`echo "$_oneaddr" | sed -e s/^Admin//g -e s/#.*$//g \
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
		addrs=`head -1 $1 | tr -d '\r'`
		sbj=`head -2 $1 | tail -1 | tr -d '\r'`
		lines=`cat $1 | wc -l`
		let lines="$lines - 2"
		if [ `uname` = "Windows_NT" ]; then
			# tail -${lines} $1 | smtpmail -s "$sbj" ${addrs}
			i=0
			mailfile="${LOGNAME}@`hostname`"
			while [ -f "$AUTOPILOT/mail/${mailfile}.$$.$i" ]; do
				let i="$i + 1"
			done
			cp $1 $AUTOPILOT/mail/${mailfile}.$$.$i
		else
			tail -${lines} $1 | mailx -s "$sbj" ${addrs}
		fi
		rm -f $1
		unset mailfile lines addrs sbj
	fi
}


#######################################################################
# Get mail address for specific user
# If there is no address for loguser, use Admin instead of it
# get_emailaddr <user> <user>...
# chk_free <path str> <expected size>
chk_free ()
{
	unset CURRFREE
	_dir=${1#*\$}
	if [ "$_dir" != "$1" ]; then
		_dir=`eval echo $1`
		echo "Check the free space on $1($_dir)"
	else
		echo "Check the free space on $_dir"
	fi
	export CURRFREE=`get_free.sh "$_dir"`
	if [ -z "$CURRFREE" ]; then
		echo "Failed to get FREE space."
	else
		echo "Curent free space = $CURRFREE KB, Expected free size $2 KB"
		if [ $CURRFREE -lt $2 ]; then
			###########################################################
			# No sufficient HD space
			# Send notify mail to executor
			###########################################################
			echo "No sufficient free space on $1"
			echo "Autopilot move on to PAUSE mode."
			if [ "$verbose" = "true" ]; then
				email_tmp="$AP_DEF_TMPPATH/`hostname`_${LOGNAME}.eml"
				[ -f "$email_tmp" ] && chmod 777 $email_tmp
				get_emailaddr $LOGNAME InstNotify $AP_ALTEMAIL 		> "$email_tmp"
				echo "Autopilot Notification (No sufficient space) - ${VERSION} ${BUILD} - `uname -n`:${_PLATNAME} ${TEST}" >> "$email_tmp"
				echo "There is no sufficient free space on $1."		>> $email_tmp
				echo ""												>> $email_tmp
				echo "  Machine         = `hostname`:$_PLATNAME"	>> $email_tmp
				echo "  Login User      = $LOGNAME"					>> $email_tmp
				echo "  Target location = $1"						>> $email_tmp
				echo "  Disk Free size  = ${CURRFREE} KB"			>> $email_tmp
				echo "  Expected size   = $2 KB"					>> $email_tmp
				echo "  Version:Build   = $VERSION:$BUILD"			>> $email_tmp
				echo "  Test Script     = $TEST"					>> $email_tmp
				echo ""												>> $email_tmp
				echo "Autopilot is moving to PAUSE mode."			>> $email_tmp
				echo "Please check the disk space on this machine."	>> $email_tmp
				send_email $email_tmp
				# Send clean up notify 10/28/2008 YK
				get_emailaddr CleanupNotify $AP_ALTEMAIL 		> "$email_tmp"
				echo "Please clean up your files on `uname -n`:${_PLATNAME}" >> "$email_tmp"
				echo "Hi All,"											>> $email_tmp
				echo ""													>> $email_tmp
				echo "There is no sufficient free space at $_dir on `uname -n`."	>> $email_tmp
				echo "Current free size is ${CURRFREE} KB."				>> $email_tmp
				echo "Essbase server regression team uses this machine"	>> $email_tmp
				echo "for the automated regression test."				>> $email_tmp
				echo "And it require at least $2 KB free space."		>> $email_tmp
				echo ""													>> $email_tmp
				echo "Could you clean up your files on `uname -n` ?"	>> $email_tmp
				echo ""													>> $email_tmp
				echo "Best regards,"									>> $email_tmp
				echo "$LOGNAME."										>> $email_tmp
				echo ""													>> $email_tmp
				echo "PS. This e-mail is sent by autopilot framework."	>> $email_tmp

				upper_folder=${_dir%%${LOGNAME}*}
				echo "==============================================="	>> $email_tmp
				if [ "$upper_folder" = "$_dir" ]; then
					# No upper folder
					echo "Target($_dir) doesn't contain the user name($LOGNAME)."
					upper_folder=`get_free.sh "$_dir" 1`
					echo "Use $upper_folder for the target location."
				fi
				echo "Check $upper_folder usage..."
				echo "Disk usage(`uname -n`:$upper_folder):" >> $email_tmp
				du -ks "$upper_folder"* 2> /dev/null | sort -nr >> $email_tmp
				unset upper_folder

				send_email $email_tmp
			fi
			set_flag PAUSE

			wrtstg "!ERR 10:No sufficient memory."
			wrtstg "  loc=$1($_dir)"
			wrtstg "  crr=$CURRFREE KB"
			wrtstg "  exp=$2 KB"
			wrtstg "#EXIT"

			exit 10
		fi
	fi
}


#######################################################################
# Check FLAG
chk_flag()
{
	_FLAG=`get_flag`
	if [ "$_FLAG" != "START" ]; then
		echo "FLAG is not set to START($_FLAG). Abort start_regress.sh $VERSION $BUILD $TEST"
		exit 2
	fi
}


#######################################################################
# Write to stage file.
stgfile="$AUTOPILOT/mon/${LOGNAME}@`hostname`.stg"
rm -f $stgfile > /dev/null 2>&1
touch $stgfile > /dev/null 2>&1
chmod 755 $stgfile > /dev/null 2>&1
wrtstg()
{
	echo "`date +%D_%T` $@" >> $stgfile
}

#######################################################################
# Main process start here
#######################################################################
set_sts RUNNING
wrtstg "#START"

#######################################################################
# Read parameter

orgpar="$@"
unset VERSION BUILD TEST opt
while [ $# -ne 0 ]; do
	case $1 in
		-opt|-o)
			shift
			if [ $# -eq 0 ]; then
				echo "'-opt' option need option string."
				unset VERSION
				break;
			fi
			[ -z "$opt" ] && opt="$1" || opt="$opt $1"
			;;
		*)
			if [ -z "$VERSION" ]; then
				VERSION=$1
			else
				if [ -z "$BUILD" ]; then
					BUILD=$1
				else
					if [ -z "$TEST" ]; then
						TEST=$1
					else
						TEST="$TEST $1"
					fi
				fi
			fi
			;;
	esac
	shift	
done

if [ -z "$VERSION" -o -z "$BUILD" -o -z "$TEST" ]; then
	echo "start_regress.sh : syntax error"
	echo "Usage: start_regress.sh <VERSION> <BUILD> <TEST>"
	echo "current parmeter: $orgpar"
	echo "current option:   $_OPTION"
	set_flag PAUSE
	wrtstg "!ERR 13:Not enough parameter."
	wrtstg "  par:$orgpar"
	wrtstg "  opt:$_OPTION"
	wrtstg "#EXIT"
	exit 13
fi

if [ -n "$opt" ]; then
	[ -z "$_OPTION" ] && export _OPTION="$opt" || export _OPTION="$opt $_OPTION"
fi
unset opt orgpar

ORG_BUILD=$BUILD
BUILD=`normbld.sh $VERSION $BUILD`
sts=$?
if [ $sts -ne 0 ]; then
	echo "### Invalid version or build number($sts)."
	echo "VERSION=$VERSION, BUILD=$ORG_BUILD."
	wrtstg "!ERR 23:Invalid ver/build number(sts=$sts)."
	wrtstg "  ver=$VERSION, bld=$ORG_BUILD."
	wrtstg "#EXIT"
	exit 23
fi

wrtstg "#VER=$VERSION"
[ "$ORG_BUILD" = "$BUILD" ] && wrtstg "#BLD=$BUILD" \
	|| wrtstg "#BLD=$BUILD($ORG_BUILD)"
wrtstg "#TEST=$TEST"
wrtstg "#TASKOPT"

#######################################################################
# Read the regression task options from _OPTION
wrtstg "#READ ENVVAR/TSKOPT"
# arch() > ARCH
arch=`chk_para.sh arch "${_OPTION}"`
[ -n "$arch" ] && export ARCH=$arch
_PLATNAME=`get_platform.sh`  # get_platform.sh need $ARCH

# AltMail() > AP_ALTMAIL
altemail=`chk_para.sh altemail "${_OPTION}"`
[ -n "$altemail" ] && AP_ALTEMAIL=$altemail

# RegMonDBG() > AP_REGMON_DEBUG
regmondbg=`chk_para.sh regmondebug "${_OPTION}"`
[ -n "$regmondbg" ] && export AP_REGMON_DEBUG=$regmondbg

# I18NGrep() > SXR_I18N_GREP
i18ngrep=`chk_para.sh i18ngrep "${_OPTION}"`
[ -z "$i18ngrep" -a -n "$SXR_I18N_GREP" ] && i18ngrep="$SXR_I18N_GREP"

# UncommentJVM() > AP_UNCOMMENTJVM
uncommentjvm=`chk_para.sh uncommentJvm "${_OPTION}"`
[ -n "$uncommentjvm" ] && export AP_UNCOMMENTJVM="$uncommentjvm"

# HangUp() > AP_HANGUP
hangup=`chk_para.sh hangup "${_OPTION}"`
if [ -z "$hangup" ]; then
	[ -n "$AP_HANGUP" ] \
		&& hangup=$AP_HANGUP \
		|| hangup=14400		# = 4H x 60 min x 60 sec
fi

# Verbose()
verbose=`chk_para.sh verbose "${_OPTION}"`
[ -z "$verbose" ] && verbose=true

# NoAgtpsetup() > AP_NOAGTPSETUP
noagtpsetup=`chk_para.sh noagtpsetup "${_OPTION}"`
[ -z "$noagtpsetup" -a -n "$AP_NOAGTPSETUP" ] && noagtpsetup="$AP_NOAGTPSETUP"

# EssbaseCFG() > AP_ESSBASECFG
essbasecfg=`chk_para.sh essbasecfg "${_OPTION}"`
[ -n "$essbasecfg" ] && export AP_ESSBASECFG="$essbasecfg"

# NotifyLvl() > AP_NOTIFYLVL
export _NOTIFYLVL=`chk_para.sh notifylvl "${_OPTION}"`
if [ -z "$_NOTIFYLVL" ]; then
	[ -n "$AP_NOTIFYLVL" ] \
		&& export _NOTIFYLVL=$AP_NOTIFYLVL \
		|| export _NOTIFYLVL="all"
fi

# TarCtrl() > AP_TARCTL
tarctl=`chk_para.sh tarctl "${_OPTION}"`
if [ -z "$tarctl" ]; then
	[ -n "$AP_TARCTL" ] \
		&& tarctl="$AP_TARCTL" \
		|| tarctl="essexer"	# default
fi

# TarCnt() > AP_TARCNT
tarcnt=`chk_para.sh tarcnt "${_OPTION}"`
if [ -z "$tarcnt" ]; then
	[ -n "$AP_TARCNT" ] \
		&& tarcnt="$AP_TARCNT" \
		|| tarcnt=10	# default
fi

agtstart=`chk_para.sh agtstart "${_OPTION}"`
if [ -z "$agtstart" ]; then
	[ -n "$AP_AGTSTART" ] && agtstart=$AP_AGTSTART
fi

# ResFolder() > AP_RESFOLDER ( <null> | i18n | aps | .. )
_tmp_=`chk_para.sh resfolder "${_OPTION}"`
[ -n "$_tmp_" ] && expot AP_RESFOLDER="$_tmp_"

# ResScript() / AP_RESSCRIPT
_tmp_=`chk_para.sh resscript "${_OPTION}"`
[ -n "$_tmp_" ] && export AP_RESSCRIPT="$_tmp_"

# AltSetup() > AP_ALTSETUP
_tmp_=`chk_para.sh altsetup "${_OPTION}"`
[ -n "$_tmp_" ] && export AP_ALTSETUP="$_tmp_"

# AltSetEnv() > AP_ALTSETENV
_tmp_=`chk_para.sh altsetenv "${_OPTION}"`
[ -n "$_tmp_" ] && export AP_ALTSETENV="$_tmp_"

# setenv() 
_tmp_=`chk_para.sh setenv "${_OPTION}"`
if [ -n "$_tmp_" ]; then
	for i in $_tmp_; do
		varn=${i%=*}
		varv=${i#*=}
		_v=${varv#*\$}
		[ "$_v" != "$varv" ] && varv=`eval echo $varv`
		export ${varn}="${varv}"
	done
	unset varn varv i _v
fi

# DiffCntNotify()
_tmp_=`chk_para.sh diffcntnotify "${_OPTION}"`
[ -n "$_tmp_" ] && export AP_DIFFCNT_NOTIFY="$_tmp_"

# snapshot()
_tmp_=`chk_para.sh snapshot "${_OPTION}"`
if [ -n "$_tmp_" ]; then
	if [ ! -d "$AUTOPILOT/../../$_tmp_/vobs/essexer/latest" ]; then
		echo "## You define snapshot($_tmp_) for this task."
		echo "## But couldn't find the $AUTOPILOT/../../$_tmp_/vobs/essexer/latest folder."
		echo "## This task doesn't use snapshot($_tmp_) option."
	else
		crr=`pwd`
		cd "$AUTOPILOT/../../$_tmp_/vobs/essexer/latest"
		export SXR_HOME=`pwd`
		cd "$crr"
		echo "## Define \$SXR_HOME=$SXR_HOME by snapshot($_tmp_) task option."
	fi
	unset crr
fi	

unset _tmp_


#######################################################################
# Check $SXR_INVIEW defined. (When defined it, sxr goview must fail.)
wrtstg "#CHECK SXR_INVIEW"
if [ -n "$SXR_INVIEW" ]; then
	echo "##################################"
	echo "### \$SXR_INVIEW IS NOT EMPTY ###"
	echo "##################################"
	echo "\$SXR_INVIEW=$SXR_INVIEW"
	echo "This setting cause 'sxr goview' failure."
	echo "And it will cause '0 suc' and '0 dif' result."
	echo "Move to PAUSE mode."
	if [ "$verbose" = "true" ]; then
		email_tmp="$AP_DEF_TMPPATH/`hostname`_${LOGNAME}.eml"
		[ -f "$email_tmp" ] && chmod 777 $email_tmp
		get_emailaddr $LOGNAME $AP_ALTEMAIL EnvNotify > $email_tmp
		echo "Autopilot Notification (SXR_INVIEW) - ${VERSION} ${BUILD} - `uname -n`:${_PLATNAME} ${TEST}" >> $email_tmp
		echo "You might be in SXR view(\$SXR_INVIEW=$SXR_INVIEW)."		>> $email_tmp
		echo ""	>> $email_tmp
		echo "  Machine         = `hostname`:$_PLATNAME"	>> $email_tmp
		echo "  Login User      = $LOGNAME"					>> $email_tmp
		echo "  Version:Build   = $VERSION:$BUILD"			>> $email_tmp
		echo "  Test Script     = $TEST"					>> $email_tmp
		echo ""	>> $email_tmp
		echo "Autopilot is moving to PAUSE mode."			>> $email_tmp
		echo "Please check the target environment of this machine."	>> $email_tmp
		send_email $email_tmp
	fi
	set_flag PAUSE
	wrtstg "!ERR 12:You are in SXR_VIEW."
	wrtstg "  \$SXR_INVIEW=$SXR_INVIEW."
	wrtstg "#EXIT"
	exit 12
fi


#######################################################################
# Check ncarg count
if [ `uname` = "AIX" ]; then
	wrtstg "#CHECK NCARG"
	_ncarg=`lsattr -EH -l sys0 | grep ncargs | awk '{print $2}'`
	if [ -z "$_ncarg" -o $_ncarg -lt 16 ]; then
		echo "##############################"
		echo "### Small ncargs parameter ###"
		echo "##############################"
		lsattr -EH -l sys0 | grep ncargs
		echo "This setting cause '0403-027 The parameter list is too long(6625591)' problem."
		echo "And it will cause '0 suc' and '0 dif' result."
		echo "Move to PAUSE mode."
		if [ "$verbose" = "true" ]; then
			email_tmp="$AP_DEF_TMPPATH/`hostname`_${LOGNAME}.eml"
			[ -f "$email_tmp" ] && chmod 777 $email_tmp
			get_emailaddr $LOGNAME $AP_ALTEMAIL EnvNotify > $email_tmp
			echo "Autopilot Notification (NCARGS) - ${VERSION} ${BUILD} - `uname -n`:${_PLATNAME} ${TEST}" >> $email_tmp
			echo "Small value for NCARGS parameter($_ncarg)."		>> $email_tmp
			echo ""	>> $email_tmp
			echo "  Machine         = `hostname`:$_PLATNAME"	>> $email_tmp
			echo "  Login User      = $LOGNAME"					>> $email_tmp
			echo "  Version:Build   = $VERSION:$BUILD"			>> $email_tmp
			echo "  Test Script     = $TEST"					>> $email_tmp
			echo ""	>> $email_tmp
			echo "Autopilot is moving to PAUSE mode."			>> $email_tmp
			echo ""		>> $email_tmp
			echo "This setting cause 'ls *.suc | wc -l' to 0 result"		>> $email_tmp
			echo "by '0403-027 The parameter list is too long(6625591)' error." >> $email_tmp
			echo "You need set it to at least 16 or greater"		>> $email_tmp
			echo "using 'chdev -l sys0 -a ncargs=256' command."		>> $email_tmp
			echo ""		>> $email_tmp
			echo "Please check http://docs.sun.com/app/doc/820-3530/gfxzh?l=en&a=view site."		>> $email_tmp
			send_email $email_tmp
		fi
		set_flag PAUSE
	wrtstg "!ERR 14:Small NCARG(aix)."
	wrtstg "  NCARG=$_ncarg."
	wrtstg "#EXIT"
		exit 14
	fi
fi


#######################################################################
# Check disk space (should above 10GB as default)
chk_tmpdir=5242880; chk_tmp=5242880; chk_temp=5242880
chk_viewpath=10485760; chk_arborpath=10485760

# Get extra ChkFree() options
checkPoints=`chk_para.sh chkfree "${_OPTION}"`
if [ -n "$checkPoints" ]; then
	for item in $checkPoints; do
		wrtstg "#CHECK FREE - $item"
		varname=${item%=*}
		value=${item#*=}
		echo "### $varname : $value"
		case $varname in
			\$ARBORPATH)	chk_arborpath=$value;;
			\$TMP)			chk_tmp=$value;;
			\$TMPDIR)		chk_tmpdir=$value;;
			\$TEMP)			chk_temp=$value;;
			\$VIEW_PATH)	chk_viewpath=$value;;
			*)				chk_free "$varname" $value;;
		esac
	done
fi


#######################################################################
# Check TMP, TEMP and TMPDIR definitions
wrtstg "#CHECK TMP/TEMP/TMPDIR"
if [ -z "$TMP" -o -z "$TEMP" -o -z "$TMPDIR" ]; then
	echo "##################################"
	echo "### No TMP,TEMP,TMPDIR defined ###"
	echo "##################################"
	echo "\$TMP   =$TMP"
	echo "\$TEMP  =$TEMP"
	echo "\$TMPDIR=$TMPDIR"
	if [ "$verbose" = "true" ]; then
		_tmp_=
		[ -z "$TMP" ] && _tmp_="TMP"
		if [ -z "$TEMP" ]; then
			[ ! -z "$_tmp_" ] && _tmp_="$_tmp_, "
			_tmp_="${_tmp_}TEMP"
		fi
		if [ -z "$TMPDIR" ]; then
			[ ! -z "$_tmp_" ] && _tmp_="$_tmp_, "
			_tmp_="${_tmp_}TMPDIR"
		fi
		email_tmp="$AP_DEF_TMPPATH/`hostname`_${LOGNAME}.eml"
		[ -f "$email_tmp" ] && chmod 777 $email_tmp
		# get_emailaddr $LOGNAME $AP_ALTEMAIL EnvNotify > $email_tmp
		get_emailaddr EnvNotify > $email_tmp
		echo "Autopilot Notification (No TMP Def) - ${VERSION} ${BUILD} - `uname -n`:${_PLATNAME} ${TEST}" >> $email_tmp
		echo "$_tmp_ not defined."		>> $email_tmp
		echo "It might cause the installation failure."		>> $email_tmp
		echo "I would recommend to define TMP,TEMP,TMPDIR variables."		>> $email_tmp
		echo "But continue the execution."		>> $email_tmp
		echo ""	>> $email_tmp
		echo "  Machine         = `hostname`:$_PLATNAME"	>> $email_tmp
		echo "  Login User      = $LOGNAME"					>> $email_tmp
		echo "  Version:Build   = $VERSION:$BUILD"			>> $email_tmp
		echo "  Test Script     = $TEST"					>> $email_tmp
		echo "  \$TMP   =$TMP"								>> $email_tmp
		echo "  \$TEMP  =$TEMP"								>> $email_tmp
		echo "  \$TMPDIR=$TMPDIR"							>> $email_tmp
		echo "---ALL ENV---" >> $email_tmp
		set >> $email_tmp
		send_email $email_tmp
		unset _tmp_
	fi
fi

# Check temp free sizes
wrtstg "#CHECK TMP/TEMP/TMPDIR FREE"
unset st_tmpdir st_tmp st_temp st_arborpath st_viewpath
if [ -n "$TMPDIR" ]; then
	chk_free "\$TMPDIR" $chk_tmpdir
	st_tmpdir=$CURRFREE
fi
if [ -n "$TMP" ]; then
	chk_free "\$TMP" $chk_tmp
	st_tmp=$CURRFREE
fi
if [ -n "$TEMP" ]; then
	chk_free "\$TEMP" $chk_temp
	st_temp=$CURRFREE
fi

chk_flag


#######################################################################
# Install Products
#######################################################################
wrtstg "#CHECK INSTALLATION"
_inst_err=0
[ -f "$AP_DEF_INSTERRSTS" ] && rm -f "$AP_DEF_INSTERRSTS"

# Get ForceInst() option
finst=`chk_para.sh forceinst "$_OPTION"`
[ -n "$finst" ] && export AP_FORCE=$finst

# Get Refresh() option
rfrsh=`chk_para.sh refresh "$_OPTION"`
[ "$rfrsh" = "true" ] && export AP_INSTALL_KIND="refresh"

# Get InstKind() option
instkind=`chk_para.sh instkind "$_OPTION"`
[ -n "$instkind" ] && export AP_INSTALL_KIND=$instkind

_force="false"
if [ "$AP_INSTALL" != "false" ]; then
	_force="true"
	if [ "$AP_FORCE" != "true" ]; then
		_verbld=`(. se.sh $VERSION > /dev/null 2>&1;get_ess_ver.sh)`
		if [ $? = 0 ]; then
			_ver=${_verbld%:*}
			_bld=${_verbld#*:}
			[ "$_ver" = "${VERSION##*/}" -a "$_bld" = "$BUILD" ] && _force="false"
		fi
	fi
	echo "debug_msg(Curr:$_ver:$_bld, Targ:$VERSION:$BUILD, inst=$_force)"
	if [ "$_force" = "true" ]; then
		wrtstg "#INSTALLING"
		clean_tmp
		echo "Performing Installation VERSION:$VERSION BUILD:$BUILD "
		hyslinst.sh $VERSION "$ORG_BUILD" $AP_INSTALL_KIND
		_inst_err=$?
		echo "debug_msg(_inst_err=$?)"
	fi
else
	echo "Skipping Installation"
fi
if [ "$_force" = "false" ]; then
	# Initialize ESSBASE
	wrtstg "#INITIALIZATION"
	echo "Initialize Essbase."
	(. se.sh $VERSION > /dev/null 2>&1; ap_essinit.sh)
	if [ $? -ne 0 ]; then
		echo "Failed to initialize Essbase."
		echo "Please check the environment setting or"
		echo "Security/License files in the framework"
		_inst_err=4
	fi
fi


#######################################################################
# Check the installation error - send e-mail notification
wrtstg "#CHECK INSTLLATION ERROR"
errbld="${AUTOPILOT}/tmp/${_PLATNAME}_${VERSION##*/}.err"
errplat="${AUTOPILOT}/tmp/`hostname`_${LOGNAME}_${VERSION##*/}_${BUILD}.err"
email_tmp="${AUTOPILOT}/tmp/`hostname`_${LOGNAME}.eml"
if [ $_inst_err -ne 0 ]; then
	echo "Installation Error.($_inst_err)"
	echo "Skip ${TEST} regression. Moving onto next task."
	if [ "$verbose" = "true" ]; then
		[ -f "$errbld" ] \
			&& errcnd=`grep "^Build ${BUILD}:$" "$errbld"` \
			|| unset errcnd
		if [ -z "$errcnd" ]; then
			echo "Build ${BUILD}:" >> "${errbld}"
			cat "$AP_DEF_INSTERRSTS" | while read line; do
				echo "  $line" >> "${errbld}"
			done
		fi
		errcnd=`grep "^Build " "${errbld}" | wc -l`
		if [ "$errcnd" -gt 3 ]; then
			rm -f $email_tmp
			get_emailaddr $LOGNAME MgrNotify InstNotify $AP_ALTEMAIL > $email_tmp
			echo "Autopilot Notification (Consecutive Installation error) - ${VERSION} ${BUILD} - `uname -n`:${_PLATNAME} ${TEST}" >> $email_tmp
			echo "Installation error occured on 3 more builds." | tee -a $email_tmp
			echo ""											>> $email_tmp
			echo "  Machine        = `hostname`:$_PLATNAME"	>> $email_tmp
			echo "  Login User     = $LOGNAME"				>> $email_tmp
			echo "  Install Status = $_inst_err"			>> $email_tmp
			echo "  Version:Build  = $VERSION:$BUILD"		>> $email_tmp
			echo "  Test Script    = $TEST"					>> $email_tmp
			echo "  ARBORPATH      = $ARBORPATH"			>> $email_tmp
			echo "  HYPERION_HOME  = $HYPERION_HOME"		>> $email_tmp
			echo "  SXR_HOME       = $SXR_HOME"				>> $email_tmp
			echo ""			>> $email_tmp
			cat" $errbld" | while read line; do
				echo "  $line"	>> $email_tmp
			done
			send_email $email_tmp
		fi
		[ -f "$errplat" ] \
			&& errcnd=`grep "^${TEST}$" "$errplat"` \
			|| unset errcnd
		if [ -z "$errcnd" ]; then
			echo "${TEST}" >> "$errplat"
			rm -f $email_tmp
			get_emailaddr $LOGNAME InstNotify $AP_ALTEMAIL > $email_tmp
			echo "Autopilot Notification (Install error) - ${VERSION} ${BUILD} - `uname -n`:${_PLATNAME} ${TEST}" >> $email_tmp
			echo "Essbase installation failed. Skip this test." >> $email_tmp
			echo ""											>> $email_tmp
			echo "  Machine        = `hostname`:$_PLATNAME"	>> $email_tmp
			echo "  Login User     = $LOGNAME"				>> $email_tmp
			echo "  Install Status = $_inst_err"			>> $email_tmp
			echo "  Version:Build  = $VERSION:$BUILD"		>> $email_tmp
			echo "  Test Script    = $TEST"					>> $email_tmp
			echo "  ARBORPATH      = $ARBORPATH"			>> $email_tmp
			echo "  HYPERION_HOME  = $HYPERION_HOME"		>> $email_tmp
			echo "  SXR_HOME       = $SXR_HOME"				>> $email_tmp
			echo ""											>> $email_tmp
			cat $AP_DEF_INSTERRSTS | while read line
			do
				echo "  $line"	>> $email_tmp
			done
			send_email $email_tmp
		fi
	fi # verbose = true
	wrtstg "!ERR 20:Install Failed."
	wrtstg "  inssts=$_inst_err."
	wrtstg "#EXIT"
	rm -f "$AP_DEF_INSTERRSTS"
	exit 20

elif [ -f "$AP_DEF_INSTERRSTS" ]; then
	if [ "$verbose" = "true" ]; then
		email_tmp="$AP_DEF_TMPPATH/`hostname`_${LOGNAME}.eml"
		rm -f $email_tmp
		get_emailaddr $LOGNAME InstNotify $AP_ALTEMAIL > $email_tmp
		echo "Autopilot Notification (Install report) - ${VERSION} ${BUILD} - `uname -n`:${_PLATNAME} ${TEST}" >> $email_tmp
		echo "Installer caused error. But execute regression." >> $email_tmp
		echo ""											>> $email_tmp
		echo "  Machine        = `hostname`:$_PLATNAME"	>> $email_tmp
		echo "  Login User     = $LOGNAME"				>> $email_tmp
		echo "  Version:Build  = $VERSION:$BUILD"		>> $email_tmp
		echo "  Test Script    = $TEST"					>> $email_tmp
		echo "  ARBORPATH      = $ARBORPATH"			>> $email_tmp
		echo "  HYPERION_HOME  = $HYPERION_HOME"		>> $email_tmp
		echo ""											>> $email_tmp
		cat $AP_DEF_INSTERRSTS | while read line; do
			echo "  $line"	>> $email_tmp
		done
		send_email $email_tmp
	fi
	rm -f "$AP_DEF_INSTERRSTS"
fi

rm -f "$errbld"
rm -f "$errplat"


########################################################################
# Check the output of directory/files comparison
wrtstg "#CHECK DIR/FILE COMPARE RESULTS"
if [ -f "$AP_DEF_DIFFOUT" ]; then
	if [ "$verbose" = "true" ]; then
		echo "There is diff output."
		email_tmp="${AUTOPILOT}/tmp/`hostname`_${LOGNAME}.eml"
		rm -f $email_tmp
		get_emailaddr $LOGNAME DirCompNotify Admin InstNotify $AP_ALTEMAIL > $email_tmp
		echo "Autopilot Notification (DirCmp diff report) - ${VERSION} ${BUILD} - `uname -n`:${_PLATNAME} ${TEST}" >> $email_tmp
		echo "Installer file/folder structure notify." >> $email_tmp
		echo ""											>> $email_tmp
		echo "  Machine        = `hostname`:$_PLATNAME"	>> $email_tmp
		echo "  Version:Build  = $VERSION:$BUILD"		>> $email_tmp
		echo ""											>> $email_tmp
		cat "$AP_DEF_DIFFOUT" >> $email_tmp
		send_email $email_tmp
	fi
	rm -f "$AP_DEF_DIFFOUT"
fi

chk_flag


#######################################################################
# Setup environment for this regression
wrtstg "#SETUPENV"
. se.sh "$VERSION"	# update

# Run extra/additional setup environment script
[ -n "$AP_ALTSETENV" ] && . "$AP_ALTSETENV" "$VERSION" "$BULD" "$TEST"

print -r "SXR_HOME: $SXR_HOME"
print -r "ARBORPATH: $ARBORPATH"
print -r "HYPERION_HOME: $HYPERION_HOME"
print -r "ESSLANG: $ESSLANG"
print -r "PATH: $PATH"
echo ""

# setenv2() 
_tmp_=`chk_para.sh setenv2 "${_OPTION}"`
if [ -n "$_tmp_" ]; then
	for i in $_tmp_; do
		varn=${i%=*}
		varv=${i#*=}
		_v=${varv#*\$}
		[ "$_v" != "$varv" ] && varv=`eval echo $varv`
		export ${varn}="${varv}"
	done
	unset varn varv i _v
fi

chk_flag
wrtstg "#CHECK FREE - ARBORPATH"
chk_free "\$ARBORPATH" $chk_arborpath
st_arborpath=$CURRFREE


#######################################################################
# Check ESSLANG value
wrtstg "#CHECK ESSLANG"
if [ "$ESSLANG" = "English_UnitedStates.US-ASCII@Binary" ]; then
	echo "##############################"
	echo "### ILLEGAL ESSLANG VALUE  ###"
	echo "##############################"
	echo "\$ESSLANG=$ESSLANG"
	echo "This value might cause a lot of difs."
	sleep 30
	if [ "$verbose" = "true" ]; then
		email_tmp="$AP_DEF_TMPPATH/`hostname`_${LOGNAME}.eml"
		[ -f "$email_tmp" ] && chmod 777 $email_tmp
		get_emailaddr $LOGNAME $AP_ALTEMAIL EnvNotify > $email_tmp
		echo "Autopilot Notification (ESSLANG) - ${VERSION} ${BUILD} - `uname -n`:${_PLATNAME} ${TEST}" >> $email_tmp
		echo "Illegal \$ESSLANG vale ($ESSLANG)."		>> $email_tmp
		echo ""	>> $email_tmp
		echo "  Machine         = `hostname`:$_PLATNAME"	>> $email_tmp
		echo "  Login User      = $LOGNAME"					>> $email_tmp
		echo "  Version:Build   = $VERSION:$BUILD"			>> $email_tmp
		echo "  Test Script     = $TEST"					>> $email_tmp
		echo ""	>> $email_tmp
		echo "Autopilot is moving to PAUSE mode."			>> $email_tmp
		echo ""		>> $email_tmp
		echo "$ESSLANG is valid value for \$ESSLANG."		>> $email_tmp
		echo "However, it might cause a lot of difs on regression tests." >> $email_tmp
		echo "Autopilot continue this test. But please check your enviroment setup scripts."		>> $email_tmp
		send_email $email_tmp
	fi
fi


########################################################################
# Alternate setup
wrtstg "#ALTSETUP"
if [ -n "$AP_ALTSETUP" ]; then
	${AP_ALTSETUP} $VERSION $ORG_BUILD "$TEST"
	ret=$?
	if [ "$ret" -ne 0 ]; then
		echo "$AP_ALTSETUP returned $ret."
		if [ "$verbose" = "true" ]; then
			email_tmp="${AUTOPILOT}/tmp/`hostname`_${LOGNAME}.eml"
			rm -f $email_tmp 2> /dev/null
			get_emailaddr $LOGNAME Admin $AP_ALTEMAIL > $email_tmp
			echo "Autopilot Notification (ALTSETUP Error) - ${VERSION} ${BUILD} - `uname -n`:${_PLATNAME} ${TEST}" >> $email_tmp
			echo "Alternate setup program failed ($ret)." >> $email_tmp
			echo ""											>> $email_tmp
			echo "  Machine       = `hostname`:$_PLATNAME"	>> $email_tmp
			echo "  User          = ${LOGNAME}"				>> $email_tmp
			echo "  AP_ALTSETUP   = ${AP_ALTSETUP}"			>> $email_tmp
			echo "  Version:Build = $VERSION:$BUILD"		>> $email_tmp
			echo "  TEST          = ${TEST}"				>> $email_tmp
			echo "  _OPTION       = ${_OPTION}"				>> $email_tmp
			echo ""											>> $email_tmp
			send_email $email_tmp
		fi
		wrtstg "!ERR 21:Failed to alt-setup."
		wrtstg "  ret=$ret"
		wrtstg "#EXIT"
		exit 21
	fi
fi	


#######################################################################
# Check test script is exist or not
wrtstg "#CHECK TEST SCRIPT($TEST)"
if [ ! -f "$VIEW_PATH/autoregress/sh/${TEST%% *}" -a \
	 ! -f "$SXR_HOME/../base/sh/${TEST%% *}" ]; then
	echo "### Target script($TEST) not found."
	email_tmp="${AUTOPILOT}/tmp/`hostname`_${LOGNAME}.eml"
	[ -f "$email_tmp" ] && rm -f $email_tmp 2> /dev/null
	get_emailaddr $LOGNAME Admin $AP_ALTEMAIL > $email_tmp
	echo "Autopilot Notification (No Test Script) - ${VERSION} ${BUILD} - `uname -n`:${_PLATNAME} ${TEST}" >> $email_tmp
	echo "Target test script not found." >> $email_tmp
	echo ""											>> $email_tmp
	echo "  Machine       = `hostname`:$_PLATNAME"	>> $email_tmp
	echo "  User          = ${LOGNAME}"				>> $email_tmp
	echo "  Version:Build = $VERSION:$BUILD"		>> $email_tmp
	echo "  TEST          = ${TEST}"				>> $email_tmp
	echo "  _OPTION       = ${_OPTION}"				>> $email_tmp
	echo ""											>> $email_tmp
	send_email $email_tmp
		wrtstg "!ERR 24:Test script not found."
		wrtstg "  script=$TEST"
		wrtstg "#EXIT"
	exit 24
fi


########################################################################
# Main Regression Section
wrtstg "#CLEAN TMP"
echo "Entering Main Regression Area"
chk_flag
clean_tmp


########################################################################
# Assign Short Names to Tests
wrtstg "#ASSIGN SHORT NAME"
abbr=`chk_para.sh abbr "${_OPTION}"`
if [ -z "$abbr" ]; then
	TEST_ABV=`cat $AP_DEF_SHABBR | grep "^$TEST:" | awk -F: '{print $2}'`
	[ -z "$TEST_ABV" ] && TEST_ABV=${TEST%.*}
else
	TEST_ABV=$abbr
fi
echo "#Assigning Short Names for $TEST to $TEST_ABV"


########################################################################
# Get Update time stamp for the snapshot
wrtstg "#CHECK SNAPSHOT UPDATED TIME"
[ `uname` = "Windows_NT" ] && updext="UPD" || updext="updt"
updt_ts=`ls $SXR_HOME/../../../*.${updext} 2> /dev/null`
if [ -z "$updt_ts" ]; then
	updt_ts="(Dynamic View:$SXR_HOME)"
else
	updt_ts=`cat $SXR_HOME/../../../*.${updext} | grep ^StartTime | \
	sed -e s/Jan/01/g -e s/Feb/02/g -e s/Mar/03/g -e s/Apr/04/g \
		-e s/May/05/g -e s/Jun/06/g -e s/Jul/07/g -e s/Aug/08/g \
		-e s/Sep/09/g -e s/Oct/10/g -e s/Nov/11/g -e s/Dec/12/g \
		-e "s/\-/ /g" -e "s/\./ /g" -e "s/\:/ /g" -e "s/^StartTime. *//g" | \
	awk '{printf("%s/%s/%s %s:%s:%s\n", $3, $2, $1, $4, $5, $6)}' | sort | tail -1`
fi
[ "$updt_ts" = "" ] && updt_ts="no date record"

########################################################################
# Create View file
wrtstg "#CREATE VIEW FILE"
viewfile=$AP_DEF_VIEWPATH/`uname -n`_${LOGNAME}.vw
if [ -f "$viewfile" ]; then
	chmod 777 $viewfile
	rm $viewfile
fi

st_datetime=$(date '+%m_%d_%y %H:%M:%S')

echo "PLATFORM=`uname`"			> $viewfile
echo "VIEWPATH=$VIEW_PATH"		>> $viewfile
echo "MAINSUIT=$TEST"			>> $viewfile
echo "VERSION=$VERSION:$BUILD"	>> $viewfile
echo "DATE=$st_datetime"		>> $viewfile
echo "SXR_HOME=${SXR_HOME}"		>> $viewfile
echo "LATEST UPDATE=$updt_ts"	>> $viewfile


########################################################################
# Check regression environment and make/clean up it

cd $VIEW_PATH

if [ ! -d "${VIEW_PATH}/autoregress" ]; then
	wrtstg "#CREATED AUTOREGRESS VIEW FOLDER"
	sxr newview autoregress
	echo "Waiting to create the autoregress view"
	sleep 50
else
	wrtstg "#CLEANUP VIEW FOLDER CONTENTS"
	_tmp_=`chk_para.sh cleanUpViewFolders "$_OPTION"`
	[ -n "$_tmp_" ] && AP_CLEANUPVIEWFOLDERS=$_tmp_
	if [ "$AP_CLEANUPVIEWFOLDERS" != "false" ]; then
		for fld in work bin csc data log msh rep scr sh sxr; do
			rm -rf "${VIEWPATH}/autoregress/${fld}/*"
		done
	fi
fi

# # cp modified agtpsetup.sh
# if [ -f "$AUTOPILOT/data/agtpsetup.sh" ]; then
# 	cp "$AUTOPILOT/data/agtpsetup.sh" "${VIEW_PATH}/autoregress/sh"
# fi

# cp 7.1 hack
if [ -d "$AUTOPILOT/data/hack71" ]; then
	if [ "$AP_HACK71" = "true" -o "${VERSION#7}" != "${VERSION}" ]; then
		if [ -f "$AUTOPILOT/data/hack71/agtctl.sh" -a -f "$AUTOPILOT/data/hack71/sxr" ]; then
			wrtstg "#COPY HACK71"
			cp "$AUTOPILOT/data/hack71/agtctl.sh" "${VIEW_PATH}/autoregress/bin"
			cp "$AUTOPILOT/data/hack71/sxr" "${VIEW_PATH}/autoregress/bin"
		fi
	fi
fi

# Check free size for the $VEWI_PATH
wrtstg "#CHECK FREE - VIEW_PATH"
chk_free "\$VIEW_PATH" $chk_viewpath
st_viewpath=$CURRFREE

# Setup SXR_I18N_GREP option
if [ -n "$i18ngrep" -a `uname` = "Windows_NT" ]; then
	wrtstg "#COPY I18N GREP"
	[ "${i18ngrep#*\$}" != "$i18ngrep" ] && i18ngrep=`eval echo $i18ngrep`
	if [ -f "$i18ngrep" ]; then
		[ -f "${VIEW_PATH}/autoregress/bin/grep.exe" ] \
			&& rm -f "${VIEW_PATH}/autoregress/bin/grep.exe"
		cp "$i18ngrep" "${VIEW_PATH}/autoregress/bin/grep.exe"
	else
		echo "No I18NGREP($i18ngrep) file exist!"
	fi
fi

# Back up essbase.cfg file
if [ -f "$ARBORPATH/bin/essbase.cfg" ]; then
	wrtstg "#BECKUP ESSBASE.CFG"
	[ -f "$ARBORPATH/bin/essbase.cfg.evacuation" ] \
		&& rm -f $ARBORPATH/bin/essbase.cfg.evacuation
	cp $ARBORPATH/bin/essbase.cfg $ARBORPATH/bin/essbase.cfg.evacuation
fi

cd ${VIEW_PATH}/autoregress
[ -f ".sxrrc" ] && chmod +w .sxrrc

# [ "$agtstart" = "true" ] && agtstart="sxr agtctl start; " || unset agtstart
[ "$noagtpsetup" != "false" ] \
	&& echo "SXR_GOVIEW_TRIGGER='sxr sh ${TEST}'" > .sxrrc \
	|| echo "SXR_GOVIEW_TRIGGER='sxr sh agtpsetup.sh; sxr sh ${TEST}'" > .sxrrc

#######################################################################
# Write current environment setting to file.
wrtstg "#WRITE ENV"

set > "$AUTOPILOT/mon/${LOGNAME}@`hostname`.env"

#######################################################################
# Launch regression monitor
wrtstg "#START REGMON.SH"

if [ "$hangup" != "0" -a "$hangup" != "false" ]; then
	rmpfile="$AP_DEF_MONPATH/`hostname`_${LOGNAME}_regmon_par.txt"
	kfile="$AP_DEF_MONPATH/`hostname`_${LOGNAME}_killedproc.txt"
	salfile="$AP_DEF_MONPATH/`hostname`_${LOGNAME}_regmon.sal"
	rm -f $rmpfile
	echo "$hangup" > $rmpfile
	echo "$$" >> $rmpfile
	echo "`hostname`~${LOGNAME}~${_PLATNAME}~${VIEW_PATH}~${TEST}~${VERSION##*/}:${BUILD}~${st_datetime}" \
		>> $rmpfile
	echo "${kfile}" >> $rmpfile
	echo "${salfile}" >> $rmpfile
	echo "${AP_RTFILE}" >> $rmpfile

	# remove previous .sog and work files before running
	rm -f $VIEW_PATH/autoregress/work/${TEST%.*}.sog
	rm -f "$kfile" 2> /dev/null
	rm -f "$salfile" 2> /dev/null

	regmon.sh $rmpfile &
	# Regression monitor is expected to delete parameter file
	# after recieving the all parameter and ready to start
	while [ -f "$rmpfile" ]; do chk_flag; done
fi

########################################################################
# Run memory monitor
wrtstg "#START MEMMON.SH"
memlog="$AUTOPILOT/mon/${LOGNAME}@`hostname`.memusage.txt"
memmon.sh $$ "$memlog" "$VERSION $BUILD $TEST" &

########################################################################
# Run Test
########################################################################
wrtstg "#REGRESSION START"
st_sec=`crr_sec`

cd ${VIEW_PATH}
[ "$agtstart" = "true" ]; ESSBASE password -b &
echo "Running Test Now"
sxr goview -eval "exit" autoregress
rm -f $VIEW_PATH/autoregress/.sxrrc
ed_sec=`crr_sec`


########################################################################
# POST PROCESSING
########################################################################
wrtstg "#POSTREGRESSION"
unlock.sh "${AUTOPILOT}/mon/${LOGNAME}@`hostname`.memmon"
# Wait for terminate memmon.sh
sts=0
while [ $sts -eq 0 ]; do
	lock_ping.sh "${AUTOPILOT}/mon/${LOGNAME}@`hostname`.memmon"
	sts=$?
done

[ -f "$memlog" ] \
	&& mempeak=`tail -1 $memlog` \
	|| mempeak="---"

########################################################################
# Post clean up

# Restore saved essbase.cfg
if [ -f "$ARBORPATH/bin/essbase.cfg" -a -f "$ARBORPATH/bin/essbase.cfg.evacuation" ]; then
	wrtstg "#RESTORE ESSBASE.CFG"
	diff "$ARBORPATH/bin/essbase.cfg" "$ARBORPATH/bin/essbase.cfg.evacuation" > /dev/null
	if [ $? -ne 0 ]; then
		mv "$ARBORPATH/bin/essbase.cfg" "$VIEW_PATH/autoregress/work/essbase.cfg.used_in_this_test.lastcfg"
		mv "$ARBORPATH/bin/essbase.cfg.evacuation" "$ARBORPATH/bin/essbase.cfg"
	else
		rm -f "$ARBORPATH/bin/essbase.cfg.evacuation" 2> /dev/null
	fi
fi

# Delete copyed grep.exe
[ -n "$i18ngrep" -a `uname` = "Windows_NT" ] \
	&& rm -f "${VIEW_PATH}/autoregress/bin/grep.exe" 2> /dev/null

# # Delete copyed agtpsetup.sh
# [ -f "${VIEW_PATH}/sh/agtpsetup.sh" ] \
# 	&& rm -f "${VIEW_PATH}/autoregress/sh/agtpsetup.sh" 2> /dev/null

# Check the reg processes was killed.
if [ "$hagup" != "0" -a "$hangup" != "false" ]; then
	wrtstg "#CHECK KILLED PROCESS"
	_sts=`get_sts`
	while [ "$_sts" != "KILLED" -a "$_sts" != "RUNNING" ]; do
		_sts=`get_sts`
	done
	if [ -f "$kfile" ]; then
		cat $kfile
		if [ "$verbose" = "true" ]; then
			### send e-mail notification here
			email_tmp="$AP_DEF_TMPPATH/`hostname`_${LOGNAME}_killnotify.eml"
			[ -f "$email_tmp" ] && chmod 777 $email_tmp
			get_emailaddr $LOGNAME KillNotify $AP_ALTEMAIL > $email_tmp
			echo "Autopilot Notification (Killed) - ${VERSION} ${BUILD} - `uname -n`:${_PLATNAME} ${TEST}" >> $email_tmp
			echo "  Machine         = `hostname`:$_PLATNAME"	>> $email_tmp
			echo "  Login User      = $LOGNAME"					>> $email_tmp
			echo "  Version:Build   = $VERSION:$BUILD"			>> $email_tmp
			echo "  Test Script     = $TEST"					>> $email_tmp
			echo ""	>> $email_tmp
			cat $kfile >> $email_tmp

			send_email $email_tmp
		fi
		rm -f "$kfile" 2> /dev/null
	fi
	# Remove regression monitor related files
	rm -f "$salfile" 2> /dev/null
	rm -f "$crrfile" 2> /dev/null
	rm -f "$AP_RTDIFFILE" 2> /dev/null
	rm -f "$AP_RTSOGFILE" 2> /dev/null
	rm -f "$AP_RTSTAFILE" 2> /dev/null
	rm -f "$AP_RTENVFILE" 2> /dev/null

	_flg=`get_flag`
	if [ "$_flg" != "${_flg#KILL/}" ]; then
		wrtstg "!ERR 22:Killed regression process."
		wrtstg "#EXIT"
		 exit 22
	fi
fi


########################################################################
# Check the execution succeeded
wrtstg "#CHECK SUC/DIF COUNTS"
_crrdir=`pwd`
cd $VIEW_PATH/autoregress/work
difcnt=`ls *.dif 2> /dev/null | wc -l`
succnt=`ls *.suc 2> /dev/null | wc -l`
# difcnt=`find . -name "*.dif" 2> /dev/null | wc -l`
# succnt=`find . -name "*.suc" 2> /dev/null | wc -l`
cd $_crrdir
unset _crrdir
if [ $difcnt -eq 0 -a $succnt -eq 0 ]; then
	echo "###############################################################"
	echo "## Dif and Suc counts are Zero. regression might be failed. ###"
	echo "###############################################################"
	echo "## VERSION : $VERSION"
	echo "## BUILD   : $BUILD"
	echo "## TEST    : $TEST"
	kill_essprocess.sh regonly
	echo "## sleep 30"
	sleep 30
	rm -rf "$VIEW_PATH/autoregress/zero_work_${VERSION##*/}_${BUILD}_${TEST_ABV}"
	mv "$VIEW_PATH/autoregress/work" "$VIEW_PATH/autoregress/zero_work_${VERSION##*/}_${BUILD}_${TEST_ABV}"
	mkdir "$VIEW_PATH/autoregress/work"
	if [ "$verbose" = "true" ]; then
		email_tmp="$AP_DEF_TMPPATH/`hostname`_${LOGNAME}.eml"
		[ -f "$email_tmp" ] && chmod 777 $email_tmp
		get_emailaddr $LOGNAME $AP_ALTEMAIL EnvNotify > $email_tmp
		echo "Autopilot Notification (ZERO RESULTS) - ${VERSION} ${BUILD} - `uname -n`:${_PLATNAME} ${TEST}" >> $email_tmp
		echo "The result seems not to be appropriate."		>> $email_tmp
		echo ""	>> $email_tmp
		echo "  Machine         = `hostname`:$_PLATNAME"	>> $email_tmp
		echo "  Login User      = $LOGNAME"					>> $email_tmp
		echo "  Version:Build   = $VERSION:$BUILD"			>> $email_tmp
		echo "  Test Script     = $TEST"					>> $email_tmp
		echo "  Suc. 0    Dif. 0"							>> $email_tmp
		echo ""	>> $email_tmp
		echo "Autopilot is moving to PAUSE mode."			>> $email_tmp
		echo "Please check the test environment of this machine."	>> $email_tmp
		send_email $email_tmp
	fi
	set_flag PAUSE
	wrtstg "!ERR 11:Zero result."
	wrtstg "#EXIT"
	exit 11
fi


########################################################################
# Collect the end time information for VIEWFILE
wrtstg "#ANALYZE"
ed_datetime=$(date '+%m_%d_%y %H:%M:%S')

echo "DONE=$ed_datetime" >> $viewfile
echo "DISK FREE:"  >> $viewfile
if [ -n "$st_tmp" ]; then
	chk_free "\$TMP" 0 > /dev/null
	ed_tmp=$CURRFREE
	echo "  TMP=$st_tmp KB -> $CURRFREE KB" >> $viewfile
fi
if [ -n "$st_temp" ]; then
	chk_free "\$TEMP" 0 > /dev/null
	ed_temp=$CURRFREE
	echo "  TEMP=$st_temp KB -> $CURRFREE KB" >> $viewfile
fi
if [ -n "$st_tmpdir" ]; then
	chk_free "\$TMPDIR" 0 > /dev/null
	ed_tmpdir=$CURRFREE
	echo "  TMPDIR=$st_tmpdir KB -> $CURRFREE KB" >> $viewfile
fi
if [ -n "$st_arborpath" ]; then
	chk_free "\$ARBORPATH" 0 > /dev/null
	ed_arborpath=$CURRFREE
	echo "  ARBORPATH=$st_arborpath KB -> $CURRFREE KB" >> $viewfile
fi
if [ -n "$st_viewpath" ]; then
	chk_free "\$VIEW_PATH" 0 > /dev/null
	ed_viewpath=$CURRFREE
	echo "  VIEW_PATH=$st_viewpath KB -> $CURRFREE KB" >> $viewfile
fi

_arbor_root=`get_free.sh $ARBORPATH mountpoint`
_viewp_root=`get_free $VIEW_PATH  mountpoint`
if [ "$_arbor_root" = "$_viewp_root" ]; then
	used_size=`expr $st_arborpath - $ed_arborpath`
else
	used_size=`expr $st_arborpath - $ed_arborpath`
	used_size=`expr $st_viewpath - $ed_viewpath + $used_size`
fi

########################################################################
# Update current status file

echo "$(hostname)~${LOGNAME}~${_PLATNAME}~~${TEST}~${VERSION}:${BUILD}~${st_datetime}~DONE -> IDLE~$succnt~$difcnt~${ed_datetime}" > "$AP_RTFILE"


########################################################################
# MAKE execution time record
wrtstg "#REPORT CURRENT STATUS FILE"
tdif=`timediff.sh "$st_datetime" "$ed_datetime"`
echo "$TEST_ABV	$VERSION	$BUILD	$used_size KB	$mempeak KB	$st_datetime	$ed_datetime	$tdif	$succnt	$difcnt	`hostname`" >> $AUTOPILOT/mon/$_PLATNAME.rec
chmod 777 $AUTOPILOT/mon/$_PLATNAME.rec
wrtstg "  $TEST_ABV:$VERSION:$BUILD:$used_size KB:$mempeak KB:$st_datetime:$ed_datetime:$tdif:$succnt:$difcnt"

########################################################################
# REPORT AND BACK UP PROCESS
# Following process are not execute when the verbose(false).
########################################################################
ret=1
if [ "$verbose" = "true" ]; then

	########################################################################
	# Make Backup of Work directory into $AUTOPILOT/res
	wrtstg "#MAKE BACKUP OF WORK FOLDER TO RES FOLDER"
	if [ "$tarctl" != "none" ]; then
		echo "Making backup of Work Directory"
		renameform="${AP_DEF_RESPATH}/${_PLATNAME}_${VERSION##*/}_${BUILD}_${TEST_ABV}.tar"
		searchform="${_PLATNAME}_${VERSION##*/}_*_${TEST_ABV}.tar.*"
		if [ "$tarcnt" != "all" ]; then
			cd ${AP_DEF_RESPATH}
			keepnth.sh "$searchform" `expr $tarcnt - 1`
		fi
		cd ${VIEW_PATH}/autoregress
		[ -d "work_$TEST_ABV" ] && rm -rf work_$TEST_ABV
		mv work work_$TEST_ABV
		if [ "$tarctl" = "all" ]; then
			tar -cf work.tar work_$TEST_ABV 2> /dev/null
		else
			[ -f "work.tar" ] && rm -f work.tar
			cd work_${TEST_ABV}
			for ext in $sxrfiles; do
				# tcnt=`ls *.$ext 2> /dev/null | wc -l`
				tcnt=`find . -name "*.$ext" 2> /dev/null | wc -l`
				if [ $tcnt -ne 0 ]; then
					[ -f "../work.tar" ] \
						&& tar -rf ../work.tar *.$ext 2> /dev/null \
						|| tar -cf ../work.tar *.$ext 2> /dev/null
				fi
			done
			cd ${VIEW_PATH}/autoregress
		fi
		if [ `uname` = "HP-UX" ]; then
			compress work.tar
			_fext=Z
		else
			cat work.tar | gzip -c > work.tar.gz
			rm -f work.tar
			_fext=gz
		fi
		tarfile="${renameform}.${_fext}"
		[ -f "$tarfile" ] && rm -f $tarfile
		cp work.tar.${_fext} $tarfile
		rm -f work.tar.${_fext}
		mv work_$TEST_ABV work
	fi


	########################################################################
	# Analyze the dif
	wrtstg "#ANALYZE DIF FILES"
	# Delete previous .ana file.
	echo Making the dif analyzation file
	renameform="${AP_DEF_RESPATH}/${_PLATNAME}_${VERSION##*/}_${BUILD}_${TEST_ABV}.ana"
	searchform="${_PLATNAME}_${VERSION##*/}_*_${TEST_ABV}.ana"
	cd ${AP_DEF_RESPATH}
	[ "$tarcnt" != "all" ] && keepnth.sh "$searchform" `expr $tarcnt - 1`
	anafile=$renameform
	[ -f $anafile ] && rm -f $anafile
	cd ${VIEW_PATH}/autoregress/work

	# Make dif analyzation file
	echo   "Test Environment:"	 	> $anafile
	echo 							>> $anafile
	if [ -f "$AP_DEF_INSTERRSTS" ]; then
		echo "Installation error occured:" >> $anafile
		cat $AP_DEF_INSTERRSTS | while read errcnt; do
			echo "  $errcnt" >> $anafile
		done
		rm -f $AP_DEF_INSTERRSTS
	fi
	echo "Machine:       `hostname`:$_PLATNAME"	>> $anafile
	echo "Login User:    $LOGNAME"	>> $anafile
	echo "Test Suite:    $TEST"	>> $anafile
	echo "Version:       $VERSION:$BUILD"	>> $anafile
	echo "VIEW_PATH:     $VIEW_PATH"	>> $anafile
	echo "HYPERION_HOME: $HYPERION_HOME"	>> $anafile
	echo "ARBORPAHTH:    $ARBORPATH"	>> $anafile
	echo "SXR_HOME:      $SXR_HOME"	>> $anafile
	echo "Snapshot TS:   $updt_ts"	>> $anafile
	echo "Env file:      $_ENVFILEBASE.env"	>> $anafile
	echo "Start Time:    $st_datetime"	>> $anafile
	echo "End   Time:    $ed_datetime"	>> $anafile
	echo "Work image:    $tarfile"	>> $anafile
	echo "Disk Free information:"	>> $anafile
	[ -n "$st_tmp" ] && 		echo "  \$TMP:       $st_tmp KB -> $ed_tmp KB"	>> $anafile
	[ -n "$st_temp" ] && 		echo "  \$TEMP:      $st_temp KB -> $ed_temp KB"	>> $anafile
	[ -n "$st_tmpdir" ] && 		echo "  \$TMPDIR:    $st_tmpdir KB -> $ed_tmpdir KB"	>> $anafile
	[ -n "$st_arborpath" ] && 	echo "  \$ARBORPATH: $st_arborpath KB -> $ed_arborpath KB"	>> $anafile
	[ -n "$st_viewpath" ] && 	echo "  \$VIEW_PATH: $st_viewpath KB -> $ed_viewpath KB"	>> $anafile
	echo "-----------------------------------------------"	>> $anafile
	if [ -f "$kfile" ]; then
		echo "Killed record exists" >> $anafile
		cat $kfile >> $anafile
		echo "-----------------------------------------------"	>> $anafile
		rm -f $kfile
	fi
	echo "Suc $succnt.\tDif $difcnt." >> $anafile
	echo 	>> $anafile


	# Check each difs
	if [ "$_NOTIFYLVL" = "all" ]; then
		_putpdif=true
	else
		[ $difcnt -le $_NOTIFYLVL ] && _putpdif=true || _putpdif=false
	fi
	rm -rf $AP_DEF_LOGPATH/*_`hostname`_${LOGNAME}_${VERSION##*/}_${BUILD}_${TEST_ABV}.msg
	[ -f "difs.rec" ] && rm -rf difs.rec
	if [ -f "${TEST%.*}.sta" ]; then
		analyze.sh ${TEST%.*} > difs.txt
		mk_difrec.sh ${VERSION##*/} ${BUILD} ${_PLATNAME} ${TEST_ABV} < difs.txt
		keepnth.sh "${AUTOPILOT}/dif/${VERSION##*/}_\*_${_PLATNAME}_${TEST_ABV}.rec" 10
		# mainscript=`echo $TEST | awk '{print $1}'`
		_cdn_label_="ConsDifNotify"
		cons_notify=`grep "^${_cdn_label_}[ 	]" "$EMAIL_LIST" | tail -1 \
			| sed -e s/^${_cdn_label_}//g -e s/#.*$//g -e "s/^[ 	]*//g" -e "s/[ 	]*$//g" -e "s/[ 	][ 	]*/ /g"`
		[ -n "$cons_notify" ] && cons_notify=${_cdn_label_}
		unset _cdn_label_
		cat difs.txt | while read difname shlist; do
			ctdif=`grep $difname ctdifs.txt`
			[ -n "$ctdif" -a "${ctdif#*\(}" = "$ctdif" ] && unset ctdif || ctdif=" ${ctdif#* }"
			unset _owner _script
			for item in $shlist; do
				_find=`grep "^$item[ 	]" "${SCRIPT_LIST}" | grep -v "^#" | tail -1 | \
					sed -e s/^${item}//g -e s/#.*$//g -e "s/^[ 	]*//g" -e "s/[ 	]*$//g" \
						-e "s/[ 	][ 	]*/ /g"`
				if [ -n "$_find" ]; then
					_owners=$_find
					_script=$item
				fi
			done
			if [ -z "$_owners" ]; then
				_owners=$LOGNAME
				[ -n "$cons_notify" ] && _owners="$_owners/$cons_notify"
				_script="unassigned"
				_sc_ow="unassigned"
			else
				_sc_ow="$_script:$_owners"
				if [ -n "$cons_notify" ]; then
					[ "${_owners#*/}" != "$_owners" ] \
						&& _owners="${_owners} ${cons_notify}" \
						|| _owners="${_owners}/${cons_notify}"
				fi
			fi
			if [ "${_owners#*/}" != "$_owners" ]; then
				if [ -z "$ctdif" ]; then
					_owners=${_owners%/*}
					unset _ctowners
				else
					_ctowners=${_owners#*/}
					_owners=`echo $_owners | sed -e "s!/! !g" -e "s/[ 	][ 	]*/ /g"`
				fi
			fi
			if [ "$_putpdif" = "true" ]; then
				for _owner in $_owners; do
					msgfile=$AP_DEF_LOGPATH/${_owner}_`hostname`_${LOGNAME}_${VERSION##*/}_${BUILD}_${TEST_ABV}.msg
					if [ ! -f "$msgfile" ]; then
						if [ -n "$_ctowners" -a "${_ctowners#*${_owner}}" != "$_ctowners" ]; then
							echo "3 more consecutive difs generated." > $msgfile
							echo	>> $msgfile
							echo "Test Environment"				>> $msgfile
							echo	>> $msgfile
							echo "PLATFORM:       $_PLATNAME"	>> $msgfile
							echo "MACHINE:        `hostname`"	>> $msgfile
							echo "LOGNAME:        $LOGNAME"		>> $msgfile
							echo "VERSION:        $VERSION"		>> $msgfile
							echo "BUILD:          $BUILD"		>> $msgfile
							echo "TEST SUITE:     $TEST"		>> $msgfile
							echo "SXR_HOME:       $SXR_HOME"	>> $msgfile
							echo "Snapshot TS:    $updt_ts"	>> $msgfile
							echo "WORK BACKUP:    ${tarfile}"	>> $msgfile
							echo	>> $msgfile
						else
							echo "Difs Generated by scripts owned by ${_owner}" > $msgfile
							echo	>> $msgfile
							echo "Test Environment"				>> $msgfile
							echo	>> $msgfile
							echo "PLATFORM:       $_PLATNAME"	>> $msgfile
							echo "MACHINE:        `hostname`"	>> $msgfile
							echo "LOGNAME:        $LOGNAME"		>> $msgfile
							echo "VERSION:        $VERSION"		>> $msgfile
							echo "BUILD:          $BUILD"		>> $msgfile
							echo "TEST SUITE:     $TEST"		>> $msgfile
							echo "SXR_HOME:       $SXR_HOME"	>> $msgfile
							echo "Snapshot TS:    $updt_ts"	>> $msgfile
							echo "WORK BACKUP:    ${tarfile}"	>> $msgfile
							echo	>> $msgfile
						fi
					fi
					echo "${difname} ${_sc_ow}(${shlist})${ctdif}" >> $msgfile
				done
			fi
			echo "${difname} ${_sc_ow}(${shlist})${ctdif}" >> $anafile
			echo "${difname} ${_sc_ow}(${shlist})${ctdif}" >> difs.rec
			chmod 777 difs.rec
			chmod 777 $anafile
		done
		rm -f difs.txt > /dev/null 2>&1
		rm -f ctdifs.txt > /dev/null 2>&1
	else
		echo "### Analyze error:No ${TEST%.*}.sta file under the \$SXR_WORK folder." >> $anafile
	fi


	########################################################################
	# send analyzation file to $LOGNAME
	wrtstg "#SNED DONE NOTIFICATION"
	if [ "$_NOTIFYLVL" = "all" -o "$_putpdif" = "false" ]; then
		email_tmp="$AP_DEF_TMPPATH/`hostname`_${LOGNAME}.eml"
		# get_emailaddr $LOGNAME DoneNotify $AP_ALTEMAIL > $email_tmp
		get_emailaddr DoneNotify $AP_ALTEMAIL > $email_tmp
		echo "Autopilot Notification (Done) - ${VERSION} ${BUILD} - `uname -n`:${_PLATNAME} ${TEST}" >> $email_tmp
		cat $anafile >> $email_tmp
		send_email $email_tmp
	fi


	########################################################################
	# send dif notification to each owner
	wrtstg "#SNED DIFF NOTIFICATION"
	if [ $difcnt -ne 0 -a "$_putpdif" = "true" ]; then
		echo "Sending e-mail to each script owner"
		cd $AP_DEF_LOGPATH
		# ls -1 *_`hostname`_${LOGNAME}_${VERSION##*/}_${BUILD}_${TEST_ABV}.msg 2> /dev/null | while read fname
		find . -name "*_`hostname`_${LOGNAME}_${VERSION##*/}_${BUILD}_${TEST_ABV}.msg" 2> /dev/null | sed -e "s!^\.\/!!g" | while read fname
		do
			target_owner=`echo $fname | awk -F_ '{print$1}'`
			target_mailaddr=`get_emailaddr $target_owner ${LOGNAME} DifNotify $AP_ALTEMAIL`
			echo "### target_owner=$target_owner, target_mailaddr=$target_mailaddr, fname=$fname"
			email_tmp="$AP_DEF_TMPPATH/`hostname`_${LOGNAME}.eml"
			echo $target_mailaddr > $email_tmp
			email_cont=`cat $fname`
			if [ "${email_cont#3}" != "${email_cont}" ]; then
				echo "Autopilot Notification(CONSECUTIVE DIF) - ${VERSION} ${BUILD} - `uname -n`:${_PLATNAME} ${TEST}" >> $email_tmp
			else
				echo "Autopilot Notification - ${VERSION} ${BUILD} - `uname -n`:${_PLATNAME} ${TEST}" >> $email_tmp
			fi
			cat $fname >> $email_tmp
			send_email $email_tmp
			chmod 777 $fname
			rm -rf $fname
		done
	fi


	########################################################################
	# Gather and Send Results (in send_result.sh refer the difs.rec)

	[ -z "$AP_RESSCRIPT" ] && scr="send_result.sh" || scr=$AP_RESSCRIPT
	cd ${VIEW_PATH}/autoregress
	echo "Sending Results for $VERSION $BUILD $TEST"
	echo "SXR_GOVIEW_TRIGGER='sxr agtctl start; ${scr} $VERSION $BUILD $TEST'" > .sxrrc
	echo "Gathering Results Now"
	cd ${VIEW_PATH}
	sxr goview -eval "exit" autoregress
	rm -f $VIEW_PATH/autoregress/.sxrrc > /dev/null 2>&1
	rm -f $VIEW_PATH/autoregress/work/difs.rec > /dev/null 2>&1
	rm -f $VIEW_PATH/autoregress/work/difs.txt > /dev/null 2>&1
	sleep 30
	kill_essprocess.sh

	########################################################################
	# Make work back up and clean it
	wrtstg "#MOVE WORK FOLDER"
	kpwork=`chk_para.sh keepwork "${_OPTION}"`
	[ -n "$kpwork" ] && export AP_KEEPWORK="$kpwork"
	renameform="work_${VERSION##*/}_${BUILD}_${TEST_ABV}"
	searchform="work_${VERSION##*/}_*_${TEST_ABV}"
	cd ${VIEW_PATH}/autoregress
	if [ "$AP_KEEPWORK" = "true" ]; then
		[ -d "$renameform" ] && rm -rf $renameform
		mv work $renameform
		mkdir work
	elif [ "$AP_KEEPWORK" = "false" ]; then
		echo "Waiting removing the work folder."
		rm -rf work
		mkdir work
	elif [ "$AP_KEEPWORK" = "leave" ]; then
		renameform="work_${TEST_ABV}"
		[ -d "$renameform" ] && rm -rf $renameform
		mv work $renameform
		mkdir work
	else
		[ -z "$AP_KEEPWORK" ] && AP_KEEPWORK=5
		[ -d "$renameform" ] && rm -rf $renameform
		echo "Waiting removing the work folder."
		keepnth.sh "$searchform" `expr $AP_KEEPWORK - 1`
		mv work $renameform
		mkdir work
		echo "Keep recent $AP_KEEPWORK work folders"
	fi
	ret=0
fi # end of of [ "$verbose" = "true" ]; then
wrtstg "#DONE"
echo "Done Regressions"
exit $ret
