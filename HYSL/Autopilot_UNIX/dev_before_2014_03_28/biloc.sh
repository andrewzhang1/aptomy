#!/usr/bin/ksh
############################################################################
# biloc.sh : Display BI location v1.0
#
# Description:
#   Display BI location for each OS.
#   If AP_ADEROOT is defined, this program return that location.
#
# Syntax:
#   biloc.sh [-h|<plat>]
# 
# Parameter:
#   <plat> : pre_rel platform name to display.
#            When you skip this parmeter, this script use current platfrom.
#
# Options:
#   -h   : Display help.
#   -hs  : Display help with Sample
#
# Description:
#   This script display the location of the BISHIPHOME folder
#
# Sample:
#   Display current platform(LINUX)
#   $ biloc.sh
#   /ade_autogs/ade_base/
#   $ biplat.sh winamd64
#   /net/stafas43.us.oracle.com/vol/ade_winports/
#
############################################################################
# HISTORY:
############################################################################
# 2011/08/12	YKono	First Edition
# 2011/10/05	YKono	Add AP_ADEROOT for the map location for ade_XXXXX
# 2012/05/02	YKono	Change default location for Unix to ade_generic3

me=$0

# -------------------------------------------------------------------------
# Read parameters
orgparam=$@
plats=
loc=
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
		-l)
			echo "ade_win=stafas31"
			echo "ade_winports=stafas43"
			echo "ade_generic3=adcavere23"
			echo "ade_rel_win02=adcavere24"
			echo "stafas29.us.oracle.com/ade_release_windows"
			exit 0
			;;
		-p)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}:-p need a second parameter as patform."
				exit 1
			fi
			[ -z "$plats" ] && plats=$1 || plats="$plats $1"
			;;
		*)
			loc=$1
			;;
	esac
	shift
done

# ==========================================================================
# Main

[ -z "$plats" ] && plats=`get_platform.sh`
fail=0
if [ -z "$loc" ]; then
	if [ -n "$AP_ADEROOT" ]; then
		echo $AP_ADEROOT
	else
		for oneplat in $plats; do
			case $oneplat in
				win32)		echo "//stafas31.us.oracle.com/ade_win";;
				winamd64)	echo "//stafas43.us.oracle.com/ade_winports";;
				aix64|solaris64|solaris.x64|hpux64)
						echo "/ade_autofs/ade_ports";;
				linux|linuxamd64|linuxx64exa)
						echo "/ade_autofs/ade_base";;
				*)		echo "UNSUPPORT($oneplat)"; fail=1;;
			esac
		done
	fi
fi
if [ -n "$loc" ]; then
	if [ "${plats#win}" != "$plats" ]; then
		second_part=`echo $loc | awk -F/ '{print $3}'`
		trail_part=${loc#/*/*/}
		[ "$trail_part" = "$loc" ] && unset trail_part || trail_part="/$trail_part"
		newroot=
		case $second_part in
			ade_win)	newroot=stafas31;; # stafas32
			ade_winports)	newroot=stafas43;;
			ade_generic3)	newroot=adcavere23;;
			ade_rel_win02)	newroot=adcavere24;;
		esac
		# Search mount location
		drive=`mount | grep -v Unavailable | egrep -w "$second_part"`
		drive=`echo $drive | awk '{print $1}'`
		if [ -d "$drive" ]; then
			[ "${drive%/}" != "$drive" ] && drive=${drive%/}
			echo "$drive$trail_part"
		else
			if [ -n "$newroot" -a -d "//$newroot/$second_part" ]; then
				# Case of ADE enable machine
				echo "//$newroot/$second_part$trail_part"
			elif [ -n "$newroot" -a -d "//$newroot.us.oracle.com/$second_part" ]; then
				# Case of ADE accesible machine
				echo "//$newroot.us.oracle.com/$second_part"
			else
				echo $loc
			fi
		fi
	else
		echo $loc
	fi
fi

exit $fail
