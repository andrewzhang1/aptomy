#!/usr/bin/ksh
#123456789012345678901234567890123456789012345678901234567890123456789012345
############################################################################
# apver.sh : Display version of the autopilot framework v 1.0
#
# Syntax:
#   apver.sh [-h|-his|-s]
# 
# Options:
#   -h   : Display help.
#   -his : Display history of the changes.
#   -s   : Display short version.
# 
# Description:
#   This script display current version of this autopilot framework.
#
# Sample:
#   Display history.
#     $ apver.sh -his
#   Display short version number.
#     $ apver.sh -s
#     0.1.0.2
#   Display just version numner.
#     $ apver.sh
#     Autopilot 0.1.0.2 - Production on <date>
#
############################################################################
# HISTORY:
############################################################################
# 2011/07/27	YKono	First Edition

me=$0
# -------------------------------------------------------------------------
# Read parameters
orgparam=$@
his=false
short=false
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			exit 0
			;;
		-hs)
			display_help.sh $me -s
			exit 0
			;;
		-s)
			short=true
			;;
		-his|-history)
			his=true
			;;
		*)
			echo "ver.sh : Too many parameter."
			display_help.sh $me
			exit 1
			;;
	esac
	shift
done

# ==========================================================================
# Main
me=`which apver.sh`
if [ $? -ne 0 -o "x${me#no}" != "x${me}" ]; then
	echo "ver.sh : Couldn't find the execution path for apver.sh."
	exit 2
fi

vertxt="${me%/*}/this version.txt"
if [ ! -f "$vertxt" ]; then
	echo "ver.sh : Couldn't find the \"this version.txt\" in current PATH."
	exit 3
fi
if [ "$his" = "true" ]; then
	more "$vertxt"
else
	crrver=`cat "$vertxt" 2> /dev/null | egrep -i "^# version :" | head -1`
	crrver=`echo $crrver | awk '{print $4}'`
	if [ "$short" = "true" ]; then
		echo $crrver
	else
		echo "Autopilot $crrver - Production on `date`"
	fi
fi

exit 0

