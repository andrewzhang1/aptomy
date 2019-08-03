#!/usr/bin/ksh
# gtlfplat.sh : Return GTLF platform
# Syntax: gtlgplat.sh [-h|-b|-g|all]<ap plat>
# Options:
#   -h : Display help
#   -b : Return BI platform.(default)
#   -g : Return GTLF platform.
#   -a : Retuen AP platform.
#   -to ap|bi|gtlf : Convert to
#   -from ap|bi|gtlf : Convert from
#   all : Display all definition
# History:
# 2012/02/12	YKono	First edition

. apinc.sh
me=$0
orgpar=$@
plt=
mode=bi
from=ap
all=
while [ $# -ne 0 ]; do
	case $1 in
		-a|-all|all)
			all=true
			;;
		-h)
			display_help.sh $me
			exit 0
			;;
		-bi|-b|bi)
			mode=bi
			;;
		-gtlf|-g|gtlf)
			mode=gtlf
			;;
		-ap|ap|-a)
			mode=ap
			;;
		-f|-from)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}: '$1' need secondparameter."
				exit 1
			fi
			from=$1
			;;
		from=*)
			from=${1#*=}
			;;
		-m|-mode|-to)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}: '$1' need second parameter."
				exit 1
			fi
			mode=$1
			;;
		mode=*|to=*)
			mode=${1#*=}
			;;
		`isplat $1`)
			plt=$1
			;;
		*)
			echo "${me##*/}:Invalid parameter."
			echo "param:$orgpar"
			exit 1
			;;
	esac
	shift
done

[ -z "$plt" ] && plt=`get_platform.sh`
if [ -z "$AUTOPILOT" ]; then
	echo "${me##*/}:AUTOPILOT not defined."
	exit 2
fi
if [ ! -f "$AUTOPILOT/data/platforms.txt" ]; then
	echo "${me##*/}:No AUTOPILOT/data/platforms.txt file."
	exit 3
fi
if [ "$all" = "true" ]; then
	echo "# from $AUTOPILOT/data/platforms.txt"
	aplen=0; bilen=0; gtlen=0
	tmpf=$HOME/.cnvplat.$$.tmp
	rm -f $tmpf 2> /dev/null
	cat $AUTOPILOT/data/platforms.txt | grep -v "^# " | grep -v "^$" > $tmpf 2> /dev/null
	while read line; do
		ap=`echo $line | awk -F: '{print $1}'`
		bi=`echo $line | awk -F: '{print $2}'`
		gt=`echo $line | awk -F: '{print $3}'`
		[ ${#ap} -gt $aplen ] && aplen=${#ap}
		[ ${#bi} -gt $bilen ] && bilen=${#bi}
		[ ${#gt} -gt $gtlen ] && gtlen=${#gt}
	done < $tmpf
	ap="AP"; i=${#ap}; while [ $i -lt $aplen ]; do ap="${ap}_"; let i=i+1; done
	bi="BI"; i=${#bi}; while [ $i -lt $bilen ]; do bi="${bi}_"; let i=i+1; done
	gt="GTLF"; i=${#gt}; while [ $i -lt $gtlen ]; do gt="${gt}_"; let i=i+1; done
	echo "$ap $bi $gt"
	while read line; do
		ap=`echo $line | awk -F: '{print $1}'`
		bi=`echo $line | awk -F: '{print $2}'`
		gt=`echo $line | awk -F: '{print $3}'`
		[ "${ap}" = "#NA" ] && ap="---"
		[ "${bi}" = "#NA" ] && bi="---"
		[ "${gt}" = "#NA" ] && gt="---"
		i=${#ap}; while [ $i -lt $aplen ]; do ap="$ap "; let i=i+1; done
		i=${#bi}; while [ $i -lt $bilen ]; do bi="$bi "; let i=i+1; done
		i=${#gt}; while [ $i -lt $gtlen ]; do gt="$gt "; let i=i+1; done
		echo "$ap $bi $gt"
	done < $tmpf
	rm -f $tmpf 2> /dev/null
else
	case $from in
		ap)	ptn="^${plt}:";;
		bi)	ptn=":${plt}:";;
		gtlf)	ptn=":${plat}\$";;
	esac

	gtlfplt=`cat $AUTOPILOT/data/platforms.txt | grep -v "^# " | grep -v "^$" | tr -d '\r' | grep "$ptn"`
	case $mode in
		bi)	echo $gtlfplt | awk -F: '{print $2}';;
		gtlf)	echo $gtlfplt | awk -F: '{print $3}';;
		ap)	echo $gtlfplt | awk -F: '{print $1}';;
		*)	echo $gtlfplt;;
	esac
fi
exit 0

