#!/usr/bin/ksh
# get_goodlatest.sh : Get good build from the pre_rel folder
# Syntax: get_goodlatest.sh [-h] <ver>
#   <ver>  Version number to get the good build
# External reference:
#   data/bldcond.txt : Build condition
#                      <ver>=<plat> [<plat>...] [DoneTHreshold(<donecnt>)|refresh(true|false)|RCDate(yyyy/mm/dd)]
# History:
# 2013/10/03 YKono First edition

. apinc.sh

# Condition definition file name and location
floc=$AUTOPILOT/data/buildcond.txt
ignplat="aix solaris"

me=$0
orgpar=$@
ver=
cnd=
dbg=false
ignlst=
while [ $# -ne 0 ]; do
	case $1 in
		-h)	( IFS=
			lno=`cat $me 2> /dev/null | egrep -n -i "# History:" | head -1`
			if [ -n "$lno" ]; then
				lno=${lno%%:*}; let lno=lno-1
				head -n $lno $me \
					| grep -v "^##" | grep -v "#!/usr/bin/ksh" \
					| while read line; do echo "${line#??}"; done
			else
				cat $me 2> /dev/null | grep -v "#!/usr/bin/ksh" \
					| grep -v "^##" | while read line; do
					[ "$line" = "${line#\#}" ] && break
					echo "${line#??}"
				done
			fi )
			exit 0
			;;
		-c)	shift
			cnd=$1
			;;
		-d)	dbg=true;;
		-dbg)	dbg=true;;
		-nodbg)	dbg=false;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			else
				echo "${me##*/}:Too many parameter."
				exit 1
			fi
			;;
	esac
	shift
done

# Check each definitions
if [ -z "$ver" ]; then
	echo "${me##*/}: No <ver> parameter defined."
	exit 2
fi

if [ -z "$BUILD_ROOT" ]; then
	echo "${me##*/}: No \$BUILD_ROOT defined."
	exit 3
fi

if [ ! -d "$BUILD_ROOT" ]; then
	echo "${me##*/}: Cannot access $BUILD_ROOT location."
	exit 4
fi

if [ ! -d "$BUILD_ROOT/$ver" ]; then
	echo "${me##*/}:Cannot access $ver folder under $BUILD_ROOT."
	exit 5
fi

# Get version condition from data/bldcond.txt
older=8
donecnt=40
allowrefresh=false
plats=
ignplats=
if [ -f "$floc" -o -n "$cnd" ]; then
	[ -z "$cnd" ] && cnd=`cat $floc 2> /dev/null | grep "^${ver}=" | tail -1`
	cnd=${cnd#*=}; cnd=${cnd%#*}
	for one in $cnd; do
		case $one in
			all)	plats=all;;
			`isplat $one`)
				one=`realplat.sh $one`
				[ -z "`echo $plats | grep $one`" ] && plats="$plats $one"
				;;
			*)	;;
		esac
	done
	s=`chk_para.sh rcdate "$cnd"`; s=${s##* }
	if [ -n "$s" ]; then
		rcdate=${s%${s#????}}
		s=${s#?????}
		rcdate="${rcdate}${s%${s#??}}${s#${s%??}}"
		today=`date +%Y%m%d`
		if [ "$today" -gt "$rcdate" ]; then
			allowrefresh=false
		else
			allowrefresh=true
		fi
	fi
	s=`chk_para.sh refresh "$cnd"`; s=${s##* }
	[ -n "$s" ] && allowrefresh=$s
	s=`chk_para.sh donethreshold "$cnd"`; s=${s##* }
	[ -n "$s" ] && donecnt=$s
	s=`chk_para.sh old "$cnd"`; s=${s##* }
	[ -n "$s" ] && older=$s
	s=`chk_para.sh ignplat "$cnd"`
	[ -n "$s" ] && ignplats=$s
	s=`chk_para.sh ignbld "$cnd"`
	[ -n "$s" ] && ignlst=$s
fi

let older=older*24
[ -z "$ignplats" ] && ignplats=$ignplat
if [ -z "$plats" -o -n "`echo $plats | grep all`" ]; then
	plats=
	for one in `isplat`; do
		one=`realplat.sh $one`
		[ -z "`echo $plats | grep $one`" ] && plats="$plats $one"
	done
fi
tmplat=
for one in $plats; do
	if [ -z "`echo $ignplats | grep $one`" ]; then
		[ -z "$tmplat" ] && tmplat=$one || tmplat="$tmplat $one"
	fi
done
plats=$tmplat

if [ "$dbg" = "true" ]; then
	echo "# cnd=<$cnd>"
	echo "# ver=$ver"
	echo "# plats=$plats"
	echo "# ignpalts=$ignplats"
	echo "# allowrefresh=$allowrefresh"
	echo "# donecnt=$donecnt"
	echo "# rcdate=$rcdate"
	echo "# today=$today"
	echo "# older=$older"
	echo "# ignlst=$ignlst"
fi

badblds=$ignlst
while [ 1 ]; do
	bld=`get_latest.sh -n $ver $badblds`
	if [ $? -eq 0 ]; then
		if [ -n "$bld" ]; then
			good=true
			for one in $plats; do
				ret=`ckbld.sh $one $ver $bld`
				sts=$?
				[ "$dbg" = "true" ] && echo "# CHECK $bld - $one - $ret"
				case ${ret%% *} in
					0)	
						elap=${ret##* }
						elap=${elap%%\(*}
						if [ "$elap" -gt "$older" ]; then
							echo "${me##*/}:There is no good build for $ver."
							echo "bld=$bld, ret=$ret, older=$older."
							exit 6
						fi
						;;
					opack*)
						if [ "$allowrefresh" != "true" ]; then
							good=false
							break
						fi
						;;
					*)	good=false;;
				esac
			done
			if [ "$good" != "true" ]; then
				badblds="$badblds $bld"
			else
				echo "$bld $allowrefresh"
				exit 0
			fi
		else
			echo "${me##*/}:There is no good build for $ver."
			echo "badblds=$badblds"
			exit 6
		fi
	else
		echo "Error returned from get_latest.sh -n $ver $badblds ($?)."
		exit 7
	fi
done

