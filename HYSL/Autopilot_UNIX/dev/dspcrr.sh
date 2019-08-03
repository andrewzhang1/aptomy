#!/usr/bin/ksh

# *.crr file format

#  1:MACHINE NAME:   stiahp5~
#  2:USER NAME:      regrrk1~
#  3:PLATFORM:       hpux64~
#  4:VIEW_PATH:      /mnt/stublnx1vol4/vol1/regrrk1/stiahp5/views~
#  5:TEST NAME:      agtp70main.sh~
#  6:VERSION/BUILD:  9.3.1.3.7:001~
#  7:START DATE&TIME:05_07_09 16:32:33~
#  8:SUBSCRIPT NAME: agsymsglog6.sh~
#  9:SUC COUNT:      31~
# 10:DIF COUNT:      0~
# 11:SNAP DATE&TIME: 05_07_09 16:41:14~
# 12:SUB DATE&TIME:  05_07_09 16:41:10

# chkcrr.sh [<plat>]
# <plat>:=all|win32...linuxamd64|<usr>@<machine>|-u <usr>|-m <machine>|

plat=`get_platform.sh -l`

display_help()
{
	echo "Check current status command."
	echo "usage:chkcrr.sh [-t] [<plat>]"
	echo " -t     : Display with time information."
	echo " <plat> : Platform kind as below."
	echo "          aix, aix64, solaris, solaris64, solaris.x64, hpux, hpux64,"
	echo "          linux, linuxamd64, win32, win64, winamd64."
}

notime=true
while [ $# -ne 0 ]; do
	case $1 in
		-h|help)
			display_help
			exit 0
			;;
		-t)
			notime=false
			;;
		`isplat $1`)
			plat=$1
			;;
		aix32|solaris32|hpux32|linux32)
			plat=${1%??}
			;;
		win)
			plat=win32
			;;
		all)
			plat=$1
			;;
		*)
			echo "Parameter error."
			display_help
			exit 1
	esac
	shift
done

disp_flt()
{
	while read line; do
		mac=${line%%\~*}; line=${line#*\~}
		usr=${line%%\~*}; line=${line#*\~}
		plat=${line%%\~*}; line=${line#*\~}
		vpath=${line%%\~*}; line=${line#*\~}
		tname=${line%%\~*}; line=${line#*\~}
		verbld=${line%%\~*}; line=${line#*\~}
		sttime=${line%%\~*}; line=${line#*\~}
		subname=${line%%\~*}; line=${line#*\~}
		succnt=${line%%\~*}; line=${line#*\~}
		difcnt=${line%%\~*}; line=${line#*\~}
		snaptime=${line%%\~*}; line=${line#*\~}
		subtime=${line%%\~*}; line=${line#*\~}

#		mac=`echo $line | awk -F~ '{print $1}'`
#		usr=`echo $line | awk -F~ '{print $2}'`
#		plat=`echo $line | awk -F~ '{print $3}'`
#		vpath=`echo $line | awk -F~ '{print $4}'`
#		tname=`echo $line | awk -F~ '{print $5}'`
#		verbld=`echo $line | awk -F~ '{print $6}'`
#		sttime=`echo $line | awk -F~ '{print $7}'`
#		subname=`echo $line | awk -F~ '{print $8}'`
#		succnt=`echo $line | awk -F~ '{print $9}'`
#		difcnt=`echo $line | awk -F~ '{print $10}'`
#		snaptime=`echo $line | awk -F~ '{print $11}'`
#		subtime=`echo $line | awk -F~ '{print $12}'`
		now=`date +"%m_%d_%y %T"`
		melaps=`timediff.sh -d "$sttime" "$snaptime" 2> /dev/null`
		[ $? -ne 0 ] && melaps="NAN"
		selaps=`timediff.sh -d "$subtime" "$snaptime" 2> /dev/null`
		[ $? -ne 0 ] && selaps="NAN"
		echo "$plat(${usr}@${mac})	$tname($subname)	$verbld	${succnt}/${difcnt}~$sttime($melaps) $subtime($selaps) $snaptime"
	done
}

replace_cr()
{
	while read line; do
		_line2=${line#*~}
		_line1=${line%%~*}
		if [ "$_line2" = "$line" ]; then
			echo $line
		else
			echo $_line1
			[ "$notime" = "false" ] && echo "        $_line2"
		fi
	done
}


if [ "$plat" = "all" ]; then
	cat $AUTOPILOT/mon/*.crr | disp_flt 
else
	cat $AUTOPILOT/mon/*.crr | grep "~${plat}~" | disp_flt | sort | replace_cr
fi

