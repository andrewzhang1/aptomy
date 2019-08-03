#!/usr/bin/ksh
# List delegate.sh machines
# SYNTAX:
#   lsd.sh [-h|-l]
#     -h : Display help
#     -l : Check live or not.

. apinc.sh

display_help()
{
	echo "List delegate.sh machines"
	echo "SYNTAX:"
	echo "$(basename $0) [-h|-l|-p|-s]"
	echo "PARAMETERS:"
	echo "   -h : Display help"
	echo "   -l : Check live or not."
	echo "   -p : Display platform kind."
	echo "   -s : Display current status."
}

checklive="false"
dispplat="false"
dispsts="false"

while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help
			exit 0
			;;
		-l)
			checklive="true"
			;;
		-s)
			dispsts="true"
			;;
		-p)
			dispplat="true"
			;;
		*)
			echo "$(basename $0): Syntax error."
			display_help
			exit 1
			;;
	esac
	shift
done

ls $AUTOPILOT/lck/*.lck \
	| grep -v .ap.lck \
	| grep -v .read.lck \
	| grep -v .parse.lck \
	| grep -v .reg.lck \
	| grep -v apmail \
	| while read line; do
	a=`basename $line`
	a=${a%.*}
	if [ -f "$AUTOPILOT/lck/${a}.ap.lck" ]; then
		if [ -f "$AUTOPILOT/mon/${a}.ap" ]; then
			apsts=`tail -1 "$AUTOPILOT/mon/${a}.ap" | crfilter`
			plt=`tail -2 "$AUTOPILOT/mon/${a}.ap" | head -1 | crfilter`
		else
			apsts="Running DL/AP. But not found mon/${a}.ap file."
			plt="UNKNOWN"
		fi
	else
		apsts="Running DL. No AP running."
		plt="UNKNOWN"
	fi
	[ "$dispplat" = "true" ] && print -n "$plt "
	print -n $a
	[ "$dispsts" = "true" ] && print -n " $apsts"
	if [ "$checklive" = "true" ]; then
		lock_ping.sh "$AUTOPILOT/lck/${a}"
		if [ $? -eq 0 ]; then
			echo " LIVE"
		else
			echo " DEAD"
		fi
	else
		echo ""
	fi
done

