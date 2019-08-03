#!/usr/bin/ksh
# get_hitblds.sh : Get HIT all builds
# HISTORY #######################################
# 12/21/2009 YK Add check pre_rel build folder.
# 01/24/2011 YK Support AP_HITPREFIX
# 02/13/2013 YK Support IGNORE build
# Syntax : get_hitblds.sh <ver> [ <ignbld#>... ]

. apinc.sh

if [ -z "$HIT_ROOT" ]; then
	echo "No HIT_ROOT definition."
	exit 1
fi
[ "${HIT_ROOT#${HIT_ROOT%?}}" = "/" ] && export HIT_ROOT=${HIT_ROOT%?}
[ -n "$AP_HITPREFIX" ] && _hitpref=$AP_HITPREFIX || _hitpref=build_

if [ -z "$BUILD_ROOT" ]; then
	echo "No BUILD_ROOT definition."
	exit 1
fi

orgpar=$@
ver=
ignbld=
while [ $# -ne 0 ]; do
	case $1 in
		*)
		if [ -z "$ver" ]; then
			ver=$1
		else
			if [ -n "$1" ]; then
				[ -z "$ignbld" ] && ignbld="${_hitpref}$1" || ignbld="$ignbld|${_hitpref}$1"
			fi
		fi
		;;
	esac
	shift
done

if [ -z "$ver" ]; then
	echo "No version parameter."
	echo "get_hitblds.sh <ver>"
	exit 2
fi

hitloc=`ver_hitloc.sh $ver`
if [ "$hitloc" = "not_ready" -o ! -d "$hitloc"  ]; then
	echo "This version $ver is not supported by HIT."
	exit 4
fi

cd "$hitloc"
[ -z "$ignbld" ] \
	&&           ignbld="${_hitpref}900|${_hitpref}3663_unzip_for_hitqe|.*\.bad$" \
	|| ignbld="${ignbld}|${_hitpref}900|${_hitpref}3663_unzip_for_hitqe|.*\.bad$"
ls -1r | grep "^${_hitpref}" | egrep -v "$ignbld" | while read a; do
	[ -d "$a" ] && echo $a
done
exit 0
