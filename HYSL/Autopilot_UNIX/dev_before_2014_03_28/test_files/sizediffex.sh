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

tmpdir="$TMP"
unset src trg
chksize=true	# "<file name> size" line
chkcksum=false	# "<file name> size # cksum" line
chkdate=false	# "<file name> size # chsum @ date(YYYY/MM/DD HH:MM[:SS])
debug=false

while [ $# -ne 0 ]; do
	case $1 in
		-t|-tmp)
			shift
			tmpdir=$1
			;;
		-debug)
			debug=true
			;;
		-h|-help)
			echo "sizediffex.sh [ -t <tmpdir> ] <src file> <trg file>"
			exit 0
			;;
		-*)
			case ${1#-} in
				size)	chksize=false;;
				cksum)	chkcksum=false;;
				date)	chkdate=false;;
				*)	echo "Illegal - option $1.";;
			esac
			;;
		+*)
			case ${1#+} in
				size)	chksize=true;;
				cksum)	chkcksum=true;;
				date)	chkdate=true;;
				*)	echo "Illegal + option $1.";;
			esac
			;;
		*)
			[ -z "$src" ] && src=$1 || trg=$1
			;;
	esac
	shift
done

if [ -z "$src" -o -z "$trg" ]; then
	echo "Syntax error:sizediff.sh <src1> <src2>"
	exit 1
fi

[ -z "$tmpdir" ] && tmpdir="."

# echo "src=$src"
# echo "trg=$trg"
# echo "tmpdir=$tmpdir"

tmpfile="$tmpdir/${LOGNAME}@$(hostname)_sizdif.$$.tmp"
tmpsrc="$tmpdir/${LOGNAME}@$(hostname)_sizdif_src.$$.tmp"
tmptar="$tmpdir/${LOGNAME}@$(hostname)_sizdif_tar.$$.tmp"
tmpdyn="$tmpdir/${LOGNAME}@$(hostname)_sizdif_dyn.$$.tmp"

# Check current product was installed by Installer
# If there is unintall* folder under the ARBORPATH, it assume to be
# installed using HIT or CD installer. Refresh command doesn't
# create it.

inst_kind=`grep "^ARBORPATH/[Uu]ninstall" "$trg"`
if [ -z "$inst_kind" ]; then
	inst_kind=refresh
else
	inst_kind=installer
fi

# echo "# TARGET INSTALLER = $inst_kind"

# Pre edit

ign_refresh=`grep "^# *IGNORE_ON_REFRESH=" "$src" | tail -1`
ign_refresh=${ign_refresh#*IGNORE_ON_REFRESH=}

ign_installer=`grep "^# *IGNORE_ON_INSTALLER=" "$src" | tail -1`
ign_installer=${ign_refresh#*IGNORE_ON_INSTALLER=}


[ "$chksize" = "true" ] && sizeptn=" \1" || sizeptn=
[ "$chkcksum" = "true" ] && cksumptn=" # \1" || cksumptn=
[ "$chkdate" = "true" ] && dateptn=" @ \1" || dateptn=
# echo "sizeptn=$sizeptn"
# echo "cksumptn=$cksumptn"
# echo "dateptn=$dateptn"

# echo "# IGNORE_ON_REFRESH = $ign_refresh"

# echo "Make source tmp."
if [ -n "$ign_refresh" -a "$inst_kind" = "refresh" ]; then
	grep -v "^#" $src | \
		sed -e "s/%[^ ]*//g" -e "s/%.*//g" \
			-e "s/# /#/g" -e "s/@ /@/g" \
			-e "s/^\([^ ][^ ]*\)/\1/g" \
			-e "s/ #\([^ ][^ ]*\)/${cksumptn}/g" \
			-e "s/ @\(.*\)$/${dateptn}/g" \
			-e "s/ \([0-9][0-9]*\)/${sizeptn}/g" | \
		egrep -v "$ign_refresh" | \
		grep -v "^$" | \
		sort | crfilter > "$tmpsrc"
	grep -v "^#" $src | egrep -v "$ign_refresh" | sed -e "s/\#.*$//g" | grep "%" | crfilter > "$tmpdyn"
elif [ -n "$ign_installer" -a "$inst_kind" = "installer" ]; then
	grep -v "^#" "$src" | \
		sed -e "s/%[^ ]*//g" -e "s/%.*//g" \
			-e "s/# /#/g" -e "s/@ /@/g" \
			-e "s/^\([^ ][^ ]*\)/\1/g" \
			-e "s/ #\([^ ][^ ]*\)/${cksumptn}/g" \
			-e "s/ @\(.*\)$/${dateptn}/g" \
			-e "s/ \([0-9][0-9]*\)/${sizeptn}/g" | \
		egrep -v "$ign_installer" | \
		grep -v "^$" | \
		sort | crfilter > "$tmpsrc"
	grep -v "^#" $src | egrep -v "$ign_installer" | sed -e "s/\#.*$//g" | grep "%" |  crfilter > "$tmpdyn"
else
	grep -v "^#" "$src" | \
		sed -e "s/%[^ ]*//g" -e "s/%.*//g" \
			-e "s/# /#/g" -e "s/@ /@/g" \
			-e "s/^\([^ ][^ ]*\)/\1/g" \
			-e "s/ #\([^ ][^ ]*\)/${cksumptn}/g" \
			-e "s/ @\(.*\)$/${dateptn}/g" \
			-e "s/ \([0-9][0-9]*\)/${sizeptn}/g" | \
		grep -v "^$" | \
		sort | crfilter > "$tmpsrc"
	grep -v "^#" $src | sed -e "s/\#.*$//g" | grep "%" | crfilter > "$tmpdyn"
fi
# echo "Make target tmp."
grep -v "^#" "$trg" | \
	sed -e "s/%[^ ]*//g" -e "s/%.*//g" \
		-e "s/# /#/g" -e "s/@ /@/g" \
		-e "s/^\([^ ][^ ]*\)/\1/g" \
		-e "s/ #\([^ ][^ ]*\)/${cksumptn}/g" \
		-e "s/ @\(.*\)$/${dateptn}/g" \
		-e "s/ \([0-9][0-9]*\)/${sizeptn}/g" | \
	grep -v "^$" | \
	sort | crfilter > "$tmptar"

if [ -z "$AP_SIZEDIFF_RATIO" ]; then
	export AP_SIZEDIFF_RATIO=20
fi

# echo "Start diff."
diff -i "$tmpsrc" "$tmptar" > "$tmpfile"

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

# echo "Start compare."
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
				let cindex="$cindex + 1"
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
					if [ "${fname%% *}" = "${line%% *}" ]; then
						fnd=${chgarry[$i]}
						chgarry[$i]=""
					fi
					let i="$i + 1"
				done
				if [ -z "$fnd" ]; then
					echo "a > $line"
				else
					fnm=${line%% *}
					fsiz=${line#* }; [ "$fsiz" = "$line" ] && fsiz="" || fsiz=${fsiz%% *}
					fck=${line#*\# }; [ "$fck" = "$line" ] && fck="" || fck=${fck%% *}
					fdt=${line#*@ }; [ "$fdt" = "$line" ] && fdt="" || fdt=${fdt%% *}
					dyn=`grep ${line%% *} "$tmpdyn"`
					if [ -z "$dyn" ]; then
						[ -n "$fck" ] && fsiz="$fsiz # $fck"
						[ -n "$fdt" ] && fsiz="$fsiz @ $fdt"
						echo "c - $fnd -> $fsiz"
					else
						ratio=${dyn##*%}
						if [ -z "$ratio" ]; then
							ratio=$AP_SIZEDIFF_RATIO
						fi
						psiz=${fnd#* }; psiz=${psiz%% *}
						sck=${fnd#*\#}; [ "$sck" = "$fnd" ] && sck= || sck=${sck%% *}
						sdt=${fnd#*@}; [ "$sdt" = "$fnd" ] && sdt= || sdt=${sdt%% *}
						psiz=${psiz%%"%"*}	# remove %
						allow=`expr ${psiz} \* $ratio / 100`
						var=`expr ${fsiz} - $psiz`
						if [ $var -lt 0 ]; then
							var=`expr $var \* -1`
						fi
						if [ $var -gt $allow -o "$fck" != "$sck" -o "$fdt" != "$sdt" ]; then
							[ -n "$fck" ] && fsiz="$fsiz # $fck"
							[ -n "$fdt" ] && fsiz="$fsiz @ $fdt"
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

[ "$debug" = "false" ] && rm -f "$tmpsrc"
[ "$debug" = "false" ] && rm -f "$tmptar"

[ "$debug" = "false" ] && rm -f "$tmpfile"
[ "$debug" = "false" ] && rm -f "$tmpdyn"

exit 0