#!/usr/bin/ksh
# rerun.sh : Rerun specific test
# Description:
#   This command run the listed tests and send e-mail notificaiton
#   You need goview before run this command.
#   This script do following for each test:
#   1) ap_essinit.sh (kill all Essbase realted processes)
#   2) If test need regress_mode.sh, do sxr sh regress-mode.sh <mode>
#      The test name start with "sb:", "sd:", "pb:" and "pd:"
#   3) sxr agtctl start
#   4) sxr sh <target test>
#   5) sxr agtctl start
#   6) kill_essprocs.sh -all
#   7) Send e-mail notification.
#   8) Copy work contents to work_$(basename <test>)
# Syntax:
#   $ cat <list> | rerun.sh
#   $ rerun.sh [-h|m:<mail>] [##:]<test> [[##:]<test>...]
# Option:
#   -h       : Display this.
#   m:<addr> : Send result e-mail to this address.
#              When you skip this, it send to current login
#              accout.
#   ##:<test>: Repeat count.
#   <test>   : Test script.(If target test take some parameter, please
#                           use double quote or usr + between parameter.
# Sample:
#   $ rerun.sh m:yukio.kono@oracle.com sb:Apotcotl.sh pd:ddxi2gigcon.sh dxbg1296.sh
# 
# History:

#if [ -z "$SXR_VIEWHOME" ]; then
#	echo "Please execute \"sxr goview <view>\" command."
#	exit 1
#fi
me=$0
orgpar=$@
ver=
bld=
lst=
opt=
[ -n "$AP_RERUNMAIL" ] && ad="$AP_RERUNMAIL" || ad=${LOGNAME}
plt=`get_platform.sh`
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			exit 0
			;;
		opt:*|opt=*)
			opt=${1#opt?}
			;;
		ver:*|ver=*)
			ver=${1#ver?}
			;;
		m:*)
			ad=${1#??}
			;;
		*)
			[ -z "$lst" ] && lst=`echo $1 | sed -e s/\ /+/g` || lst="$lst `echo $1 | sed -e s/\ /+/g`"
			;;
	esac
	shift
done

go=true
if [ -z "$lst" ]; then
	echo "Please enter test names then \"go\" or \"exit\" command."
	while [ 1 ] ; do
		read ans
		case $ans in
			ver:*|ver=*)
				ver=${ans#ver?}
				;;
			opt:*|opt=*)
				opt=${ans#opt?}
				;;
			go|g)
				go=true
				break
				;;
			exit|quit|x|q)
				go=false
				break
				;;
			list|l)
				if [ -n "$lst" ]; then
					i=1
					echo "Current selection:"
					for one in $lst; do
						echo "  $i:$one"
						let i=i+1
					done

				else
					echo "There is no script selected."
				fi
				;;
			-h|?|help)
				echo "Please enter test script name or below commands."
				echo "(g)o, e(x)it, (l)ist, ver:###, opt:###, m:<mail-addr>"
				;;
			m:*)
				ad=${ans#??}
				;;
			*)
				[ -z "$lst" ] && lst=`echo $ans | sed -e s/\ /+/g` || lst="$lst `echo $ans | sed -e s/\ /+/g`"
				;;
		esac
	done
fi

[ "$go" = "false" ] && exit 0

if [ -z "$lst" ]; then
	echo "${me##*/}:No test entered."
	exit 1
fi

if [ -z "$HYPERION_HOME" ]; then
	if [ -z "$ver" ]; then
		echo "${me##*/}:No version entered."
		exit 1
	fi
	. se.sh $opt $ver
fi

if [ -z "$SXR_INVIEW" ]; then
	cd $VIEW_PATH
	if [ ! -d "rerun" ]; then
		sxr newview rerun
	fi
	sxr goview rerun
	sts=$?
	if [ $sts -ne 0 ]; then
		echo "${me##*/}:Failed to goview($sts)."
		exit 1
	fi
fi
if [ -z "$ver" -o -z "$bld" ]; then
	vb=`get_ess_ver.sh`
	ver=${vb%:*}
	bld=${vb#*:}
fi

export AP_RESETCFG=true

to=900
for one in $lst; do

case $one in
	to:*|timeout:*|hu:*|hangup:*)
		to=${one#*:}
		continue
		;;
	to=*|timeout=*|hu=*|hangup=*)
		to=${one#*=}
		continue
		;;
esac

if [ `echo $one | grep "^[0-9][0-9]*:"` ]; then
	icnt=${one%%:*}
	one=${one#*:}
else
	icnt=1
fi
ap_essinit.sh -force
case $one in
	sb:*) sxr sh regress_mode.sh serial buffer ; md="sb:"; mode="serial buffer"; one=${one#???} ;;
	sd:*) sxr sh regress_mode.sh serial direct ; md="sd:"; mode="serial direct"; one=${one#???} ;;
	pb:*) sxr sh regress_mode.sh parallebuffer ; md="pb:"; mode="parallel buffer"; one=${one#???} ;;
	pd:*) sxr sh regress_mode.sh parallel direct ; md="pd:"; mode="parallel direct"; one=${one#???} ;;
	*) md=; mode=;;
esac
i=1
one=`echo $one | sed -e s/+/\ /g`
sog="${one%.*}.sog"
while [ $i -le $icnt ]; do
	[ $icnt -gt 1 ] && cntmsg="$i/$icnt " || cntmsg=
	(
	for dir in bin csc data log msh scr rep sh; do
		rm -rf $dir/*
	done
	prevline=0
	sxr agtctl start
	sxr sh $one > /dev/null 2>&1 &
	tpid=$!
	unset prevzero
	while [ -n "`ps -p $tpid | grep -v PID`" ]; do
		crrline=`cat $SXR_WORK/$sog 2> /dev/null | wc -l`
		if [ "$prevline" = "0" ]; then
			cat $SXR_WORK/$sog 2> /dev/null
			prevline=$crrline
			n=$crrline
		else
			let n=crrline-prevline
			if [ "$n" -ne "0" ]; then
				tail -${n} $SXR_WORK/$sog 2> /dev/null
				prevline=$crrline
			fi
		fi
		if [ "$n" -eq "0" ]; then
			crrsec=`perl -e 'print time;'`
			if [ -n "$prevzero" ]; then
				let diftime=crrsec-prevzero
				if [ "$diftime" -gt "$to" ]; then 
					echo "### Output has not been updated about $to sec." | tee -a $SXR_WORK/killed.txt
					echo "### Kill test processs($tpid)." | tee -a $SXR_WORK/killed.txt
					pstree.sh -kill $tpid | while read line; do
						echo "###   $line" | tee -a $SXR_WORK/killed.txt
					done
					break
				fi
			else
				prevzero=`perl -e 'print time;'`
			fi
		else
			unset prevzero
		fi
	done
	sxr agtctl stop
	cd $SXR_WORK
	dif=`ls *.dif 2> /dev/null | wc -l`
	suc=`ls *.suc 2> /dev/null | wc -l`
	let dif=dif
	let suc=suc
	tmpf=$SXR_VIEWHOME/rerun.tmp
	rm -rf $tmpf > /dev/null 2>&1
	if [ -f "$SXR_WORK/killed.txt" ]; then
		echo "Killed ${cntmsg}rerunning of $one on ${LOGNAME}@$(hostname)($plt) with $ver:$bld." >> $tmpf
	else
		if [ -z "$mode" ]; then
			echo "Done ${cntmsg}rerunning of $one on ${LOGNAME}@$(hostname)($plt) with $ver:$bld." >> $tmpf
		else
			echo "Done ${cntmsg}rerunning of $one with $mode on ${LOGNAME}@$(hostname)($plt) with $ver:$bld." >> $tmpf
		fi
	fi
	echo "Command:sxr sh $one" >> $tmpf
	echo "Machine:${LOGNAME}@$(hostname)($plt)" >> $tmpf
	tail ${one%%.*}.sta >> $tmpf 2> /dev/null
	echo "" >> $tmpf 2> /dev/null
	if [ -f "$ARBORPATH/bin/essbase.cfg" ]; then
		(IFS=
		echo "# essbase.cfg after execution"
		cat $ARBORPATH/bin/essbase.cfg | while read line; do
			echo "    $line"
		done
		) >> $tmpf
	else
		echo "# There is no essbase.cfg file after execution."
	fi
	echo "# Essbase status = `sxr agtctl status`" >> $tmpf
	if [ "$dif" -ne 0 ]; then
		(
		echo ""
		echo "Diff informaiotn:======================"
		ls *.dif 2> /dev/null
		echo ""
		echo "Each diff contetns:===================="
		ls *.dif 2> /dev/null | while read df; do
			echo "$df:"
			(IFS=
			cat $df | while read line; do
				echo "	$line"
			done
			)
		done
		) >> $tmpf
		i=$icnt
	fi
	if [ -f "$SXR_WORK/killed.txt" ]; then
		echo "Killed record:=========================" >> $tmpf
		cat $SXR_WORK/killed.txt >> $tmpf
		rm -rf $SXR_WORK/killed.txt
	fi
	cd $SXR_VIEWHOME
	echo "Views contents after rerun ===================" >> $tmpf
	for dir in bin csc data log msh scr rep sh; do
		echo "$dir:" >> $tmpf
		ls $one >> $tmpff
	done
	send_email.sh noap \
		"to:$ad" "sbj:Rerun ${cntmsg}-${ver}:${bld} ${md}${one}($suc/$dif) - $(hostname)($plt)." \
		"ne:$tmpf"
	rm -rf $tmpf 2> /dev/null
	kill_essprocs.sh -all
	[ -n "$mode" ] && bk="${one%.*}_${md%?}" || bk=${one%.*}
	echo "Make work back up(work_$bk)."
	rm -rf work_$bk 2> /dev/null
	mkdir work_$bk 2> /dev/null
	cp -Rp work/* work_$bk 2> /dev/null
	) 2>&1 | while read oneline; do
		echo "${cntmsg}${one%.*}: $oneline"
	done
	let i=i+1
done

done
		

