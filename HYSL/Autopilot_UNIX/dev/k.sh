#!/usr/bin/ksh
# keepnth.sh : Remove files which over N-th count
# Syntax:   keepnth.sh [-s|-d|-r|-p <path>] <pattern> [ <remcnt> ]
#     <pattern> : egrep pattern for deleting files. i.e. kennedy_*.txt
#     <remcnt>  : The count for remained files. (Default 10)
# Option:
#     -s        : Sorted by size
#     -d        : Sorted by date
#     -r        : Reverse order
#     -p <path> : Target path. If you don't define <path> parameter,
#                 this script get it from <pattern> using ${<pattern>%/*}.
#                 If <pattern> need "/" character to determin target file,
#                 you need to use -p option.
#
# History:
# 09/05/2013 YKono Bug 17349226 - DIRCMP ISN'T GENERATING SIZ FILE FOR DIRCMP

# Functions:
dg() # dg [-w <wid>|-z|-s] <str>
{
	_fch="0"; _wid=16; _trgs=
	while [ $# -ne 0 ]; do
		case $1 in
			-z)     _fch="0";;
			-s)     _fch=" ";;
			-c)     if [ $# -gt 1 ]; then
					_fch=$2
					shift
				fi;;
			-w)     if [ $# -gt 1 ]; then
					_wid=$2
					shift
				fi;;
			*)      [ -z "$_trgs" ] && _trgs=$1 || _trgs="$_trgs $1" ;;
		esac
		shift
	done
	if [ -n "$_trgs" ]; then
		_i=0; _fs=; _qs=
		while [ "$_i" -lt "$_wid" ]; do
			_fs="${_fs}${_fch}"
			_qs="${_qs}?"
			let _i=_i+1
		done
		for _trg in $_trgs; do
			(IFS=; n="${_fs}${_trg}"; n=${n#${n%${_qs}}}; echo $n)
		done
	fi
}

dt() # dt <abbr-mon> <day> <year>|<time>
{
	if [ $# -eq 3 ]; then
		if [ "${3#*:}" != "$3" ]; then
			_h=`dg -w 2 ${3%:*}`
			_mm=`dg -w 2 ${3#*:}`
			_y=$yr
		else
			_h="00"
			_mm="00"
			_y=$3
		fi
		case $1 in
			Jan)	_m=01;;
			Feb)	_m=02;;
			Mar)	_m=03;;
			Apr)	_m=04;;
			May)	_m=05;;
			Jun)	_m=06;;
			Jul)	_m=07;;
			Aug)	_m=08;;
			Sep)	_m=09;;
			Oct)	_m=10;;
			Nov)	_m=11;;
			Dec)	_m=12;;
		esac
		_d=`dg -w 2 $2`
		echo "$_y$_m$_d$_h$_mm"
	fi
}

list_files()
{
	ls -l ${pth} 2> /dev/null | grep -v "^total" | while read attr id usr grp siz m d y nm; do
		case $md in
			nm)	s=$nm;;
			sz)	s=`dg $siz`;;
			dt)	s=`dt $m $d $y`;;
		esac
		echo "$s $nm"
	done | sort $srt | while read s nm; do echo "$nm"; done | egrep "$ptn"
}

# Main
me=$0
orgpar=$@
md="nm"	# can be nm/sz/dt
yr=`date +%Y`
pth=
ptn=
srt=
rcnt=
while [ $# -ne 0 ]; do
	case $1 in
		-s)	md="sz";;
		-d)	md="dt";;
		-r)	srt="-r";;
		-p)	if [ $# -gt 2 ]; then
				pth=$2
				shift
			else
				echo "keepnth.sh : '-p' parameter need second parameter as path definition."
				exit 1
			fi
			;;
		*)	[ -z "$ptn" ] && ptn=$1 || let rcnt=`echo $1`;;
	esac
	shift
done

if [ -z "$ptn" ]; then
	echo "keepnth.sh : Parameter error."
	echo "keepnth.sh [-s|-d|-r|-p <path>] <pattern> [ <remcnt> ]"
	echo " <pattern> : ls pattern for remove."
	echo " <remcnt>  : remain count."
	echo "Org Params : $@"
	exit 1
fi
[ -z "$rcnt" ] && rcnt=10

if [ -z "$pth" ]; then
	pth=${ptn%/*}
	[ "$pth" = "$ptn" ] && pth="." || ptn=${ptn##*/}
fi
list_files
cnt=`list_files | wc -l`
let cnt="$cnt - $rcnt"
if [ $cnt -gt 0 ]; then
	# ls $PATH | egrep "$_ptn" 2> /dev/null | sort | head -${cnt} | while read fn; do
	# find $_path -name "$_ptn" 2> /dev/null | sort | head -${cnt} | while read fn; do
	list_files | head -${cnt} | while read fn; do
		# rm -rf $fn > /dev/null 2>&1
		echo "`date +%D_%T` $fn" 
	done
fi
exit 0
