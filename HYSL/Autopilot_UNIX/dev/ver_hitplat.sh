#!/usr/bin/ksh
# ver_hitplat.sh : Display HIT paltform
# 
# SYNTAX:
# ver_hitplat.sh [-p <plat>|all] [-hitopack]
# 
# RETURN: HIT platform extension name
#
# CALL FROM:
# hitinst.sh
# get_hitlatest.sh
# chg_hit_essver.sh
#
# HISTORY
# 11/12/2009 YK - First Edition.
# 12/15/2009 YK - Add -p parameter
# 02/04/2011 YK - Change solarisx86 to solaris.x64

. apinc.sh
_plat=
_hp=false
while [ $# -ne 0 ]; do
	case $1 in
		`isplat $1`)
			_plat=`realplat.sh $1`
			;;
		all)
			_plat=$1
			;;
		-p|-plat|-platform)
			if [ $# -lt 2 ]; then
				echo "ver_hitplat.sh : -p need <plat> as second parameter."
				exit 1
			fi
			shift
			_plat=$1
			;;
		-hitopack|-op)
			_hp=true
			;;
		-h)
			echo "ver_hitplat.sh : Get HIT platform."
			echo "Description: This script return HIT platform for specific pre_rel platforms."
			echo "Syntax: ver_hitplat.sh [-p <plat>|all] [-hitopack]"
			echo "Option:"
			echo "  -p <plat> : Define pre_rel platform"
			echo "              `isplat`"
			echo "  -hitopack : Return HIT opack platform."
			exit 0
			;;

		*)
			echo "ver_hitplat.sh : syntax error."
			echo "ver_hitplat.sh [-p <plat>|all]"
			exit 1
			;;
	esac
	shift
done
[ -z "$_plat" ] && _plat=`get_platform.sh`
if [ "$_hp" = "true" ]; then
	case $_plat in
		solaris64|solaris.x64|solaris|solaris64exa)
				echo "SPARC64";;
		aix64|aix)	echo "AIX64";;
		hpux64)		echo "HPUXIA64";;
		winamd64)	echo "WIN64";;
		linux)		echo "LINUX32";;
		linuxamd64|linuxx64exa)	echo "LINUX64";;
		win32)		echo "WIN32";;
		all)
			echo "WIN32"
			echo "WIN64"
			echo "LINUX32"
			echo "LINUX64"
			echo "AIX64"
			echo "SPARC64"
			echo "HPUXIA64"
			;;
		*)	;;
	esac
else
	case $_plat in
		solaris64|solaris.x64|solaris|solaris64exa)
				echo "solaris";;
		aix64|aix)	echo "aix";;
		hpux64)		echo "hpitanium";;
		winamd64)	echo "amd64";;
		linux)		echo "linux32";;
		linuxamd64|linuxx64exa)	echo "linux64";;
		win32)		echo "win32";;
		all)
			echo "win32"
			echo "amd64"
			echo "linux32"
			echo "linux64"
			echo "aix"
			echo "solaris"
			echo "hpitanium"
			;;
		*)	;;
	esac
fi
exit 0
