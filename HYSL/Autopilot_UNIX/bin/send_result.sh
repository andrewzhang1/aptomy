#!/usr/bin/ksh
######################################################################
# send_result.sh : Send test result to Web location
# Description: Will gather results after Regressions
#		and send to Repository
# Syntax:
#   send_result.sh [<option>] <ver> <bld> <tst> [<parms>...]
# Parameters:
#   <ver>   : Essbase version
#   <bld>   : Essbase build
#   <tst>   : Test script name
#   <parms> : Test parameters is <tst> needed.
# Options: [-h|-fromap|-notfromap]
#   -h      : Display help
#   -fromap : Let send_result.sh know the call is from autopilot.sh
######################################################################
# History:
# 00/00/0000 RK Original worte by Rumitkar
# 08/27/2007 YK Add Kennedy to version check
# 08/29/2007 YK Add i18n check on setting for the destination folder
# 08/08/2008 YK Support $AP_RESFOLDER
# 09/16/2008 YK Change I18N folder to i18n/essbase
# 02/17/2009 YK Add installer kind information into wsp2 file.
# 05/20/2010 YK Change to get VERSION BUILD TEST from *.sog file.
# 06/04/2010 YK Add fix when the test is regress.sh all
# 07/28/2010 YK Trust parameters when this script is called 
#               from autopilot framework.
#               Change the .rtf name and put nth count.
# 08/05/2010 YK Omitt manual execution.
# 02/03/2011 YK Add system version to the result.wsp2 file.
# 02/07/2011 YK Add HIT Base information when installer is opack.
# 02/16/2011 YK Ignore sxr.sta file to determine V/B/T
#            YK Add tag() task option to label the build number
# 03/30/2012 YK Add HSS information.
# 05/10/2012 YK Add AP_REALPATH for the post location.
# 08/24/2012 YK Bug 14538613 - ADD TEST SECURITY MODE TO RESULT.WSP2 FILE
# 08/30/2012 YK BUG 14545624 - NEED EXTRA INFO ON REGRESSION RUN IN NEW RESULTS.WSP3 FILE
# 09/11/2012 YK BUG 14606359 - NEED TO ADD SUC COUNT FROM #: SUC: FILED FROM TEST SCRIPT

. apinc.sh

RESLOC="$AP_DEF_RESLOC"

###########################################################
# Check Parameters
###########################################################

unset _ver _bld _test opt
fromap=true # Not restrict run manually
while [ $# -ne 0 ]; do
	case $1 in
		-fromap)
			fromap=true
			;;
		-h)
			display_help.sh $me
			exit 0
			;;
		-notfromap)
			fromap=false
			;;
		-o)
			if [ $# -lt 2 ]; then
				echo "${me##*.}:'$1' need second parameter."
				exit 1
			fi
			shift
			[ -z "$opt" ] && opt=$1 || opt="$opt $1"
			;;
		*)
			if [ -z "$_ver" ]; then
				_ver=$1
			elif [ -z "$_bld" ]; then
				_bld=$1
			else
				[ -z "$_test" ] && _test=$1 || _test="$_test $1"
			fi
			;;
	esac
	shift
done

if [ -n "$opt" ]; then
	[ -z "$_OPTION" ] && export _OPTION="$opt" || export _OPTION="$_OPTION $opt"
fi
if [ "$fromap" != "true" ]; then
	if [ -n "$_ver" -o -n "$_bld" -o -n "$_test" ]; then
		echo "send_result.sh cannot work without start_regress.sh."
		echo "Please run \"start_regress.sh <ver> <bld> <test script>\""
		echo "command instead of running send_result.sh manually."
		exit 1
	else
		unset _ver _bld _test
	fi
fi

if [ -z "$_ver" -o -z "$_bld" -o -z "$_test" ]; then
	# Otherwise, get VERSION, BUILD, TEST from .sog file.
	crr=`pwd`
	[ -z "$SXR_WORK" ] && export SXR_WORK=$crr
	cd $SXR_WORK
	fnm=$(ls -l *.sog | awk '{print $5, $9}' | while read siz fnm; do
		siz="000000000000${siz}"; siz=${siz#${siz%00?????????????}}
		echo "$siz $fnm"; done | sort | tail -1)
	echo "### Longuest sog file : $fnm"
	fnm=${fnm#* }
	TEST=`grep "^+ sxr shell" $fnm`
	TEST=${TEST#+ sxr shell }
	if [ "${TEST#regress.sh}" != "$TEST" -a "$TEST" != "${TEST#*all}" ]; then
		case `basename $SXR_WORK` in
			SerialDirect)	TEST="regress.sh serial direct";;
			parallelbuffer)	TEST="regress.sh parallel buffer";;
			serialbuffer)	TEST="regress.sh serial buffer";;
			paralleldirect)	TEST="regress.sh parallel direct";;
			*) echo "Invalid regress.sh mode."; exit 1; ;;
		esac
	fi
	rm -rf _send_result.tmp
	egrep "^Essbase Command Mode|^ Essbase MaxL Shell" $fnm > _send_result.tmp
	verbld=`tail -1 _send_result.tmp`
	verbld=`echo $verbld | sed -n -e 's/^[^(]*(ESB//g' -e 's/).*$//g' -e 's/B/:/' -e 1p`
	ver=${verbld%:*}; BUILD=${verbld#*:}
	echo "### fnm=$fnm, TEST=$TEST, verbld=$verbld, ver=$ver, BUILD=$BUILD"
	[ "$ver" = "${ver%.*}" ] && \
		ver=`echo $ver | sed -e "s/./&./g" | sed -e "s/.$//g"`
	VERSION=`ver_codename.sh $ver`
	echo "### codename = $ver"
	cd "$crr"
	unset verbld ver fnm crr
else
	VERSION=$_ver
	BUILD=$_bld
	TEST="$_test"
fi

###########################################################
# Determine Machine Type
###########################################################
_PLATNAME=`get_platform.sh -l`
echo "VERSION=$VERSION"
echo "BUILD  =$BUILD"
echo "TEST   =$TEST"
echo "PLATNAME is ${_PLATNAME}"

###########################################################
# Check RealPath() option for AUTOPILOT location
###########################################################
rpstr=`chk_para.sh realpath "$_OPTION"`
[ -z "$rpstr" ] && rpstr="$AP_REALPATH"
if [ -n "$rpstr" ]; then
	ev=`echo $rpstr | grep \$`
	[ -n "$ev" ] && ev=`eval echo $ev 2> /dev/null`
	[ -d "$rpstr" ] && RESLOC=${rpstr%/*}
fi

###########################################################
# Check result folder
###########################################################
if [ -n "$AP_RESFOLDER" ]; then
	RESDIR=$VERSION/$AP_RESFOLDER
else
	_i18n=`echo $TEST | grep ^i18n_`
	if ( test -n "$_i18n" -o -n "$AP_I18N" )
	then
		RESDIR=$VERSION/i18n/essbase
	elif ( test "$TEST" = "xprobmain.sh" )
	then
		RESDIR=$VERSION/i18n/essbase
	else
		RESDIR=$VERSION/essbase
	fi
fi
[ -d "$RESLOC/$RESDIR" ] || mkddir.sh "$RESLOC/$RESDIR"

########################################################################
# Assign Short Names to Tests
########################################################################
echo "Assigining Short Names"
abbr=`chk_para.sh abbr "${_OPTION}"`
if [ -z "$abbr" ]; then
	TEST_ABV=`cat $AP_DEF_SHABBR | grep "^$TEST:" | awk -F: '{print $2}'`
	if [ -z "$TEST_ABV" ]; then
		[ "$TEST" = "${TEST#* }" ] && TEST_ABV=${TEST%.*} \
			|| TEST_ABV="${TEST%.*}_`echo ${TEST#* } | sed -e s/\ /_/g`"
	fi
else
	TEST_ABV=$abbr
fi

if [ "$(uname)" = "AIX" -o "$(uname)" = "Linux" ]; then
	cd $SXR_WORK
	SUC=`perl -e 'print scalar(@files = <*.suc>)'`
	DIF=`perl -e 'print scalar(@files = <*.dif>)'`
else
	SUC=`ls $SXR_WORK/*.suc 2> /dev/null | wc -l`
	DIF=`ls $SXR_WORK/*.dif 2> /dev/null | wc -l`
fi

crr=`pwd`
cd $RESLOC/$RESDIR
# echo ${_PLATNAME}_${BUILD}_${TEST_ABV}_.rtf
# ls -r ${_PLATNAME}_${BUILD}_${TEST_ABV}_*.rtf
lastrtf=`ls -r ${_PLATNAME}_${BUILD}_${TEST_ABV}_*.rtf 2> /dev/null | head -1`
if [ -n "$lastrtf" ]; then
	n=${lastrtf##*_}
	n=${n%.*}
	let n=n+1 2> /dev/null
	n="000${n}"
	n=${n#${n%??}}
	rtfname=${_PLATNAME}_${BUILD}_${TEST_ABV}_${n}.rtf
	unset n
else
	rtfname=${_PLATNAME}_${BUILD}_${TEST_ABV}_01.rtf
fi
unset lastrtf n
ckresults2.sh $TEST > $RESLOC/$RESDIR/${rtfname}
get_applogs.sh
sysinfo.sh "$RESLOC/$RESDIR/${rtfname}"
cat $SXR_WORK/${TEST%.*}.sta >> $RESLOC/$RESDIR/${rtfname}
chmod 666 $RESLOC/$RESDIR/${rtfname} 2> /dev/null
TEST=`echo $TEST | sed -e "s/ /_/g"`

########################################################################
# Get build date
########################################################################
plat=`get_platform.sh`
bldrec="$BUILD_ROOT/$VERSION/$BUILD/logs/essbase_${plat}.txt"
if [ -f "$bldrec" ]; then
	lno=`grep "^build.top: DONE running for essbase on" "$bldrec"`
	if [ -n "$lno" ]; then
	# YYMMDD -> MM/DD/YY
		lno=${lno##* }
		lno=${lno%-*}
		bldrec=${lno%????}
		lno=${lno#??}
		bldrec="${lno%??}/${lno#??}/${bldrec}"
	else
		bldrec="Unknown"
	fi
else
	bldrec="Unknown"
fi

########################################################################
# Get installer information 02/17/2009
########################################################################
if [ -f "$HYPERION_HOME/refresh_version.txt" ]; then
	instkind="refresh"
elif [ -f "$HYPERION_HOME/opack_version.txt" ]; then
	instkind=`cat $HYPERION_HOME/opack_version.txt | sed -e "s/base://g" -e "s/ hit\[/:/g" -e "s/ bi\[/:/g" -e "s/\]//g"`
	# $ver:$bld(base:$hv hit[$hb])
	# instkind=${instkind%%\(*}
	instkind="OP_${instkind#*:}"
elif [ -f "$HYPERION_HOME/hit_version.txt" ]; then
	instkind=`cat $HYPERION_HOME/hit_version.txt`
	instkind="hit_${instkind#*_}"
elif [ -f "$HYPERION_HOME/cd_version.txt" ]; then
	instkind="CD"
elif [ -f "$HYPERION_HOME/bi_version.txt" ]; then
	instkind=`cat $HYPERION_HOME/bi_version.txt | tr -d '\r'`
else
	instkind="Unknown"
fi

########################################################################
# Collect OS version information 02/03/2011 YK
########################################################################
os_ver=`get_osrev.sh`

########################################################################
# Get tag() task option
########################################################################
TAG=`chk_para.sh tag "$_OPTION"`
TAG=${TAG##* }
[ -z "$CRRPRIORITY" ] && export CRRPRIORITY="0100"
case $AP_SECMODE in
	hss)	secmode=HSS;;
	fa)	secmode=FA;;
	rep)	secmode=BI;;
	*)	secmode=native
esac

########################################################################
# Get expected Suc count from test script
########################################################################
testname=${TEST%% *}
if [ -f "../sh/$testname" ]; then
	testname="`pwd`/../sh/$testname"
elif [ -f "$SXR_HOME/../base/sh/$testname" ]; then
	testname="${SXR_HOME%/*}/base/sh/$testname"
else
	unset testname
fi
expsuc="-"
if [ -n "$testname" ]; then
	sucline=`echo $testname 2> /dev/null | egrep "^#[ 	]*SUC:" | tail -1`
	[ -n "$sucline" ] && expsuc=`echo ${sucline#*SUC:} | awk '{print $1}'`
fi
		
########################################################################
# BUG 14545624 - NEED EXTRA INFO ON REGRESSION RUN IN NEW RESULTS.WSP3 FILE
########################################################################
[ -n "$APS_VERSION" ] && apsv=$APS_VERSION || apsv="-"
[ -n "$APS_BUILD" ] && apsb=$APS_BUILD || apsb="-"
# yyyy-mm-dd-hh-mm
# MM_DD_YY HH:MM:SS
cd $SXR_WORK
sttm=`grep "^Start Time:" anafile 2> /dev/null | head -1`
if [ -n "$sttm" ]; then
	dt=`echo "$sttm" | awk '{print $3}'`
	_year=`echo $dt | awk -F_ '{print $3}'`
	_month=`echo $dt | awk -F_ '{print $1}'`
	_day=`echo $dt | awk -F_ '{print $2}'`
	tm=`echo "$sttm" | awk '{print $4}'`
	_hour=`echo $tm | awk -F: '{print $1}'`
	_minute=`echo $tm | awk -F: '{print $2}'`
	let _year=_year+2000
	sttm="${_year}-${_month}-${_day}-${_hour}-${_minute}"
else
	sttm="-"
fi
edtm=`grep "^End   Time:" anafile 2> /dev/null | head -1`
if [ -n "$edtm" ]; then
	dt=`echo "$edtm" | awk '{print $3}'`
	_year=`echo $dt | awk -F_ '{print $3}'`
	_month=`echo $dt | awk -F_ '{print $1}'`
	_day=`echo $dt | awk -F_ '{print $2}'`
	tm=`echo "$edtm" | awk '{print $4}'`
	_hour=`echo $tm | awk -F: '{print $1}'`
	_minute=`echo $tm | awk -F: '{print $2}'`
	let _year=_year+2000
	edtm="${_year}-${_month}-${_day}-${_hour}-${_minute}"
else
	edtm="-"
fi
# Old format
# echo "${BUILD}${TAG} ${_PLATNAME} ignore $TEST $SUC $DIF ${rtfname} $bldrec $instkind $CRRPRIORITY $os_ver $secmode" >> \
#	$RESLOC/$RESDIR/results.wsp2
# chmod 666 $RESLOC/$RESDIR/results.wsp2 2> /dev/null
# echo "${BUILD}${TAG} ${_PLATNAME} ignore $TEST $SUC $DIF ${rtfname} $bldrec $instkind $CRRPRIORITY $os_ver $secmode" >> \
#	$RESLOC/$RESDIR/res.rec
# chmod 666 $RESLOC/$RESDIR/res.rec 2> /dev/null
let SUC=SUC
let DIF=DIF
outstr="${BUILD}${TAG}"
outstr="${outstr}|${_PLATNAME}|ignore|$TEST|$SUC|$DIF|${rtfname}"
outstr="${outstr}|$bldrec|$instkind|$CRRPRIORITY|$os_ver|$secmode"
outstr="${outstr}|${LOGNAME}|$(hostname)|${sttm}|${edtm}|${apsv}|${apsb}"
outstr="${outstr}|${expsuc}"
umask 000
echo "${outstr}" >> $RESLOC/$RESDIR/results.wsp2
echo "${outstr}" >> $RESLOC/$RESDIR/res.rec

########################################################################
# Add history
########################################################################
[ "$fromap" = "false" ] \
	&& echo "`date +%D_%T` $LOGNAME@$(hostname) : SEND_RESULT.SH $VERSION $BUILD $TEST (FROM_AP=${fromap})" \
	>> $aphis
