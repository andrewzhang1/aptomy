#!/usr/bin/ksh
# Make size file list for the current Essbase installation
#
# 05/14/08 YK Add dirlist from parameter
#

# SYNTAX: 
# filesize.sh [ -cksum | -lower ] [ <path> ]
# INPUT:
#  -cksum : Add cksum value
#  -date  : Add date stamp 
#  -lower : Make all alphabet in lower case.
#  <path> : The folder location to make a size file.
#           Note: If you define <path> with $ARBORPATH,
#                 This script output exact path for it
#                 like below:
#                   C:/Hyperion/products/essbase/EssbaseServer/bin/ESSBASE.EXE 22222
#                   ...
#                 This might be problem when you compare
#                 with base file.
#                 So, if you don't want this kind output,
#                 please use \$ARBORPATH for the <path>.
#                 Then this script create following output:
#                   $ARBORPATH/bin/ESSBASE.EXE 22222
#                   ...
# OUTPUT:
#   The whole file list under the <path> location. following format.
#     <file path> <file size> [ # <cksum value> [ @ <date stamp> ] ]
#     ...
# SAMPLE:
# filesize.sh > kennedy2_091.siz
#
#

debug=off
unset dirlist
file_lower=false
cksumf=false
fdate=false
tmpdir="$TMP"

while [ $# -ne 0 ]; do
	case $1 in
		-debug)
			debug=on
			;;
		-cksum)
			cksumf=true
			;;
		-date)
			fdate=true
			;;
		-lower)
			file_lower=true
			;;
		-t|-tmp)
			shift
			tmpdir=$1
			;;
		-h|-help)
			echo "filesize.sh [ -t <tmpdir> | -cksum | -date | -lower ] <dump dir>"
			exit 0
			;;
		*)
			if [ -z "$dirlist" ]; then
				dirlist=$1
			else
				dirlist="$dirlist $1"
			fi
			;;
	esac
	shift
done

if [ -z "$tmpdir" ]; then
	# echo "filesize.sh : No temporary directory defined."
	# echo "Please define \$TMP variable or use -t <tmpdir> options"
	# exit 1
	tmpdir=.
fi

if [ -z "$dirlist" ]; then
	echo "filesize.sh : No target directory for file-size-dump."
	exit 2
fi

crrsave=`pwd`
cd "$tmpdir"
tmpdir=`pwd`
cd "$crrsave"
tmpfile="$tmpdir/`hostname`_${LOGNAME}_$$.filesize.1.tmp"
tmpfile2="$tmpdir/`hostname`_${LOGNAME}_$$.filesize.2.tmp"

rm -rf $tmpfile
rm -rf $tmpfile2

actdir=
for dirname in ${dirlist}; do
	dirtmp=`eval echo $dirname`
	if [ "$dirtmp" = "$dirname" ]; then
		[ -z "$actdir" ] && actdir="$dirname" || actdir="$actdir $dirname"
	else
		[ -z "$actdir" ] && actdir="$dirname($dirtmp)" || actdir="$actdir $dirname($dirtmp)"
	fi
	echo "${dirname}:" >> "$tmpfile"
	ls -lRp "${dirtmp}" | \
		egrep -v "^total |^$|.*/$" | \
		sed	-e "s!${dirtmp}!${dirname}!g" \
		>> "$tmpfile"
	echo "sed -e s!${dirtmp}!${dirname}!g"
done

# -rwxrwxrwa   1 Administrators  HYPERIONAD\sxrdev   16925 Oct 15 10:04 sh_histo
# -rwxrwxrwa   1 Administrators  HYPERIONAD\sxrdev      38 Apr  2  2008 tstenv
#     perm                    1(?)                user                gorup               size                Mon                 Day                 time/year           File name
#     "s/^[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*.*$/\1/g"`
fnptn="s/^[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*\(.*\)$/\1/g"
szptn="s/^[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*\([^ ][^ ]*\)[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*.*$/\1/g"
mnptn="s/^[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*\([^ ][^ ]*\)[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*.*$/\1/g"
dyptn="s/^[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*\([^ ][^ ]*\)[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*.*$/\1/g"
tmptn="s/^[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*[^ ][^ ]*[ 	][ 	]*\([^ ][^ ]*\)[ 	][ 	]*.*$/\1/g"

crrsave=`pwd`
rm -rf "$tmpfile2" > /dev/null 2>&1

while [ 1 ]; do
	lnk=`grep " -> " "$tmpfile"`
	if [ -z "$lnk" ]; then
		break
	fi
	mv $tmpfile $tmpfile2
	ppath=
	cat $tmpfile2 | while read line; do
		case $line in
			*:)
				ppath=$line
				echo $line >> $tmpfile
				;;
			*" -> "*)
				fnm=`echo $line | sed -e "$fnptn"`
				f1=${fnm%" -> "*}
				f2=${fnm#*" -> "}
				dirtmp=`eval echo ${ppath%:*}`
				echo "${ppath%:*}/${f1}:" >> $tmpfile
				cd "$dirtmp/$f1"
				ls -lRp | \
					egrep -v "^total |^$|.*/$" | \
					sed	-e "s!^\./!${ppath%:*}/${f1}/!g" \
					>> "$tmpfile"
				echo $ppath >> "$tmpfile"
				;;
			*)
				echo $line >> $tmpfile
				;;
		esac
	done
	rm -rf "$tmpfile2" > /dev/null 2>&1
done
cd ${crrsave}

ppath=
cat $tmpfile | while read line; do
	case $line in
		*:)
			ppath=$line
			;;
		*)
			fnm=`echo $line | sed -e "$fnptn"`
			fnm=${fnm##*/}
			sz=`echo $line | sed -e  "$szptn"`
			if [ "$cksumf" = "true" ]; then
				tmp=`eval echo ${ppath%:*}`
				cs=`cksum "$tmp/$fnm"`
				sz="$sz # ${cs%%[ 	]*}"
			fi
			if [ "$fdate" = "true" ]; then
				mn=`echo $line | sed -e "$mnptn" | \
					sed -e "s/Jun/01/g" -e "s/Feb/02/g" \
						-e "s/Mar/03/g" -e "s/Apr/04/g" \
						-e "s/May/05/g" -e "s/Jun/06/g" \
						-e "s/Jul/07/g" -e "s/Aug/08/g" \
						-e "s/Sep/09/g" -e "s/Oct/10/g" \
						-e "s/Nov/11/g" -e "s/Dec/12/g"`
				dy=`echo $line | sed -e "$dyptn"`
				tm=`echo $line | sed -e  "$tmptn"`
				if [ "x${tm#*:}" = "x${tm}" ]; then
					yr=$tm
					tm="00:00"
				else
					yr=`date +%Y`
				fi
				let dy="$dy + 100"
				dy=${dy#${dy%??}}
				sz="$sz @ ${yr}/${mn}/${dy}_${tm}"
			fi
			if [ "$file_lower" = "true" ]; then
				echo "${ppath%:*}/`echo $fnm | tr "A-Z" "a-z"` $sz" >> "$tmpfile2"
			else
				echo "${ppath%:*}/$fnm $sz" >> "$tmpfile2"
			fi
			;;
	esac
done

echo "# TARGET=$actdir"
if [ "$debug" = "on" ]; then
echo "# lower=$file_lower, chksum=$cksumf"
fi
cat "$tmpfile2" | sort

if [ "$debug" = "off" ]; then
	rm -rf $tmpfile
	rm -rf $tmpfile2
fi
exit 0
