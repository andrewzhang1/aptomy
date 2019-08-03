#!/usr/bin/ksh
# keepnth.sh : Remove older files
# Syntax:   keepnth.sh <pattern> [ <remcnt> ]
# 	<pattern> : ls pattern for deleting files. i.e. kennedy_*.txt
# 	<remcnt>  : The count for remained files. (Default 10)

if [ $# -lt 1 ]; then
	echo "keepnth.sh : Parameter error."
	echo "keepnth.sh <pattern> [ <remcnt> ]"
	echo " <pattern> : ls pattern for remove."
	echo " <remcnt>  : remain count."
	exit 1
fi
if [ $# -eq 2 ]; then
	let rcnt=`echo $2`
else
	rcnt=10
fi

# echo "`date +%D_%T` ${LOGNAME}@`hostname` CRRDIR=`pwd` ARGS=$@ RCNT=$rcnt" # >> $AUTOPILOT/tst/keepnth.log

_path="${1%/*}"
_ptn="${1##*/}"
[ "$_path" = "$1" ] && _path="."
cnt=`find $_path -name "$_ptn" 2> /dev/null | wc -l`
let cnt="$cnt - $rcnt"
if [ $cnt -gt 0 ]; then
	find $_path -name "$_ptn" 2> /dev/null | sort | head -${cnt} | while read fn; do
		rm -rf $fn > /dev/null 2>&1
		# echo "`date +%D_%T` $fn" # >> $AUTOPILOT/tst/keepnth.log
	done
fi
exit 0
