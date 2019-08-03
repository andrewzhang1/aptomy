#!/usr/bin/ksh
# getdskfree.sh : Get free spece size of the location
# Description:
#   This script get the fee space size of the location of current
#   machine. If skip <loc> parameter, this script get the free
#   space size of the server ARBORPATH locaiton.
#   If you are not in the sxr view, this script try to get the
#   $ARBORPATH free size and display "##### (local)" format.
# Syntax:
#   getfreemem.sh [-u|-b|-k|-m|-g|-c|<loc>]
# Parameter:
#   <loc> : The location to get disk free size in local.
#   -u : Use Unit in appricable Unit
#   -b : Display size in byte
#   -k : Display size in KB
#   -m : Display size if MB
#   -g : Display size in GB
#   -c : Display comma separate format.
# Exit:
#   =0  : Get free size.
#   !=0 : Syntax error or execution error of command.
# History:
# 2013/07/24	YKono	First edition

# Function : get_dskfree <loc> [<loc>...]
get_dskfree()
{
	if [ -n "$1" ]; then
		if [ -d "$1" -o -f "$1" ]; then
			case `uname` in
				Windows_NT) df -k "$1" | awk '{print $3}' | sed "s/\// /g" | awk '{print $1}' ;;
				AIX) df -k "$1" | tail -1 | awk '{print $3}' ;;
				SunOS) df -k "$1" | tail -1 | awk '{print $4}' ;;
				HP-UX) df -k "$1" | grep free | tail -1 | awk '{print $1}' ;;
				Linux) df -kP "$1" | tail -1 | awk '{print $4}' ;;
				*) echo 0 ;;
			esac
		else
			echo "!Failed to access \"$1\""
		fi
	fi
}

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
		else _u=B; fi
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

# Variables
orgpar=$@
me=$0
locs=
sts=0
istarted=
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
		*)
			[ -z "$locs" ] && locs=$1 || locs="$locs $1"
			;;
	esac
	shift
done

if [ -z "$locs" ]; then
	if [ -n "$SXR_INVIEW" ]; then
		ofile1=$SXR_WORK/OsResources.out
		ofile2=$SXR_WORK/SysConfig.out
		rm -rf $ofile1
		rm -rf $ofile2
		sts=`sxr agtctl status`
		if [ "$sts" -eq 0 ]; then
			sxr agtctl start > /dev/null 2>&1
			sts=$?
			istarted="true"
		else
			sts=0
		fi
		if [ "$sts" -eq 0 ]; then
			sxr esscmd -q msxxgetosres.scr \
				%HOST=${SXR_DBHOST} %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
				%OFILE=$ofile1 > /dev/null 2>&1
			sts=$?
			if [ "$sts" -eq 0 ]; then
				sxr esscmd -q msxxgetsyscfg.scr \
					%HOST=${SXR_DBHOST} %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
					%OFILE=$ofile2 > /dev/null 2>&1
				sts=$?
				if [ "$sts" -eq 0 ]; then
					arb=`cat $ofile2 2> /dev/null | \
						grep "^Environment Variable:  ARBORPATH" | tail -1`
					if [ -n "$arb" ]; then
						arb=${arb#*= }
						if [ "`uname`" != "Windows_NT" ]; then
							arb=${arb%?${arb#/*/}}
						else
							arb=${arb%%:*}
						fi
						lno=`cat $ofile1 2> /dev/null | \
							grep -n "^   Drive Name:         $arb" | tail -1`
						if [ -z "$lno" ]; then
							lno=`cat $ofile1 2> /dev/null | \
								grep -n "^   Drive Name:         /scratch" | tail -1`
						fi
						lno=${lno%%:*}
						let lno=lno+5
						free=`cat $ofile1 2> /dev/null | head -n $lno | tail -1`
						u=`echo $free | awk '{print $5}'`
						f=`echo $free | awk '{print $4}'`
						cnvunit $f $u
					else
						echo "${me##*/}: Failed to get ARBORPATH."
						sts=1
					fi
				else
					echo "${me##*/}: Failed to execute msxxgetsyscfg.scr($sts)."
				fi
			else
				echo "${me##*/}: Failed to execute msxxgetosres.scr($sts)."
			fi
		else
			echo "${me##*/}: Failed to start agent($sts)."
		fi
		[ "$istarted" = "true" ] && sxr agtctl stop > /dev/null 2>&1
		# rm -rf $ofile1
		# rm -rf $ofile2
	else
		if [ -n "$ARBORPATH" -a -d "$ARBORPATH" ]; then
			free=`get_dskfree $ARBORPATH`
			if [ "$free" != "${free#!}" ]; then
				echo "${free#!}"
			elif [ -n "$free" ]; then
				free=`cnvunit $free K`
				echo "$free (local)"
			fi
		else
			echo "${me##*/}: You are not in the sxr view and doesn't have valid \$ARBORPATH."
			exit 1
		fi
	fi
else
	for one in $locs; do
		free=`get_dskfree $one`
		if [ "$free" != "${free#!}" ]; then
			echo "${free#!}"
		elif [ -n "$free" ]; then
			free=`cnvunit $free K`
			[ "$one" != "$locs" ] && echo "$one=$free" || echo $free
		fi
		sts=$?
	done
fi

exit $sts

