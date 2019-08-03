#!/usr/bin/ksh
# ver_hitplat.sh : Display HIT paltform
# 
# SYNTAX:
# ver_hitplat.sh
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
		-mp)
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
case $_plat in
	solaris64|solaris.x64|solaris)	echo "solaris";;
	aix64|aix)		echo "aix";;
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
	*)			echo $_crrplat;;
esac
exit 0
