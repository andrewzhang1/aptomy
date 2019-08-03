#!/usr/bin/ksh
# Change HIT build number to Essbase version and build number
# SYNTAX:
#   chg_hit_essver.sh [<plat>] <ver#> <HIT bld#>
# IN:
#	<plat>:		Get build for specifc platform.
#               with out this parameter, this script returns generic build number.
#	<ver#>:		Essbase version number
#	<HIT bld#>:	HIT build number
# OUT:
#	0: <Ess bld#>_<HIT bld#>_{<plat>|generic|platerr}
#        <plat>  = bld# is came from platform specific.
#        generic = bld# is came from generic definition.
#        platerr = there is no <plat> bld#. bld# is came from generic definition.
#	1: Parameter error
#	2: No HIT_ROOT definition
#	3: HIT not ready for this version.
#	4: There is no valid essbase_version.xml for that build
#	5: There is no valid build number in the essbase_version.xml

# This script recognize following 3 patterns:
# 1) <Name>essbase_${plat}<Name>
#    <Release>99.9.9.9.9.99</Release>
# 2) <Name>essbase</Name>
#    <Platform>${plat}</Platform>
#    <Release>99.9.9.9.9.99</Release>
# 3) <Name>essbase</Name>
#    <Release>99.9.9.9.9.99</Release>
#

###############################################################################
# HISTORY:
# 05/28/2008 YK First edition
# 07/01/2008 YK Use version.sh to covert the version number to the code name.
# 08/01/2008 YK Add $ver parameter
# 10/13/2008 YK Correspond new format.
# 12/11/2008 YK Return HIT build number,
# 12/22/2008 YK Add recognization "<Name>essbase</Name>" and 
#                                 "<Release>99.9.9.9.9.99</Release>" format.
# 03/24/2009 YK Correspondent Talleyrand's EssbaseRTC_version.txt format. (from 5000)
# 08/13/2009 YK Add Talleyrand HIT_<plat> installer location.
# 01/24/2011 YK Support AP_HITPREFIX variable to allow to use syspost/talleyrand_ps1/drop28_6725

. apinc.sh

plat=`get_platform.sh`

display_help()
{
	echo "chg_hit_essver.sh [ -p <plat> ] <ver> <HIT bld#>"
}

[ -n "$AP_HITPREFIX" ] && _hitpref=$AP_HITPREFIX || _hitpref=build_
# Read parameter
orgpar=$@
pbld=
bver=
pplat=
while [ $# -ne 0 ]; do
	case $1 in
		# win32|win64|winamd64|aix|aix64|solaris|solaris.x64|solaris64|hpux|hpux64|linux|linuxamd64)
		`isplat $1`)
			pplat=$1
			;;
		-p|-plat|-platform)
			if [ $# -lt 2 ]; then
				echo "#PAR\n -p need <plat> paramter."
				display_help
				exit 1
			fi
			shift
			pplat=$1
			;;
		*)
		if [ -z "$pver" ]; then
			pver=$1
		elif [ -z "$pbld" ]; then
			pbld=$1
		else
			echo "#PAR\n too many parameter."
			echo "params: $orgpar"
			display_help
			exit 1
		fi
		;;
	esac
	shift
done

# Check mandatory parameters
if [ -z "$pver" -o -z "$pbld" ]; then
	echo "#PAR"
	echo "Few parameter."
	echo "params: $orgpar"
	display_help
	exit 1
fi

# Check $HIT_ROOT environment variable
if [ -z "$HIT_ROOT" ];then
	echo "#VAR"
	echo "\$HIT_ROOT not defined";
	exit 2
fi
if [ ! -d "$HIT_ROOT" ]; then
	echo "#VAR"
	echo "Couldn't access \$HIT_ROOT($HIT_ROOT) locaion."
	exit 2
fi

[ "${HIT_ROOT#${HIT_ROOT%?}}" = "/" ] && export HIT_ROOT=${HIT_ROOT%?}
hit=$pbld
hitloc=`ver_hitloc.sh $pver`
if [ "$hitloc" = "not_ready" ]; then
	echo "#VER"
	echo "HIT doesn't support this version($pver)."
	exit 3
fi

[ "$hit" = "latest" ] && hit=`get_hitlatest.sh $pver`

# Correspond to Talleyrand folder structure
hitplat=
if [ "$pplat" ]; then
	hitplat=`ver_hitplat.sh $pplat`
else
	hitplat=`ver_hitplat.sh all`
fi

hittmp=
for one in $hitplat; do
	[ -z "$hittmp" ] && hittmp="HIT_${one}" || hittmp="${hittmp} HIT_${one}"
done
[ -z "$hittmp" ] && hittmp="HIT" || hittmp="$hittmp HIT"
hitdir=
for one in $hittmp; do
	if [ -f "$hitloc/${_hitpref}${hit}/${one}/essbase_version.xml" ]; then
		hitdir=$one
		break
	fi
done

if [ ! -f "$hitloc/${_hitpref}${hit}/${hitdir}/installTool.jar" ]; then
	echo "#VER"
	echo "There is no valid installer structure for HIT build $hit."
	exit 5
fi

verxml="$hitloc/${_hitpref}${hit}/${hitdir}/essbase_version.xml"
verlbl="[Ee]ssbase"
bldchr="."

if [ ! -f "$verxml" ]; then
	echo "#BLD"
	echo "There is no valid HIT build ${hit}."
	eecho "Couldn't find valid essbase_version.xml under $hitloc/${_hitpref}${hit}/${hitdir} folder."
	exit 4
fi
unset ver bld

# Before 900, there is <Name>essbase_%PLAT%</Name> or
# <Name>essbase</Name> then follow the <Release>%VER%.%BLD%</Release>
# From 900, <Name>essbase</Name> and <Platform>%PLAT%</Platform>
# then follow the <Release>%VER%.%BLD%</Release>
ttl=`cat ${verxml} | wc -l`
verfrom=none
unset lno
tmpplt=`grep -n "<[Nn]ame>essbase_${plat}</[[Nn]ame>" "$verxml"`
if [ -n "$tmpplt" ]; then
	lno=${tmpplt%%:*}
	let lno="$lno + 1"
	verfrom=old
else
	tmpplt=`grep -n "<[Nn]ame>${verlbl}</[Nn]ame>" "$verxml"`
	if [ -n "$tmpplt" ]; then
		lno=${tmpplt%%:*}
		let ttl="$ttl - $lno"
		[ -z "$pplat" ] && tmpplt= \
			|| tmpplt=`tail -$ttl "$verxml" | grep -n "<[Pp]latform>${pplat}</[Pp]latform>"`
		if [ -n "$tmpplt" ]; then
			lofs=${tmpplt%%:*}
			let lno="$lno + $lofs + 1"
			verfrom=$plat
		else
			let lno="$lno + 1"
			verfrom=generic
		fi
	fi
fi

if [ -n "$lno" ]; then
	tmpver=`head -$lno "$verxml" \
			| tail -1 \
			| grep "<[Rr]elease>.*</[Rr]elease>" \
			| sed -e "s/<[Rr]elease>\(.*\)<\/[Rr]elease>/\1/g"`
	if [ -n "tmpver" ]; then
		bld=${tmpver##*${bldchr}}
	fi
fi
if [ -z "$hit" -o -z "$bld" ]; then
	echo "#VER"
	echo "There is no valid Essbase version and build number in HIT build $hit."
	echo "ver_xml:$verxml"
	exit 5
fi
if [ -n "$pplat" ]; then
	[ "$verfrom" != "old" -a "$verfrom" != "generic" -a "$pplat" != "$verfrom" ] && verfrom="platerr"
fi
echo "${bld}_${hit}_${verfrom}" | tr -d '\r'
exit 0
