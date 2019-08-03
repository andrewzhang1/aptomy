#!/usr/bin/ksh
# getfreemem.sh : Get free memory of server or local machine.
# Description:
#   This script get the free memory of the server. Whne define
#   "loc" parameter, this command return a free memory of 
#   current machine.
# Syntax:
#   getfreemem.sh [-h|-u|-c|-b|-k|-m|-g|loc]
# Parameter:
#   loc : Display free memory form local machine.
#   -h  : Display help.
#   -u  : Display size in appropriate unit.
#   -c  : Display size with comma separator.
#   -b  : Display size in byte.
#   -k  : Display size in KB.
#   -m  : Display size in MB.
#   -g  : Display size in GB.
# Exit:
#   =0  : Get free size.
#   !=0 : Syntax error or execution error of command.
# History:
# 2013/07/24	YKono	First edition

# Function : cnvunit <size> <unit>
cnvunit()
{
	_u=$unit
	if [ -n "$2" ]; then
		case $2 in
			mb|MB|mM)	let m=1048576;;
			b|B)		let m=1;;
			gb|GB|g|G)	let m=1073741824;;
			*)		let m=1024;; # KB
		esac
	else
		m=1024
	fi
	size=$(echo "$1 * $m" | bc)
	if [ "$_u" = "u" ]; then
		if [ "$size" -gt 1073741824 ]; then _u=GB
		elif [ "$size" -gt 1048576 ]; then _u=MB
		elif [ "$size" -gt 1024 ]; then _u=KB
		else _u=B
		fi
	fi
	case $_u in
		B) ;;
		MB)	size=$(echo "scale=2;$size/1048576" | bc);;
		GB)	size=$(echo "scale=2;$size/1073741824" | bc);;
		*)	size=$(echo "scale=2;$size/1024" | bc);;
	esac
	[ "$size" != "${size%.00}" ] && size=${size%.00}
	if [ "$comsep" = "true" ]; then
		s=${size%.*}
		[ "$s" = "$size" ] && d= || d=".${size#*.}"
		t=
		while [ -n "$s" ]; do
			l=${s#${s%???}}
			[ -z "$l" ] && l=$s
			s=${s%${l}}
			[ -z "$t" ] && t=$l || t="${l},${t}"
		done
		size="${t}${d}"
	fi
	# [ "$_u" = "$unit" ] && echo "$size" || echo "$size $_u"
	echo "$size $_u"
}

# Vars
orgpar=$@
me=$0
which=server
sts=0
mem=
unit=KB
comsep=
# Read parameter.
while [ $# -ne 0 ]; do
	case $1 in
		-u)	unit=u;;
		-b)	unit=B;;
		-k)	unit=KB;;
		-m)	unit=MB;;
		-g)	unit=GB;;
		-c)	comsep=true;;
		-h)	(IFS=
			lno=`cat $me 2> /dev/null | grep -n "# History:" | head -1`
			if [ -n "$lno" ]; then
				lno=${lno%%:*}; let lno=lno-1
				cat $me 2> /dev/null | head -n $lno | grep -v "#!/usr/bin/ksh" \
					| while read line; do echo "${line#??}"; done
			else
				cat $me 2> /dev/null | grep -v "#!/usr/bin/ksh" | while read line; do
					[ "$line" = "${line#\# }" ] && break
					echo "${line#??}"
				done
			fi)
			exit 0 ;;
		loc|local|-l|-loc|-local)
			which=current;;
		svr|server|remote|rem|-s|-svr|-server|-r|-rem|-remote)
			which=server;;
		*)
			echo "${me##*/}: Illegal parameter."
			exit 1
			;;
	esac
	shift
done

# Run check
if [ "$which" = "server" ]; then
	if [ -n "$SXR_INVIEW" ]; then
		ofile=$SXR_WORK/OsResources.out
		rm -rf $ofile
		sxr agtctl start > /dev/null 2>&1
		sts=$?
		if [ "$sts" -eq 0 ]; then
			sxr esscmd -q msxxgetosres.scr \
				%HOST=${SXR_DBHOST} %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
				%OFILE=$ofile > /dev/null 2>&1
			sts=$?
		fi
		[ "$sts" = 0 ] && mem=`cat $ofile 2> /dev/null | grep "Free Physical Memory" | awk '{print $6}'`
		mem=${mem#\(}
		mem=${mem%\)}
		# rm -rf $ofile
	else
		echo "${me##*/}: You are not in the sxr view. This command couldn't get the server information."
		exit 1
	fi
	mem=`cnvunit $mem B`
else
	case `uname` in
		Windows_NT)
			mem=`sysinf memory | awk '{print $3}'`
			sts=$?
			mem=`cnvunit $mem B`
			;;
		HP-UX)
			mem=`vmstat | tail -1 | awk '{print $5}'`
			sts=$?
			mem=$(echo "$mem * 4096" | bc)
			mem=`cnvunit $mem B`
			;;
		AIX)
			mem=`vmstat | tail -1 | awk '{print $4}'`
			sts=$?
			mem=$(echo "$mem * 4096" | bc)
			mem=`cnvunit $mem B`
			;;
		*)
			mem=`vmstat | tail -1 | awk '{print $4}'`
			sts=$?
			mem=`cnvunit $mem K`
			;;
	esac
fi
[ "$sts" -eq 0 -a -n "$mem" ] && echo "$mem"
exit $sts

