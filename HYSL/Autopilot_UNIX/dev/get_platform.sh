#!/usr/bin/ksh
#######################################################################
# get_platform.sh : Get OS platform kind.
# Syntax:
#   get_platform.sh [-h|-d]
# Options:
#   -h : Display help
#   -d : Display detailed OS information
#   -l : Display long format
# Description:
#   This script return the OS platform kind likw win32, winamd64...
#   When define "-d" option, this script returned detailed information.
#######################################################################
# History:
# 09/06/2007 YK Fist edition. 
# 07/30/2008 YK Add linuxamd64
# 10/13/2010 YK Add solaris86 and CYGWIN*
# 10/29/2010 YK Fix Solaris X86 names.
# 02/04/2011 YK Change Solaris X86 platform name to solaris.x64
# 08/23/2011 YK Add detailed OS information.
# 12/12/2012 YK Add exalytics-linuxx64 and -l option
# 04/04/2013 YK Add exalytics-solaris.x64 and -l option
#               BUG 16602243 - AUTOPILOT NEEDS TO SUPPORT SOLARIS EXALYTICS 
me=$0
orgpar=$@
detail=false
long=false
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			exit 0
			;;
		-d|detail)
			detail=true
			;;
		-l)
			long=true
			;;
		*)
			echo "get_platform.sh:Syntax error."
			exit 1
			;;
	esac
	shift
done

case `uname` in
	HP-UX)
		unm=`uname -m`
		[ "$unm" = "ia64" ] && _plat=hpux64 || _plat=hpux
		;;
	SunOS)
		# (ykono@slc02les) uname -m; isainfo -kv
		# sun4v
		# 64-bit sparcv9 kernel modules
		# (regrrk1@scl14511)> uname -m; isainfo -kv
		# i86pc
		# 64-bit amd64 kernel modules
		unm=`uname -m`
		if [ "${unm#i86}" = "$unm" ]; then
			[ "${ARCH%64*}" != "$ARCH" ] && _plat=solaris64 || _plat=solaris
			if [ "${ARCH%EXA}" != "$ARCH" -o "${ARCH%EX}" != "$ARCH" ]; then
				[ "$long" = "true" ] &&  _plat="${_plat}exa"
			fi
		else
			isasts=`isainfo -kv`
			if [ "${isasts#64}" != "$isasts" ]; then
				kernel=64
				_plat=solaris.x64
			else
				kernel=32
				_plat=solaris.x32
			fi
			[ "${ARCH%64*}" != "$ARCH" ] && _plat=solaris.x64
			[ "${ARCH%32*}" != "$ARCH" ] && _plat=solaris.x32
			if [ "${ARCH%EXA}" != "$ARCH" -o "${ARCH%EX}" != "$ARCH" ]; then
				[ "$long" = "true" ] && _plat="${_plat}exa"
			fi
		fi
		;;
	Linux)
		unm=`uname -m`
		if [ "$unm" = "x86_64" ]; then
			if [ "$ARCH" = "AMD64" ]; then _plat=linuxamd64
			elif [ "$ARCH" = "AMD64EXA" -o "$ARCH" = "AMD64EX" ]; then
				[ "$long" = "true" ] && _plat=linuxx64exa || _plat=linuxamd64
			elif [ "$ARCH" = "64" ]; then _plat=linux64
			else _plat=linux; fi
		else
			_plat=linux
		fi
		;;		
	AIX)
		[ "${ARCH}" = "64" ] && _plat=aix64 || _plat=aix
		;;
	Windows_NT)
		if [ "$ARCH" = "64"    ]; then _plat=win64;
		elif [ "$ARCH" = "AMD64" ]; then _plat=winamd64;
		elif [ "$ARCH" = "64M" ]; then _plat=winmonte;
		else _plat=win32 
		fi
		;;
	CYGWIN*)
		if [ "$ARCH" = "64"    ]; then _plat=win64;
		elif [ "$ARCH" = "AMD64" ]; then _plat=winamd64;
		elif [ "$ARCH" = "64M" ]; then _plat=winmonte;
		else _plat=win32 
		fi
		;;
	*)
		_plat=unknown
		;;
esac
[ "$detail" = "false" ] && echo $_plat || echo "${_plat}#$(get_osrev.sh)"
exit 0
