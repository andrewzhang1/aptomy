#!/usr/bin/ksh
# Search HIT build number by Essbase version number
# SYNTAX:
#   srch_hit.sh <ver#> <Ess bld#>
# IN:
#	<ver#>:		Essbase version number
#	<Ess bld#>:	HIT build number
# OUT:
#	0	 : HIT build number.
#	!= 0 : Error 
#

###############################################################################
# HISTORY:
# 10/13/2008 YK First edition
# 01/24/2011 YK Support AP_HITPREFIX

display_help()
{
	echo "Syntax 1:srch_hit.sh [-p <plat>] <ver#> <Ess bld#>"
	echo "  Return HIT build number which contains <ver#> and <Ess bld#>."
	echo "Syntax 2:srch_hit.sh <ver#>"
	echo "  List up Essbase build number and HIT build number for <ver#>."
	echo "Syntax 3:srch_hit.sh"
	echo "  List all versions under the HIT prodpost folder."
}

. apinc.sh

[ -n "$AP_HITPREFIX" ] && _hitpref=$AP_HITPREFIX || _hitpref=build_
orgpar=$@
plat=
ver=
bld=
while [ $# -ne 0 ]; do
	case $1 in
		`isplat $1`)
			plat=`realplat.sh $1`
			;;
		-p|-plat|-platform)
			if [ $# -lt 2 ]; then
				echo "-p need <plat> paramter."
				echo "params: $orgpar"
				display_help
				exit 1
			fi
			shift
			plat=$1
			;;
		-h)
			display_help
			exit 0
			;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			else
				if [ -z "$bld" ]; then
					bld=$1
				else
					echo "Too many parameter."
					echo "params: $orgpar"
					display_help
					exit 2
				fi
			fi
			;;
	esac
	shift
done

if [ -z "$ver" ]; then
	srch_basehit.sh
	exit 0
fi

# Check $HIT_ROOT environment variable
if [ -z "$HIT_ROOT" ];then
	echo "\$HIT_ROOT not defined";
	exit 4
fi
[ "${HIT_ROOT#${HIT_ROOT%?}}" = "/" ] && export HIT_ROOT=${HIT_ROOT%?}
hitloc=`ver_hitloc.sh $ver`
if [ "$hitloc" = "not_ready" ]; then
	echo "HIT doesn't support this version($ver)."
	exit 5
fi

[ "$bld" = "latest" ] && bld=`get_latest.sh $plat $ver`
builds=`get_hitblds.sh $ver`
for line in $builds; do
	hit=${line#${_hitpref}}
	essver=`chg_hit_essver.sh $plat $ver $hit`
	if [ $? -eq 0 ]; then
		if [ -z "$bld" ]; then
			echo $essver
		else
			if [ "${essver%%_*}" = "$bld" ]; then
				echo $hit
				exit 0
			fi
		fi
	fi
done
if [ -n "$bld" ]; then
	[ -n "$plat" ] && plat=" for $plat platform"
	echo "There is no HIT build for Essbase $ver:${bld}${plat}."
	exit 4
fi

exit 0
