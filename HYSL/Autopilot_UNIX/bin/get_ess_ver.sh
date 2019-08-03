#!/usr/bin/ksh
# get_ess_ver.sh : Get Essbase version and build information.
# 
# DESCRIPTION:
# Get the Essbase version and build informations from current
# installated modules, ESSCMD.
#
# SYNTAX:
# get_ess_ver.sh
#
# RETURN:
#   = 0 : Normal
#   = 1 : Environment variables error. ARBORPATH, HYPERION_HOME
#   = 2 : Failed to launch ESSCMD.
#
# HISTORY:
# 05/09/08 YK Add 11.1.1.0.0 as Kennedy
# 06/25/08 YK Change ver->code conversion to use ver_code.sh
# 07/01/08 YK Use version.sh for ver->code conv
# 03/17/11 YK Change ARBORPATH to ESSBASEPATH if defined.
# 04/05/13 YK Support private build.

. apinc.sh

display_help()
{
	echo "get_ess_ver.sh [<agent|cmdq|cmdg|msh>]"
}

orgpar=$@
testcmd="ESSCMDQ"
while [ $# -ne 0 ]; do
	case $1 in
		esscmd|cmd)
			testcmd=ESSCMD
			;;
		essbase|agent)
			testcmd=ESSBASE
			;;
		esscmdq|cmdq)
			testcmd=ESSCMDQ
			;;
		esscmdg|cmdg)
			testcmd=ESSCMDG
			;;
		essmsh|msh)
			testcmd=essmsh
			;;
		all)
			testcmd="ESSBASE ESSCMDQ ESSCMDG essmsh"
			;;
		-h)
			display_help
			exit 0
			;;
		*)
			echo "Too much parameters."
			echo "parms: $orgpar"
			display_help
			exit 1
			;;
	esac
	shift
done

#######################################################################
# Check if ARBORPATH is defined and Exists
#######################################################################
if [ -z "$ARBORPATH" ];then
	echo "ARBORPATH not defined";
	exit 1
fi

# Comment out because when sec mode is HSS and no initialize, there is
#   no ARBORPATH directory.
# # Check if ARBORPATH directory exists
# if [ ! -d "$ARBORPATH" ];then
# 	echo "ARBORPATH does not exist, please create directory"
# 	exit 1
# fi

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
# Start ESSCMD and get build number
#######################################################################
if [ -n "$ESSBASEPATH" ]; then
	ESSCMD_CMD="$ESSBASEPATH/bin/ESSCMD"
else
	ESSCMD_CMD="$ARBORPATH/bin/ESSCMD"
fi
if [ `uname` = "Windows_NT" ];then
	ESSCMD_CMD="${ESSCMD_CMD}.exe"
fi

if [ ! -f "$ESSCMD_CMD" ]; then
	ESSCMD_CMD=$(basename $ESSCMD_CMD)
fi

tmp=`$ESSCMD_CMD "$AP_DEF_ACCPATH/quit.scr" 2> /dev/null`
ret=$?
if [ $ret = 0 ];then
	if [ -n "$AP_CHEATVER" ]; then
		ver=$AP_CHEATVER
	else
		ver=`echo $tmp | sed -n -e 's/^[^(]*(ESB//g' -e 's/).*$//g' -e 's/B/:/' -e 1p`
	fi
	_ver=${ver%:*}
	_bld=${ver#*:}
	# Add . betweem each digit if ver like 7600 or 95000
	[ "$_ver" = "${_ver%.*}" ] && \
		_ver=`echo $_ver | sed -e "s/./&./g" | sed -e "s/.$//g"`
	_ver=`ver_codename.sh $_ver`
# temporary workaround
	if [ "$_ver" = "talleyrand_sp1" ]; then
		if [ "$_bld" = "002" -o "$_bld" = "003" -o "$_bld" = "004" ]; then
			echo "talleyrand_sp1_269a:$_bld" | tr -d '\r'
		else
			echo "$_ver:$_bld" | tr -d '\r'
		fi
	else
		echo "$_ver:$_bld" | tr -d '\r'
	fi
else
	echo "Failed to launch $ESSCMD_CMD(sts=$ret).";
	ret=2
fi

exit $ret

