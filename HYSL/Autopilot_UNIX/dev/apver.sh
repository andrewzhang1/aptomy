#!/usr/bin/ksh
############################################################################
# apver.sh : Display version of the autopilot framework v 1.0
# Description:
#   This script display current version of this autopilot framework.
# Syntax:
#   apver.sh [-h|-his|-s|-sv]
# Options:
#   -h   : Display help.
#   -his : Display history of the changes.
#   -s   : Display short version.
#   -sv  : Display short version and version kind(bin/dev).
# Sample:
#   Display history.
#     $ apver.sh -his
#   Display short version number.
#     $ apver.sh -s
#     0.1.0.2
#   Display just version numner.
#     $ apver.sh
#     Autopilot 0.1.0.2 - Production on <date>
############################################################################
# HISTORY:
############################################################################
# 2011/07/27	YKono	First Edition
# 2013/08/14	YKono	Add -sv option and update help display

me=`which $0`
# -------------------------------------------------------------------------
# Read parameters
orgparam=$@
his=false
short=false
while [ $# -ne 0 ]; do
	case $1 in
		-h)	(
			IFS=
                        lno=`cat $me 2> /dev/null | egrep -n -i "# History:" \
				| head -1`
                        if [ -n "$lno" ]; then
                                lno=${lno%%:*}
				let lno=lno-1
                                cat $me 2> /dev/null | head -n $lno \
				   | grep -v "#!/usr/bin/ksh" \
				   | grep -v "^##" \
				   | while read line; do echo "${line#??}"; done
                        else
                                cat $me 2> /dev/null | grep -v "#!/usr/bin/ksh" \
				   | grep -v "^##" | while read line; do
					[ "$line" = "${line#\# }" ] && break
					echo "${line#??}"
				done
			fi
			)
			exit 0 ;;
		-s)	short=true ;;
		-sv)	short=kind ;;
		-his)	his=true ;;
		*)	echo "${me##*/} : Too many parameter."
			exit 1 ;;
	esac
	shift
done

# ==========================================================================
# Main
me=`which apver.sh`
if [ $? -ne 0 -o "x${me#no}" != "x${me}" ]; then
	echo "${me##*/} : Couldn't find the execution path for apver.sh."
	exit 2
fi

vertxt="${me%/*}/this version.txt"
if [ ! -f "$vertxt" ]; then
	echo "${me##*/} : Couldn't find the \"this version.txt\" in current PATH."
	exit 3
fi
if [ "$his" = "true" ]; then
	more "$vertxt"
else
	crrver=`cat "$vertxt" 2> /dev/null | egrep -i "^# version :" | head -1`
	crrver=`echo $crrver | awk '{print $4}'`
	if [ "$short" = "true" ]; then
		echo "$crrver"
	elif [ "$short" = "kind" ]; then
		me=${me%/*}
		me=${me##*/}
		echo "$crrver $me"
	else
		echo "Autopilot $crrver - Production on `date`"
	fi
fi

exit 0

