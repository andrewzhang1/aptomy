#!/usr/bin/ksh
# Check build status
# Syntax : ckbld.sh [-h|-p <plat>|-a] <ver> <bld>
# Parameter:
#   <ver> : Version number for check
#   <bld> : Build number for check
# Option:
#   -h:        Display help.
#   -p <plat>: Display build number for specific platform
#   -a:        Display all latest build.
# Return:
#   0: Build is Okay
#   1: Parameter error
#   2: No <ver>/<bld>/logs folder
#   3: No essbase_<plat>.txt in the 
#   4: Build Failure
#   5: Acceptance failure
#   6: opack failure
#   7: Build is okay but time is over than 12hrs
# History:
# 09/18/2013	YKono   First edition

. apinc.sh

unset set_vardf
set_vardef AP_BUILDTHRESHOLDHOUR

# Function
# get_time_diff <fname>
#   Get elapsed hours for <fname> from last updated time to now.
get_time_diff()
{
	if [ -f "$1" ]; then
		export _pfname=$1
		perl -e 'sub leapyc() { $_y=($_[0]==0) ? 0 : $_[0] - 1; return int($_y/4)-int($_y/100)+int($_y/400); }
			$_fnm=$ENV{'_pfname'}; $_nm=$_fnm; $_nm=~s/^.+\/(.+)$/$1/g;
			($_fsc,$_fmi,$_fhr,$_fdy,$_fmo,$_fyr,$_wdy,$_fdoy,$_dst)=localtime((stat($_fnm))[9]);
			($_csc,$_cmi,$_chr,$_cdy,$_cmo,$_cyr,$_wdy,$_cdoy,$_dst)=localtime(time);
			$_fyr+=1900; $_cyr+=1900; $_fmo++; $_cmo++;
			$_clyc=&leapyc($_cyr); $_flyc=&leapyc($_fyr);
			if ($_cyr > $_fyr) { $_cdoy+=($_cyr-$_fyr)*365+($_clyc-$_flyc); }
			elsif ($_cyr < $_fyr) { $_fdoy+=($_fyr-$_cyr)*365+($_flyc-$_clyc); }
			$_ftime=$_fdoy*24*60*60+$_fhr*60*60+$_fmi*60;
			$_ctime=$_cdoy*24*60*60+$_chr*60*60+$_cmi*60;
			$_d=$_ctime-$_ftime; $_dh=int($_d/(60*60));
			printf("%s:%04d/%02d/%02d_%02d:%02d:%02d %d",
				$_nm, $_fyr,$_fmo,$_fdy,$_fhr,$_fmi,$_fsc, $_dh);'
			#printf("%s:%04d/%02d/%02d_%02d:%02d:%02d-%d Crr:%04d/%02d/%02d_%02d:%02d:%02d-%d %d",
			#	$_nm, $_fyr,$_fmo,$_fdy,$_fhr,$_fmi,$_fsc,$_fdoy,
			#	$_cyr,$_cmo,$_cdy,$_chr,$_cmi,$_csc,$_cdoy,$_dh);'
	else
		echo "#NA"
	fi
}

me=$0
orgpar=$@
unset ver bld plat
to=$AP_BUILDTHRESHOLDHOUR
[ -z "$to" ] && to=12
while [ $# -ne 0 ]; do
	case $1 in
		`isplat $1`) [ -z "$plat" ] && plat=$1 || plat="$plat $1";;
		-a|all|-all)
			plat=`isplat`;;
		-p|-plat)
			if [ $# -lt 2 ]; then
				echo "${me##*/}:-p need <plat> paramter."
				echo "params: $orgpar"
				exit 1
			fi
			[ -z "$plat" ] && plat=$2 || plat="$plat $2"
			shift ;;
		-h|help|-help)
			( IFS=
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
			exit 0 ;;
		-t)	shift
			if [ $# -lt 1 ]; then
				echo "${me##*/}:-t need <threshold-hour> as second parameter."
				echo "params: $orgpar"
				exit 1
			fi
			to=$1;;
		*)	if [ -z "$ver" ]; then
				ver=$1
			elif [ -z "$bld" ]; then
				bld=$1
			else
				echo "${me##*/}:Too much parameter."
				echo "params=$orgpar"
				exit 1
			fi
			;;
	esac
	shift
done

if [ -z "$ver" ];then
	echo "${me##*/}:No <ver> parameter."
	echo "ver=$ver"
	echo "bld=$bld"
	echo "params=$orgpar"
	exit 1
fi
if [ -z "$bld" -o "$bld" = "latest" ]; then
	bld=`get_latest.sh -n $ver`
	_b=$bld
fi
if [ -z "$BUILD_ROOT" ]; then
	echo "${me##*/}:No \$BUILD_ROOT defined."
	exit 3
fi

[ -z "$plat" ] && plat=`get_platform.sh`
sts=0
if [ -d "$BUILD_ROOT/$ver/$bld/logs" ]; then
	for one in $plat; do
		if [ "$one" = "$plat" ]; then
			_p=
		else
			_p="$one              "
			_p=${_p%${_p#?????????????}}
		fi	
		if [ -n "$_b" -a -n "$_p" ]; then
			echo "latest($_b)"
			unset _b
		fi
		one=`realplat.sh $one`
		if [ -f "$BUILD_ROOT/$ver/$bld/logs/essbase_${one}.txt" ]; then
			sts=`tail -1 $BUILD_ROOT/$ver/$bld/logs/essbase_${one}.txt | tr -d '\r'`
			if [ "$sts" != "${sts##*EXITCODE is}" ]; then
				sts=${sts##* }
			else
				sts=notyet
			fi
			if [ "$sts" != "0" ]; then # Check each process
				chktmpf=$HOME/.${thisnode}.bldchk.tmp
				rm -rf $chktmpf
				cat $BUILD_ROOT/$ver/$bld/logs/essbase_${one}.txt 2> /dev/null \
					| grep -n "Target started:" | tr -d '\r' >> $chktmpf
				txtttl=`cat $BUILD_ROOT/$ver/$bld/logs/essbase_${one}.txt 2> /dev/null | wc -l`
				ttl=`cat $chktmpf | wc -l`
				for ckitm in build pre_rel tst opack; do
					st=`cat $chktmpf | grep -n "${ckitm}$"`
					if [ -n "$st" ]; then
						sts=$ckitm
						st=${st%%:*}
						let tl=ttl-st+1
						st=`cat $chktmpf | tail -n $tl | head -1`
						st=${st%%:*}
						if [ "$tl" -gt 1 ]; then
							let tl=tl-1
							ed=`cat $chktmpf | tail -n $tl | head -1`
							ed=${ed%%:*}
						else
							ed=$txtttl
						fi
						let tl=txtttl-st+1
						[ "$ed" = "$txtttl" ] && let ed=ed+1
						let hd=ed-st
						err=`cat $BUILD_ROOT/$ver/$bld/logs/essbase_${one}.txt 2> /dev/null \
							|  tail -n ${tl} | head -n ${hd} | grep "ERROR: EXITCODE =" `
						if [ -n "$err" ]; then
							sts="${sts}-err"
							break
						fi
					fi
				done
				rm -rf $chktmpf
			fi
			sts="$sts `get_time_diff $BUILD_ROOT/$ver/$bld/logs/essbase_${one}.txt`($to)"
		else
			sts=notxt
		fi
		if [ -n "$_p" ]; then # Multiple platform
			[ "$sts" != "notxt" ] && echo "$_p:$sts"
		else
			echo "$sts"
		fi
	done
else
	echo "${me##*/}:No $ver/$bld/logs folder."
	echo "version=$ver, build=$bld, platform=$plat."
	exit 2
fi
case ${sts%% *} in
	notxt)	exit 3 ;;
	build*)	exit 4 ;;
	tst*)	exit 5 ;;
	opack*)	exit 6 ;;
esac
elaptime=${sts##* }
elaptime=${elaptime%%\(*}
[ "$elaptime" -gt "$to" ] && exit 7 || exit 0
