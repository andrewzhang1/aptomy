#!/usr/bin/ksh
# Get Essbase latest build number.
# Syntax : get_latest.sh [<prod>][-h|-p <plat>|-a|-n] <f-ver#>
# Parameter:
#   <f-ver#> : Full version number like 7.1/7.1.6.7, 9.2/9.3.0.3.0 and kennedy2
# Option:
#   -h:        Display help.
#   -p <plat>: Display build number for specific platform
#   -a:        Display all latest build.
#   -n <prod>: Do not use "latest" folder for Essbase.
#              Use maximum number of the build number which doesn't contain
#              alphabet character and symbols.
#              If you define <prod> parameter, this program return each latest.
#   <prod>:=aps/studio/eas
# Return:
#  0 : Display latest number.
#  1 : Parameter error.
#  2 : Illegal version or platform.
#  3 : No BUILD_ROOT definition
# History:
# 05/20/2009	YKono	Remove ver_cmstrct.sh call.
# 09/23/2010	YKono	Add "all" for <plat> option.
# 08/18/2013	YKono	Support dangling "latest" link. > Remove this feature
# 09/18/2013	YKono   Support -n option

. apinc.sh

aps_reloc="../../eesdev/aps"
studio_reloc="../../bailey/builds"
eas_reloc="../../eas/builds"

me=$0
orgpar=$@
unset ver
unset plat
unset nolatest
kind=essbase
ign=
dbg=false
while [ $# -ne 0 ]; do
	case $1 in
		`isplat $1`) plat=$1 ;;
		-a|all|-all)
			list=`isplat`
			plat=
			for one in $list; do
				if [ -n "`echo  $one | grep -v exa$`" ]; then
					[ -z "$plat" ] && plat="$one" || plat="$plat $one"
				fi
			done
			;;
		-p|-plat)
			if [ $# -lt 2 ]; then
				echo "-p need <plat> paramter."
				echo "params: $orgpar"
				exit 1
			fi
			plat=$1
			shift ;;
		-n|-nolatest|nolatest)
			nolatest=true;;
		-d|-dbg)	dbg=true;;
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
		aps|APS)	kind=aps;;
		studio|STUDIO)	kind=studio;;
		eas|EAS)	kind=eas;;
		*)	if [ -z "$ver" ]; then
				ver=$1
			else
				[ -z "$ign" ] && ign=$1 || ign="$ign|$1"
			fi
			;;
	esac
	shift
done

[ -z "$plat" ] && plat=`get_platform.sh`
[ -n "$ign" ] && nolatest=true
if [ "$dbg" = "true" ]; then
	echo "# plat=\"$plat\""
	echo "# kind=\"$kind\""
	echo "# ver=\"$ver\""
	echo "# nolatest=\"$nolatest\""
	echo "# ign=\"$ign\""
fi
if [ -z "$ver" ];then
	echo "#PAR"
	echo "No version parameter."
	echo "params=$orgpar"
	exit 1
fi
if [ -z "$BUILD_ROOT" ]; then
	echo "#VAR"
	echo "No \$BUILD_ROOT defined."
	exit 3
fi
if [ ! -d "$BUILD_ROOT" ]; then
	echo "#VAR"
	echo "Coudln't access \$BUILD_ROOT($BUILD_ROOT) folder."
	exit 3
fi

# Check AP_<PROD>ROOT location.(AP_ESSBASEROOT, AP_APSROOT, ...)
str=`echo $kind | tr a-z A-Z`
val=`eval echo \\$AP_${str}ROOT`
if [ -n "$val" -a -d "$val" ]; then
	prodroot="$val"
else
	# Otherwise, set $BUILD_ROOT/<prod>_reloc location to product root.
	val=`eval echo \\$${kind}_reloc`
	[ -n "$val" ] && prodroot="$BUILD_ROOT/$val" || prodroot=$BUILD_ROOT
fi
if [ ! -d "$prodroot" ]; then
	echo "#ROOT"
	echo "Couldn't access to $prodroot(root of $kind) folder."
	echo "version=$ver, platform=$plat."
	exit 2
fi
if [ ! -d "${prodroot}/${ver}" ]; then
	echo "#VER"
	echo "Couldn't access to the version($ver) folder for $kind."
	echo "prodroot=$prodroot, ver=$ver, plat=$plat."
	exit 2
fi

if [ "$nolatest" = "true" ]; then
	[ -n "$ign" ] \
		&& ls $prodroot/$ver 2> /dev/null | egrep ^[0-9]+$ | egrep -v ^9+$ | egrep -v "$ign" | tail -1 \
		|| ls $prodroot/$ver 2> /dev/null | egrep ^[0-9]+$ | egrep -v ^9+$ | tail -1 
else
	if [ "$kind" = "essbase" ]; then
		for one in $plat; do
			if [ "$one" = "$plat" ]; then
				_p=
			else
				_p="$one              "
				_p=${_p%${_p#?????????????}}
			fi
			if [ -d "$prodroot/$ver/latest/cd/$one" ]; then # old format
				echo "$_p`ls $prodroot/$ver/latest/cd/$one \
					| grep [0-9] | tr -d '\r'`"
			elif [ -d "$prodroot/$ver/latest/$one" ]; then # new format
				echo "$_p`cat $prodroot/$ver/latest/$one/bldno.sh \
					| awk -F= '{print $2}' | tr -d '\r'`"
			else
				echo "$_p`ls $prodroot/$ver 2> /dev/null | egrep ^[0-9]+$ | egrep -v ^9+$ | tail -1 ` (nolatest)"
			fi
		done
	else
		if [ -f "$prodroot/$ver/latest/bldnum.txt" ]; then
			tarbld=`cat $prodroot/$ver/latest/bldnum.txt | tail -1 | tr -d '\r'`
		else
			if [ -n "$ign" ]; then
				tarbld=`ls $prodroot/$ver 2> /dev/null | \
					egrep ^[0-9]+$ | egrep -v ^9+$ | egrep -v "$ign" | tail -1`
			else
				tarbld=`ls $prodroot/$ver 2> /dev/null | \
					egrep ^[0-9]+$ | egrep -v ^9+$ | tail -1 | tr -d '\r'`
			fi
		fi
		echo $tarbld
	fi
fi

exit 0
