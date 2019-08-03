#!/usr/bin/ksh

platlist="hhashimo@staix12"
platlist="$platlist ykono@staix12"
# platlist="$platlist ykono@sthp16"
# platlist="$platlist ykono@stiahp3"
platlist="$platlist hhashimo@issol13"
platlist="$platlist ykono@issol13"

if [ $# -lt 2 ]; then
	echo "Please define <ver> and <bld> number."
	echo "runi18n.sh <ver> <bld> [ <opt>...]"
	exit 1
fi

ret=`normbld.sh $1 $2`
sts=$?
if [ $sts -ne 0 ]; then
	echo "normbld.sh return an error for $1, $2."
	echo "$ret"
	exit 2
fi

ver=$1
bld=$2
shift
shift

for one in $platlist; do
	addtsk.sh -f i18n.tsk $one $ver $bld $@
done

