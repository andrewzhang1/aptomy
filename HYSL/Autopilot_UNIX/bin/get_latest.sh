#!/usr/bin/ksh
# Get Essbase latest build number.
# Syntax : get_latest.sh <f-ver#> [<plat>]
#          <f-ver#> : Full version number line 7.1/7.1.6.7, 9.2/9.3.0.3.0 and kennedy2
# Return:
#  0 : Display latest number/
#  1 : Parameter error.
#  2 : Illegal version or platform.
#  3 : No BUILD_ROOT definition
# History:
# 05/20/2009	YKono	Remove ver_cmstrct.sh call.
# 09/23/2010	YKono	Add "all" for <plat> option.

. apinc.sh

display_help()
{
	[ $# -ne 0 ] && echo "Get Essbase latest build number tool. V1.01\n"
	echo "Syntax : get_latest.sh [-h] <f-ver#> [<plat>|all]"
	echo " <f-ver#> : Full version number like 7.1/7.1.6.7, 9.2/9.2.0.3.0 and kennedy2"
	echo " -h       : Display help."
	echo " <plat>   : Platform to get the latest number."
	echo " all      : Get the latest build for all platform."
	if [ $# -ne 0 ]; then
		echo "\nsample:"
		echo "  $> get_latest.sh kennedy # Get latest build number for the Kennedy"
		echo "  $> get_latest.sh 9.2/9.2.0.3.0 # Get latest for 9.2.0.3.0"
		echo "  $> get_latest.sh talleyrand hpux64 # Get latest for Talleyrand and hpux64\n"
	fi
}

orgpar=$@
unset ver
unset plat
while [ $# -ne 0 ]; do
	case $1 in
		`isplat $1`)
			plat=$1
			;;
		-p|-plat|-platform)
			if [ $# -lt 2 ]; then
				echo "-p need <plat> paramter."
				echo "params: $orgpar"
				display_help
				exit 1
			fi
			plat=$1
			shift
			;;
		-h)
			display_help sample
			exit 0
			;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			else
				echo "#PAR"
				echo "Too much parameter."
				echo "params=$orgpar"
				display_help
				exit 1
			fi
			;;
	esac
	shift
done

if [ -z "$ver" ];then
	echo "#PAR"
	echo "No version parameter."
	echo "params=$orgpar"
	display_help
	exit 1
fi

if [ -z "$BUILD_ROOT" ]; then
	echo "#VAR"
	echo "No \$BUILD_ROOT defined."
	display_help
	exit 3
fi

[ -z "$plat" ] && plat=`get_platform.sh`
if [ "$plat" = "all" ]; then
	if [ -d "$BUILD_ROOT/$ver/latest/cd" ]; then # old format
		ls "$BUILD_ROOT/$ver/latest/cd" | while read plat; do
			_p="$plat              "
			_p=${_p%${_p#????????????}}
			echo "$_p`ls $BUILD_ROOT/$ver/latest/cd/$plat | grep [0-9] | tr -d '\r'`"
		done
	else
		ls "$BUILD_ROOT/$ver/latest" | while read plat; do
			_p="$plat              "
			_p=${_p%${_p#????????????}}
			echo "$_p`cat $BUILD_ROOT/$ver/latest/$plat/bldno.sh | awk -F= '{print $2}' | tr -d '\r'`"
		done
	fi
	exit 0
else
	if [ -f "$BUILD_ROOT/$ver/latest/$plat/bldno.sh" ]; then # New
		if [ -f "$BUILD_ROOT/$ver/latest/$plat/bldno.sh" ]; then
			cat $BUILD_ROOT/$ver/latest/$plat/bldno.sh | awk -F= '{print $2}' | tr -d '\r'
			exit 0
		fi
	elif [ -d "$BUILD_ROOT/$ver/latest/cd/$plat" ]; then # Old
		if [ -d "$BUILD_ROOT/$ver/latest/cd/$plat" ]; then
			ls $BUILD_ROOT/$ver/latest/cd/$plat | grep [0-9] | tr -d '\r'
			exit 0
		fi
	fi
fi

echo "#VER"
echo "Invalid VER number or missing latest folder."
echo "version=$ver, platform=$plat."

exit 2
