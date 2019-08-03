#!/usr/bin/ksh
# mk_difrec.sh <ver> <bld> <plat> <abv> <ctdif file>
# <ver>_<bld>_<plat>_<test_abv>.rec in $AUTOPILOT/dif
# $1     $2    $3     $4
# <ctdif file> will be created in current directory

# HISTORY
# 05/18/2010 YKono - Change method to get bld number.
#                    Correspond a version name which uses "_".
#                    like talleyrand_sp1.
# 07/22/2010 YKono - Change rec file name separated by "~" and
#                    Change version/build recognization method.
# 07/22/2010 YKono - Put dif record into ../dfl/${version}.dfl file.
# 08/25/2010 YKono - Put date into the description area when
#                    it is first appearance.

# edit_dif <difname> <script list>
edit_dif() {
	unset bld desc comm
	[ -n "$2" ] && comm=" $2"
	if [ -f "$fname" ]; then
		fnd=`grep "$1" "$fname" | tail -1`
		if [ -n "$fnd" ]; then
			# found previous record for this dif and get previous record.
			[ "${fnd#*#}" != "$fnd" ] && comm=${fnd#*#}
			bld=${fname#${thisver}[_~]}
			bld=${bld%%[_~]*}
			desc=`echo ${fnd%#*} | awk '{print $2}'`
		fi
	fi
	[ -n "$comm" ] && comm="	#$comm"
# echo "dif=$1, bld=<$bld>, desc=<$desc>, comm=<$comm>"
	if [ -n "$desc" ]; then
		if [ "${desc%\(*}" = "$desc" ]; then
			# No build description -> That time is first dif and this time is second.
			echo "$1	$desc($bld)$comm" >> "$output"
			echo "$1,$desc,$bld,2,$2" >> "$ctdif"
			echo "$thisbld~$thisplt~$thisabv~$1~(${bld}:2)~$2" >> ../dfl/${thisver}.dfl
		else
			# There is build description, braces, XXX(###:nn)
			tmp=${desc#*\(}
			tmp=${tmp%\)*}
			bld=${tmp%:*}
			ccnt=${tmp#*:}
			[ "$ccnt" = "$tmp" ] && ccnt=2
			let ccnt="$ccnt + 1"
			echo "$1	${desc%\(*}(${bld}:${ccnt})$comm" >> "$output"
			echo "$1,${desc%\(*},${bld},${ccnt},$2" >> "$ctdif"
			echo "$thisbld~$thisplt~$thisabv~$1~(${bld}:${ccnt})~$2" >> ../dfl/${thisver}.dfl
		fi
	else
		if [ -n "$bld" ]; then
			echo "$1	`date +$D`($bld)$comm" >> "$output"
			echo "$thisbld~$thisplt~$thisabv~$1~($bld:2)~$2" >> ../dfl/${thisver}.dfl
			echo "$1,`date +%Di`,${bld},2,$2" >> "$ctdif"
		else
			echo "$1	`date +%D`$comm" >> "$output"
			echo "$thisbld~$thisplt~$thisabv~$1~($thisbld:1)~$2" >> ../dfl/${thisver}.dfl
			echo "$1,`date +%D`,${thisbld},1,$2" >> "$ctdif"
		fi
	fi
	# First dif:
	# <difname>     <date>	# script list
	# Second dif:
	# <difname>  <date or desc>(bld#)   # script list
	# Third or more dif:
	# <difname>   <date or desc>(bld#:cc#)  # script list
}

thisver=$1
thisbld=$2
thisplt=$3
thisabv=$4

if [ $thisbld -lt 100 ]; then
	thisbld="000$thisbld"
	thisbld=${thisbld#${thisbld%???}}
fi
output="${thisver}~${thisbld}~${thisplt}~${thisabv}.rec"

ctdif="`pwd`/$5"
cd $AUTOPILOT/dif
rm -f "$output" > /dev/null 2>&1
rm -f "$ctdif" > /dev/null 2>&1
# Get latest record file name
reclist=`ls ${1}[_~]*[_~]${3}[_~]${4}.rec 2> /dev/null | sed -e "s/~/_/g" | sort`
fname=
for one in $reclist; do
	tarbld=${one#${thisver}[_~]}
	tarbld=${tarbld%%[_~]*}
	if [ "$thisbld" -le "$tarbld" ]; then
		break
	else
		fname=$tarbld
	fi
done
fname=`ls ${1}[_~]${fname}[_~]${3}[_~]${4}.rec 2> /dev/null`
# echo "fname=$fname"
[ -f "$output" ] && rm -rf "$output"
touch $output
while read line shdata; do
	if [ "${line%${line#?}}" != "#" ]; then
		edit_dif $line "$shdata"
	fi
done
