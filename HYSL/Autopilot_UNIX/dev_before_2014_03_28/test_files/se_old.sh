#!/usr/bin/ksh

# 11/25/2008 YK Add snapshot option.
# 03/21/2011 YK Add -nativesec, -forcearborpath
. apinc.sh

_se_ver=talleyrand_sp1
_se_ev=
_se_upd=
_se_sst=

set_vardef AP_NATIVESEC AP_FORCEARBORPATH AP_SINGLEARBORPATH

# Read parameter

disp_help()
{
	echo "Set environment variables for the regression test."
	echo "Syntax:"
	echo " . se.sh [<options>] <version>"
	echo " <options> = [-h | -e <env-file> | -updt | -s <view> | -nomkdir | "
	echo "              -cl | -nativesec | -forcearborpath ]"
	echo " Note: You may need to execute this command with '.' command if you want"
	echo "       to setup current environment."
	echo "Option:"
	echo " -h            : display this help"
	echo " -e <env-file> : Use <env-file>"
	echo " -update|-updt : Update <env-file>"
	echo "                 Note: If you don't define -e <env-file> with -update option, "
	echo "                 se.sh use \$AUTOPILOT/env/<user>/<ver>_<host>.env file."
	echo " -s <view>     : Use <view> snapshot"
	echo "                 If <view> doesn't include '/' character, se.sh use following path:"
	echo "                   \$AUTOPILOT/../../<view>/vobs/essbase/latest"
	echo "                 So, if you want to use zola view on dickens, use following syntax."
	echo "                   \$ . se.sh -s zola dickens"
	echo " -nomkdir      : Do not create \$ARBORPATH and \$VIEW_PATH when those are not exist."
	echo " -cl           : Set this environment for client execution."
	echo "                 Note: There is no ESSBASE in the \$PATH definition."
	echo " -nativesec    : Use native security mode."
	echo " -forcearborpath : Define ARBORPATH forcebry when use HSS mode."

}

_nomkdir=
_cl=
while [ -n "$1" ]; do
	case $1 in
		update|-updt|-update)	_se_upd=true;;
		-e|-env)	shift; _se_ev=$1;;
		env=*)	_se_ev=${1#*=};;
		env:*)	_se_ev=${1#*:};;
		-nomkdir)	_nomkdir=$1;;
		-s|-snapshot)
			shift;
			_se_sst=$1
			;;
		-cl|client) _cl="-cl";;
		-hss|hss)
			export AP_NATIVESEC=false
			;;
		-nativesec|-nat|native|nat)
			export AP_NATIVESEC=true
			;;
		-forcearborpath|-arbor|arbor|force)
			export AP_FORCEARBORPATH=true
			;;
		-single|-singlearborpath|single)
			export AP_SINGLEARBORPATH=true
			;;
		-h|help|-help)	disp_help; exit 1;;
		*)
			case $1 in
				*=*) ;;
				*)	_se_ver=$1;;
			esac;;
	esac
	shift
done

if [ -n "$_se_sst" ]; then
	# Check the snapshot define include "/"
	if [ "x${_se_sst#*/}" = "x${_se_sst}" ]; then
		_ss_sst="$AUTOPILOT/../../$_se_sst/vobs/essexer/latest"
	fi
	if [ -d "$_ss_sst" ]; then
		crr=`pwd`
		cd "$_ss_sst"
		export SXR_HOME=`pwd`
		cd "$crr"
		unset crr
	fi
fi

if [ -z "$_se_ev" -a -n "$AP_ENVFILE" -a -f "$AP_ENVFILE" ]; then
	_se_ev="$AP_ENVFILE"
fi

if [ -z "$_se_ev" ]; then
	_se_ev="$AP_DEF_ENVPATH/${LOGNAME}/${_se_ver##*/}_`hostname`"
	if [ "${ARCH}" = "64" ]; then
		if [ "`uname`" != "Windows_NT" ]; then
			_se_ev="${_se_ev}_64"
		fi
	elif [ "${ARCH}" = "32" ]; then
		_se_ev="${_se_ev}_32"
	fi
	_se_ev=${_se_ev}.env
fi

if [ -f "$_se_ev" ]; then
	. "$_se_ev"
	echo "Setup environment usign ${_se_ev}"
else
	echo "No env file($_se_ev) is found."
fi

export _ENVFILEBASE=${_se_ev%.env}

if [ "$AP_NOENV" = "true" -o "$_se_upd" != "true" ]
then
	. setchk_env.sh $_cl "${_se_ver##*/}" $_nomkdir
else
	. setchk_env.sh $_cl "${_se_ver##*/}" $_nomkdir "$_se_ev"
fi

unset _se_ev _se_ver _se_upd _nomkback _nomkdir
