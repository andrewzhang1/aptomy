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
# exit 15   Failed to start regression monitor.
# exit 16	not enough free mem -> pause / move back to que
# - delete current task file (Those may re-create next task parse)
# exit 20	install error -> skip tsk -> delete
# exit 21	alter setup error -> skip tsk -> delete
# exit 22	Regression Killed/Terminated -> delete
# exit 23   Invalid ver or bld number -> skip tsk
# exit 24   Test script not found -> skip tsk
# exit 25   Initialization error -> skip tsk -> delete
# exit 26   Invalid installed ver or bld number -> skip tsk
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
# 06/24/2009 YK Add basefile check
# 06/26/2009 YK Change the Installation error notification.
# 08/07/2009 YK Add BaseInst() task option,
# 09/16/2009 YK Add AP_MAILDELEGATE for sending e-mail notification.
# 12/23/2009 YK Change tar and backup method for work directory.
#               To avoid diretory change the work fodler. We should
#               create work_XXX first and copy/move files into ther.
#               Then start tar or backup. We shouldn't manipulate
#               in work folder.
# 01/14/2010 YK Change "mv work/* work_<abbr>" statement to avoid
#               ARG_MAX problem on AIX and Lunx.
# 02/09/2010 YK Remove shared drive on Windows platform.
# 03/11/2010 YK Modify consecutive dif notification can send by n-times.
# 03/22/2010 YK Change e-mail notification logic.
# 05/17/2010 YK Add START to flag file.
# 06/16/2010 YK Add -fromap option when calling start_regress.sh
# 06/21/2010 YK Add Ignore dif /script feature.
# 07/12/2010 YK Add keep same contents as tar file in the backup folders.
#               Autopilot only keeps ceratin files (such as sog) in the 
#               backed-up work directories.  It needs to match what we 
#               currently archive in the zip file.
# 08/02/2010 YKono Add calling lock.sh to start_regress.sh
# 08/06/2010 YKono Change .RTF name including nth counter and remove
#                  user name.
# 08/13/2020 YKono Debug e-mail.
# 09/09/2010 YKono Change backup file count to 5 on the central place.
#                  And not make .ana file.
#                  Move out <main>.sog file from backup work folder
#                  and archives.
# 10/15/2010 YKono Add check ignCM() option.
# #NEW# for new feature 
#    1) Not save work folder when $CRRPRIORITY is 9990
# 02/22/2011 YKono Change disconnect net-drive method on win32
# 08/02/2011 YKono BUG 12742271 - CHECK VERSION AFTER INSTALL ESSBASE
# 08/24/2011 YKono Bug 12904974 - ADD OS REVISION TO RTF
# 09/27/2011 YKono Add AP_NOEMAIL
# 11/01/2011 YKono Implement BUG 13331419 - RESTORE DEFAULT ESSBASE.CFG IN BETWEEN MAIN TESTS
# 02/13/2012 YKono Add gtlf.sh just before send_result.
# 03/08/2012 YKono Add GTLF_testunit tag support
# 03/27/2012 YKono Support FreeMem() task option.
# 05/08/2012 YKono Support bi(<bi-brnch>/<bi-label>) for build number
# 05/21/2012 YKono User AP_SNAPROOT for snapshot() task option.
# 06/05/2012 YKono Support DoneMark() task option with AP_DMFILE
# 06/06/2012 YKono Move GTLF_testunit part to get_gtlftu.sh
# 2012/10/18 YKono Implement Bug 14780983 - SUPPORT AIME* USER IN THE E-MAIL TARGET.
# 2012/10/25 YKono Keep client essbase.cfg file under work folder.
# 2012/11/12 YKono Add tag() contents to the zip file name.
# 2013/01/17 YKono Fix Bug 16187011 - RTF FILE DISPLAY WRONG TIME STAMP FOR THE SNAPSHOT.
# 2013/01/17 YKono Fix Bug 16186568 - START AND END TIMES IN RESULT RTF FILE DOESN'T SHOWUP THE TIME ZONE
#                  -> $AUTOPILOT/form/ana.txt (Add $TZ)
# 2013/01/17 YKono BUG 16172549 - NUMBERING ZIP FILES THE SAME WAY NUMBERING RTF FILES
# 2013/03/18 YKono Check the installation is HIT when target build is HTI.
# 2013/03/22 YKono BUG 16538459 - CONSECUTIVE DIF NOTIFICATION NEEDS TO BE SENT TO SCRIPT OWNER 
# 2013/03/26 YKono Bug 15985737 - EXECUTE TESTS EVEN IF ESSBASESXR DOESN'T HAVE MORE THAN 10GB
# 2013/04/12 YKono BUG 16571221 - NOTIFICATION ONLY SENT TO PLATFORM PERSON WHEN DIF FROM TEST IS 25+ 
# 2013/06/26 YKono Bug 16667156 - AUTOPILOT CHECKS SERVER BUILD NUMBER AND CLIENT BUILD NUMBER
# 2013/07/11 YKono Bug 17088261 - AUTOPILOT SENT MULTIPLE E-MAIL NOTIFICATION WHEN DIF OCCURRED CONSECUTIVELY
# 2013/07/11 YKono Bug 17082824 - DIRCMP DIFF REPORT MISS THE INSTALL TYPE RECORD.
# 2013/07/12 YKono Bug 16264215 - GTLF OPTION KEYS AND GTLF.DAT
# 2013/08/27 YKono Bug 17354989 - INDENTIFY THE SECURITY MODE FOR THE INSTALLATION LOG
#######################################################################

. apinc.sh

echo ""
apver.sh
echo ""
rm -rf $stgfile > /dev/null 2>&1

reglckf="$AUTOPILOT/lck/${LOGNAME}@$(hostname).reg"
trap 'unlock.sh "$reglckf" > /dev/null 2>&1' EXIT

# CONSTANT DEFINITION AND CHECK OVERRIDE BY ENV-VAR

# set_vardef sxrfiles AP_EMAILLIST AP_SCRIPTLIST AP_TARCNT AP_NOEMAILLIST AP_DMFILE AP_RUNGTLF
set_vardef sxrfiles AP_EMAILLIST AP_SCRIPTLIST AP_TARCNT AP_NOEMAILLIST AP_DMFILE AP_NOTIFYLVL

if [ ! -f "$AP_EMAILLIST" ]; then
	unset AP_EMAILLIST
	set_vardef AP_EMAILLIST
fi

if [ ! -f "$AP_SCRIPTLIST" ]; then
	unset AP_SCRIPTLIST
	set_vardef AP_SCRIPTLIST
fi

if [ ! -f "$AP_NOEMAILLIST" ]; then
	unset AP_NOEMAILLIST
	set_vardef AP_NOEMAILLIST
fi

export EMAIL_LIST=$AP_EMAILLIST
export SCRIPT_LIST=$AP_SCRIPTLIST

#######################################################################
# Clean tmp directory

clean_tmp ()
{
	echo "Trying to Clean up Temp Space."

	if [ `uname` = "Windows_NT" ]; then
		echo "No Need to Clean Temp Space"
	elif [ `uname` = "AIX" ]; then
		ls -l /tmp | grep -i $LOGNAME | while read line; do
			MYTMP=`echo $line | awk '{print $9}'`
			chmod -R 0777 /tmp/$MYTMP > /dev/null 2>&1
			rm -rf /tmp/$MYTMP  > /dev/null 2>&1
		done	
	else
		ls -l /var/tmp | grep -i $LOGNAME | while read line; do
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
			[ "${_onename#aime}" != "$_onename" ] && _onename="${_onename}@`get_platform.sh`"
			_targline=`cat "$EMAIL_LIST" | grep "^${_onename}[ 	]" | grep -v "^#" | tail -1  | tr -d '\r'`
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
		_oneaddr=`cat "$EMAIL_LIST" | grep "^Admin" | grep -v "^#" | tr -d '\r'`
		_addrlist=`echo "$_oneaddr" | sed -e s/^Admin//g -e s/#.*$//g \
						-e "s/^[ 	]*//g" -e "s/[ 	]*$//g" -e "s/[ 	][ 	]*/ /g"`
	fi
	echo $_addrlist
}


#######################################################################
# eval_form <in-form> <out-file> <ind>
eval_form()
{
	_in_form_="$1"
	if [ -f "$_in_form_" ]; then
		_ifs_back=$IFS
		IFS=""
		cat "$_in_form_" | egrep -v ^# | while read -r _in_; do
			_in_=`eval echo \"$_in_\"`
			echo "$3$_in_" >> "$2"
		done
		IFS=$_ifs_back
	fi
}


#######################################################################
# Send e-mail 
# send_email <mail form name>
#   tmpfile format:
#     Line 1: To addresses which start with To:
#     Line 2: Subject which start with Subject:
#     Line 3- Contents
# This routine delete the tmp file. If there is no tmp file, ignore.
winsmtp=internal-mail-router.oracle.com
send_email()
{
	orgp=$@
	email_tmpfile="$AUTOPILOT/tmp/${mysvnode}_send_email.tmp"
	rm -rf ${email_tmpfile} > /dev/null 2>&1
	exaddr=
	ind=
	while [ $# -ne 0 ]; do
		case $1 in
			ind:*)
				ind=${1#ind:}
				;;
			ne:*)
				( IFS=
				  cat "${1#ne:}" | while read line; do
					print "${ind}${line}" >> "${email_tmpfile}"
				  done
				)
				;;
			msg:*|Msg:*|Txt:*|txt:*|TXT:*|MSG:*)
				echo "${ind}${1#????}" >> "${email_tmpfile}"
				;;
			sep:*|line:*)
				echo "${ind}========================================" >> "${email_tmpfile}"
				;;
			to:*|To:*|TO:*)
				[ -z "$exaddr" ] && exaddr=${1#???} || exaddr="$exaddr ${1#???}"
				;;
			*)
				eval_form "$1" "${email_tmpfile}" "$ind" > /dev/null 2>&1
				;;
		esac
		shift
	done
	if [ -f "$email_tmpfile" ]; then
		addrs=`head -1 "$email_tmpfile" | tr -d '\r'`
		if [ -n "$exaddr" ]; then
			[ -z "$addrs" ] && addrs=$exaddr || addrs="$exaddr $addrs"
		fi
		if [ "$AP_NOEMAIL" = "true" ]; then
			[ -n "$AP_NOEMAIL_REASON" ] \
				&& mail_target="No email by $AP_NOEMAIL_REASON\nOrg To:$addrs\n" \
				|| mail_target="Org Recipient:$addrs\n"
			addrs="NoMail"
		elif [ "$AP_NOEMAIL" != "false" -a -n "$AP_NOEMAIL" ]; then
			mail_target="Org Recipient:$addrs\n"
			addrs="$AP_NOEMAIL"
		else
			mail_target=
		fi
		_tmpa_=`get_emailaddr $addrs`
		addrs=
		for _one_addr_ in $_tmpa_; do
			[ -z "$addrs" ] && addrs=$_one_addr_ || addrs="$addrs $_one_addr_"
		done
		mail_target="${mail_target}Recipient:$addrs"
		sbj=`head -2 "$email_tmpfile" | tail -1 | tr -d '\r'`
		lines=`cat "$email_tmpfile" | wc -l`
		let lines=lines-2
		if [ "`uname`" = "Windows_NT" ]; then
			sndr=`get_emailaddr $LOGNAME`
			( unset set_vardef
			  [ -z "$HYPERION_HOME" ] && . se.sh ${VERSION##*/} > /dev/null 2>&1
			  [ -n "$mail_target" ] \
				&& echo "$mail_target\n"
			  tail -${lines} $email_tmpfile 
			) | smtpmail -s "$sbj" -h ${winsmtp} -f ${sndr} ${addrs}
		else
			( unset set_vardef
			  [ -z "$HYPERION_HOME" ] && . se.sh ${VERSION##*/} > /dev/null 2>&1
			  [ -n "$mail_target" ] \
				&& echo "$mail_target\n"
			  tail -${lines} $email_tmpfile 
			) | mailx -s "$sbj" ${addrs}
		fi
		[ -d "$AUTOPILOT/mail_sent" ] \
			&& cp "$email_tmpfile" $AUTOPILOT/mail_sent/${LOGNAME}@`hostname`_`date +%m%d%y_%H%M%S`.txt > /dev/null 2>&1
		rm -f "$email_tmpfile" > /dev/null 2>&1
		unset email_tmpfile lines addrs sbj mailfile
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
		dskloc="$1($_dir)"
	else
		echo "Check the free space on $_dir"
		dskloc=$1
	fi
	export CURRFREE=`get_free.sh "$_dir"`
	if [ -z "$CURRFREE" ]; then
		echo "Failed to get FREE space."
	else
		echo "Curent free space = $CURRFREE KB, Expected free size $2 KB"
		if [ $CURRFREE -lt $2 ]; then
			expfree=$2
			###########################################################
			# No sufficient HD space
			# Send notify mail to executor
			###########################################################
			echo "No sufficient free space on $1"
			echo "Autopilot move on to PAUSE mode."
			if [ "$verbose" = "true" ]; then
				send_email "$AUTOPILOT/form/01_No_sufficient_space.txt"
				email_tmp=${AUTOPILOT}/tmp/${mysvnode}_email.tmp
				[ -f "$email_tmp" ] && rm -rf "$email_tmp" > /dev/null 2>&1
				cp $AUTOPILOT/form/Cleanup_notification.txt "$email_tmp"
				# Add disk usage information
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
				send_email "$email_tmp"
				rm -rf "$email_tmp" > /dev/null 2>&1
			fi
			if [ "$1" != "\$AUTOPILOT" ]; then
				set_flag PAUSE

				wrtstg "!ERR 10:No sufficient memory."
				wrtstg "  loc=$1($_dir)"
				wrtstg "  crr=$CURRFREE KB"
				wrtstg "  exp=$2 KB"
				wrtstg "#EXIT"

				wrtwsp2 "NOFREE No sufficient free space on $1($_dir). $CURRFREE KB/$2 KB"

				exit 10
			else
				wrtstg "!ERR 10:AUTOPILOT:No sufficient memory."
				wrtstg "  loc=$1($_dir)"
				wrtstg "  crr=$CURRFREE KB"
				wrtstg "  exp=$2 KB"
			fi
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
# Write to wsp2 file.
wrtwsp2()
{
	if [ $# -ne 0 ]; then
		description=${1#* }
		errsym=${1%% *}
		errsym="ERR ${errsym}"
		crrsts="error"
	else
		description="start"
		errsym="Started -"
		crrsts="start"
	fi
	# Get result location and tag option
	resloc=`get_resloc.sh $VERSION $BUILD $TEST`
	tag=${resloc##*:}; resloc=${resloc%:*}
	reltag=${resloc##*:}; resloc=${resloc%:*}
	rtf=${resloc##*:}; resloc=${resloc%:*}
	if [ $# -ne 0 ]; then
		(IFS=
		########################################################################
		# Make dummy response file
		echo "$errsym:$description"
		echo ""
		echo "  Machine   : ${myhost}"
		echo "  User      : ${LOGNAME}"
		echo "  Version   : ${VERSION}"
		echo "  Build     : ${BUILD}"
		echo "  Test Suite: ${TEST}"
		echo ""
		if [ -f "$AUTOPILOT/mon/${mysvnode}.ap.vdef.txt" ]; then
			echo "### PREDEFINED VARIABLE BEFORE AUTOPILOT.SH ###"
			cat "$AUTOPILOT/mon/${mysvnode}.ap.vdef.txt" | while read line; do
				echo "  $line"
			done
			echo ""
		fi		
		if [ -f "$AUTOPILOT/mon/${mysvnode}.reg.vdef.txt" ]; then
			echo "### PREDEFINED VARIABLE BEFORE START REGRESSION ###"
			cat "$AUTOPILOT/mon/${mysvnode}.reg.vdef.txt" | while read line; do
				echo "  $line"
			done
			echo ""
		fi		
		echo "### TOOLS INFO ###"
		echo "which java : `which java 2> /dev/null` "
		echo "java -version :$(java -v 2> /dev/null)"
		echo "which perl : `which perl 2> /dev/null` "
		echo "" 
		echo "### SYS ENV VARIABLES ###"
		env
		if [ -f "$AP_DEF_INSTERRSTS" ]; then
			echo "" 
			echo "### INSTALLATION/TEST ERROR CONTENTS ###" 
			cat "$AP_DEF_INSTERRSTS" | while read line; do
				echo "  $line"
			done
		fi
		if [ -f "$AUTOPILOT/instlog/${LOGNAME}@${myhost}~${VERSION}~${BUILD}*.log" ]; then
			echo ""
			echo "### Installation log ($AUTOPILOT/instlog/${LOGNAME}@${myhost}~${VERSION}~${BUILD}.log)"
			cat $AUTOPILOT/instloc/${LOGNAME}@${myhost}~${VERSION}~${BUILD}.log 2> /dev/null | while read line; do
				echo "  $line"
			done
		fi
		) >> $resloc/$rtf
	else
		rm -f $resloc/$rtf
		rtf="-"
	fi
	
	########################################################################
	# Add record to results.wsp2 and res.rec
	testnametmp=`echo $TEST | sed -e "s/ /_/g"`
	[ -z "$CRRPRIORITY" ] && export CRRPRIORITY="0100"
	cont="${BUILD}${tag} $_platname $crrsts $testnametmp $errsym $rtf - - $CRRPRIORITY" 
	echo "$cont" >> $resloc/results.wsp2
	echo "$cont" >> $resloc/res.rec
	unset testnametmp
}

#######################################################################
# Main process start here
#######################################################################
reglck=`lock.sh "$reglckf" $$ 2> /dev/null`
if [ $? -ne 0 ]; then
	echo "Failed to lock \"$reglckf\"."
	echo "Please check there is another start_regress.sh running or not."
	echo "Or make sure you can access to \$AUTOPILOT/lck folder."
	exit 1
fi
export st_datetime=$(date '+%m_%d_%y %H:%M:%S')
set_flag START
set_sts RUNNING
wrtstg "#START"
wrtcrr "START"
unset succnt difcnt

#######################################################################
# Start regression monitor
echo "Start regression monitor."
myhost=$(hostname)
mynode=${LOGNAME}@${myhost}
mysvnode=${myhost}_${LOGNAME}
rm_paramf=$AUTOPILOT/mon/${mynode}.mon.par
rm_log=$AUTOPILOT/mon/${mynode}.mon.log
rm_lck=$AUTOPILOT/lck/${mynode}.mon
rm_env=$AUTOPILOT/mon/${mynode}.env
rm -rf $rm_paramf > /dev/null 2>&1
rm -rf $rm_log > /dev/null 2>&1
rm -rf $rm_env > /dev/null 2>&1
regmon.sh > $AUTOPILOT/mon/${mynode}.debug 2>&1 < /dev/null &
rm_pid=$!
rm_wcnt=30
while [ 1 ]; do
	n=`ps -p $rm_pid | grep -v PID`
	[ -n "$n" ] && break
	let rm_wcnt=rm_wcnt-1
	if [ $rm_wcnt -le 0 ]; then
		echo "Faied to launch regression monitor."
		wrtstg "!ERR 15:Failed to start regression monitor."
		wrtwsp2 "PARAM Failed to launch regmon.sh"
		exit 15
	fi
done

#######################################################################
# Read parameter
wrtstg "# PRE _OPTION=<$_OPTION>"
orgpar="$@"
unset VERSION BUILD TEST
while [ $# -ne 0 ]; do
	case $1 in
		-opt|-o)
			shift
			if [ $# -eq 0 ]; then
				echo "'-opt' option need option string."
				unset VERSION
				break;
			fi
			[ -z "$_OPTION" ] && export _OPTION="$1" || export _OPTION="$_OPTION $1"
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
	wrtwsp2 "PARAM Parameter error($orgpar)"
	exit 13
fi

unset orgpar

#######################################################################
# Check the no-email-list file
# AP_NOEMAILLIST file format:
# <script>
# <ver>:<script>
unset AP_NOEMAIL_REASON
if [ -f "$AP_NOEMAILLIST" ]; then
	no_email_tmp=`cat $AP_NOEMAILLIST 2> /dev/null | grep -v ^# | grep "$VERSION:$TEST" 2> /dev/null`
	if [ -n "$no_email_tmp" ]; then
		export AP_NOEMAIL=true
		export AP_NOEMAIL_REASON="${AP_NOEMAILLIST}->${VERSION}:${TEST}"
	else
		no_email_tmp=`cat $AP_NOEMAILLIST 2> /dev/null | grep -v ^# | grep "$TEST" 2> /dev/null`
		if [ -n "$no_email_tmp" ]; then
			export AP_NOEMAIL=true
			export AP_NOEMAIL_REASON="${AP_NOEMAILLIST}->$TEST"
		fi
	fi
	[ "$AP_NOEMAIL" = "true" ] \
		&& echo "`date +%D_%T:$LOGNAME@$(hostname)`:AP_NOEMAIL=$AP_NOEMAIL($AP_NOEMAIL_REASON)" \
		>> $AUTOPILOT/mon/noemail.log
	unset no_email_tmp
fi

ignCM=`chk_para.sh ignCM "${_OPTION}"`
ignCM=${ignCM##* }
noinst=`chk_para.sh noinst "${_OPTION}"`
nobldchk=`chk_para.sh NoBuildCheck "${_OPTION}"`
[ -z "$nobldchk" ] && nobldchk=`chk_para.sh NoBuildTest "${_OPTION}"`
nobldchk=${nobldchk##* }
[ "$nobldchk" = "true" ] && noinst="true"
# echo "### _OPTION = $_OPTION"
# echo "### nobldchk=$nobldchk"
# echo "### noinst  =$noinst"

ORG_BUILD=$BUILD
if [ "$nobldchk" != "true" ]; then
	[ "$ignCM" = "true" ] && BUILD=`normbld.sh -w -icm $VERSION $BUILD` \
		|| BUILD=`normbld.sh -w $VERSION $BUILD`
	sts=$?
	#echo "### normvld.sh (ignCM=$ignCM) $VERSION $BUILD return $sts."
	if [ $sts -ne 0 ]; then
		echo "### Invalid version or build number($sts)."
		echo "VERSION=$VERSION, BUILD=$ORG_BUILD."
		echo "Status:$BUILD"
		send_email $AUTOPILOT/form/16_Invalied_VerBld.txt
		wrtstg "!ERR 23:Invalid ver/build number(sts=$sts)."
		wrtstg "  ver=$VERSION, bld=$ORG_BUILD."
		wrtstg "  Status:$BUILD"
		wrtstg "#EXIT"
		export BUILD=000
		wrtwsp2 "INVVER Invalid version and build number.($VERSION,$ORG_BUILD)"
		exit 23
	fi
	[ "$BUILD" != "${BUILD%_bi}" ] && export AP_BISHIPHOME=true
	BUILD=${BUILD%%_*}
else
	_bitmp=`chk_para.sh BI "$BUILD"`
	[ -n "$_bitmp" ] && export AP_BISHIPHOME=true
	echo "Skip build check(nobldchk=$nobldchk)."
fi
export VERSION BUILD TEST
wrtstg "#VER=$VERSION"
[ "$ORG_BUILD" = "$BUILD" ] && wrtstg "#BLD=$BUILD" \
	|| wrtstg "#BLD=$BUILD($ORG_BUILD)"
wrtstg "#TEST=$TEST"
wrtstg "#TASKOPT=$_OPTION"

#######################################################################
# Read the regression task options from _OPTION
wrtstg "#READ ENVVAR/TSKOPT"
wrtcrr "READING TSKOPT"

# arch() > ARCH
arch=`chk_para.sh arch "${_OPTION}"`
[ -n "$arch" ] && export ARCH=$arch
_PLATNAME=`get_platform.sh`  # get_platform.sh need $ARCH
_platname=`get_platform.sh -l`  # get_platform.sh need $ARCH

# bi() > AP_BISHIPHOME (default=false)
bishiphome=`chk_para.sh bi "${_OPTION}"`
[ -n "$bishiphome" ] && export AP_BISHIPHOME=$bishiphome

# AltMail() > AP_ALTMAIL
altemail=`chk_para.sh altemail "${_OPTION}"`
[ -n "$altemail" ] && AP_ALTEMAIL=$altemail

# RegMonDBG() > AP_REGMON_DEBUG
regmondbg=`chk_para.sh regmondebug "${_OPTION}"`
[ -n "$regmondbg" ] && export AP_REGMON_DEBUG=$regmondbg

# I18NGrep() > SXR_I18N_GREP
i18ngrep=`chk_para.sh i18ngrep "${_OPTION}"`
[ -z "$i18ngrep" -a -n "$SXR_I18N_GREP" ] && i18ngrep="$SXR_I18N_GREP"
[ -n "$i18ngrep" -a "$i18ngrep" != "${i18ngrep#*\$}" ] && i18ngrep=`eval echo $i18ngrep`

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
[ -n "$essbasecfg" -a "$essbasecfg" != "${essbasecfg#*\$}" ] && essbasecfg=`eval echo $essbasecfg`

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
		|| tarcnt=5	# default
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
if [ -n "$_tmp_" ]; then
	[ "$_tmp_" != "${_tmp_#*\$}" ] && _tmp_=`eval echo $_tmp_`
	export AP_RESSCRIPT="$_tmp_"
fi

# AltSetup() > AP_ALTSETUP
if [ -n "$_tmp_" ]; then
	[ "$_tmp_" != "${_tmp_#*\$}" ] && _tmp_=`eval echo $_tmp_`
	export AP_ALTSETUP="$_tmp_"
fi

# AltSetEnv() > AP_ALTSETENV
_tmp_=`chk_para.sh altsetenv "${_OPTION}"`
[ -n "$_tmp_" ] && export AP_ALTSETENV="$_tmp_"
if [ -n "$_tmp_" ]; then
	[ "$_tmp_" != "${_tmp_#*\$}" ] && _tmp_=`eval echo $_tmp_`
	export AP_ALTSETENV="$_tmp_"
fi

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

# noemail()
_tmp_=`chk_para.sh noemail "${_OPTION}"`
[ -n "$_tmp_" ] && export AP_NOEMAIL="$_tmp_"
echo "`date +%D_%T:$LOGNAME@$(hostname)`: NoEmail() - AP_NOEMAIL=$AP_NOEMAIL" >> $AUTOPILOT/mon/noemail.log

# snapshot()
_tmp_=`chk_para.sh snapshot "${_OPTION}"`
if [ -n "$_tmp_" ]; then
	echo "### CHECK SNAPSHOT"
	echo "### _OPTION=<$_OPTION>"
	echo "### _tmp_=<$_tmp_>"
	_tmp_=${_tmp_##* }
	if [ -n "$AP_SNAPROOT" ]; then
		_snap_="$AP_SNAPROOT/$_tmp_/vobs/essexer/latest"
	else
		_snap_="$AUTOPILOT/../../$_tmp_/vobs/essexer/latest"
	fi
	if [ ! -d "$_snap_" ]; then
		if [ ! -d "${_snap_%/*/*/*}/essexer/latest" ]; then
			echo "## You define snapshot($_tmp_) for this task."
			echo "## But couldn't find the $_snap_ or ${_snap_%/*/*/*}/essexer/latest folder."
			echo "## This task doesn't use snapshot($_tmp_) option."
			unset _snap_
		else
			_snap_="${_snap_%/*/*/*}/essexer/latest"
		fi
	fi
	if [ -n "$_snap_" ]; then
		crr=`pwd`
		cd "$_snap_"
		export SXR_HOME=`pwd`
		cd "$crr"
		echo "## Define \$SXR_HOME=$SXR_HOME by snapshot($_tmp_) task option."
		unset crr _snap_
	fi
	unset _tmp_
fi	

baseinst=`chk_para.sh baseinst "${_OPTION}"`
opack=`chk_para.sh opack "${_OPTION}"`
unset _tmp_

# Add start record
wrtwsp2

#######################################################################
# Check $SXR_INVIEW defined. (When defined it, sxr goview must fail.)
wrtstg "#CHECK SXR_INVIEW"
wrtcrr "CHECKING SXR_INVIEW"
if [ -n "$SXR_INVIEW" ]; then
	echo "##################################"
	echo "### \$SXR_INVIEW IS NOT EMPTY ###"
	echo "##################################"
	echo "\$SXR_INVIEW=$SXR_INVIEW"
	echo "This setting cause 'sxr goview' failure."
	echo "And it will cause '0 suc' and '0 dif' result."
	echo "Move to PAUSE mode."
	[ "$verbose" = "true" ] && send_email "$AUTOPILOT/form/04_SXR_Inview.txt"
	set_flag PAUSE
	wrtstg "!ERR 12:You are in SXR_VIEW."
	wrtstg "  \$SXR_INVIEW=$SXR_INVIEW."
	wrtstg "#EXIT"
	wrtwsp2 "SXRINVIEW This environment already in SXR_VIEW($SXR_INVIEW)."
	exit 12
fi


#######################################################################
# Check ncarg count
if [ `uname` = "AIX" ]; then
	wrtstg "#CHECK NCARG"
	wrtcrr "CHECKING NCARG"
	_ncarg=`lsattr -EH -l sys0 | grep ncargs | awk '{print $2}'`
	if [ -z "$_ncarg" -o $_ncarg -lt 16 ]; then
		echo "##############################"
		echo "### Small ncargs parameter ###"
		echo "##############################"
		lsattr -EH -l sys0 | grep ncargs
		echo "This setting cause '0403-027 The parameter list is too long(6625591)' problem."
		echo "And it will cause '0 suc' and '0 dif' result."
		echo "Move to PAUSE mode."
		[ "$verbose" = "true" ] && send_email "$AUTOPILOT/form/06_Small_NCARGS.txt"
		set_flag PAUSE
		wrtstg "!ERR 14:Small NCARG(aix)."
		wrtstg "  NCARG=$_ncarg."
		wrtstg "#EXIT"
		wrtwsp2 "NARGS The NARGS setting is too small."
		exit 14
	fi
fi


#######################################################################
# Check disk space (should above 10GB as default)

chk_tmpdir=5242880; chk_tmp=5242880; chk_temp=5242880
#chk_tmpdir=10485760; chk_tmp=10485760; chk_temp=10485760

chk_viewpath=5242880; chk_arborpath=5242880
#chk_viewpath=10485760; chk_arborpath=10485760

# chk_autopilot=10485760
# chk_free "\$AUTOPILOT" $chk_autopilot

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
		email_tmp="$AP_DEF_TMPPATH/${mysvnode}.eml"
		[ -f "$email_tmp" ] && chmod 777 $email_tmp
		cp "$AUTOPILOT/form/07_No_TMP_Def.txt" "$email_tmp"
		set >> $email_tmp
		send_email "$email_tmp"
		rm -rf "$email_tmp" > /dev/null 2>&1
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
# Check free memory size
_tmp_=`chk_para.sh freemem "${_OPTION}"`
_tmp_=${_tmp_##* }
if [ -n "$_tmp_" ]; then
	wrtstg "#CHECK FREE MEMORY($_tmp_)"
	wrtcrr "CHECK FREE MEM"
	echo "# Found FreeMem($_tmp_) task option and check current free."
	case $_tmp_ in
		*KB)	_tmp_=${_tmp_%??};;
		*MB)	let _tmp_=${_tmp_%??}\*1024 2> /dev/null;;
		*GB)	let _tmp_=${_tmp_%??}\*1048576 2> /dev/null;;
		*B)	let _tmp_=\(${_tmp_%?}+512\)/1024 2> /dev/null;;
	esac
	_crrmem_=`get_freemem.sh`
	if [ "$_crrmem_" -lt "$_tmp_" ]; then
		echo "#########################"
		echo "### Small free memory ###"
		echo "#########################"
		echo "Found freeMem($_tmp_) task option."
		echo "But current free is small($_crrmem_) than it."
		echo "This may cause un-expected crash of test."
		echo "Move to PAUSE mode."
		[ "$verbose" = "true" ] && send_email "$AUTOPILOT/form/28_No_sufficient_free_mem.txt"
		set_flag PAUSE
		wrtstg "!ERR 16:Small free memory."
		wrtstg "  Current free memory size=$_crrmem_ KB($_tmp_ KB)."
		wrtstg "#EXIT"
		wrtwsp2 "Free memory is too small($_crrmem_/$_tmp_)."
		exit 16 
	fi
	unset _crrmem_ _tmp_
fi
		

#######################################################################
# Install Products
#######################################################################
wrtstg "#CHECK INSTALLATION"
[ -f "$AP_DEF_INSTERRSTS" ] && rm -f "$AP_DEF_INSTERRSTS"
echo "#  noinst=$noinst, nobldchk=$nobldchk"
email_tmp="${AUTOPILOT}/tmp/${mysvnode}.eml"
_inst_err=0
_force="false"
if [ "$noinst" != "true" ]; then
	# Get ForceInst() option
	finst=`chk_para.sh forceinst "$_OPTION"`
	[ -n "$finst" ] && export AP_FORCE=$finst
	# echo "#  AP_FORCE=$AP_FORCE"

	# Get Refresh() option
	rfrsh=`chk_para.sh refresh "$_OPTION"`
	rfrsh=${rfrsh##* }
	[ "$rfrsh" = "true" ] && export AP_INSTALL_KIND="refresh"
	# echo "#  AP_INSTALL_KIND(refresh)=$AP_INSTALL_KIND"

	# Get InstKind() option
	instkind=`chk_para.sh instkind "$_OPTION"`
	[ -n "$instkind" ] && export AP_INSTALL_KIND=$instkind
	# echo "#  AP_INSTALL_KIND(instkind)=$AP_INSTALL_KIND"

	# echo "#  AP_INSTALL=$AP_FORCE"
	if [ "$AP_INSTALL" != "false" ]; then
		_force="true"
		if [ "$AP_FORCE" != "true" ]; then
			wrtcrr "CHECKING PRE-INST VER/BLD"
			_verbld=`(. se.sh $VERSION > /dev/null 2>&1;get_ess_ver.sh)`
			if [ $? -eq 0 ]; then
				_ver=${_verbld%:*}
				_bld=${_verbld#*:}
                        	_vnm=`ver_vernum.sh $_ver`
                        	_VNM=`ver_vernum.sh ${VERSION##*/}`
				[ "$_vnm" = "$_VNM" -a "$_bld" = "$BUILD" ] && _force="false"
				# 2013/03/18 YK Add installed kind check
				_ishit=`chk_para.sh hit "$ORG_BUILD"`
				_ishit=${_ishit##* }
				if [ "$_force" = "false" -a -n "$_ishit" ]; then
					_force="true"
					_ishit=`(. se.sh $VERSION > /dev/null 2>&1; get_instkind.sh -s)`
					[ "$_ishit" = "hit" ] && _force="false"
				fi
			fi
		fi
echo "# ORG_BUILD=$ORG_BUILD"
echo "# _ishit=$_ishit"
		echo "# Curr:$_ver:$_bld, Targ:$VERSION:$BUILD, inst=$_force"
		if [ "$_force" = "true" ]; then
			wrtstg "#INSTALLING"
			wrtcrr "INSTALLING"
			clean_tmp
			logext=$( . se.sh -nomkdir $VERSION > /dev/null 2>&1; get_secmode.sh -ext )
			echo "Performing Installation VERSION:$VERSION BUILD:$BUILD "
			[ -n "$baseinst" ] && baseinst="-base $baseinst"
			[ -n "$opack" ] && opack="-opack $opack"
			[ "$ignCM" = "true" ] && igncmopt="-icm" || igncmopt=
			( hyslinst.sh $VERSION "$ORG_BUILD" $AP_INSTALL_KIND $baseinst $opack $igncmopt
			  echo "logto.sh return status=$?"
			) 2>&1 | logto.sh $AUTOPILOT/instlog/${LOGNAME}@$(hostname)~${VERSION}~${BUILD}${logext}.log \
				${HOME}/inst~${VERSION}~${BUILD}${logext}.log console
			rm -rf console
			_inst_err=$?
			echo "$thisnode($thisplat):`(. se.sh $VERSION; get_instkind.sh -l)`" >> \
				$AUTOPILOT/instlog/${LOGNAME}@$(hostname)~${VERSION}~${BUILD}${logext}.log
			# echo "debug_msg(_inst_err=$?)"
			# Bug 16667156 - AUTOPILOT CHECKS SERVER BUILD NUMBER AND CLIENT BUILD NUMBER
			# Check installed version numbers
			_vertmp=$HOME/${LOGNAME}@$(hostname)_ckver.tmp
			rm -f $_vertmp
			(. se.sh $VERSION > /dev/null 2>&1;get_ess_ver.sh -test all) > $_vertmp
			sts=$?
			if [ $sts -eq 0 ]; then
				echo "# Check module versions succeeded."
				cat $_vertmp
				wrtstg "#INSTALLED VERSION CHECK FINE."
				wrtstg "#(`cat $_vertmp | tail -1`)"
				rm -f $_vertmp
			else
				wrtstg "#FAILED INSTALLED VERSION CHECK ($sts)."
				cat $_vertmp | while read line; do wrtstg "# > $line"; done
				wrtstg "# BUT CONTINUE TEST."
				echo "# Failed installed version check ($sts)."
				cat $_vertmp | while read line; do echo "# > $line"; done
				_mtmp=$HOME/${LOGNAME}@$(hostname)_mail.tmp
				rm -f $_mtmp
				cat $AUTOPILOT/form/26_Invalid_InstVerBld.txt > $_mtmp
				cat $_vertmp >> $_mtmp
				send_email $_mtmp
				rm -f $_mtmp 
				rm -f $_vertmp
			fi
		fi
	else
		echo "Skip Installation by AP_INSTALL=$AP_INSTALL"
	fi
else
	echo "Skip Installation by NoInst() or NoBuildCheck() task option(noinst=$noinst)."
fi

if [ "$_force" = "false" ]; then
	# Initialize ESSBASE
	wrtstg "#INITIALIZATION"
	wrtcrr "INITIALIZING"
	echo "Initialize Essbase."
	(. se.sh $VERSION > /dev/null 2>&1; ap_essinit.sh )
	if [ $? -ne 0 ]; then
		echo "Failed to initialize Essbase."
		echo "Please check the environment setting or"
		echo "Security/License files in the framework."
		[ "$verbose" = "true" ] && send_email \
			"$AUTOPILOT/form/19_Init_Failure.txt" \
			"sep:" "txt:\nOutput:" "ind:    " \
			"ne:$HOME/$thisnode.ap_init.out"
		wrtstg "!ERR 20:Initialization Failed."
		wrtstg "  inssts=$_inst_err."
		wrtstg "#EXIT"
		rm -f "$AP_DEF_INSTERRSTS" 2> /dev/null
		wrtwsp2 "INIT Failed to initialize Essbase."
		rm -rf "$HOME/$thisnoade.ap_init.out" > /dev/null 2>&1
		exit 25
	fi
	rm -rf "$HOME/$thisnoade.ap_init.out" > /dev/null 2>&1
fi


#######################################################################
# Check the installation error - send e-mail notification
wrtstg "#CHECK INSTLLATION ERROR"
errbld="${AUTOPILOT}/tmp/${_platname}@${VERSION##*/}.err"
errplat="${AUTOPILOT}/tmp/${mysvnode}_${VERSION##*/}_${BUILD}.err"
if [ "$_force" = "true" ]; then
	wrtstg "# - Did installation."
	hh=$(. se.sh $VERSION > /dev/null 2>&1; echo $HYPERION_HOME)
	if [ -f "$hh/refresh_version.txt" ]; then
		# Error counter handling
		[ -f "$errbld" ] \
			&& errcnd=`cat $errbld 2> /dev/null | grep "^Build ${BUILD}:$"` \
			|| unset errcnd
		if [ -z "$errcnd" ]; then
			echo "Build ${BUILD}:" >> "${errbld}"
			cat $AUTOPILOT/instlog/${LOGNAME}@$(hostname)~${VERSION}~${BUILD}.log 2> /dev/null \
			| while read line; do
				echo "! $line" >> "${errbld}"
			done
		fi
		errcnd=`cat $errbld 2> /dev/null | grep "^Build " | wc -l`
		wrtstg "# - Consecutive error ccount = $errcnd."
		if [ "$verbose" = "true" ]; then
			if [ "$errcnd" -ge 3 ]; then
				wrtstg "# - Sending consecutive installation error notification."
				email_tmp="$AP_DEF_TMPPATH/${mysvnode}.eml"
				rm -rf $email_tmp > /dev/null 2>&1
				( IFS=
				  echo "\nError reported builds:"
				  cat $errbld 2> /dev/null | grep "^Build" 2> /dev/null | while read l; do
					echo "    $l"
				  done
				) >> $email_tmp
				( . se.sh ${VERSION##*/}
				  send_email "$AUTOPILOT/form/08_Consecutive_InstErr.txt" \
					"sep:" "ne:$email_tmp" "sep:" "txt:Latest log:" "ind:   " \
					"ne:$AUTOPILOT/instlog/${thisnode}~${VERSION}~${BUILD}.log" )
				rm -rf $email_tmp > /dev/null 2>&1
			fi

			wrtstg "# - Sending installation error notification."
			echo "${TEST}" >> "$errplat"
			if [ $_inst_err -ne 0 ]; then
				_insterr_kind="Error"
				_insterr_mess="Skip this test."
			else
				_insterr_kind="Report"
				_insterr_mess="But got refresh succeeded. Continue execution."
			fi
			( . se.sh ${VERSION##*/}
			  send_email "$AUTOPILOT/form/02_InstErr.txt" \
				"sep:" "txt:Latest log:" "ind:    " \
				"ne:$AUTOPILOT/instlog/${thisnode}~${VERSION}~${BUILD}.log" )
		fi # $verbose = true
		if [ $_inst_err -ne 0 ]; then
			wrtstg "!ERR 20:Install Failed."
			wrtstg "  inssts=$_inst_err."
			wrtstg "#EXIT"
			wrtwsp2 "INST Failed to install products."
			exit 20
		fi
	else
		# Reset error counter
		wrtstg "# - NO ERROR. Reset the installation error counter."
		rm -f "$errbld"
		rm -f "$errplat"
	fi
fi # $_force = true


########################################################################
# Check the DirComp result.
wrtstg "#CHECK DIR/FILE COMPARE RESULTS"
wrtcrr "CHECKING DIRCMP RESULTS"
cntfile=$AUTOPILOT/tmp/${_platname}@${VERSION##*/}.nobase.cnt
if [ -f "$AP_DEF_DIFFOUT" ]; then
	echo "There is diff output."
	wrtstg "#  FOUND DIF FILE.($AP_DEF_DIFFOUT)"
	if [ "$verbose" = "true" ]; then
		_tmp_=`cat $AP_DEF_DIFFOUT | head -1 | grep "^#NO BASE FILE"`
		if [ -n "$_tmp_" ]; then
			wrtstg "#  $_tmp_"
			if [ -f "$cntfile" ]; then
				_tmp_=`cat "$cntfile" | grep "^${BUILD}"`
				[ -z "$_tmp_" ] && echo "$BUILD" >> "$cntfile"
			else
				echo "$BUILD" > "$cntfile"
				chmod 777 $cntfile 2> /dev/null
			fi
			cnscnt=`cat $cntfile | wc -l`
			let cnscnt=cnscnt
			email_tmp="${AUTOPILOT}/tmp/${mysvnode}.eml"
			[ $cnscnt -ge 3 ] \
				&& _fname=21_Consecutive_NoBase.txt \
				|| _fname=20_NoBase.txt
			send_email "$AUTOPILOT/form/$_fname" \
				"sep:" "msg:Diff outpu:" "ind:    " "ne:$AP_DEF_DIFFOUT"
		else
			send_email "$AUTOPILOT/form/10_BaseDif.txt" \
				"sep:" "msg:Diff output:" "ne:$AP_DEF_DIFFOUT"
			wrtstg "#  Send file/folder structure dif notification."
		fi
		unset _tmp_
	fi # Verbose
	rm -f "$AP_DEF_DIFFOUT" 2> /dev/null
else
	wrtstg "#  No file/folder structure dif file. Erase NoBase count file."
	rm -f $cntfile 2> /dev/null
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
	[ "$verbose" = "true" ] && send_email "$AUTOPILOT/form/11_Esslang.txt"
fi


########################################################################
# Alternate setup
wrtstg "#ALTSETUP"
if [ -n "$AP_ALTSETUP" ]; then
	${AP_ALTSETUP} $VERSION $ORG_BUILD "$TEST"
	ret=$?
	if [ "$ret" -ne 0 ]; then
		echo "$AP_ALTSETUP returned $ret."
		[ "$verbose" = "true" ] && send_email "$AUTOPILOT/form/12_ALTSETUP.txt"
		wrtstg "!ERR 21:Failed to alt-setup."
		wrtstg "  ret=$ret"
		wrtstg "#EXIT"
		wrtwsp2 "ALTINST Failed to do alternate instalation($AP_ALTSETUP)."
		exit 21
	fi
fi	


#######################################################################
# Check test script is exist or not
wrtstg "#CHECK TEST SCRIPT($TEST)"
if [ ! -f "$VIEW_PATH/autoregress/sh/${TEST%% *}" -a \
	 ! -f "$SXR_HOME/../base/sh/${TEST%% *}" ]; then
	echo "### Target script(${TEST%% *}) not found."
# echo "### TEST=<$TEST>"
# echo "### $VIEW_PATH/autoregress/sh"
# ls $VIEW_PATH/autoregress/sh
# echo "### $SXR_HOME/../base/sh"
# ls $SXR_HOME/../base/sh
	send_email "$AUTOPILOT/form/13_No_test_script.txt"
		wrtstg "!ERR 24:Test script not found."
		wrtstg "  script=$TEST"
		wrtwsp2 "NOSCR There is no test script(${TEST%% *})."
		wrtstg "#EXIT 24"
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
wrtcrr "ASSIGNING SHORT NAME"
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
updt_ts=`get_snapshot_ts.sh`
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
	wrtcrr "CREATING SXRVIEW"
	sxr newview autoregress
	echo "Waiting to create the autoregress view"
	sleep 5
else
	wrtstg "#CLEANUP VIEW FOLDER CONTENTS"
	wrtcrr "CLEANNING UP SXRVIEW FOLDER CONTENTS"
echo "### CLEANNING UP SXRVIEW FOLDER (AP_CLEANUPVIEWFOLDERS=$APCLEANUPVIEWFOLDERS)"
	_tmp_=`chk_para.sh cleanUpViewFolders "$_OPTION"`
	[ -n "$_tmp_" ] && AP_CLEANUPVIEWFOLDERS=$_tmp_
echo "###   $_tmp_ (AP_CLEANUPVIEWFOLDERS=$APCLEANUPVIEWFOLDERS)"
	if [ "$AP_CLEANUPVIEWFOLDERS" != "false" ]; then
		for fld in work bin csc data log msh rep scr sh sxr; do
echo "###   removing $fld contents (${VIEW_PATH}/autoregress/${fld}/*)"
			rm -rf ${VIEW_PATH}/autoregress/${fld}/*
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
wrtcrr "CHECKING FREE"
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
	wrtstg "#BACKUP ESSBASE.CFG"
	[ -f "$ARBORPATH/bin/essbase.cfg.evacuation" ] \
		&& rm -f $ARBORPATH/bin/essbase.cfg.evacuation
	cp $ARBORPATH/bin/essbase.cfg $ARBORPATH/bin/essbase.cfg.evacuation
fi

cd ${VIEW_PATH}/autoregress
[ -f ".sxrrc" ] && chmod +w .sxrrc

[ "$agtstart" = "true" ] && agtstart="sxr agtctl start; " || unset agtstart
[ "$noagtpsetup" != "false" ] \
	&& echo "SXR_GOVIEW_TRIGGER='set > $AUTOPILOT/mon/${mynode}.env; $agtstart sxr sh ${TEST}'" > .sxrrc \
	|| echo "SXR_GOVIEW_TRIGGER='set > $AUTOPILOT/mon/${mynode}.env; $agtstart sxr sh agtpsetup.sh; sxr sh ${TEST}'" > .sxrrc


#######################################################################
# Write monitor parameter file

# Line 1:regression info - crr base.
#     1      2     3      4           5      6           7
#    <host>~<usr>~<plat>~<view-path>~<test>~<ver>:<bld>~<st-dttim>
# Line 2:Limit time.
# Line 3:Killed record filename.
wrtstg "#WRITE MONITOR PARAMETER"
rm -rf $AUTOPILOT/mon/${mynode}.mon.kill.rec
rm -rf $rm_paramf > /dev/null 2>&1
tout=`(. se.sh ${VERSION##*/} -nomkdir > /dev/null 2>&1; sv_get_timeout.sh)`
lmcnt=60
while [ $lmcnt -gt 0 ]; do
	sts=`lock.sh "$rm_paramf" $$`
	[ $? -eq 0 ] && break
	let lmcnt=lmcnt-1
	if [ $lmcnt -eq 0 ]; then
		wrtstg "#FAILED TO LOCK MONITOR PARAMETER FILE"
		exit 16
	fi
	sleep 1
done
echo "${myhost}~${LOGNAME}~${_platname}~${VIEW_PATH}~${TEST}~${VERSION##*/}:${BUILD}~${st_datetime}" \
		>> $rm_paramf
echo "$tout" >> $rm_paramf
unlock.sh $rm_paramf

########################################################################
# Start services if security mode is BI/FA/HSS
case "$AP_SECMODE" in
	bi|BI|fa|FA|rep|REP|birep|BIREP|hss|HSS)
		# cp $ORACLE_INSTANCE/config/OPMN/opmn/opmn.xml $VIEW_PATH/autoregress/work/pre_opmn.xml
		# cp $ARBORPATH/bin/essbase.cfg $VIEW_PATH/autoregress/work/pre_essbase.cfg
		# cp $SXR_CLIENT_ARBORPATH/bin/essbase.cfg $VIEW_PATH/autoregress/work/pre_client_essbase.cfg
		# cp $ORACLE_INSTANCE/config/OPMN/opmn/opmn.xml $VIEW_PATH/autoregress/pre_opmn.xml
		# cp $ARBORPATH/bin/essbase.cfg $VIEW_PATH/autoregress/pre_essbase.cfg
		# cp $SXR_CLIENT_ARBORPATH/bin/essbase.cfg $VIEW_PATH/autoregress/pre_client_essbase.cfg
		start_service.sh
		;;
esac

########################################################################
# Run memory monitor
wrtstg "#START MEMMON.SH"
memlog="$AUTOPILOT/mon/${mysvnode}.memusage.txt"
memmon.sh $$ "$memlog" "$VERSION $BUILD $TEST" &

########################################################################
# Run Test
########################################################################
echo "View contents ==================================================="
for fld in work bin csc data log msh rep scr sh sxr; do
	ls -R $fld
done
echo "================================================================="
wrtstg "#REGRESSION START"
wrtcrr "START"
st_sec=`crr_sec`
test_backup=$TEST
unset TEST

cd ${VIEW_PATH}
echo "Running Test Now"
sxr goview -eval "exit" autoregress
export TEST=$test_backup
rm -f $VIEW_PATH/autoregress/.sxrrc	# This also trigger the regmon.sh to terminate monitor.
ed_sec=`crr_sec`


########################################################################
# POST PROCESSING
########################################################################
wrtstg "#POSTREGRESSION"
unlock.sh "${AUTOPILOT}/mon/${mynode}.memmon"
# Wait for terminate memmon.sh
sts=0
wcnt=0
while [ $sts -eq 0 ]; do
	lock_ping.sh "${AUTOPILOT}/mon/${mynode}.memmon"
	sts=$?
	let wcnt=wcnt+1
	if [ $wcnt -gt 60 ]; then
		break
	fi
done

[ -f "$memlog" ] \
	&& mempeak=`tail -1 $memlog` \
	|| mempeak="---"

if [ `uname` = "Windows_NT" ]; then
	wrtstg "#WIN: DISCONNECT SHARED VOLUME"
	echo "### Win: Disconecting shared volume."
	# net use w: /d > /dev/null 2>&1
	# net use v: /d > /dev/null 2>&1
	# net use u: /d > /dev/null 2>&1
	# net share vol1 /d > /dev/null 2>&1
	# net share vol2 /d > /dev/null 2>&1
	# net share vol3 /d > /dev/null 2>&1
	net use | grep vol | while read dmy drv rest; do
		wrtstg "#     $drv $rest"
		echo "Disconnect $drv($rest)."
		net use $drv /d
	done
fi

# ########################################################################
# # Start services if security mode is BI/FA/HSS
# case "$AP_SECMODE" in
# 	bi|BI|fa|FA|rep|REP|birep|BIREP|hss|HSS)
# 		cp $ORACLE_INSTANCE/config/OPMN/opmn/opmn.xml $VIEW_PATH/autoregress/post_opmn.xml
# 		cp $ARBORPATH/bin/essbase.cfg $VIEW_PATH/autoregress/post_essbase.cfg
# 		cp $SXR_CLIENT_ARBORPATH/bin/essbase.cfg $VIEW_PATH/autoregress/post_client_essbase.cfg
# 		cp $ORACLE_INSTANCE/config/OPMN/opmn/opmn.xml $VIEW_PATH/autoregress/work/post_opmn.xml
# 		cp $ARBORPATH/bin/essbase.cfg $VIEW_PATH/autoregress/work/post_essbase.cfg
# 		cp $SXR_CLIENT_ARBORPATH/bin/essbase.cfg $VIEW_PATH/autoregress/work/post_client_essbase.cfg
# 		;;
# esac

########################################################################
# Post clean up

# Restore saved essbase.cfg
if [ -f "$ARBORPATH/bin/essbase.cfg" ]; then
	wrtstg "#CP ESSBASE.CFG TO SXR_WORK(current_essbase.cfg)"
	echo "### CP ESSBASE.CFG TO SXR_WORK(current_essbase.cfg)"
	cp $ARBORPATH/bin/essbase.cfg $VIEW_PATH/autoregress/work/current_essbase.cfg > /dev/null 2>&1
	if [ -f "$ARBORPATH/bin/essbase.cfg.evacuation" ]; then
		wrtstg "#RESTORE ESSBASE.CFG"
		echo "### RESTORE ESSBASE.CFG"
		echo "### DIFF CURRENT.CFG SAVED.CFG"
		diff "$ARBORPATH/bin/essbase.cfg" "$ARBORPATH/bin/essbase.cfg.evacuation" 
		rm -rf $ARBORPATH/bin/essbase.cfg > /dev/null 2>&1
		mv "$ARBORPATH/bin/essbase.cfg.evacuation" "$ARBORPATH/bin/essbase.cfg" > /dev/null 2>&1
	fi
else
	wrtstg "#NO ESSBASE.CFG AFTER TEST"
	echo "### NO ESSBASE.CFG AFTER TEST"
	echo "; MISSING ESSBASE.CFG FILE." > $VIEW_PATH/autoregress/work/current_essbase.cfg > /dev/null 2>&1
	if [ -f "$ARBORPATH/bin/essbase.cfg.evacuation" ]; then
		wrtstg "#RESTORE ESSBASE.CFG(NO CFG)"
		echo "### RESTORE ESSBASE.CFG(NO CFG)"
		mv "$ARBORPATH/bin/essbase.cfg.evacuation" "$ARBORPATH/bin/essbase.cfg" > /dev/null 2>&1
	fi
fi
if [ -n "$SXR_CLIENT_ARBORPATH" ]; then
	if [ -f "$SXR_CLIENT_ARBORPATH/bin/essbase.cfg" ]; then
		wrtstg "#CP CLIENT ESSBASE.CFG TO SXR_WORK(current_client_essbase.cfg)"
		echo "### CP CLIENT ESSBASE.CFG TO SXR_WORK(current_client_essbase.cfg)"
		cp $SXR_CLIENT_ARBORPATH/bin/essbase.cfg $VIEW_PATH/autoregress/work/current_client_essbase.cfg > /dev/null 2>&1
	fi
fi

# Delete copyed grep.exe
[ -n "$i18ngrep" -a `uname` = "Windows_NT" ] \
	&& rm -f "${VIEW_PATH}/autoregress/bin/grep.exe" 2> /dev/null

# # Delete copyed agtpsetup.sh
# [ -f "${VIEW_PATH}/sh/agtpsetup.sh" ] \
# 	&& rm -f "${VIEW_PATH}/autoregress/sh/agtpsetup.sh" 2> /dev/null

# Check the reg processes was killed.
wrtstg "#CHECK KILLED PROCESS"
if [ -f "$AUTOPILOT/mon/${mynode}.mon.kill.rec" ]; then
	cat $AUTOPILOT/mon/${mynode}.mon.kill.rec
	if [ "$verbose" = "true" ]; then
		### send e-mail notification here
		send_email $AUTOPILOT/form/14_Killed.txt \
			"sep:" "txt:Kill history:" "ind:    " \
			"ne:$AUTOPILOT/mon/${mynode}.mon.kill.rec"
	fi
fi
# Remove regression monitor related files
rm -f "$crrfile" 2> /dev/null

_flg=`get_flag`
if [ "$_flg" != "${_flg#KILL/}" ]; then
	wrtstg "!ERR 22:Killed regression process."
	wrtstg "#EXIT"
	 exit 22
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
let difcnt=difcnt
let succnt=succnt
cd $_crrdir
unset _crrdir
if [ $difcnt -eq 0 -a $succnt -eq 0 ]; then
	echo "###############################################################"
	echo "## Dif and Suc counts are Zero. regression might be failed. ###"
	echo "###############################################################"
	echo "## VERSION : $VERSION"
	echo "## BUILD   : $BUILD"
	echo "## TEST    : $TEST"
	kill_essprocs.sh -agtsvr
	echo "## sleep 30"
	sleep 30
	rm -rf "$VIEW_PATH/autoregress/zero_work_${VERSION##*/}_${BUILD}_${TEST_ABV}" > /dev/null 2>&1
	mv "$VIEW_PATH/autoregress/work" \
		"$VIEW_PATH/autoregress/zero_work_${VERSION##*/}_${BUILD}_${TEST_ABV}" > /dev/null 2>&1
	mkdir "$VIEW_PATH/autoregress/work"
	[ "$verbose" = "true" ] && send_email $AUTOPILOT/form/05_Zero_result.txt
	set_flag PAUSE
	wrtstg "!ERR 11:Zero result."
	wrtstg "#EXIT"
	wrtwsp2 "ZERO The test caused zero dif and zero suc."
	exit 11
fi

if [ -f "$VIEW_PATH/autoregress/work/apsinfo.txt" ]; then
	_v=`grep APS_BUILD $VIEW_PATH/autoregress/work/apsinfo.txt 2> /dev/null | tr -d '\r' | head -1`
	if [ -n "$_v" ]; then
		_v=${_v#*=}
		echo "# Found APS_BUILD=$_v"
		export APS_BUILD=$_v
	fi
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
_viewp_root=`get_free.sh $VIEW_PATH  mountpoint`
if [ "$_arbor_root" = "$_viewp_root" ]; then
	used_size=`expr $st_arborpath - $ed_arborpath`
else
	used_size=`expr $st_arborpath - $ed_arborpath`
	used_size=`expr $st_viewpath - $ed_viewpath + $used_size`
fi

########################################################################
# Update current status file
# echo "${myhost}~${LOGNAME}~${_PLATNAME}~~${TEST}~${VERSION}:${BUILD}~
#   ${st_datetime}~DONE -> REC_UPDT~$succnt~$difcnt~${ed_datetime}" > "$AP_RTFILE"
wrtcrr "DONE -> REC_UPDT"


########################################################################
# MAKE execution time record
wrtstg "#REPORT CURRENT STATUS FILE"
tdif=`timediff.sh "$st_datetime" "$ed_datetime"`
umask 000
echo "$TEST_ABV	$VERSION	$BUILD	$used_size KB	$mempeak KB	$st_datetime	$ed_datetime	$tdif	$succnt	$difcnt	${myhost}" >> $AUTOPILOT/mon/$_platname.rec
echo "$TEST|$VERSION|$BUILD|$used_size KB|$mempeak KB|$st_datetime|$ed_datetime|$tdif|$succnt|$difcnt|${LOGNAME}@${myhost}" >> $AUTOPILOT/mon/${_platname}.rec2
echo "$TEST|$VERSION|$BUILD|$used_size KB|$mempeak KB|$st_datetime|$ed_datetime|$tdif|$succnt|$difcnt" >> $AUTOPILOT/mon/${LOGNAME}@${myhost}.rec
wrtstg "  $TEST_ABV:$VERSION:$BUILD:$used_size KB:$mempeak KB:$st_datetime:$ed_datetime:$tdif:$succnt:$difcnt"

########################################################################
# REPORT AND BACK UP PROCESS
# Following process are not execute when the verbose(false).
########################################################################
ret=1
if [ "$verbose" = "true" ]; then
	wrtcrr "DONE -> ANALYZE"
	########################################################################
	# Analyze the dif
	wrtstg "#ANALYZE DIF FILES"
	# Delete previous .ana file.
	echo "Making the dif analyzation file"
	renameform="${AP_DEF_RESPATH}/${_platname}_${VERSION##*/}_${BUILD}_${TEST_ABV}.ana"
	searchform="${_platname}_${VERSION##*/}_*_${TEST_ABV}*.ana"
	cd ${AP_DEF_RESPATH}
	[ "$tarcnt" != "all" ] && keepnth.sh "$searchform" `expr $tarcnt - 1`
	# BUG 16172549 - NUMBERING ZIP FILES THE SAME WAY NUMBERING RTF FILES
	lastfile=`ls $searchform 2> /dev/null | sort | tail -1`
	lastfile=${lastfile%.ana}
	lastfile=${lastfile##*_}
	if [ "$lastfile" = "$TEST_ABV" ]; then
		lastfile="01"
	else
		let lastfile=lastfile+1 2> /dev/null
		lastfile="000${lastfile}"
		lastfile=${lastfile#${lastfile%??}}
	fi
	renameform="${AP_DEF_RESPATH}/${_platname}_${VERSION##*/}_${BUILD}_${TEST_ABV}_${lastfile}.ana"
	# Make archivefile name which is used in form/ana.txt
	TAG=`chk_para.sh tag "$_OPTION"`
	lastfile=`ls ${_platname}_${VERSION##*/}_${BUILD}${TAG}_${TEST_ABV}*.tar.* 2> /dev/null | sort | tail -1`
	lastfile=${lastfile%.*.*}
	lastfile=${lastfile##*_}
	if [ "$lastfile" = "$TEST_ABV" ]; then
		lastfile="01"
	else
		let lastfile=lastfile+1 2> /dev/null
		lastfile="000${lastfile}"
		lastfile=${lastfile#${lastfile%??}}
	fi
	archivefile="${_platname}_${VERSION##*/}_${BUILD}${TAG}_${TEST_ABV}_${lastfile}.tar"
	if [ `uname` = "HP-UX" ]; then
		archivefile="${archivefile}.Z"
	else
		archivefile="${archivefile}.gz"
	fi

	# Make dif analyzation file
	anafile=$renameform
	[ -f "$anafile" ] && rm -f $anafile
	# Add platform revision record 2011/08/24 YK
	platrev=`get_platform.sh -d`
	platrev=${platrev##*\#}
	cd ${VIEW_PATH}/autoregress/work
	eval_form $AUTOPILOT/form/ana.txt $anafile
	[ -f "anafile" ] && rm -f anafile

	echo "Disk Free information:"	>> $anafile
	echo "*************************************************************************"	>> $anafile
	[ -n "$st_tmp" ] && 		echo "  TMP:       $st_tmp KB -> $ed_tmp KB"	>> $anafile
	[ -n "$st_temp" ] && 		echo "  TEMP:      $st_temp KB -> $ed_temp KB"	>> $anafile
	[ -n "$st_tmpdir" ] && 		echo "  TMPDIR:    $st_tmpdir KB -> $ed_tmpdir KB"	>> $anafile
	[ -n "$st_arborpath" ] && 	echo "  ARBORPATH: $st_arborpath KB -> $ed_arborpath KB"	>> $anafile
	[ -n "$st_viewpath" ] && 	echo "  VIEW_PATH: $st_viewpath KB -> $ed_viewpath KB"	>> $anafile
	echo "" >> $anafile
	# Check Installation error
	if [ -f "$AP_DEF_INSTERRSTS" ]; then
		echo "Installation error occured:" >> $anafile
		echo "*************************************************************************"	>> $anafile
		cat $AP_DEF_INSTERRSTS | while read errcnt; do
			echo "  $errcnt" >> $anafile
		done
		echo "" >> $anafile
		rm -f $AP_DEF_INSTERRSTS
	fi
	# Check killed record.
	if [ -f "$kfile" ]; then
		echo "Killed record exists:" >> $anafile
		echo "*************************************************************************"	>> $anafile
		cat $kfile | while read one; do
			echo "  $one" >> $anafile
		done
		echo "" >> $anafile
		rm -f $kfile
	fi
	cp $anafile anafile
	echo "Suc $succnt.	Dif $difcnt." >> $anafile
	echo 	>> $anafile

	[ -f "difs.rec" ] && rm -rf difs.rec > /dev/null 2>&1
	[ -f "difs.txt" ] && rm -rf difs.txt > /dev/null 2>&1
	[ -f "ctdifs.txt" ] && rm -rf ctdifs.txt > /dev/null 2>&1

	if [ $difcnt -ne 0 ]; then

		# Check each difs
		if [ "$_NOTIFYLVL" = "all" ]; then
			_putpdif=true
		else
			[ $difcnt -le $_NOTIFYLVL ] && _putpdif=true || _putpdif=false
		fi
		rm -rf $AP_DEF_LOGPATH/*_${mysvnode}_${VERSION##*/}_${BUILD}_${TEST_ABV}.msg
		if [ -f "${TEST%.*}.sta" ]; then
			analyze.pl ${TEST%.*} $AUTOPILOT/data/dif_script.txt $AUTOPILOT/data/ignoresh.txt > difs.txt
			if [ $? -ne 0 ]; then
				echo "#ANALYZE ERROR" > difs.txt
				ls *.dif > difs.txt
			fi
			mk_difrec.sh ${VERSION##*/} ${BUILD} ${_platname} ${TEST_ABV} ctdifs.txt < difs.txt
			keepnth.sh "${AUTOPILOT}/dif/${VERSION##*/}_\*_${_platname}_${TEST_ABV}.rec" 10
			# Make a Consecutive Notify list from $EMAIL_LIST
			_cdnlist=`cat $EMAIL_LIST 2> /dev/null | grep "^ConsDifNotify[ 	]" | tail -1 | sed -e s/#.*$//g `
			_cdnlist=${_cdnlist#ConsDifNotify}
			_cdnlist=`echo $_cdnlist | sed -e "s/^[ 	]*//g" -e "s/[ 	]&$//g" -e "s/[ 	][ 	]*/ /g"`
			# Check each diffs.
			if [ -f "ctdifs.txt" ]; then
				cat ctdifs.txt | while read shlist; do
					difname=${shlist%%,*}
					shlist=${shlist#*,}
					difdesc=${shlist%%,*}
					shlist=${shlist#*,}
					difbld=${shlist%%,*}
					shlist=${shlist#*,}
					difnum=${shlist%%,*}
					shlist=${shlist#*,}
					wrtstg "$difname	$difbld	$difnum[$difdesc]	$shlist"
					unset _owner _owners _script
					for item in $shlist; do
						_find=`cat $SCRIPT_LIST 2> /dev/null | grep "^$item[ 	]" | grep -v "^#" | tail -1 | \
							sed -e "s/^${item}//g" -e "s/#.*$//g" -e "s/^[ 	]*//g" -e "s/[ 	]*$//g" \
								-e "s/[ 	][ 	]*/ /g" | tr -d '\r'`
						if [ -n "$_find" ]; then
							_owners=$_find
							_script=$item
						fi
					done
					if [ -z "$_owners" ]; then
						_owners=$LOGNAME
						_script="unassigned"
						_sc_ow="unassigned"
					else
						_sc_ow=`echo ${_owners%%/*} | sed -e "s/[ 	]*$//g"`
						_sc_ow="$_script:$_sc_ow"
					fi
					export _scr_owner=$_owners
					_ctowners=
					_tmpctowners=$_cdnlist
					# Append consecutive notification user from script list.
					if [ "${_owners#*/}" != "$_owners" ]; then
						[ -z "$_tmpctowners" ] && _tmpctowners=${_owners#*/} \
							|| _tmpctowners="$_tmpctowners ${_owners#*/}"
						_owners=${_owners%%/*}
					fi
					for one in $_tmpctowners; do
						_cnt=${one#*\(}
						if [ "$_cnt" = "$one" ]; then
							_cnt=3
						else
							_cnt=${_cnt%\)*}
							one=${one%\(*}
						fi
						[ -z "$_cnt" ] && _cnt=3
						if [ $difnum -ge $_cnt ]; then
							[ -z "$_ctowners" ] \
								&& _ctowners="${one}(${_cnt})" \
								|| _ctowners="$_ctowners ${one}(${_cnt})"
						fi
					done
					if [ -n "$_ctowners" ]; then
						_n=$difnum
						let _n=_n-1
						for one in $_owners; do 
							_ctowners="$_ctowners ${one}($_n)"
						done
					fi
					[ -z "$_owners" ] && _owners=$_ctowners || _owners="${_owners} $_ctowners"
					if [ $difnum -eq 2 ]; then
						ctdif=" $difdesc($difbld)"
					elif [ $difnum -gt 2 ]; then
						ctdif=" $difdesc($difbld:$difnum)"
					else
						ctdif=
					fi
					unset _ignorable
					######################################
					# Check dif or scripts are ignorable #
					######################################
					if [ -f "$AUTOPILOT/data/ignore.txt" ]; then
						_dslist="${difname} ${shlist}"
						for onescr in ${_dslist}; do
							_ignorable=`cat $AUTOPILOT/data/ignore.txt 2> /dev/null | grep ^${onescr}`
							[ -n "$_ignorable" ] && break
						done
						if [ -n "$_ignorable" ]; then
							_expdate=`echo $_ignorable | awk '{print $2}'`
							if [ -n "$_expdate" ]; then
								_crrdate=`date +%Y/%m/%d`
								_cmpstr_=`cmpstr "$_crrdate" "$_expdate"`	
								[ "$_cmpstr_" != ">" ] \
									&& _ignorable=" IGN(${_ignorable%%[ 	]*}:$_expdate)" \
									|| unset _ignorable
							else
								unset _ignorable
							fi
							#NEW# _ignorable=" IGN(${_ignorable%%[ 	]*})"
						fi
					fi
					if [ "$_putpdif" = "true" -a -z "$_ignorable" ]; then
						for _owner in $_owners; do
							if [ "${_owner%%\(*}" != "$_owner" ]; then
								_ct=${_owner#*\(}
								_ct=${_ct%\)*}
								_owner=${_owner%%\(*}
							else
								_ct=
							fi
							_owt=`echo $_owner | sed -e s!\<!~!g -e s!\>!~!g -e s!\@!~!g`
							msgfile="$AUTOPILOT/log/${_owt}_${mysvnode}_${VERSION##*/}_${BUILD}_${TEST_ABV}"
							if [ -n "$_ct" ]; then
								msgfile="${msgfile}_ct.msg"
								[ ! -f "$msgfile" ] \
									&& eval_form $AUTOPILOT/form/18_Consecutive_Dif.txt $msgfile
							else
								msgfile="${msgfile}.msg"
								[ ! -f "$msgfile" ] \
									&& eval_form $AUTOPILOT/form/03_Dif.txt $msgfile
							fi
							echo "${difname} ${_sc_ow}(${shlist})${ctdif}" >> $msgfile
						done
					fi
					echo "${difname} ${_sc_ow}(${shlist})${ctdif}${_ignorable}" >> $anafile
					echo "${difname} ${_sc_ow}(${shlist})${ctdif}${_ignorable}" >> difs.rec
					chmod 777 difs.rec > /dev/null 2>&1
					chmod 777 $anafile > /dev/null 2>&1
				done	
			else # if [ -f "ctdifs.txt" ]
				echo "### Analyze error:No ctdifs.txt created." >> $anafile
				ls -l *.dif >> $anafile
			fi # if [ -f "ctdifs.txt" ]
	
		else
			echo "### Analyze error:No ${TEST%.*}.sta file under the \$SXR_WORK folder." >> $anafile
			ls -l *.dif >> $anafile
		fi

	fi # if [ $difcnt != 0 ]

	wrtcrr "DONE -> NOTIFY"
	########################################################################
	# send Done notification
	wrtstg "#SEND DONE NOTIFICATION"
	[ "$_NOTIFYLVL" = "all" -o "$_putpdif" = "false" ] \
		&& send_email $AUTOPILOT/form/15_Done.txt $anafile

	########################################################################
	# Write done record if there is DoneMark() task option.
	wrtstg "#CHECK DONE RECORD OPTION($AP_DMFILE)"
	dm=`chk_para.sh DoneMark "$_OPTION"`
	dm=${dm##* }
	if [ -n "$dm" ]; then
		if [ -f "$HYPERION_HOME/bi_version.txt" ]; then
			instmode=BI
		else
			instmode=EPM
		fi
		dmrep=`echo "$dm" | \
			sed -e "s!%VER!$VERSION!g" -e "s!%BLD!$BUILD!g" \
			-e "s!%PLAT!$thisplat!g" -e "s!%INST!$instmode!g"`
		wrtstg "#  Found DoneMark($dmrep:$dm) option."
		umask 000
		echo "$dmrep|`date +%D_%T`(${thisnode})" >> $AP_DMFILE
	fi

	########################################################################
	# send dif notification to each owner
	wrtstg "#SEND DIFF NOTIFICATION"
	if [ $difcnt -ne 0 -a "$_putpdif" = "true" ]; then
		echo "Sending e-mail to each script owner"
		cd $AP_DEF_LOGPATH
		find . -name "*_${mysvnode}_${VERSION##*/}_${BUILD}_${TEST_ABV}*.msg" 2> /dev/null \
		  | sed -e "s!^\.\/!!g" | while read fname; do
			# target_owner=`echo $fname | awk -F_ '{print$1}'`
			target_owner=${fname%_*_*_*_*_*.msg}
			wrtstg "#   SEND TO $target_owner"
			send_email "ne:./$fname" "ne:$AUTOPILOT/form/27_dif_regend.txt"
			rm -rf $fname > /dev/null 2>&1
		done
	fi

	########################################################################
	# GTLF xml
	run_gtlf=false

	### Following function is using CC view to determine values.
	### with Bug 16264215 implementation, we delete this feature.
	# if [ -f "$VIEW_PATH/autoregress/data/gtlf.dat" -o -f "$SXR_HOME/../base/data/gtlf.dat" ]; then
	# 	# <sxr-view>/data/gtlf.dat should contains following lines
	# 	# GTLF=true|false
	# 	# GTLFRelease=<gtlf-release-value>
	# 	# GTLFLoad=<gtlf-load-value>
	# 	if [ -f "$VIEW_PATH/autoregress/data/gtlf.dat" ]; then
	# 		gtlfdat=$VIEW_PATH/autoregress/data/gtlf.dat
	# 	elif [ -f "$VIEW_HOME/../base/data/gtlf.dat" ]; then
	# 		gtlfdat=$VIEW_HOME/../base/data/gtlf.dat
	# 	else
	# 		gtlfdat=
	# 	fi
	# 	g_exec=`cat $gtlfdat 2> /dev/null | grep "^GTLF=" | tr -d '\r'`
	# 	g_exec=${g_exec#GTLF=}
	# 	g_rel=`cat $gtlfdat 2> /dev/null | grep "^GTLFRelease=" | tr -d '\r'`
	# 	g_rel=${g_rel#GTLFRelease=}
	# 	g_load=`cat $gtlfdat 2> /dev/null | grep "^GTLFLoad=" | tr -d '\r'`
	# 	g_load=${g_load#GTLFLoad=}
	# 	if [ "$g_exec" = "true" ]; then
	# 		export _OPTION="$_OPTION GTLFRelease2($g_rel) GTLFLoad2($g_load)"
	# 		run_gtlf=true
	# 	fi
	# fi
	if [ -f "$AUTOPILOT/data/gtlf.dat" ]; then # BUG 16264215
		wrtstg "#GTLF: Found AP/data/gtlf.dat file."
		g_line=`cat $AUTOPILOT/data/gtlf.dat 2> /dev/null | grep "^${VERSION}=" | tail -1 | tr -d '\r'`
		if [ -n "$g_line" ]; then
			wrtstg "#GTLF: g_line=\"$g_line\""
			g_line=${g_line#${VERSION}=}
			g_line=`echo $g_line | sed -e "s/#.*$//g" -e "s/^[ 	]*//g" -e "s/[ 	]*$//g"`
			wrtstg "#GTLF:     -> \"$g_line\""
		fi
		if [ -n "$g_line" -a "$g_line" != "false" ]; then
			g_release=${g_line%:*}
			g_load=${g_line#*:}
			if [ "$g_release" = "$g_line" ]; then
				unset g_release g_load
			else
	 			export _OPTION="$_OPTION GTLFRelease2($g_release) GTLFLoad2($g_load)"
				run_gtlf=true
			fi
			wrtstg "#GTLF: run_gtlf=$run_gtlf, g_release=$g_release, g_load=$g_load"
		fi
	fi
	if [ "$run_gtlf" = "false" ]; then
		_g=`chk_para.sh gtlf "$_OPTION"`; _g=${_g#* }
		[ "$_g" = "true" ] && run_gtlf=GTLF
		if [ "$run_gtlf" != "true" ]; then
			_g=`chk_para.sh gtlfload "$_OPTION"`; _g=${_g#* }
			[ -n "$_g" ] && run_gtlf=GTLFLoad
		fi
		if [ "$run_gtlf" != "true" ]; then
			_g=`chk_para.sh gtlfrelease "$_OPTION"`; _g=${_g#* }
			[ -n "$_g" ] && run_gtlf=GTLFRelease
		fi
		wrtstg "#GTLF: Check run_gtlf=$run_gtlf"
		[ "$run_gtlf" != "false" ] && run_gtlf=true
	fi
	if [ "$run_gtlf" = "true" ]; then
		wrtcrr "DONE -> GTLF XML"
		echo "# Get GTLF test unit string"
		wrtstg "#GET GTLF TEST UNIT($TEST)"
		tstunit=`get_gtlftu.sh ${TEST%% *}`
		gtlfunitf="GTLF_testunit.log"  # This should be same as $gtlfunitf in gtlf.sh
		rm -f $VIEW_PATH/autoregress/work/${gtlfunitf} 2> /dev/null
		echo "#   tstunit=\"$tstunit\""
		[ -n "$tstunit" ] && echo "$tstunit" > $VIEW_PATH/autoregress/work/${gtlfunitf}
		gtlf.sh $VERSION $BUILD "$TEST" $VIEW_PATH/autoregress/work
	fi

	wrtcrr "DONE -> SEND_RESULT"
	########################################################################
	# Gather and Send Results (in send_result.sh refer the difs.rec)

	[ -z "$AP_RESSCRIPT" ] && scr="send_result.sh" || scr=$AP_RESSCRIPT
	cd ${VIEW_PATH}/autoregress
	echo "Sending Results for $VERSION $BUILD $TEST"
	echo "SXR_GOVIEW_TRIGGER='sxr agtctl start; ${scr} -fromap $VERSION $BUILD $TEST'" > .sxrrc
	echo "Gathering Results Now"
	cd ${VIEW_PATH}
	sxr goview -eval "exit" autoregress
	rm -f $VIEW_PATH/autoregress/.sxrrc > /dev/null 2>&1
	# rm -f $VIEW_PATH/autoregress/work/difs.rec > /dev/null 2>&1
	# rm -f $VIEW_PATH/autoregress/work/difs.txt > /dev/null 2>&1
	# rm -f $VIEW_PATH/autoregress/work/ctdifs.txt > /dev/null 2>&1
	sleep 30
	kill_essprocs.sh -agtsvr

	wrtcrr "DONE -> BACKUP TAR"
	########################################################################
	# Make Backup of Work directory into $AUTOPILOT/res
	wrtstg "#MAKE BACKUP OF WORK FOLDER TO RES FOLDER"
	if [ "$tarctl" != "none" ]; then
		_platname=`get_platform.sh -l`
		echo "Making backup of Work Directory"
		TAG=`chk_para.sh tag "$_OPTION"`
		renameform="${AP_DEF_RESPATH}/${_platname}_${VERSION##*/}_${BUILD}${TAG}_${TEST_ABV}.tar"
		searchform="${_platname}_${VERSION##*/}_${BUILD}${TAG}_${TEST_ABV}*.tar.*"
		cd ${AP_DEF_RESPATH}
		[ "$tarcnt" != "all" ] && keepnth.sh "$searchform" `expr $tarcnt - 1`
		# BUG 16172549 - NUMBERING ZIP FILES THE SAME WAY NUMBERING RTF FILES
		lastfile=`ls $searchform 2> /dev/null | sort | tail -1`
		lastfile=${lastfile%.tar.*}
		lastfile=${lastfile##*_}
		if [ "$lastfile" = "$TEST_ABV" ]; then
			lastfile="01"
		else
			let lastfile=lastfile+1 2> /dev/null
			lastfile="000${lastfile}"
			lastfile=${lastfile#${lastfile%??}}
		fi
		renameform="${AP_DEF_RESPATH}/${_platname}_${VERSION##*/}_${BUILD}${TAG}_${TEST_ABV}_${lastfile}.tar"
		cd ${VIEW_PATH}/autoregress
		rm -rf work_${TEST_ABV} 2> /dev/null
		if [ "$tarctl" = "all" ]; then
			# cp work/* work_${TEST_ABV} 2> /dev/null
			cp -Rp work work_${TEST_ABV} 2> /dev/null
		else
			mkdir work_${TEST_ABV}
			cd work
			for ext in $sxrfiles; do
				cp -p *.${ext} ../work_${TEST_ABV} 2> /dev/null
			done
			# rm -rf ${TEST%.*}.sog > /dev/null 2>&1
			cp -Rp applogs ../work_${TEST_ABV} > /dev/null 2>&1
			cp -p dif.txt ../work_${TEST_ABV} 2> /dev/null
			cp -p ctdifs.txt ../work_${TEST_ABV} 2> /dev/null
			cp -p dif.rec ../work_${TEST_ABV} 2> /dev/null
			cd ..
		fi
		rm -f work.tar 2> /dev/null
		tar -cf work.tar work_${TEST_ABV} 2> /dev/null
		rm -rf work_${TEST_ABV} 2> /dev/null
		if [ `uname` = "HP-UX" ]; then
			compress work.tar
			_fext=Z
		else
			cat work.tar | gzip -c > work.tar.gz
			rm -f work.tar 2> /dev/null
			_fext=gz
		fi
		tarfile="${renameform}.${_fext}"
		[ -f "$tarfile" ] && rm -f $tarfile 2> /dev/null
		cp work.tar.${_fext} $tarfile 2> /dev/null
		rm -f work.tar.${_fext} 2> /dev/null
	fi

	wrtcrr "DONE -> CLEANUP"
	########################################################################
	# Make work back up and clean it

	# When priority is 999, doesn't make backup
	#NEW# if [ "$CRRPRIORIT" != "9990" ]; then
		wrtstg "#MOVE WORK FOLDER"
		kpwork=`chk_para.sh keepwork "${_OPTION}"`
		[ -n "$kpwork" ] && export AP_KEEPWORK="$kpwork"
		wrtstg "#  AP_KEEPWORK=$AP_KEEPWORK"
		wrtstg "#  renameform=$renameform"
		wrtstg "#  searchform=$searchform"
		renameform="work_${VERSION##*/}_${BUILD}_${TEST_ABV}"
		searchform="work_${VERSION##*/}_*_${TEST_ABV}"
		cd ${VIEW_PATH}/autoregress
		if [ "$AP_KEEPWORK" = "true" ]; then
			[ -d "$renameform" ] && rm -rf $renameform
			mv work $renameform
			mkdir work > /dev/null 2>&1
		elif [ "$AP_KEEPWORK" = "false" ]; then
			echo "Waiting removing the work folder."
			rm -rf work > /dev/null 2>&1
			mkdir work > /dev/null 2>&1
		elif [ "$AP_KEEPWORK" = "leave" ]; then
			renameform="work_${TEST_ABV}"
			[ -d "$renameform" ] && rm -rf $renameform
			# cp -R work $renameform > /dev/null 2>&1
			mkdir $renameform
			for ext in $sxrfiles; do
				cp work/*.${ext} $renameform 2> /dev/null
			done
			cp work/dif.txt $renameform 2> /dev/null
			cp work/ctdifs.txt $renameform 2> /dev/null
			cp work/dif.rec $renameform 2> /dev/null
			# rm -rf $renameform/${TEST%.*}.sog > /dev/null 2>&1
			rm -rf work > /dev/null 2>&1
			mkdir work > /dev/null 2>&1
		else
			[ -z "$AP_KEEPWORK" ] && AP_KEEPWORK=5
			[ -d "$renameform" ] && rm -rf $renameform
			echo "Waiting removing the work folder."
			keepnth.sh "$searchform" `expr $AP_KEEPWORK - 1`
			# cp -R work $renameform > /dev/null 2>&1
			mkdir $renameform
			for ext in $sxrfiles; do
				cp work/*.${ext} $renameform 2> /dev/null
			done
			cp work/dif.txt $renameform 2> /dev/null
			cp work/ctdifs.txt $renameform 2> /dev/null
			cp work/dif.rec $renameform 2> /dev/null
			# rm -rf $renameform/${TEST%.*}.sog > /dev/null 2>&1
			rm -rf work > /dev/null 2>&1
			mkdir work > /dev/null 2>&1
			echo "Keep recent $AP_KEEPWORK work folders"
		fi
	#NEW# fi # if [ "$CRRPRIORIT" != "9990" ]; then
	ret=0
fi # end of of [ "$verbose" = "true" ]; then
wrtstg "#DONE"
echo "Done Regressions"
wrtcrr "DONE -> IDLE"
kill_essprocs.sh all > /dev/null 2>&1
exit $ret
