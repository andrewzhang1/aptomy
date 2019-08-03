#!/usr/bin/ksh
###########################################################
# Filename: get_resloc.sh
# Author: Y.Kono
# Description: Return result store location.
# Syntax: get_resloc.sh <ver> <bld>|- <test> [<test-param>...]
#   <ver>  Essbase version
#   <bld>  Essbase build. If you pass "-" to this parameter,
#          This script won't create RTF file. It just return
#          a result location.
#   <test> Test name.
# Return:
#   0: Return following strings
#      <result-directory>|<RTF-file-name>|<RelTAG>|<TAG>
#   #: Error
###########################################################
# 05/25/2011 YK First edition
# 10/03/2013 YK Add <bld> parameter and support TAG and RelTag option
. apinc.sh
umask 000
set_vardef AP_RESLOC > /dev/null 2>&1
unset ver bld tst resloc rtfname reltag tag
while [ $# -ne 0 ]; do
	case $1 in
		-o)	shift
			[ -z "$_OPTION" ] && export _OPTION=$1 || export _OPTION="$_OPTION $1"
			;;
		*)	if [ -z "$ver" ]; then
				ver=$1
			elif [ -z "$bld" ]; then
				bld=$1
			else
				[ -z "$tst" ] && tst=$1 || tst="$tst $1"
			fi
			;;
	esac
	shift
done
if [ -z "$ver" -o -z "$bld" -o -z "$tst" ]; then
	echo "#Not enough parameters."
	exit 1
fi
ver=${ver##*/}
# Normalize Result location and default value
tag=`chk_para.sh tag "$_OPTION"`
tag=${tag##* }
reltag=`chk_para.sh reltag "$_OPTION"`
reltag=${reltag##* }
realoc=`chk_para.sh realpath "$_OPTION"`
realoc=${realoc##* }
[ -n "$realoc" ] && resloc=$realoc || resloc=$AP_RESLOC
if [ -n "$AP_RESFOLDER" ]; then
	resdir=$AP_RESFOLDER
else
	_i18n=`echo $tst | grep ^i18n_`
	if [ "$_i18n" -o -n "$AP_I18N" ]; then
		resdir=i18n/essbase
	elif [ "$tst" = "xprobmain.sh" ]; then
		resdir=i18n/essbase
	else
		resdir=essbase
	fi
fi
resloc="${resloc}/${ver}${reltag}/${resdir}"
[ -d "$resloc" ] || mkddir.sh "$resloc"
cd $resloc
resloc=`pwd`
# Decide the RTF file name
if [ "$bld" != "-" ]; then
	# Assign Short Names to Tests
	abbr=`chk_para.sh abbr "$_OPTION"`
	if [ -z "$abbr" ]; then
		abbr=`cat $AUTOPILOT/data/shabbr.txt | grep "^$tst:" | tr -d '\r' | awk -F: '{print $2}'`
		if [ -z "$abbr" ]; then
			if [ "$tst" = "${tst#* }" ]; then
				abbr=${tst%.*}
			else
				abbr="${tst%.*}_`echo ${tst#* } | sed -e s/\ /_/g`"
			fi
		fi
	fi
	# Decide .rtf file name
	n=01
	plat=`get_platform.sh -l`
	lastrtf=`ls -r ${plat}_${bld}_${abbr}_*.rtf 2> /dev/null | head -1`
	if [ -n "$lastrtf" ]; then
		n=${lastrtf##*_}
		n=${n%.*}
		let n=n+1 2> /dev/null
		n="00${n}"
		n=${n#${n%??}}
	fi
	rtfname=${plat}_${bld}_${abbr}_${n}.rtf
	touch $rtfname
fi
echo "${resloc}:${rtfname}:${reltag}:${tag}"
exit 0

