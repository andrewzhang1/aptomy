#!/usr/bin/ksh
# Search BASE HIT build number by Essbase version number
# SYNTAX:
#   srch_basehit.sh <ver#>
# IN:
#	<ver#>:		Essbase version number
# OUT:
#	0 : HIT build number. in "<ver>:<hit-buld>"
#	1 : No <ver> parameter.
#	2 : No HIT_ROOT definition
#	3 : Specifed <ver> is not HIT enable.
#

###############################################################################
# HISTORY:
# 07/29/2009 YK First edition

. apinc.sh

### Function

display_help()
{
	#     0         1         2         3         4         5         6         7
	#     01234567890123456789012345678901234567890123456789012345678901234567890123456789
	echo "srch_basehit.sh {-h|[-w ]<ver>}"
	echo "Description:"
	echo "    This command serch the base HIT for given version number and display base"
	echo "    version number and HIT build number separated by colon character."
	echo "Options:"
	echo "    <ver> : Search version number."
	echo "    -h    : Display help."
	echo "    -w    : wide format(<ver>:<hit-bld>:<ess-bl>)."
	echo "    Note: When you skip <ver>, this command display all HIT versions."
	echo "Sample:"
	echo "    $ srch_basehit.sh 11.1.2.2.000"
	echo "    11.1.2.2.0:7528"
	echo "    $ srch_basehit.sh 11.1.2.1.102 -w"
	echo "    talleyrand_sp1:6765_rtm:347"
	
}

# Listup all HIT version
list_all_hit()
{
	_crr=`pwd`
	cd ${hitbase}
	ls | grep -v prodpost | ver_vernum.sh -org | sort | while read vernum vername; do
		echo $vernum $vername
	done
	cd $_crr
}

### Main start here

hitbase=`ver_hitloc.sh baselocation`
unset ver
wide=false
while [ $# -ne 0 ]; do
	case $1 in
		-h)		display_help with usage; exit 0;;
		-w)		wide=true;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			else
				echo "srch_basehit.sh : Too many parameter."
				display_help
				exit 1
			fi
			;;
	esac
	shift
done

if [ -z "$ver" ]; then
	list_all_hit
	exit 0
fi

. settestenv.sh $ver HIT_ROOT > /dev/null 2>&1
# Check $HIT_ROOT environment variable
if [ -z "$HIT_ROOT" ];then
	echo "\$HIT_ROOT not defined for this version($ver)."
	exit 2
fi
[ "${HIT_ROOT#${HIT_ROOT%?}}" = "/" ] && export HIT_ROOT=${HIT_ROOT%?}
crr=`pwd`
cd ${hitbase}

targ=$(
	myver=`ver_vernum.sh $ver`
	ls | grep -v prodpost | ver_vernum.sh -org | sort | while read vernum vername; do
		sts=`cmpstr "$vernum" "$myver"`
		[ "$sts" = ">" ] && break
		echo $vernum $vername
	done | tail -1)
if [ -n "$targ" ]; then
	ver=${targ##* }
	bld=`get_hitlatest.sh -w $ver`
	essbld=${bld#*:}
	essbld=${essbld%%_*}
	bld=${bld%:*}
	if [ "$wide" = "true" ]; then
		echo "${ver}:${bld}:${essbld}"
	else
		echo "${ver}:${bld}"
	fi
else
	exit 3
fi
