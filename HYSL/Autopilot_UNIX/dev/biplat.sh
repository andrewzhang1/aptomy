#!/usr/bin/ksh
############################################################################
# biplat.sh : Display the platform name for BISHIHOME v1.0
#
# Syntax:
#   biplat.sh [-h|<plat>]
# 
# Parameter:
#   <plat> : pre_rel platform name to display.
#            When you skip this parmeter, this script use current platfrom.
#
# Options:
#   -h   : Display help.
#
# Description:
#   This script display the platform name using in BISHIPHOME folder.
#
# Mapping:(on 2011/08/12)
#   win32       NT
#   winamd64    WINDOWS.X64
#   solaris     UNSUPPORT(solaris)
#   solaris64   SOLARIS.SPARC64
#   solaris.x64 SOLARIS.X64
#   linux       LINUX
#   linux64     UNSUPPORT(linux64)
#   linuxamd64  LINUX.X64
#   linuxx64exa LINUX.X64
#   hpux        UNSUPPORT(hpux)
#   hpux64      HPUX.IA64
#   aix         UNSUPPORT(aix)
#   aix64       AIX.PPC64
#
# Sample:
#   Display current platform
#   $ biplat.sh
#   LINUX
#   $ biplat.sh winamd64
#   WINDOWS.X64
#
############################################################################
# HISTORY:
############################################################################
# 2011/08/12	YKono	First Edition

me=$0

# -------------------------------------------------------------------------
# Read parameters
orgparam=$@
plats=
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
		*)
			[ -z "$plats" ] && plats=$1 || plats="$plats $1"
			;;
	esac
	shift
done

# ==========================================================================
# Main

fail=0
[ -z "$plats" ] && plats=`get_platform.sh`
for oneplat in $plats; do
	case $oneplat in
		win32)		echo "NT";;
		winamd64)	echo "WINDOWS.X64";;
		aix64)		echo "AIX.PPC64";;
		solaris64)	echo "SOLARIS.SPARC64";;
		solaris64exa)	echo "SOLARIS.SPARC64";;
		solaris.x64)	echo "SOLARIS.X64";;
		linux)		echo "LINUX";;
		linuxamd64)	echo "LINUX.X64";;
		linuxx64exa)	echo "LINUX.X64";;
		hpux64)		echo "HPUX.IA64";;
		*)		echo "UNSUPPORT($oneplat)"; fail=1;;
	esac
done

exit $fail
