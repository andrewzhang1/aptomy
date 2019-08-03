#!/usr/bin/ksh
############################################################################
#
# normbls.sh : NORMalize BuiLD number v1.0
# Syntax:
#   normbld.sh [-w|-h|-p <plat>|-icm] <f-ver#> <bld#>
# 
# Parameters:
#   f-ver# : Full version number like 7.1/7.1.6.7
#   bld#   : Build number
#             - 032         : Essbase build 032
#             - latest      : Latest build number of <f-ver#>
#             - HIT(123)    : Get essbase build number from HIT build 123
#             - hit[latest] : Get essbase build number from HIT latest build
#             - hit_####    : HIT
#             - bi(MAIN:LATEST)
#             - bi(BISHIPHOME/MAIN)
#
# Options:
#   -w        : wide build format <essbld>_<hitbld>
#               without this option, this script just return Essbase build.
#   -p <plat> : Display build number for <plat> platform.
#   -icm      : Ignore the CM acceptance result
#   -h        : Display help.
#
# Exit code:
#   $? = 0 success
#        1 Parameter error
#        2 No BUILD_ROOT
#        3 No HIT_ROOT
#        4 Invalid build number. No build folder under pre_rel
#        5 Failed CM acceptance.
#
############################################################################
# HISTORY:
############################################################################
# 07/31/2008 YK - First Edition
# 07/14/2010 YK - Add check a result of the CM acceptance
# 10/15/2010 YK - Add ignore CM check optiont.
# 12/13/2010 YK - Add paring hit_###
# 01/24/2011 YK - Temporary version fix for talleyrand_ps1 to talleyrand_sp1

. apinc.sh

# Function -----------------------------------------------------------------

me=$0
      
if [ -z "$BUILD_ROOT" ]; then
	echo "#ENV"
	echo "No BUILD_ROOT definition."
	exit 2
fi

if [ -z "$HIT_ROOT" ]; then
	echo "#ENV"
	echo "No HIT_ROOT definition."
	exit 3
fi

[ "${HIT_ROOT#${HIT_ROOT%?}}" = "/" ] && export HIT_ROOT=${HIT_ROOT%?}

plat=`get_platform.sh`
toomany=
unset ver bld wide ignCM
while [ $# -ne 0 ]; do
	case $1 in
		-w)
			wide=true
			;;
		-h)
			display_help.sh $me
			exit 0
			;;
		`isplat $1`)
			plat=$1
			;;
		-p)
			if [ $# -eq 0 ]; then
				echo "#PAR"
				echo "'-p' parameter need second parameter as platform."
				display_help.sh $me
				exit 1
			fi
			shift
			plat=$1
			;;
		-icm|-igncm|-ignCM)
			ignCM=true
			;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			else
				if [ -z "$bld" ]; then
					bld=$1
				else
					echo "#PAR"
					echo "Too many parameters."
					display_help.sh $me
					exit 1
				fi
			fi
			;;
	esac
	shift
done

if [ -z "$ver" ]; then
	echo "#PAR"
	echo "No version parameter."
	display_help.sh $me
	exit 1
fi
[ -z "$bld" ] && bld="latest"
# plat=`realplat.sh $plat`
ret=0
_bldknd=
if [ "$bld" = "latest" ]; then
	[ "$ver" = "talleyrand_ps1" ] && ver=talleyrand_sp1
	bld=`get_latest.sh $ver`
	ret=$?
else
	_tmpstr=`chk_para.sh hit "$bld"`
	if [ -n "$_tmpstr" ]; then
		_bldknd=hit
		bld=$_tmpstr
	else 
		_tmpstr=`chk_para.sh bi "$bld"`
		if [ -n "$_tmpstr" ]; then
			_bldknd=bi
			bld=$_tmpstr
		else
			_tmpstr=`echo $bld | tr 'A-Z' 'a-z'`
			if [ "$_tmpstr" != "${_tmpstr#hit_}" ]; then
				_bldknd=hit
				bld=${bld#???_}
			elif [ "$_tmpstr" != "${_tmpstr#bi_}" ]; then
				_bldknd=bi
				bld=${bld#??_}
			fi
		fi
	fi

	if [ "$_bldknd" = "hit" ]; then
		bld=`chg_hit_essver.sh -p $plat $ver $bld`
		if [ $? -ne 0 ]; then
			echo "$bld."
			exit 4
		fi
		bld=${bld%_*}
	elif [ "$_bldknd" = "bi" ]; then
		if [ "$bld" = "latest" ]; then
			bld=
			srch_bi.sh $ver  > /dev/null 2>&1
			sts=$?
		else
			srch_bi.sh $ver -bi $bld > /dev/null 2>&1
			sts=$?
		fi
		if [ $sts -eq 0 ]; then
			[ -n "$bld" ] && bld=`srch_bi.sh $ver -bi $bld | tail -1` \
				|| bld=`srch_bi.sh $ver | tail -1`
			ebld=`echo $bld | awk '{print $3}'`
			bibld=`echo $bld | awk '{print $1}'`
			bld="${ebld#*:}_${bibld}_bi"
		else
			srch_bi.sh $ver -bi $bld
			exit 4
		fi
	else
		[ "$ver" = "talleyrand_ps1" ] && ver=talleyrand_sp1
		if [ ! -d "$BUILD_ROOT/$ver/$bld/$plat" ]; then
			echo "#BLD"
			echo "No build folder($ver/$bld/$plat) in pre_rel."
			exit 4
		fi
	fi
fi

# Check CM acceptance result
[ "$ver" = "talleyrand_ps1" ] && ver=talleyrand_sp1
if [ "$ignCM" != "true" ]; then
	if [ -f "$BUILD_ROOT/$ver/${bld%%_*}/logs/$plat/${plat}_test.txt" ]; then
		ret=`grep "acctest.sh: EXITCODE is" "$BUILD_ROOT/$ver/${bld%%_*}/logs/$plat/${plat}_test.txt" | tr -d '\r'`
		ret=${ret##* }
	elif [ -f "$BUILD_ROOT/$ver/${bld%%_*}/logs/$plat/${plat}_test_details.txt" ]; then
		ret=`grep "^# Exit code:" "$BUILD_ROOT/$ver/${bld%%_*}/logs/$plat/${plat}_test_details.txt" | tr -d '\r'`
		ret=${ret##* }
	fi
	if [ "$ret" != "0" ]; then
		echo "#BLD"
		echo "CM Acceptance was failed for $ver/$bld/$plat."
		exit 5
	fi
fi

[ -n "$wide" ] && echo ${bld} | tr -d '\r' \
	|| echo ${bld%%_*} | tr -d '\r'

exit $ret
