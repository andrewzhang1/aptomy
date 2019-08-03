#!/usr/bin/ksh
# crr.sh : Display current status
# Syntax: crr.sh [<test-name>|-l|-h|-w <wait>|-v <view>]
# Options:
#   <test-name> : test name
#   -h          : Display help
#   -l          : Display long format
#   -w <wait>   : Wait time in sec
#   -v <view>   : SXR view name
# History:
# 2012/02/23	YKono	First edition.

me=$0
orgpar=$@
dbg=true
view=autoregress
scr=
vlong=false
wt=15
while [ $# -ne 0 ]; do
	case $1 in
		-l)
			vlong=true
			;;
		-h)
			display_help.sh $me
			exit 0
			;;
		-w)
			if [ $# -lt 2 ]; then
				echo "${me##*/}: $1 need second parameter."
				exit 1
			fi
			shift
			wt=$1
			;;
		-v)
			if [ $# -lt 2 ]; then
				echo "${me##*/}: $1 need second parameter."
				exit 1
			fi
			shift
			view=$1
			;;
		*)
			scr=$1
			;;
	esac
	shift
done

if [ -z "$VIEW_PATH" ]; then
	vp=$HOME/views
else
	vp=$VIEW_PATH
fi

while [ -z "$scr" ]; do
	scr=`ls -l $vp/$view/work/*.sog 2> /dev/null | while read d1 d2 d3 d4 sz d6 d7 d8 fn; do
		sz="00000000$sz"
		sz=${sz#${sz%????????}}
		echo "$sz $fn"
	done | sort | tail -1`
	if [ -n "$scr" ]; then
		scr=${scr##*/}
		scr=${scr%.*}
	else
		echo "Failed to get .sog file from $vp/$view/work."
		echo "Will try again after $wt seconds."
		sleep $wt
	fi
done

tst=`cat $vp/$view/work/$scr.sog 2> /dev/null | grep "^+ sxr shell" | head -1`
if [ -z "$tst" ]; then
	tst=$scr
else
	tst=${tst#+ sxr shell }
fi

if [ "$dbg" = "true" ]; then
	echo "view path=$vp"
	echo "view     =$view"
	echo "test bas =$scr"
	echo "test cmd =$tst"
	echo "long disp=$vlong"
	echo "wait cnt =$wt"
fi

psuc=
pdif=
pcrr=
pdifs=$HOME/.crr.pdif.tmp
cdifs=$HOME/.crr.cdif.tmp
rm -f $pdifs 2> /dev/null
rm -f $cdifs 2> /dev/null
sta=$vp/$view/work/$scr.sta
trap 'rm -f $pdifs 2> /dev/null; rm -f $cdifs 2>/dev/null; exit' 2
while [ 1 ]; do
	suc=`ls $vp/$view/work/*.suc 2> /dev/null | wc -l`
	dif=`ls $vp/$view/work/*.dif 2> /dev/null | wc -l`
	let suc=suc
	let dif=dif
	ls $vp/$view/work/*.dif 2> /dev/null | sort > $cdifs
	crr=`cat "$sta" 2> /dev/null | grep "^+" | tail -1 2> /dev/null`
	if [ "$pcrr" != "$crr" -o "$psuc" != "$suc" -o "$pdif" != "$dif" ]; then
		dl=
		if [ "$pdif" != "$dif" ]; then
			if [ -f "$pdifs" ]; then
				dfs=`diff $pdifs $cdifs 2> /dev/null`
			else
				dfs=`cat $cdifs 2> /dev/null`
			fi
			for one in $dfs; do
				one=${one##* }
				one=${one##*/}
				dl="$dl $one"
			done
			cp $cdifs $pdifs
		fi
		if [ "$vlong" = "true" ]; then
			echo "`date +%D_%T` view($view) test($tst) ====================="
			echo "$crr"
			echo "Suc $suc, Dif $dif$dl"
		else
			echo "`date +%D_%T` ${view} ${tst} $suc/$dif ($crr)$dl"
		fi
		pcrr=$crr
		psuc=$suc
		pdif=$dif
	fi
	sleep $wt
done

