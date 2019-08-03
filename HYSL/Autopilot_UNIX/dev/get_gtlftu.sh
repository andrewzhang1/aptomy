#!/usr/bin/ksh
# get_gtlftu.sh : Get GTLF testunit definition
# Syntax:
#   get_gtlftu.sh <test-name>
# Output:
#   0 : GTLF testunit
#   1 : Not enough parameter
#   2 : Target file is not found
# History:
# 2012/06/07    YKono   First edition

[ $# -ne 1 ] && exit 1
tstscr=${1%% *}
tstpth=
if [ -f "$SXR_VIEWHOME/sh/${tstscr}" ]; then
	tstpth="$SXR_VIEWHOME/sh/${tstscr}"
fi
if [ -z "$tstpth" ]; then
	if [ -f "$SXR_HOME/../base/sh/${tstscr}" ]; then
		tstpth="$SXR_HOME/../base/sh/${tstscr}"
	fi
fi
if [ -n "$tstpth" ]; then
	tstunit=`cat $tstpth 2> /dev/null | grep "^#:[ 	][ 	]*GTLF_testunit:" | tr -d '\r'`
	tstunit=${tstunit#*GTLF_testunit:}
	if [ -z "$tstunit" ]; then
		case $tstscr in
			i18n_j.sh)	echo "I18N_Acceptance_NtoN";;
			i18n_j_mlc.sh)	echo "I18N_Acceptance_NtoU";;
			i18n_i.sh)	echo "I18N_Acceptance_UtoU";;
			i18n_i_slc.sh)	echo "I18N_Acceptance_UtoN";;
			i18n_x.sh)	echo "I18N_Extended_Cross";;
		esac
	else
		echo $tstunit | awk '{print $1}'
	fi
	exit 0
else
	echo "$tstscr_NotFound"
	exit 2
fi
