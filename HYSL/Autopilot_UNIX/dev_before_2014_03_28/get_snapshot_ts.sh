#!/usr/bin/ksh
# get_snapshot_ts.sh : Get snapshot update time
# Description: Get latest update time of current snapshot
# Synxtax:
#   $ get_snapshot_ts.sh
# History:
# 2013/01/17	YKono	First edition
#			Bug 16187011 - RTF FILE DISPLAY WRONG TIME STAMP FOR THE SNAPSHOT.

[ `uname` = "Windows_NT" ] && updext="UPD" || updext="updt"
updt_ts=`ls $SXR_HOME/../../../*.${updext} 2> /dev/null`
if [ -z "$updt_ts" ]; then
	echo "Dynamic View"
else
	cd $SXR_HOME/../../.. 2> /dev/null
	grep "^StartTime:" *.${updext} | while read dmy one; do
		if [ "$one" = "${one#*.}" ]; then
			echo ${one%?} | sed -e "s/T/ /g"
		else
			one=`echo $one | sed -e "s/\./ /g" -e "s/\-/ /g" \
				-e "s/Jan/01/g" \
				-e "s/Feb/02/g" \
				-e "s/Mar/03/g" \
				-e "s/Apr/04/g" \
				-e "s/May/05/g" \
				-e "s/Jun/06/g" \
				-e "s/Jul/07/g" \
				-e "s/Aug/08/g" \
				-e "s/Sep/09/g" \
				-e "s/Oct/10/g" \
				-e "s/Nov/11/g" \
				-e "s/Dec/12/g"`
			d=`echo $one | awk '{print $1}'`
			m=`echo $one | awk '{print $2}'`
			y=`echo $one | awk '{print $3}'`
			t=`echo $one | awk '{print $4}'`
			let y=y+2000
			echo "$y-$m-${d} $t"
		fi
	done | sort | tail -1
fi

