#!/usr/bin/ksh
###########################################################
###########################################################
# Filename: get_resloc.sh
# Author: Y.Kono
# Description: Return result store location.
###########################################################
# 05/25/2011 YK First edition

# Syntax: get_resloc.sh <ver> <test>
. apinc.sh

set_vardef AP_RESLOC > /dev/null 2>&1

ver=
tst=
while [ $# -ne 0 ]; do
	case $1 in
		-h)	display_help
			exit 0
			;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			elif [ -z "$tst" ]; then
				tst=$1
			else
				echo "#PAR too much parameter"
				display_help
				exit 1
			fi
			;;
	esac
	shift
done

if [ -z "$ver" ]; then
	echo "#PAR No version parameter."
	display_help
	exit 1
fi

# Normalize Result location and default value
ap_def_resloc=$AUTOPILOT/..

if [ -n "$AP_RESFOLDER" ]; then
	RESDIR=$AP_RESFOLDER
else
	_i18n=`echo $tst | grep ^i18n_`
	if [ "$_i18n" -o -n "$AP_I18N" ]; then
		RESDIR=i18n/essbase
	elif [ "$tst" = "xprobmain.sh" ]; then
		RESDIR=i18n/essbase
	else
		RESDIR=essbase
	fi
fi
if [ "$AP_RESLOC" = "$ap_def_resloc" ]; then
	RESDIR=$AP_RESLOC/$ver/$RESDIR
else
	RESDIR=$AP_RESLOC/$RESDIR
fi
[ -d "$RESDIR" ] || mkddir.sh "$RESDIR"
cd $RESDIR
pwd
exit 0

