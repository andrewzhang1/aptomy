#!/usr/bin/ksh
# get_ess_ver.sh : Get Essbase version and build information.
# 
# DESCRIPTION:
# Get the Essbase version and build informations from current
# installated modules, ESSCMD.
#
# SYNTAX:
#   get_ess_ver.sh [-h|-w|-t] [ESSCMD|ESSCMDQ|ESSCMDG|essmsh|ESSBASE|all]
# PARAMETER:
#   When you provide a parameter, this program get the version number from
#   target command. When you define "ESSBASE", this program start ESSBASE
#   in backgound and get the server version number from ESSCMDQ.
#   -h   : Display help.
#   -w   : Display command location.
#   -t   : Test version in all command.
#
# RETURN:
#   = 0 : Normal
#   = 1 : Environment variables error. ARBORPATH, HYPERION_HOME
#   = 2 : Failed to launch target command.
#   = 3 : Version numbers are not same on -test command.
#
# HISTORY:
# 05/09/08 YK Add 11.1.1.0.0 as Kennedy
# 06/25/08 YK Change ver->code conversion to use ver_code.sh
# 07/01/08 YK Use version.sh for ver->code conv
# 03/17/11 YK Change ARBORPATH to ESSBASEPATH if defined.
# 04/05/13 YK Support private build.
# 05/30/13 YK Bug 16667156 - AUTOPILOT CHECKS SERVER BUILD NUMBER AND CLIENT BUILD NUMBER

. apinc.sh

me=$0
orgpar=$@
testcmd=
usewhich=false
testver=false
while [ $# -ne 0 ]; do
	case $1 in
		esscmd|cmd|c|ESSCMD|CMD|C)
			[ -z "$testcmd" ] && testcmd=ESSCMD || testcmd="$testcmd ESSCMD"
			;;
		essbase|agent|a|ESSBASE|AGENT|A)
			[ -z "$testcmd" ] && testcmd=ESSBASE || testcmd="$testcmd ESSBASE"
			;;
		esscmdq|cmdq|q|ESSCMDQ|CMDQ|Q)
			[ -z "$testcmd" ] && testcmd=ESSCMDQ || testcmd="$testcmd ESSCMDQ"
			;;
		esscmdg|cmdg|g|ESSCMDG|CMDG|G)
			[ -z "$testcmd" ] && testcmd=ESSCMDG || testcmd="$testcmd ESSCMDG"
			;;
		essmsh|msh|m|ESSMSH|MSH|M)
			[ -z "$testcmd" ] && testcmd=essmsh || testcmd="$testcmd essmsh"
			;;
		all)
			testcmd="ESSBASE ESSCMD ESSCMDQ ESSCMDG essmsh"
			;;
		-t|-test)
			testver=true
			;;
		-w)
			usewhich=true
			;;
		-wall)
			usewhich=true
			testcmd="ESSBASE ESSCMD ESSCMDQ ESSCMDG essmsh"
			;;
		-tall)
			testver=true
			testcmd="ESSBASE ESSCMD ESSCMDQ ESSCMDG essmsh"
			;;
		-h)
			display_help.sh $me
			exit 0
			;;
		*)
			echo "${me##*/}:Too much parameters."
			echo "parms: $orgpar"
			exit 1
			;;
	esac
	shift
done
[ -z "$testcmd" ] && testcmd=ESSCMD

#######################################################################
# Check if ARBORPATH is defined and Exists
#######################################################################
if [ -z "$ARBORPATH" ];then
	echo "ARBORPATH not defined";
	exit 1
fi

if [ -n "$ESSBASEPATH" ]; then
	# Check if ESSBASEPATH directory exists
	if [ ! -d "$ESSBASEPATH" ];then
		echo "ESSBASEPATH does not exist, please create directory"
		exit 1
	fi
fi

#######################################################################
# Check if HYPERION_HOME is defined and Exists
#######################################################################
if [ -z "$HYPERION_HOME" ];then
	echo "HYPERION_HOME not defined";
	exit 1
fi

if [ ! -d "$HYPERION_HOME" ];then
	echo "HYPERION_HOME directory doesn't exist"
	exit 1
fi

#######################################################################
# Get the version number from each tools.
#######################################################################
get_version() {
	ret=0
	if [ -z "$AP_CHEATVER" ]; then
		if [ "$1" = "ESSBASE" ]; then
			stagent=
			runagent=`psu -ess | egrep -i essbase`
			if [ -z "$runagent" ]; then
				if [ -z "$AP_SECMODE" ]; then
					ESSBASE -b password > /dev/null 2>&1 &
				else
					start_service.sh > /dev/null 2>&1
					opmnctl startall > /dev/null 2>&1
				fi
				stagent=true
			fi
			tstcmd=ESSCMDQ
			[ `uname` = "Windows_NT" ] && tstcmd="${tstcmd}.exe"
			tmpf=$HOME/.get_ess_ver.$$.scr
			rm -rf $tmpf
			[ -n "$SXR_DBHOST" ] && sxr_dbhost="$SXR_DBHOST" || sxr_dbhost="localhost"
			[ -n "$SXR_USER" ] && sxr_usr="$SXR_USER" || sxr_usr="essexer"
			[ -n "$SXR_PASSWORD" ] && sxr_pwd="$SXR_PASSWORD" || sxr_pwd="password"
			outf=$HOME/.get_ess_ver.$$.out
			cat ${APCC}/acc/getsyscfg.scr 2> /dev/null | sed \
				-e "s/%HOST/$sxr_dbhost/g" \
				-e "s/%UID/$sxr_usr/g" \
				-e "s/%PWD/$sxr_pwd/g" > $tmpf
			# tmp=`$tstcmd "${tmpf}" 2> /dev/null | grep "Essbase Description:"`
			tmp=`$tstcmd "${tmpf}" 2> /dev/null | grep "Module Description:" | head -1`
			ret=$?
			rm -rf $tmpf
			if [ "$stagent" = "true" ]; then
				if [ -z "$AP_SECMODE" ]; then
					cat $APCC/acc/shutdown.scr 2> /dev/null | sed \
						-e "s!%OUTF!$outf!g" \
						-e "s/%HOST/$sxr_dbhost/g" \
						-e "s/%USR/$sxr_usr/g" \
						-e "s/%PWD/$sxr_pwd/g" > $tmpf
					$tstcmd "${tmpf}" > /dev/null 2>&1
					rm -rf $tmpf
					rm -rf $outf
				else
					opmnctl stopall > /dev/null 2>&1
				fi
			fi
			ver=`echo $tmp | sed -e "s/^.*ESB//g" -e "s/B.*$//g"`
			bld=`echo $tmp | sed -e "s/^.*B//g" | sed -e "s/\..*$//g"`
			# ver=`echo $tmp | sed -e "s/^.*ESB//g" -e "s/B/:/g"`
			ver="$ver:$bld"
		else
			tstcmd=$1
			[ `uname` = "Windows_NT" ] && tstcmd="${tstcmd}.exe"
			tmp=`$tstcmd "${APCC}/acc/quit.scr" 2> /dev/null`
			ret=$?
			ver=`echo $tmp | sed -n -e 's/^[^(]*(ESB//g' -e 's/).*$//g' -e 's/B/:/' -e 1p`
		fi
	else
		ver=$AP_CHEATVER
	fi
	_ver=${ver%:*}
	_bld=${ver#*:}
	# Add . betweem each digit if ver like 7600 or 95000
	[ "$_ver" = "${_ver%.*}" ] && \
		_ver=`echo $_ver | sed -e "s/./&./g" | sed -e "s/.$//g"`
	_ver=`ver_codename.sh $_ver | tr -d '\r'`
	if [ $ret -eq 0 ]; then
		if [ "$_ver" = "talleyrand_sp1" ]; then
			if [ "$_bld" = "002" -o "$_bld" = "003" -o "$_bld" = "004" ]; then
				ver="talleyrand_sp1_269a:$_bld"
			else
				ver="$_ver:$_bld"
			fi
		else
			ver="$_ver:$_bld"
		fi
		if [ "$cnt" -eq 1 ]; then
			if [ "$usewhich" = "true" ]; then
				echo "`which $1`=$ver"
			else
				echo "$ver"
			fi
		else
			if [ "$usewhich" = "true" ]; then
				echo "`which $1`=$ver"
			else
				echo "$1=$ver"
			fi
		fi
	else
		echo "$1=failed."
		ret=2
	fi
}

# Count parameter
cnt=0
for one in $testcmd; do
	let cnt=cnt+1
done

# Get each version
if [ "$testver" = "true" ]; then
	if [ $cnt -lt 2 ]; then
		echo "${me##*/}:-test parameter need at least two modules to compare version numbers."
		echo "params:$orgpar"
		exit 1
	fi
	prevver=
	ret=0
	for one in $testcmd; do
		tmp=`get_version $one`
		tmp=${tmp#*=}
		if [ -z "$prevver" ]; then
			prevver=$tmp
		elif [ "$tmp" = "failed." -o "$prevver" != "$tmp" ]; then
			echo "#ERR Miss matched version/bld numbers(prevver=$prevver,tmp=$tmp)."
			usewhich=true
			for i in $testcmd; do
				get_version $i
			done
			ret=3
			break
		fi
	done
	[ "$ret" = "0" ] && echo $prevver
else
	for one in $testcmd; do
		get_version $one
	done
fi

exit $ret

