#!/usr/bin/ksh
#
# chktsk.sh : Check task condition for specific plat/ver/bld.
#
# Syntax:
#	chktsk.sh [<node>|<plat>] <ver><bld>
# Parameter:
#	<ver>  : Version number
#	<bld>  : Build number
#	<node> : Node name
#	<plat> : Platform name
#
# History:
# 08/06/2010 YKono First edition.

. apinc.sh

# Default values
host=`hostname`
usr=$LOGNAME
[ "$AP_NOPLAT" != "true" ] \
	&& plat=`get_platform.sh -l` \
	|| plat="${usr}@${host}"
unset ver bld
# Read parameter

while [ "$#" -gt 0 ]; do
	case $1 in
		*@*)	plat=$1;;
		`isplat $1`) plat=$1;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			elif [ -z "$bld" ]; then
				bld=$1
			else
				echo "chktsk.sh [ <plat> ] <ver> <bld>"
				exit 1
			fi
			;;
	esac
	shift
done

# Check parameter error
if [ -z "$ver" -o -z "$bld" ]; then
	echo "chktsk.sh [ <plat> ] <ver> <bld>"
	exit 1
fi

if [ ! -d "$AUTOPILOT/../$ver/essbase" ]; then
	echo "The result folder for $ver is not found in \$AUTOPILOT/.."
	exit 1
fi

echo "plat=$plat, ver=$ver, bld=$bld"
cd $AUTOPILOT/../$ver/essbase
rtfcnt=0
echo "RTF File:"
ls ${plat}_*${bld}* > ${usr}~${host}~chktsk.tmp 2> /dev/null
while read one; do
	echo "    $one"
	let rtfcnt=rtfcnt+1
done < ${usr}~${host}~chktsk.tmp
rm -f ${usr}~${host}~chktsk.tmp

echo "Done Task:"
lstsk.pl opt -ap done ${plat} ${ver} ${bld} > "${usr}~${host}~chktsk.tmp"
donecnt=0
while read one; do
	echo $one | awk -F\| '{print "    " $3 "/" $6 " # " $7 " " $8 " " $9 " " $10}'
	let donecnt=donecnt+1
done < "${usr}~${host}~chktsk.tmp"
rm -f ${usr}~${host}~chktsk.tmp

echo "Running Task:"
lstsk.pl opt -ap crr ${plat} ${ver} ${bld} > "${usr}~${host}~chktsk.tmp"
crrcnt=0
while read one; do
	echo $one | awk -F\| '{print "    " $3 "/" $6 " # " $7 " " $8}'
	let crrcnt=crrcnt+1
done < "${usr}~${host}~chktsk.tmp"
rm -f ${usr}~${host}~chktsk.tmp

echo "Waiting Task:"
lstsk.pl opt -ap ${plat} ${ver} ${bld} > "${usr}~${host}~chktsk.tmp"
tskcnt=0
while read one; do
	echo $one | awk -F\| '{print "    " $4 "/" $7}'
	let tskcnt=tskcnt+1
done < "${usr}~${host}~chktsk.tmp"
rm -f ${usr}~${host}~chktsk.tmp

echo "RTF $rtfcnt, Done $donecnt, Runnning task $crrcnt, Waiting task $tskcnt"
