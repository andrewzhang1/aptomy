#!/usr/bin/ksh

# LckF=<lock file name>
# LogF=<log file name>
# StsF=<status output file>

# History:
# 07/21/2010 YK First edition.

. apinc.sh

node="${LOGNAME}@`hostname`"
lckf="$AUTOPILOT/lck/${node}.runbg.$$"
logf="$AUTOPILOT/mon/${node}.runbg.$$.log"
stsf=
locf="$HOME/runbg.$$.cmd"
[ -f "$logf" ] && rm -f "$logf" 2> /dev/null
if [ $# -ne 1 ]; then
	echo "No script parameter."
	exit 1
fi
if [ ! -f "$1" ]; then
	echo "Couldn't find $1."
	exit 2
fi
sts=0
alckf=`egrep -i "^#[ 	]*LckF=" "$1"`
if [ -n "$alckf" ]; then
	alckf=${alckf#*=}
	[ ! "$alckf" = "${alckf#*\$}" ] && alckf=`eval echo "$alckf"`
	dtmp=`dirname $alckf`
	[ -d "$dtmp" ] && lckf=$alckf
fi
alogf=`egrep -i "^#[ 	]*LogF=" "$1"`
if [ -n "$alogf" ]; then
	alogf=${alogf#*=}
	[ ! "$alogf" = "${alogf#*\$}" ] && alogf=`eval echo "$alogf"`
	dtmp=`dirname $alogf`
	[ -d "$dtmp" ] && logf=$alogf
fi
astsf=`egrep -i "^#[ 	]*StsF=" "$1"`
if [ -n "$alogf" ]; then
	astsf=${astsf#*=}
	[ ! "$astsf" = "${astsf#*\$}" ] && astsf=`eval echo "$astsf"`
	dtmp=`dirname $astsf`
	[ -d "$dtmp" ] && stsf=$astsf
fi
rm -rf "$stsf" > /dev/null 2>&1
lock.sh "$lckf" $$ > /dev/null
if [ $? -ne 0 ]; then
	echo "Lock failed for runbg.sh($?)." >> $logf
	if [ -f "$lckf.lck" ]; then
		cat "$lckf.lck" | while read line; do
			echo "> $line" >> $logf
		done
	fi
	sts=3
	rm -f "$1" 2> /dev/null
else
	cp "$1" "$locf"
	rm -f "$1" 2> /dev/null
	chmod +x "$locf"
	"$locf" > "$logf" 2>&1
	sts=$?
	rm -rf "$locf" 2> /dev/null
fi
if [ -n "$stsf" ]; then
	echo "$sts" > $stsf
else
	echo "\$sts=$sts" >> "$logf"
fi
exit $sts
