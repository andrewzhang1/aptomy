#!/usr/bin/ksh
#######################################################################
# File: cmdgqinst.sh <ver> <bld>
# Author: Yukio Kono
# Description: Installs ESSCMDQ and ESSCMDG
#######################################################################
# Related Environment Variable:
#   HYPERION_HOME (*must*)
#   AUTOPILOT (*must*)
#
# Related exernal shell script:
#
# Exit value:
#   0 : Installation success 
#       (if .error.sts exists, it mean the installer failed but success on refresh)
#   1 : Parameter error
#   2 : Bad build number
#   3 : No BUILD_ROOT definition
#   4 : No ARBORPATH definition
#   5 : No ARBORPATH directory
#   6 : No ARBORPATH/bin directory
#
#######################################################################
# History:
# 06/25/2008 YK Fist edition. 
# 12/15/2008 YK Add fix for WINAMD64 on Dickens (cp server DLLs)
# 12/10/2009 YK Fix the ESSCMDG/Q location by using ver_cmdgq.sh
# 08/02/2010 YK Remove extacting client DLL and libraries from cmdgqinst.sh
#               - Only extract ESSCMDQ and ESSCMDG
# 07/11/2011 YK Extract to RTC folder.
# 06/11/2012 YK Change install target folder to SXR_CLIENT_ARBORPATH location
#               if the variable defined. Otherwise, install to ARBORPATH.
# 01/29/2013 YK Make sure we won't copy commands to EssbaseRTC folder
#               when SXR_CLIENT_ARBORPATH is not defined.

. apinc.sh

unset ver bld icm
while [ $# -ne 0 ]; do
	case $1 in 
		-icm)
			icm="-icm"
			;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			elif [ -z "$bld" ]; then
				bld=$1
			else
				echo "cmdgqinst.sh: Too many parameter."
				echo "syntax: cmdgqinst.sh [-icm] <ver> <bld>"
				exit 1
			fi
			;;
	esac
	shift
done

if [ -z "$ver" -o -z "$bld" ]; then
	echo "cmdgqinst.sh: Not enough parameter."
	echo "syntax: cmdgqinst.sh <ver> <bld>"
	exit 1
fi

# Temporary patch for talleyrand_ps1 and talleyrand_sp1
if [ "$ver" = "talleyrand_ps1" ] ; then
	ver=talleyrand_sp1
fi

bld=`normbld.sh $icm $ver $bld`
if [ $? -ne 0 ]; then
	echo "$bld"
	exit 2
fi

#######################################################################
# Get installation related variable from se.sh
#######################################################################
. settestenv.sh $ver BUILD_ROOT HYPERION_HOME ARBORPATH ESSBASEPATH SXR_CLIENT_ARBORPATH

if [ -z "$BUILD_ROOT" ]; then
	echo "cmdgqinst.sh: No BUILD_ROOT defined."
	exit 3
fi

if [ -n "$SXR_CLIENT_ARBORPATH" -a -d "$SXR_CLIENT_ARBORPATH" ]; then
	rtc="$SXR_CLIENT_ARBORPATH/bin"
else
# If no SXR_CLIENT_ARBORPATH/bin, we won't copy ESSCMDQ/G to EssbaseRTC folder any more.
#	rtc="$HYPERION_HOME/common/EssbaseRTC"
#	if [ "$thisplat" != "${thisplat%64*}" ]; then
#		rtc="${rtc}-64"
#	fi
#	if [ -d "$rtc" ]; then
#		vfld=`ls -1r $rtc 2> /dev/null | egrep "[0-9\\.]+" | head -1`
#		rtc="${rtc}/${vfld}"
#		if [ ! -d "$rtc/bin" ]; then
#			unset rtc
#		else
#			rtc="$rtc/bin"
#		fi
#	else
		unset rtc
#	fi
fi

if [ -n "$ESSBASEPATH" -a -d "$ESSBASEPATH/bin" ]; then
	arb=$ESSBASEPATH
else
	arb=$ARBORPATH
fi
if [ -z "$arb" -o ! -d "$arb/bin" ]; then
	echo "cmdgqinst.sh: No $arb/bin folder."
	exit 4
fi

[ -z "$rtc" ] && rtc="$arb/bin"

#######################################################################
# Get ESSCMDG and ESSCMDQ
#######################################################################
echo "Extracting ESSCMDQ and ESSCMDG to $rtc"
cmdgqloc=`ver_cmdgq.sh $ver`
# if [ ! -d "$BUILD_ROOT/$ver/$bld/server" ]; then # New (After 9.3)
plat=`get_platform.sh`
if [ "$plat" = "$cmdgqloc" ]; then # New (After 9.3) # Old version has server/$plat/opt...
	if [ `uname` = "Windows_NT" ]; then
		cp $BUILD_ROOT/$ver/$bld/$plat/*.tar.* $arb/bin
		cd $arb/bin
		tf=`ls *.tar.* | head -1`
		targs=
		exes="ESSCMDG ESSCMDQ ESSTESTCREDSTORE"
		for one in $exes; do
			[ -z "$targs" ] && targs="ARBORPATH/bin/$one.exe" || targs="$targs ARBORPATH/bin/$one.exe"
		done
		tar xvf ${tf} ${targs} 2> /dev/null
		if [ -n "$rtc" ]; then
			rtcexe="ESSCMDG ESSCMDQ"
			for one in $rtcexe; do
				mv ARBORPATH/bin/$one.exe $rtc
			done
		fi
		mv ARBORPATH/bin/* $arb/bin
	else	# Not Windows = Unix
		cp $BUILD_ROOT/$ver/$bld/$plat/*.tar.Z $arb/bin
		cd $arb/bin
		zcat *.tar.Z | tar xvf - ARBORPATH/bin/ESSCMDG 2> /dev/null
		zcat *.tar.Z | tar xvf - ARBORPATH/bin/ESSCMDQ 2> /dev/null
		zcat *.tar.Z | tar xvf - ARBORPATH/bin/ESSTESTCREDSTORE 2> /dev/null
		if [ -n "$rtc" ]; then
			rtcexe="ESSCMDG ESSCMDQ"
			for one in $rtcexe; do
				echo "  mv $one to $rtc."
				mv ARBORPATH/bin/$one $rtc
			done
		fi
		mv ARBORPATH/bin/* $arb/bin
	fi
	rm -rf *.tar.* 2> /dev/null
	rm -rf ARBORPATH 2> /dev/null
else # OLD (9.2 and previous version)
	if [ `uname` = "Windows_NT" ]; then
		cp $BUILD_ROOT/$ver/$bld/$cmdgqloc/esscmd?.exe $arb/bin
	else
		cp $BUILD_ROOT/$ver/$bld/$cmdgqloc/*.tar.Z $arb/bin
		cd $arb/bin
		zcat *.tar.Z | tar xvf - ESSCMDG 2> /dev/null
		zcat *.tar.Z | tar xvf - ESSCMDQ 2> /dev/null
		rm -rf *.tar.* 2> /dev/null
		rm -rf ARBORPATH 2> /dev/null
	fi
fi

exit 0
