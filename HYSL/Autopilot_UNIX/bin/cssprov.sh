#!/usr/bin/ksh
# =========================================================================
# %ME% : Add/display provider information to/in the HSS registry
# =========================================================================
# Syntax: 
#   %ME% [-h|-p <pwd>] [<xml>]
# Description:
#   Add/display provider informations to/in the HSS registry database.
#   When you deifne <xml> parameter, this program send that XML file
#   to the HSS registry. And when you skip <xml> parameter, this 
#   program just display current HSS registry.
# Parameter:
#   <xml> : XML file for send.
# Options:
#   -h      : Display help.
#   -p <pwd>: Password for the shared serivices database.
#             When you skip this parameter, this script
#             use "password" for it.
# Note: This script need HSS configured version environment
#       and use user_projects/bin/epmsys_registry.sh(bat).
#
###########################################################################
# History:
# 2012/07/19	YKono	First edition
# 2012/07/20	YKono	Change spec

me=$0
[ -n "$SXR_WORK" ] && tmpdir=$SXR_WORK || tmpdir="$HOME"

display_help()
{
	[ $# -ne 0 ] && endline="^# HISTORY:" \
		|| endline="^# HISTORY:|^# SAMPLE:|^# Example:"
	# descloc=`egrep -ni "^# .+ :" $me | head -1`
	descloc=2
	histloc=`egrep -ni "$endline" $me | head -1`
	descloc=${descloc%%:*}
	histloc=${histloc%%:*}
	let lcnt=histloc-descloc
	let tcnt=$histloc-1
	lastline=`head -${tcnt} $me | tail -1`
	if [ "${lastline%${lastline#???}}" = "###" ]; then
		let tcnt=tcnt-1
		let lcnt=lcnt-1
	fi
	(IFS=
	head -${tcnt} $me | tail -${lcnt} | while read line; do
		if [ "$line" != "#!/usr/bin/ksh" ]; then
			[ "$line" = "#" ] && echo "" || echo "${line##??}"
		fi
	done) | sed -e "s!%ME%!${me##*/}!g"
}

keepfiles="false"
xml=
pass=password
while [ $# -ne 0 ]; do
	case $1 in
	-h|-hs)
		display_help
		exit 0
		;;
	-keepfiles)
		keepfiles=true
		;;
	-p)
		shift
		if [ $# -eq 0 ]; then
			echo "${me##*/}: '-p' parameter need second parameter."
			exit 1
		fi
		pass=$1
		;;
	-xml)
		;;
	*)
		if [ -z "$vxml" ]; then
			xml=$1
			disp="false"
		else
			echo "${me##*/}: Unknown parameter '$1'."
			exit 1
		fi
		;;
	esac
	shift
done

if [ ! -d "$tmpdir" ]; then
	echo "${me##*/}: Cannot access to $tmpdir folder."
	exit 1
fi

if [ -z "$HYPERION_HOME" ]; then
	echo "${me##*/}: No \$HYPERION_HOME defined."
	exit 1
fi

orains="$HYPERION_HOME/../user_projects/epmsystem1"
if [ ! -d "$orains/bin" ]; then
	echo "${me##*/}: Cannot access to $orains/bin folder."
	exit 1
fi

if [ "`uname`" = "Windows_NT" ]; then
	prog="epmsys_registry.bat"
	iswin=win
else
	prog="epmsys_registry.sh"
	unset iswin
fi

if [ ! -f "$orains/bin/$prog" ]; then
	echo "${me##*/}: No $orains/bin/$prog file found."
	exit 1
fi

# Normalize provxml and sodrxml before change directory
if [ -n "$xml" -a -f "$xml" ]; then
	crrdir=`pwd 2> /dev/null`
	dir=$(dirname $xml)
	cd $dir 2> /dev/null
	xml="`pwd 2> /dev/null`/${xml##*/}"
	cd $crrdir 2> /dev/null
fi
# Change directory to the tmpdir and make node folder.
[ -z "$thisnode" ] && thisnode="$LOGNAME@$(hostname)"
cd $tmpdir
rm -rf "${tmpdir}/${thisnode}.tmp" 2> /dev/null
mkdir ${thisnode}.tmp 2> /dev/null
cd ${thisnode}.tmp 2> /dev/null
tmpdir="${tmpdir}/${thisnode}.tmp"

# Prepare password file
passfile="$tmpdir/password.txt"
echo "$pass" > $passfile
[ -n "$iswin" ] && passfile=`echo $passfile | sed -e "s!/!\\\\\\\\\\\\\\\\!g"`

# Script dir
scrptdir=$orains/bin
[ -n "$iswin" ] && scrptdir=`echo "$scrptdir/" | sed -e "s!/!\\\\\\\\\\\\\\\\!g"`

trgprog="$tmpdir/${prog}"

# Edit program script
cat $orains/bin/$prog | while read -r line; do
	print -r $line | \
	 	sed -e "s!-DEPM_ORACLE_HOME!-DpasswordFile=${passfile} -DEPM_ORACLE_HOME!g" \
		    -e "s!SCRIPT_DIR=.*\$!SCRIPT_DIR=${scrptdir}!g"
done > $trgprog
chmod +x $trgprog

if [ -z "$xml" ]; then
	# Get current repository
	repname="${tmpdir}/Comp_1_SHARED_SERVICES_PRODUCT_CSSConfig"
	rm -rf "${repname}" 2> /dev/null
	${trgprog} view "SYSTEM9/FOUNDATION_SERVICES_PRODUCT/SHARED_SERVICES_PRODUCT/@CSSConfig" > /dev/null 2>&1
	if [ ! -f "${repname}" ]; then
		echo "${me##*/}: Failed to get the current CSSConfiguration."
		exit 2
	fi
	cat $repname
else
	# Update HSS repository
	${trgprog} updatefile "SYSTEM9/FOUNDATION_SERVICES_PRODUCT/SHARED_SERVICES_PRODUCT/@CSSConfig" $xml
fi
cd ..
[ "$keepfiles" != "true" ] && rm -rf $tmpdir 2> /dev/null
exit 0
