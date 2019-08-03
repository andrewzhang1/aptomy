#!/usr/bin/ksh
# Calculate time differences
#
# Syntax: 		timediff.sh [-s|-h|-d] <start> <end>
# Date format:	MM_DD_YY HH:MM:SS 
# Options:
#   -h : Display help
#   -d : Display with days
#   -s : Display in seconds.
# History:
# 10/07/2010	YKono	Add -s option

display_help()
{
	echo "timediff.sh [-h|-d|-s] <startts> <endts>"
	echo " -h        : display help."
	echo " -d        : display with days."
	echo " -s        : display in sec unit."
	echo " <startts> : Start time stamp MM_DD_YY HH:MM:SS"
	echo " <endts>   : Start time stamp MM_DD_YY HH:MM:SS"
}

unset src trg datef
allpara=$@

while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help
			exit 0
			;;
		-d)	datef=true;;
		-s)	datef=sec;;
		*)
			if [ -z "$src" ]; then
				src=$1
			elif [ -z "$trg" ]; then
				trg=$1
			else
				display_help
				exit 1
			fi
			;;
	esac
	shift
done
if [ -z "$src" -o -z "$trg" ]; then
	echo "Not enough parameters."
	echo "Params=$allpara"
	display_help
	exit 1
fi

m1=`echo $src | awk '{print $1}' | awk -F_ '{print $1}'`
d1=`echo $src | awk '{print $1}' | awk -F_ '{print $2}'`
y1=`echo $src | awk '{print $1}' | awk -F_ '{print $3}'`

hr1=`echo $src | awk '{print $2}' | awk -F: '{print $1}'`
mn1=`echo $src | awk '{print $2}' | awk -F: '{print $2}'`
sc1=`echo $src | awk '{print $2}' | awk -F: '{print $3}'`

m2=`echo $trg | awk '{print $1}' | awk -F_ '{print $1}'`
d2=`echo $trg | awk '{print $1}' | awk -F_ '{print $2}'`
y2=`echo $trg | awk '{print $1}' | awk -F_ '{print $3}'`

hr2=`echo $trg | awk '{print $2}' | awk -F: '{print $1}'`
mn2=`echo $trg | awk '{print $2}' | awk -F: '{print $2}'`
sc2=`echo $trg | awk '{print $2}' | awk -F: '{print $3}'`


export m1
export d1
export y1
export hr1
export mn1
export sc1

export m2
export d2
export y2
export hr2
export mn2
export sc2

[ $y1 -lt 70 ] && y1="20$y1" || y1="19$y1"
[ $y2 -lt 70 ] && y2="20$y2" || y1="19$y2"

# echo "$y1/$m1/$d1 $hr1:$mn1:$sc1 - $y2/$m2/$d2 $hr2:$mn2:$sc2"
cdate=`perl -e \
'use  Time::Local;$dd="$ENV{d1}";$mm="$ENV{m1}";$yy=$ENV{"y1"};$hr="$ENV{hr1}";$mn="$ENV{mn1}";$sc=$ENV{"sc1"};$src=timelocal($sc,$mn,$hr,$dd,$mm-1,$yy);$dd="$ENV{d2}";$mm="$ENV{m2}";$yy=$ENV{"y2"};$hr="$ENV{hr2}";$mn="$ENV{mn2}";$sc=$ENV{"sc2"};$trg=timelocal($sc,$mn,$hr,$dd,$mm-1,$yy);\
					printf("%0d",$trg-$src);'`
# echo "$cdate"
if [ "$datef" = "sec" ]; then
	echo $cdate
else
	sec=`expr $cdate % 60`
	cdate=`expr $cdate / 60`
	min=`expr $cdate % 60`
	cdate=`expr $cdate / 60`
	sec="00$sec"
	sec=${sec#${sec%??}}
	min="00$min"
	min=${min#${min%??}}
	if [ "$datef" = "true" ]; then
		hr=`expr $cdate % 24`
		hr="00$hr"
		hr=${hr#${hr%??}}
		cdate=`expr $cdate / 24`
		echo "$cdate $hr:$min:$sec"
	else
		hr=$cdate
		if [ $hr -lt 100 ]; then
			hr="00$hr"
			hr=${hr#${hr%??}}
		fi
		echo "$hr:$min:$sec"
	fi
fi
exit 0