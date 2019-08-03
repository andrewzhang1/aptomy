#!/usr/bin/ksh
# Get APS latest build number.
# Syntax : get_apslatest.sh <APS-ver>
# Return:
#  0 : Display latest number/
#  1 : Parameter error.
#  2 : Illegal version or platform.
#  3 : No BUILD_ROOT definition
# History:
# 12/17/2012	YKono	First edition

. apinc.sh

me=$0
orgpar=$@
unset ver
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			exit 0
			;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			else
				echo "#PAR"
				echo "Too much parameter."
				echo "params=$orgpar"
				display_help.sh $me
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
	exit 1
fi

if [ -z "$BUILD_ROOT" ]; then
	echo "#VAR"
	echo "No \$BUILD_ROOT defined."
	exit 3
fi

if [ ! -d "$BUILD_ROOT/../../eesdev/aps/$ver" ]; then
	echo "#VAR"
	echo "No \$BUILD_ROOT/../../eesdev/aps/$ver find."
	exit 3
fi

cd $BUILD_ROOT/../../eesdev/aps/$ver 2> /dev/null
if [ ! -d "latest" ]; then
	echo "#VAR"
	echo "No \$BUILD_ROOT/../../eesdev/aps/$ver/latest find."
	exit 3
fi
cd latest 2> /dev/null
if [ ! -f "bldnum.txt" ]; then
	echo "#VAR"
	echo "No \$BUILD_ROOT/../../eesdev/aps/$ver/latest/bldnum.txt find."
	exit 3
fi

bld=`cat bldnum.txt | tr -d '\r'`
echo $bld
exit 0
