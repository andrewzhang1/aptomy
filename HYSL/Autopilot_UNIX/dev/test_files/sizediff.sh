#!/usr/bin/ksh

# 05/06/08	YKono	Add installer kind check

# SYMTAX:
#    sizediff.sh <src> <trg>
# INPUT:
#   <src> : Base Size file for the comparison
#   <trg> : Target Size file for the comparison
# OUTPUT:
#   If there is differetia between <src> and <trg> file,
#   This script display following informations:
#   1. Newly added to <trg>. (Not in <src>)
#     a> <file path> <file size>
#   2. Deleted in <trg>. (Exist in <src>, but not in <trg>
#     d< <file path> <file size>
#   3. Change the file size.
#     c <file path> <src file size> -> <trg file size>
#
# SAMPLE:
#   sizediff.sh kennedy2.bas kennedy2_094.siz > kennedy2_094.dif
#

. apinc.sh

if [ $# -ne 2 ]; then
	echo "Syntax error:sizediff.sh <src1> <src2>"
	exit 1
fi

tmpfile="$AUTOPILOT/tmp/${LOGNAME}@$(hostname)_sizdif.tmp"
tmpsrc="$AUTOPILOT/tmp/${LOGNAME}@$(hostname)_sizdif_src.tmp"
tmptar="$AUTOPILOT/tmp/${LOGNAME}@$(hostname)_sizdif_tar.tmp"
tmpdyn="$AUTOPILOT/tmp/${LOGNAME}@$(hostname)_sizdif_dyn.tmp"

# Check current product was installed by Installer
# If there is unintall* folder under the ARBORPATH, it assume to be
# installed using HIT or CD installer. Refresh command doesn't
# create it.

inst_kind=`grep "^ARBORPATH/[Uu]ninstall" $2`
if [ -z "$inst_kind" ]; then
	inst_kind=refresh
else
	inst_kind=installer
fi

# echo "# TARGET INSTALLER = $inst_kind"

# Pre edit

ign_refresh=`grep "^# *IGNORE_ON_REFRESH=" $1 | tail -1`
ign_refresh=${ign_refresh#*IGNORE_ON_REFRESH=}

ign_installer=`grep "^# *IGNORE_ON_INSTALLER=" $1 | tail -1`
ign_installer=${ign_refresh#*IGNORE_ON_INSTALLER=}

# echo "# IGNORE_ON_REFRESH = $ign_refresh"

if [ -n "$ign_refresh" -a "$inst_kind" = "refresh" ]; then
	grep -v "^#" $1 | sed -e "s/\#.*$//g" | sed -e "s/%.*//g" | egrep -v "$ign_refresh" | grep -v "^$" | sort | crfilter > "$tmpsrc"
	grep -v "^#" $1 | egrep -v "$ign_refresh" | sed -e "s/\#.*$//g" | grep "%" | crfilter > "$tmpdyn"
elif [ -n "$ign_installer" -a "$inst_kind" = "installer" ]; then
	grep -v "^#" $1 | sed -e "s/\#.*$//g" | sed -e "s/%.*//g" | egrep -v "$ign_installer" | grep -v "^$" | sort | crfilter > "$tmpsrc"
	grep -v "^#" $1 | egrep -v "$ign_installer" | sed -e "s/\#.*$//g" | grep "%" |  crfilter > "$tmpdyn"
else
	grep -v "^#" $1 | sed -e "s/\#.*$//g" | sed -e "s/%.*//g" | grep -v "^$" | sort | crfilter > "$tmpsrc"
	grep -v "^#" $1 | sed -e "s/\#.*$//g" | grep "%" | crfilter > "$tmpdyn"
fi
grep -v "^#" $2 | sed -e "s/\#.*$//g" | sed -e "s/%.*//g" | grep -v "^$" | sort | crfilter > "$tmptar"

if [ -z "$AP_SIZEDIFF_RATIO" ]; then
	export AP_SIZEDIFF_RATIO=20
fi

diff -i "$tmpsrc" "$tmptar" > "$tmpfile"

rm -f "$tmpsrc"
rm -f "$tmptar"

flush_array()
{
	if [ $cindex -ne 0 ]; then
		i=0
		while [ $i -lt $cindex ]; do
			if [ -n "${chgarry[$i]}" ]; then
				echo "d < ${chgarry[$i]}"
			fi
			i=`expr $i + 1`
		done
	fi
	cindex=0
}

cindex=0
mode=
while read line; do
	case $line in
		[,0-9]*d[,0-9]*|[,0-9]*a[,0-9]*|[,0-9]*c[,0-9]*)
			if [ "$mode" = "c" ]; then
				i=0
				while [ $i -lt $cindex ]; do
					if [ -n "${chgarry[$i]}" ]; then
						echo "d < ${chgarry[$i]}"
					fi
					i=`expr $i + 1`
				done
				cindex=0
			fi
			mode=`echo $line | sed s/[,0-9][,0-9]*//g`
			;;
		---)
			;;
		\<\ *)
			if [ "$mode" = "c" ]; then
				chgarry[$cindex]=${line#??}
				cindex=`expr $cindex + 1`
			else
				echo $mode $line
			fi
			;;
		\>\ *)
			if [ "$mode" = "c" ]; then
				i=0
				fnd=
				line=${line#??}
				while [ $i -lt $cindex -a -z "$fnd" ]; do
					fname=${chgarry[$i]}
					if [ "${fname% *}" = "${line% *}" ]; then
						fnd=${chgarry[$i]}
						chgarry[$i]=""
					fi
					i=`expr $i + 1`
				done
				if [ -z "$fnd" ]; then
					echo "a > $line"
				else
					fsiz=${line#* }
					dyn=`grep ${line% *} "$tmpdyn"`
					if [ -z "$dyn" ]; then
						echo "c - $fnd -> $fsiz"
					else
						ratio=${dyn##*%}
						if [ -z "$ratio" ]; then
							ratio=$AP_SIZEDIFF_RATIO
						fi
						psiz=${fnd#* }
						psiz=${psiz%%"%"*}	# remove %
						allow=`expr ${psiz} \* $ratio / 100`
						var=`expr ${fsiz} - $psiz`
						if [ $var -lt 0 ]; then
							var=`expr $var \* -1`
						fi
						if [ $var -gt $allow ]; then
							echo "c - $fnd -> $fsiz(allow=$allow, variance=$var, ratio=$ratio)"
						fi
					fi
				fi

			else
				echo $mode $line
			fi
			;;
		*)
				echo $mode $line
			;;
	esac
done < $tmpfile

if [ $cindex -ne 0 ]; then
	i=0
	while [ $i -lt $cindex ]; do
		if [ -n "${chgarry[$i]}" ]; then
			echo "d < ${chgarry[$i]}"
		fi
		i=`expr $i + 1`
	done
fi

rm -f "$tmpfile"
rm -f "$tmpdyn"

exit 0