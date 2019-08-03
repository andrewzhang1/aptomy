#!/usr/bin/ksh
# Search BASE HIT build number by Essbase version number
# SYNTAX:
#   get_opackbase.sh [-h|-v <ver>|-o <opt>|-p <plat>|-dbg] <ver#> <bld>
# Parameters:
#   <ver#>     : Essbase version number
#   <bld>      : Essbase build number
# Options:
#   -h         : Display help
#   -ver <ver> : Use <ver> for version filter
#   -opt <opt> : Task option.
#                This script read "OpackVer()" option.
#   -p <plat>  : Target platform.(Default is current platform)
#   -dbg       : Debug execution.
# OUT:
#	0 : HIT version number
#	1 : Parameter error
#	2 : No opack folder
#
###############################################################################
# HISTORY:
# 07/01/2011 YK First edition
# 04/12/2012 YK Add -ver parameter to get specific version from mutiple vers opack
# 06/11/2012 YK Support BI 11.1.1.7 format name
# 01/28/2013 YK Fix opackver() problem with 11.1.1.3.502.
# 07/29/2013 YK Bug 17236987 - GET_OPACKBASE.SH SHOULD SUPPORT INVENTORY.XML FILE ALSO

. apinc.sh

me=$0
orgp=$@
ver=
bld=
opbld=latest
fltver=
trgplat=${thisplat}
dbg=false
while [ $# -ne 0 ]; do
	case $1 in
		+d|-dbg)
			dbg=true
			;;
		-d|-nodbg)
			dbg=false
			;;
		-p|-plat)
			if [ $# -lt 2 ]; then
				echo "${me##*/}: \"$1\" need second parameter as the platform."
				exit 1
			fi
			shift
			trgplat=$1
			;;
		p=*|plat=*)
			trgplat=${1#*=}
			;;
		p:*|plat:*)
			trgplat=${1#*:}
			;;
		-h)
			display_help.sh $me
			exit 0
			;;
		-opack|opack)
			shift
			if [ $# -eq 0 ]; then
				echo "get_opackbase.sh : -opack need the opack build number as 2nd parameter."
				exit 1
			fi
			opbld=$1
			;;
		ver:*|ver=*)
			fltver=${1#????}
			;;
		-v|-ver|ver)
			if [ $# -lt 2 ]; then
				echo "${me##/}: \"$1\" parameter need a filter version number."
				exit 1
			fi
			shift
			fltver=$1
			;;
		-o|-opt|opt)
			if [ $# -lt 2 ]; then
				echo "${me##/}: \"$1\" parameter need a second parameter."
				exit 1
			fi
			shift
			[ -z "$_OPTION" ] && export _OPTION="$1" || export _OPTION="$_OPTION $1"
			;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			elif [ -z "$bld" ]; then
				bld=$1
			else
				echo "Too much parameters."
				echo "Params: $orgp"
				exit 1
			fi
			;;
	esac
	shift
done

if [ -z "$BUILD_ROOT" -o ! -d "$BUILD_ROOT" ]; then
	echo "Couldn't access \$BUILD_ROOT($BUILD_ROOT) folder."
	exit 1
fi

if [ -z "$ver" -o -z "$bld" ]; then
	echo "Few parameters."
	echo " ver=$ver"
	echo " bld=$bld"
	echo " par=$orgp"
	exit 1
fi

[ -z "$fltver" ] && fltver="$ver"

if [ -n "$_OPTION" ]; then
	_opt=`chk_para.sh opackver "$_OPTION"`
	[ -n "$_opt" ] && fltver="${_opt##* }"
fi

bld=`normbld.sh $ver $bld`
if [ $? -ne 0 ]; then
	echo "Failed to normalize build number."
	echo "$bld"
	exit 1
fi

if [ ! -d "$BUILD_ROOT/$ver/$bld" ]; then
	echo "No $BUILD_ROOT/$ver/$bld folder."
	exit 1
fi

if [ ! -d "$BUILD_ROOT/$ver/$bld/opack" ]; then
	echo "No opack folder under $BUILD_ROOT/$ver/$bld folder."
	exit 1
fi

# Copy zip files into $VIEW_PATH/opack.
zipf=
trgplat=`realplat.sh $trgplat`
if [ "$dbg" = "true" ]; then
	echo "# ver=$ver"
	echo "# bld=$bld"
	echo "# fltver=$fltver"
	echo "# _OPTION=$_OPTION"
	echo "# trgplat=$trgplat"
fi
if [ -d "$BUILD_ROOT/$ver/$bld/opack/$trgplat" ]; then
	# Case Refresh opack
	zipf=`ls $BUILD_ROOT/$ver/$bld/opack/$trgplat/*.zip | head -1`
else
	# ls $BUILD_ROOT/$ver/$bld/opack/*${fltver}*_${trgplat}_*.zip > /dev/null 2>&1
	if [ "${fltver#!}" != "$fltver" ]; then
		fl=`ls $BUILD_ROOT/$ver/$bld/opack/*_${trgplat}_*.zip 2> /dev/null | grep -v "${fltver#!}"`
	else
		fl=`ls $BUILD_ROOT/$ver/$bld/opack/*_${trgplat}_*.zip 2> /dev/null | grep "$fltver"`
	fi
	if [ -n "$fl" ]; then
		zipf=`echo $fl | awk '{print $1}'`
	else
		crrdir=`pwd`
		cd $BUILD_ROOT/$ver/$bld/opack
		if [ "$opbld" = "latest" ]; then
			opblds=`ls -1r | grep "^[0-9][0-9]*$"`
			for one in $opblds; do
				ls $one/$trgplat/*.zip > /dev/null 2>&1
				if [ $? -eq 0 ]; then
					opbld=$one
					break
				fi
				ls $one/*.zip > /dev/null 2>&1
				if [ $? -eq 0 ]; then
					opbld=$one
					break
				fi
			done
		fi
		cd $crrdir
		if [ "${fltver#!}" != "$fltver" ]; then
			fl=`ls $BUILD_ROOT/$ver/$bld/opack/$opbld/${trgplat}/*.zip 2> /dev/null | grep -v "${fltver#!}"`
		else
			fl=`ls $BUILD_ROOT/$ver/$bld/opack/$opbld/${trgplat}/*.zip 2> /dev/null | grep "$fltver"`
		fi
		if [ -n "$fl" ]; then
			zipf=`echo $fl | awk '{print $1}'`
		else
			if [ "${fltver#!}" != "$fltver" ]; then
				fl=`ls $BUILD_ROOT/$ver/$bld/opack/$opbld/*_${trgplat}_*.zip 2> /dev/null | grep -v "${fltver#!}"`
			else
				fl=`ls $BUILD_ROOT/$ver/$bld/opack/$opbld/*_${trgplat}_*.zip 2> /dev/null | grep "$fltver"`
			fi
			if [ -n "$fl" ]; then
				zipf=`echo $fl | awk '{print $1}'`
			else
				unset zipf
			fi
		fi
	fi
fi

if [ -z "$zipf" ]; then
	echo "Couldn't find the opack zip file for $ver:$bld"
	exit 1
fi

cd $HOME
unzipcmd=`which unzip`
if [ $? -ne 0 -o "x${unzipcmd#no}" != "x${unzipcmd}" ]; then
        case `uname` in
                HP-UX)  unzipcmd=`which unzip_hpx32`;;
                Linux)  unzipcmd=`which unzip_lnx`;;
                SunOS)  unzipcmd=`which unzip_sparc`;;
                AIX)    unzipcmd=`which unzip_aix`;;
        esac
fi
if [ $? -ne 0 -o -z "${unzipcmd}" ]; then
        echo "Couldn't find the unzip command."
        exit 1
fi
rm -rf .opackbasetmp.$$ > /dev/null 2>&1
mkdir .opackbasetmp.$$ > /dev/null 2>&1
cd .opackbasetmp.$$ > /dev/null 2>&1
cp $zipf . > /dev/null 2>&1
zipf=$(basename $zipf)
[ -f unzip.log ] && rm -rf unzip.log > /dev/null 2>&1
${unzipcmd} -o ${zipf} > unzip.log 2> /dev/null
opdir=`grep "creating" unzip.log | head -1 | awk '{print $2}'`
opdir=${opdir%?}
# echo "opdir=$opdir"
invf="$opdir/etc/config/inventory"
[ -f "${invf}.xml" ] && invf="${invf}.xml"
if [ ! -f "$invf" ]; then
	echo "$zipf doesn't contain correct $invf."
	exit 1
fi
lnm=`grep -n "<required_components>" $invf`
lnm=${lnm%:*}
ttl=`wc -l $invf`
ttl=${ttl% *}
let tlnm=ttl-lnm
cmpver=`tail -${tlnm} $invf | grep "version=" | head -1`
bi=
if [ "${cmpver#*oracle.bi.bi}" != "$cmpver" ]; then
	bi="bi:"
fi
cmpver=${cmpver#*version=\"}
cmpver=${cmpver%%\"*}
# echo "cmpver=$cmpver"
cd $HOME
[ "$dbg" != "true" ] && rm -rf .opackbasetmp.$$ > /dev/null 2>&1
echo "${bi}`ver_codename.sh $cmpver | tr -d '\r'`"
exit 0
