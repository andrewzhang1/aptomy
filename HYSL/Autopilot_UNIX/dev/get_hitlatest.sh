#!/usr/bin/ksh
# Get HIT latest build numner
# HISTORY #######################################
# 12/17/2009 YK Add check pre_rel build folder.
# 01/24/2011 YK Support AP_HITPREFIX
# 02/15/2013 YK Support ignore build for 
#               Bug 16324848 - 11.1.2.3.000 ESSBASE INSTALL ORDER
# 04/18/2013 YK Skip 7793 for TPS2

. apinc.sh

[ -n "$AP_HITPREFIX" ] && _hitpref=$AP_HITPREFIX || _hitpref=build_
if [ -z "$HIT_ROOT" ]; then
	echo "#VAR"
	echo "No HIT_ROOT definition."
	exit 2
fi

if [ -z "$BUILD_ROOT" ]; then
	echo "$VAR"
	echo "No BUILD_ROOT definition."
	exit 3
fi

orgpar=$@
pver=
pplat=
wide=false
ignbld=
while [ $# -ne 0 ]; do
	case $1 in
		`isplat $1`)
			pplat=$1
			;;
		-p|-plat|-platform)
			if [ $# -lt 2 ]; then
				echo "#PAR\n -p need <plat> paramter."
				exit 4
			fi
			pplat=$1
			shift
			;;
		-w)
			wide=true;;
		*)
			if [ -z "$pver" ]; then
				pver=$1
			else
				[ -z "$ignbld" ] && ignbld=$1 || ignbld="$ignbld $1"
			fi
			;;
	esac
	shift
done

if [ -z "$pver" ]; then
	echo "#PAR"
	echo "No version parameter."
	echo "get_hitlatest.sh [<plat>] <ver>"
	exit 1
fi

hitloc=`ver_hitloc.sh $pver`
if [ "$hitloc" = "not_ready" -o ! -d "$hitloc"  ]; then
	echo "#VERERR"
	echo "This version $pver is not supported by HIT."
	exit 6
fi
cd "$hitloc"
# WORKAROUND for PS3 7793
builds=`get_hitblds.sh $pver $ignbld 7793`
goodlatest=
pplat=`realplat.sh $pplat`
for one in $builds; do
	if [ -d "$one" ]; then
		##################################################
		### WE NEED CHECK THE HIT IS VALID OR NOT HERE ###
		##################################################
		if [ -d "$one" ]; then
		# if [ -f "$one/time_rule_config_spec.txt" ]; then
			essbld=`chg_hit_essver.sh $pplat $pver ${one#${_hitpref}}`
			if [ $? -eq 0 ]; then
				goodlatest=${one#${_hitpref}}
				break
			fi
		fi
	fi
done

if [ -n "$goodlatest" ]; then
	if [ "$wide" = "true" ]; then
		echo "$goodlatest:$essbld"
	else
		echo "$goodlatest"
	fi
	exit 0
else
	echo "#VERERR"
	echo "This version $pver is not supported by HIT."
	exit 7
fi
