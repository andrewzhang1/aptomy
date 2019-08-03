#!/usr/bin/ksh

if [ -z "$1" ]; then
	tartst="dxmdmainaso.sh"
else
	tartst=$1
fi
tarsub=$2
if [ -z "$3" ]; then
	tarplt="winamd64"
else
	tarplt=$3
fi

if [ -z "$4" ]; then
	chkvers="11.1.1.3.500 talleyrand_sp1 11.1.2.1.102 11.1.2.1.000_12417382"
else
	chkvers=$4
fi

echo "# TEST:$tartst"
echo "# SUB :$tarsub"
echo "# PLAT:$tarplt"
echo "# VERS:$chkvers"

tmp1=~/timespent.$$.1.tmp
tmp2=~/timespent.$$.2.tmp

for ver in $chkvers; do
	cd $AUTOPILOT/../$ver/essbase
	rm -rf $tmp1 > /dev/null 2>&1
	grep -n "$tartst" ${tarplt}*${tarsub}*.rtf | grep "Elapsed" > $tmp1
	cat $tmp1 | while read d1 d2 d3 d4 d5 elap d7; do
		fn=${d1%%:*}
		mc=`grep "^Machine:" $fn | awk '{print $2}'`
		if [ -z "$mc" ]; then
			mc=`grep "CHECKING REGRESSION RESULTS FROM" $fn | awk '{print $5}' | sed -e "s///g"`
			
		else
			mc=${mc%%:*}
			dt=`grep "^Start Time:" $fn | awk '{print $3"_" $4}' | sed -e "s///g"`
			m=${dt%${dt#??}}
			dt=${dt#???}
			d=${dt%${dt#??}}
			dt=${dt#???}
			y=${dt%${dt#??}}
			dt=${dt#???}
			dt="20${y}${m}${d}_${dt}"
			vb=`grep "^Version:" $fn | awk '{print $2}' | sed -e "s///g"`
			us=`grep "^Login User:" $fn | awk '{print $3}' | sed -e "s///g"`
		fi
		echo "$dt $mc $vb $elap"
	done
done

