#!/usr/bin/ksh

# You can use this command like below
# cd $AUTOPILOT/res
# lstver.sh -d -v talleyrand -n 2 | while read msk
# do
#   rm -rf *${msk}*
# done

display_help()
{
	echo "lstver.sh : list up the version and build in the directory."
	echo "lstver:"
	echo "  lsver.sh [-h|-pos <pos1> <pos2>|-n <keepn>|-d|-v <ver>] [<tardir>]"
	echo "Params:"
	echo " <ver>    : Delete version name. If skip this parameter, list up all ver/bld."
	echo " <tardir> : Target directory. If skip, use current directory."
	echo "  -h      : Display help."
	echo "  -pos    : Set position parameter of version to <pos1>, build to <pos2>."
	echo "  -n      : Set keep count to <keepn>."
	echo "  -d      : Display delete target <ver>_<bld>."
	echo "  -sz     : Display size also."
}


[ -z "$AP_DEFVAR" ] && . apinc.sh

dspnum()
{
	cs=
	col=
	frm=
	pdg=
	str=
	nm=
	ut=
	while [ $# -ne 0 ]; do
		case $1 in
			-cs|-c)
				cs=true;;
			-col)
				if [ $# -ge 2 ]; then
					shift
					col=$1
				fi
				;;
			-ut|-u)
				ut=true
				;;
			*)
				[ -z "$nm" ] && nm=$1 || nm="$nm $1"
				;;
		esac
		shift
	done
	if [ -n "$col" ]; then
		i=0
		while [ $i -lt $col ]; do
			frm="${frm}?"
			pdg="${pdg} "
			let i=i+1
		done
	fi
	for str in $nm; do
		trg=
		while [ -n "$str" ]; do
			s3=${str#${str%???}}
			if [ -z "$s3" ]; then
				s3=$str
				str=
			fi
			if [ -z "$trg" ]; then
				trg=$s3
			else
				trg="$s3,$trg"
			fi
			if [ "$s3" = "$str" ]; then
				str=
			else
				str=${str%???}
			fi
		done
		if [ -n "$frm" ]; then
			trg="${pdg}${trg}"
			trg=${trg#${trg%${frm}}}
		fi
		echo "${trg}B"
	done
}

orgpar=$@
tar=
pos1=
pos2=
ver=
keepn=
delete=
siz=
while [ $# -ne 0 ]; do
	case $1 in
		-pos|-p)
			shift
			if [ $# -lt 2 ]; then
				echo "'-pos' parameter need 2 more position parameters."
				exit 2
			fi
			pos1=$1
			shift
			pos2=$1
			;;
		-n)
			shift
			if [ $# -lt 1 ]; then
				echo "'-n' parameter need second parameter for keeping number."
				display_help
				exit 3
			fi
			keepn=$1
			;;
		-h)
			display_help with sample
			;;
		-d)
			delete=true
			;;
		-sz)
			siz=true
			;;
		-v)
			shift
			if [ $# -lt 1 ]; then
				echo "'-v' parameter need second parameter for version number."
				display_help
				exit 3
			fi
			ver=$1
			;;
		*)
			if [ -z "$tar" ]; then
				tar=$1
			else
				echo "Too many paramaeter."
				echo "params: $orgpar"
				display_help
				exit 1
			fi
			;;
	esac
	shift
done

[ -z "$tar" ] && tar=`pwd`
[ -z "$keepn" ] && keepn=5
if [ ! -d "$tar" ]; then
	echo "Couldn't find $tar folder."
	display_help
	exit 4
fi
crr=`pwd`
cd $tar
if [ -z "$ver" ]; then
	if [ -z "$pos1" -o -z "$pos2" ]; then
		tardir=`pwd`
		if [ "$tardir" = "$AUTOPILOT/res" ]; then
			pos1=1
			pos2=2
		elif [ "$tardir" = "$AUTOPILOT/dif" ]; then
			pos1=0
			pos2=1
		else
			cd $crr
			echo "This command without <ver> paramter, you need define -pos <pos1> <pos2> parameter."
			display_help
			exit 5
		fi
	fi
fi

tmpfile=$AUTOPILOT/tmp/${LOGNAME}@`hostname`.cleanup.tmp
rm -rf $tmpfile > /dev/null 2>&1
tmpfile2=$AUTOPILOT/tmp/${LOGNAME}@`hostname`.cleanup2.tmp
rm -rf $tmpfile2 > /dev/null 2>&1

if [ -z "$ver" ]; then
	ls | while read line; do
		p=$line
		i=0
		unset arry
		while [ -n "$p" ]; do
			pp=${p%%_*}
			arry[$i]=$pp
			let i="$i + 1"
			[ "$pp" != "$p" ] && p=${p#*_} || p=""
		done
		echo "$ver ${arry[$pos1]}_${arry[$pos2]}" >> $tmpfile
	done

	sort $tmpfile > $tmpfile2
	rm -rf $tmpfile > /dev/null 2>&1
	prevline=
	cat $tmpfile2 | while read line; do
		if [ "$prevline" != "$line" ]; then
			echo $line >> $tmpfile
			prevline=$line
		fi
	done
	if [ "$siz" = "true" ]; then
		cat $tmpfile | while read one; do
			sz=0
			ls -l *${one}* | while read d1 d2 d3 d4 s rest; do
				let sz=sz+s
			done
			sz=`dspnum $sz -c -col 15`
			echo "$one $sz"
		done
	else
		cat $tmpfile
	fi
else

	ls | grep $ver | while read line; do
		p=$line
		i=0
		vpos=
		unset arry
		while [ -n "$p" ]; do
			pp=${p%%_*}
			arry[$i]=$pp
			let i="$i + 1"
			[ "$pp" = "$ver" ] && vpos=$i
			[ "$pp" != "$p" ] && p=${p#*_} || p=""
			[ "$pp" = "$ver" ] && vpos=$i
		done
		if [ -n "$vpos" ]; then
			echo "${ver}_${arry[$vpos]}" >> $tmpfile
		fi
	done

	sort $tmpfile > $tmpfile2
	rm -f $tmpfile > /dev/null 2>&1
	prevline=
	cat $tmpfile2 | while read line; do
		if [ "$prevline" != "$line" ]; then
			echo $line >> $tmpfile
			prevline=$line
		fi
	done
	if [ "$delete" = "true" ]; then
		ttl=`cat $tmpfile | wc -l`
		let n="$ttl - $keepn"
		head -${n} $tmpfile
	else
		cat $tmpfile
	fi

fi

rm -f $tmpfile > /dev/null 2>&1
rm -f $tmpfile2 > /dev/null 2>&1
cd $crr
