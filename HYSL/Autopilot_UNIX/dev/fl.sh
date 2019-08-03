#!/usr/bin/ksh
# fl.sh : File list by pattern
# Syntax: fl.sh [-h|-s|-d|-r|-l|-p <path>] <pattern>
#   <pattern> : list pattern
# Option:
#   -h        : Display help
#   -s        : Sorted by size
#   -d        : Sorted by date
#   -r        : Reverse order
#   -l        : Display detail
#   -p <path> : Target path. If you don't define <path> parameter,
#               this script get it from <pattern> using ${<pattern>%/*}.
#               If <pattern> need "/" character to determin target file,
#               you need to use -p option.
# 
# History:
# 09/05/2013 YKono First edition

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
	done | sort $srt | while read s nm; do [ "$det" = "true" ] && echo "$s:$nm" || echo "$nm"; done | egrep "$ptn"
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
det=false
while [ $# -ne 0 ]; do
	case $1 in
		-h|-hs)	( IFS=
			[ "$1" = "-hs" ] \
				&& lno=`cat $me 2> /dev/null | egrep -n -i "^# History:" | head -1` \
				|| lno=`cat $me 2> /dev/null | egrep -n -i "^# Sample:" | head -1`
			[ -z "$lno" ] && lno=`cat $me 2> /dev/null | egrep -n -i "^# History:" | head -1`
			if [ -n "$lno" ]; then
				lno=${lno%%:*}; let lno=lno-1
				cat $me 2> /dev/null | head -n $lno \
				    | grep -v "^##" | grep -v "#!/usr/bin/ksh" \
				    | while read line; do echo "${line#??}"; done
			else
				cat $me 2> /dev/null | grep -v "#!/usr/bin/ksh" \
				    | grep -v "^##" | while read line; do
					[ "$line" = "${line#\#}" ] && break
					echo "${line#??}"
				done
			fi )
			exit 0 ;;
		-his)	( IFS=; his=
			cat $me 2> /dev/null | while read line; do
				[ "$line" = "${line#\#}" ] && break
				if [ -n "$his" -o -n "`echo $line | egrep -i \"^# History:\"`" ]; then
					his=true
					echo "${line#??}"
				fi
			done ) 
			exit 0 ;;
		-s)	md="sz";;
		-d)	md="dt";;
		-r)	srt="-r";;
		-l)	det=true;;
		-p)	if [ $# -gt 2 ]; then
				pth=$2
				shift
			else
				echo "keepnth.sh : '-p' parameter need second parameter as path definition."
				exit 1
			fi ;;
		*)	[ -z "$ptn" ] && ptn=$1 || let rcnt=`echo $1` 2> /dev/null;;
	esac
	shift
done

if [ -z "$ptn" ]; then
	echo "fl.sh : Parameter error."
	echo "Syntax: fl.sh [-s|-d|-r|-l|-p <path>] <pattern>"
	echo " <pattern> : egrep pattern to list."
	echo "Org Params : $@"
	exit 1
fi

if [ -z "$pth" ]; then
	pth=${ptn%/*}
	[ "$pth" = "$ptn" ] && pth="." || ptn=${ptn##*/}
fi
list_files
exit 0
