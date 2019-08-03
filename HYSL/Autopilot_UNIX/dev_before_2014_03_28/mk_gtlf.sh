#!/usr/bin/ksh
# mk_gtlf.sh : extract compressed result file.
# Syntax:
#   mk_gtlf.sh [<plat>|all] [-h|-l|-d|-o <opt>] <ver> <bld> [<test>]
# Description:
#   This script extract compressed work image to $HOME location
#   and create GTLF XML file under the $AUTOPILOT/gtlf folder.
# Parameter:
#   <plat> : Platform to create XML.
#            When you skip this parameter, this script will
#            use current platform.
#   all    : Create XML file for all platforms.
#   <ver>  : Essbase version number.
#   <bld>  : Essbase build number.
#   <test> : Test name. If the test has some parameter,
#            You need enquote it like below:
#            mk_gtlf.sh 11.1.2.2.100 2122 "agtpjlmain.sh parallel direct"
#            or replace space between parameter to "+" character.
#            mk_gtlf.sh 11.1.2.2.100 2122 agtpjlmain.sh+parallel+direct
#            When you skip this parameter, this script will create XML
#            files for all test suite.
# Option:
#   -h       : Display help.
#   -d       : Display debug information
#   -l       : List only
#   -o <opt> : Task option.
# History:
# 2012/02/10	YKono	First edition

. apinc.sh

me=$0
orgpar=$@
unset ver bld tests
plats=
listonly=false
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			exit 0
			;;
		-l)
			listonly=true
			;;
		-d)
			dbg=true
			;;
		-o)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}:'-o' option need second parameter."
				exit 1
			fi
			[ -z "$_OPTION" ] && export _OPTION=$1 || export _OPTION="$1 $_OPTION"
			;;
		`isplat $1`)
			[ -z "$plats" ] && plats=$1 || plats="$plats $1"
			;;
		all)
			plats=`isplat`
			;;
		*.sh|*.ksh)
			[ -z "$tests" ] && tests=$1 || tests="$tests $1"
			;;
		*)
			if [ "${1#*+}" != "$1" ]; then
				# might be test
				[ -z "$tests" ] && tests=$1 || tests="$tests $1"
			elif [ "${1#* }" != "$1" ]; then
				# migt be enquoted test
				t=`echo $1 | sed -e "s! !+!g"`
				[ -z "$tests" ] && tests=$t || tests="$tests $t"
			else
				if [ -z "$ver" ]; then
					ver=$1
				elif [ -z "$bld" ]; then
					bld=$1
				else
					[ -z "$tests" ] && tests=$1 || tests="$tests $1"
				fi
			fi
			;;
	esac
	shift
done

[ -z "$ver" ] && ver="*"
[ -z "$bld" ] && bld="*"
[ -z "$tests" ] && tests="*"
[ -z "$plats" ] && plats=`get_platform.sh`
 
if [ "$dbg" = "true" ]; then
echo "Version=$ver"
echo "Build  =$bld"
echo "Plats  =$plats"
echo "Tests  =$tests"
fi

tmpf=${me##*/}
tmpf=$HOME/${tmpf%.*}
rm -rf $tmpf.log 2> /dev/null
rm -rf $tmpf 2> /dev/null
mkdir $tmpf 2> /dev/null
tlist=$tmpf/target_list.txt
for oneplat in $plats; do
	if [ "$tests" = "*" ]; then
		ls $AUTOPILOT/res/${oneplat}_${ver}_${bld}_*.tar.* >> $tlist 2> /dev/null
	else
		for onetest in $tests; do
			testn=`echo $onetest | sed -e "s!+! !g"`
			ot=`cat $AUTOPILOT/data/shabbr.txt | grep "^$testn:" | awk -F: '{print $2}'`
			[ -n "$ot" ] && testn=$ot
			if [ "${testn#* }" != "$testn" ]; then
				_onetest=${testn%% *}
				_rest=${testn%${_onetest}}
				_onetest=${_onetest%.sh}
				_onetest=${_onetest%.ksh}
				_onetest=`echo "${_onetest}${_rest}" | sed -e "s! !_!g"`
			else
				testn=${testn%.sh}
				testn=${testn%.ksh}
				_onetest=$testn
			fi
			echo "$onetest `ls $AUTOPILOT/res/${oneplat}_${ver}_${bld}_${_onetest}.tar.* 2> /dev/null`" \
				>> $tlist 2> /dev/null
		done
	fi
done
if [ "$listonly" != "true" ]; then
	cd $tmpf
	while read tstn one; do
		if [ "${one%.Z}" != "$one" ]; then
			cmdname=compress
		else
			cmdname=gzip
		fi
		cp $one .
		fn=${one##*/}
		${cmdname} -d ${fn}
		fn=${fn%.*}
		tar -xf $fn
		extdn=`ls -1d work_* 2> /dev/null | head -1`
		fn=${fn%.*}
		tnm=${extdn#work_}
		pnm=${fn%%_*}
		bnm=${fn%_${tnm}}
		bnm=${bnm##*_}
		vnm=${fn#${pnm}_}
		vnm=${vnm%_${bnm}_${tnm}}
		# mv $extdn "reswork~${pnm}~${vnm}~${bnm}~${tnm}"
		rm -rf *.tar 2> /dev/null
		if [ -f "$extdn/${tstn%.*}.sog" ]; then
			fn=`grep "^+ sxr shell " $extdn/${tstn%.*}.sog | head -1 | tr -d '\r'`
			tstn=${fn#+ sxr shell }
			echo "  found ${tstn%.*}.sog : $fn"
		fi
		scnt=`ls $extdn/*.suc 2> /dev/null | wc -l`
		dcnt=`ls $extdn/*.dif 2> /dev/null | wc -l`
		let scnt=scnt
		let dcnt=dcnt
		echo "$pnm : $vnm : $bnm : $tnm : sog=$sog tstn=$tstn suc=$scnt dif=$dcnt" | tee -a $tmpf.log
		echo "gtlf.sh $pnm $vnm $bnm $tstn -s $extdn"
		[ "$dbg" = "true" ] && gtlf.sh -dbg $pnm $vnm $bnm $tstn -s $extdn \
			|| gtlf.sh $pnm $vnm $bnm $tstn -s $extdn
		# rm -rf $extdn 2> /dev/null
	done < $tlist
else
	cat $tlist
fi
rm -rf $tlist 2>&1


