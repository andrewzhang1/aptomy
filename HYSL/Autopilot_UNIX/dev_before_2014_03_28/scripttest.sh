#!/usr/bin/ksh

export tagstr=

if [ -z "$ARBORPATH" ]; then
	echo "Please define ARBORPATH."
	exit 1
fi
if [ -z "$SXR_VIEWHOME" ]; then
	echo "Please execute \"sxr goview <view>\" command."
	exit 2
fi

if [ ! -d "$SXR_VIEWHOME/mod" ]; then
	mkdir $SXR_VIEWHOME/mod
	if [ $? -ne 0 ]; then
		echo "Failed to create $SXR_VIEWHOME/mod folder."
		echo "Please check $SXR_VIEWHOME is writable."
		exit 3
	fi
fi

onetest()
{
(
	one=$1
	tst=`echo $one | sed -e "s!+! !g"`
	scr=${tst%% *}
	if [ ! -f "$SXR_BASE/sh/$scr" -a ! -f "$SXR_VIEWHOME/sh/$scr" ]; then
		echo "`date +%D_%T`:Missing $scr."
		continue
	fi
	if [ "${scr%.pl}" != "$scr" ]; then
		echo "`date +%D_%T`:Target seems to be perl script($scr). Skip this."
		contine
	fi
	if [ -f "$SXR_VIEWHOME/mod/$scr" ]; then
		echo "`date +%D_%T`:$scr already in mod folder. Skip this test."
		continue
	fi
	echo "`date +%D_%T`:Initialize Essbase."
	ap_essinit.sh -force > /dev/null 2>&1
	rm -rf $SXR_VIEWHOME/$one.log 2> /dev/null
	rm -rf $HOME/stop.req 2> /dev/null
	rm -rf $SXR_VIEWHOME/$one.mon 2> /dev/null
	rm -rf $SXR_VIEWHOME/$one.res 2> /dev/null
	monitor.sh -w 10 -l $SXR_VIEWHOME/$one.mon -r $SXR_VIEWHOME/$one.res > /dev/null 2>&1 < /dev/null &
	mps=$!
	echo "`date +%D_%T`:monitor.sh start as $mps."
	echo "`date +%D_%T`:Start \"$tst\" test."
	st=`date +%D_%T`
	stsec=`perl -e 'print time;'`
	sxr agtctl start
	sxr sh $tst > $SXR_VIEWHOME/$one.log 2>&1
	edsec=`perl -e 'print time;'`
	ed=`date +%D_%T`
	echo a > $HOME/stop.req
	i=60
	while [ $i -ne 0 ]; do
		mexist=`ps -p $mps 2> /dev/null | grep -v PID`
		[ -z "$mexist" ] && break
		let i=i-1
		sleep 1
	done
	echo "`date +%D_%T`:Analyze resource usages and time($i)."
	ures=`tail -1 "$SXR_VIEWHOME/${one}.res" 2> /dev/null`
	umon=`tail -1 "$SXR_VIEWHOME/${one}.mon" 2> /dev/null`
	suc=`ls $SXR_VIEWHOME/work/*.suc 2> /dev/null | wc -l`
	dif=`ls $SXR_VIEWHOME/work/*.dif 2> /dev/null | wc -l`
	let suc=suc
	let dif=dif
	let ttlcnt=suc+dif
	let ttlsec=edsec-stsec
	let ttlmin=ttlsec+30
	let ttlmin=ttlmin/60
	src=
	if [ -f "$SXR_VIEWHOME/sh/$scr" ]; then
		src=$SXR_VIEWHOME/sh/$scr
	elif [ -f "$SXR_BASE/sh/$scr" ]; then
		src=$SXR_BASE/sh/$scr
	fi
	IFS=
	t=`head -1 $src 2> /dev/null | grep "^#!"`
	[ -n "$t" ] && head -1 $src > $SXR_VIEWHOME/mod/$scr
	echo "#: Authors:" >> $SXR_VIEWHOME/mod/$scr
	echo "#: Reviewers:" >> $SXR_VIEWHOME/mod/$scr
	echo "#: Date:" >> $SXR_VIEWHOME/mod/$scr
	echo "#: Purpose:" >> $SXR_VIEWHOME/mod/$scr
	echo "#: Owned by:" >> $SXR_VIEWHOME/mod/$scr
	echo "#: Tag:${tagstr}" >> $SXR_VIEWHOME/mod/$scr
	echo "#: Dependencies:" >> $SXR_VIEWHOME/mod/$scr
	echo "#: Runnable:" >> $SXR_VIEWHOME/mod/$scr
	echo "#: Arguments:" >> $SXR_VIEWHOME/mod/$scr

	mem=`echo $ures | awk '{print $1}'`
	ttl=`echo $ures | awk '{print $4}'`
	mem=${mem#mem=}; mem=${mem%(*}
	ttl=${ttl#ttl=}; ttl=${ttl%(*}
	echo "#: Memory/Disk: $mem/$ttl" >> $SXR_VIEWHOME/mod/$scr
	echo "#: Execution Times(Minutes): $ttlmin" >> $SXR_VIEWHOME/mod/$scr
	if [ -f "$SXR_VIEWHOME/machinfo.txt" ]; then
		lc=`cat $SXR_VIEWHOME/machinfo.txt | wc -l`
		if [ $lc -eq 1 ]; then
			lc=`head -1 $SXR_VIEWHOME/machinfo.txt`
			echoo "#: Machine for Statistics: $lc" >> $SXR_VIEWHOME/mod/$scr
		else
			echo "#: Machine for Statistics:" >> $SXR_VIEWHOME/mod/$scr
			cat $SXR_VIEWHOME/machinfo.txt | while read l; do echo "#:    $l" >> $SXR_VIEWHOME/mod/$scr; done
		fi
	else
		echo "#: Machine for Statistics: $(hostname) $(get_platform.sh -d)" >> $SXR_VIEWHOME/mod/$scr
	fi
	echo "#: SUC: $ttlcnt" >> $SXR_VIEWHOME/mod/$scr
	echo "#: Created for:" >> $SXR_VIEWHOME/mod/$scr
	echo "#: Retired for:" >> $SXR_VIEWHOME/mod/$scr
	echo "#: Test cases:" >> $SXR_VIEWHOME/mod/$scr
	echo "#: History:" >> $SXR_VIEWHOME/mod/$scr
	echo "# =Exec detail============================================" >> $SXR_VIEWHOME/mod/$scr
	echo "# Test            : $tst" >> $SXR_VIEWHOME/mod/$scr
	echo "# Machine         : $(hostname) $(get_platform.sh -d)" >> $SXR_VIEWHOME/mod/$scr
	echo "# Version/BUild   : $(get_ess_ver.sh)" >> $SXR_VIEWHOME/mod/$scr
	echo "# Start timestamp : $st($stsec)" >> $SXR_VIEWHOME/mod/$scr
	echo "# End timestamp   : $ed($edsec)" >> $SXR_VIEWHOME/mod/$scr
	echo "# Elapsed time    : $ttlmin min($ttlsec sec)" >> $SXR_VIEWHOME/mod/$scr
	echo "# Status files #  : Suc:$suc, Dif:$dif, Total:$ttlcnt" >> $SXR_VIEWHOME/mod/$scr
	echo "# Usage           : " >> $SXR_VIEWHOME/mod/$scr
	echo "#          Memory : $(echo $ures | awk '{print $1}') $(echo $umon | awk '{print $6}')" >> $SXR_VIEWHOME/mod/$scr
	echo "#   ARBORPATH/app : $(echo $ures | awk '{print $2}') $(echo $umon | awk '{print $7}')" >> $SXR_VIEWHOME/mod/$scr
	echo "#    SXR_VIEWHOME : $(echo $ures | awk '{print $3}') $(echo $umon | awk '{print $8}')" >> $SXR_VIEWHOME/mod/$scr
	echo "#      Disk total : $(echo $ures | awk '{print $4}') $(echo $umon | awk '{print $9}')" >> $SXR_VIEWHOME/mod/$scr
	echo "# ========================================================" >> $SXR_VIEWHOME/mod/$scr
	# cat $src | while read -r line; do
	# 	if [ -n "$t" ]; then
	# 		unset t
	# 	else
	# 		echo $line
	# 	fi
	# done >> $SXR_VIEWHOME/mod/$scr
	cat $src >> $SXR_VIEWHOME/mod/$scr
	echo "`date +%D_%T`:$SXR_VIEWHOME/mod/$scr created."
)
}

testlist=
if [ $# -ne 0 ]; then
	while [ $# -ne 0 ]; do
		case $1 in
			-t)
				if [ $# -lt 2 ]; then
					echo "Please define second parameter for -t(tag) definition."
					exit 1
				fi
				shift
				export tagstr=" $1"
				;;
			*)
				[ -z "$testlist" ] && testlist=$1 || testlist="$testlist $1"
				;;
		esac
		shift
	done
fi
if [ -n "$testlist" ]; then
	for one in $testlist; do
		onetest $one
	done
else
	while read ans; do
		if [ "$ans" = "quit" -o -z "$ans" ]; then
			break
		fi
		onetest $ans
	done
fi

