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
# 10/08/2013 YK Bug 17531687 NEED A WAY TO TAG THE RELEASE NAME
# 01/30/2014 YK Bug 18078885 - FIND A WAY TO AUTOMATE THE PROCESS TO COMPARE THE DIF FROM DIFFERENT BUILD

umask 000
. apinc.sh

# Read Parameters
unset _ver _bld _test opt
fromap=true # Not restrict run manually
while [ $# -ne 0 ]; do
	case $1 in
		-fromap) fromap=true ;;
		-h) display_help.sh $me; exit 0 ;;
		-notfromap) fromap=false ;;
		-o)	if [ $# -lt 2 ]; then
				echo "${me##*.}:'$1' need second parameter."
				exit 1
			fi
			shift
			[ -z "$opt" ] && opt=$1 || opt="$opt $1"
			;;
		*)	if [ -z "$_ver" ]; then
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

# Find ver/bld/test from sog file
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

# Determine Machine Type
_PLATNAME=`get_platform.sh -l`
echo "VERSION=$VERSION"
echo "BUILD  =$BUILD"
echo "TEST   =$TEST"
echo "PLATNAME is ${_PLATNAME}"

# Get security mode
secmode=`get_secmode.sh`

# Decide result locaiton and RTF file name
resloc=`get_resloc.sh $VERSION $BUILD $TEST`
tag=${resloc##*:}; resloc=${resloc%:*}
reltag=${resloc##*:}; resloc=${resloc%:*}
rtf=${resloc##*:}; resloc=${resloc%:*}

# Get suc/dif count
if [ "$(uname)" = "AIX" -o "$(uname)" = "Linux" ]; then
	cd $SXR_WORK
	SUC=`perl -e 'print scalar(@files = <*.suc>)'`
	DIF=`perl -e 'print scalar(@files = <*.dif>)'`
else
	SUC=`ls $SXR_WORK/*.suc 2> /dev/null | wc -l`
	DIF=`ls $SXR_WORK/*.dif 2> /dev/null | wc -l`
fi
let SUC=SUC
let DIF=DIF

crr=`pwd`
ckresults2.sh $TEST > $resloc/$rtf
get_applogs.sh
sysinfo.sh "$resloc/$rtf"
cat $SXR_WORK/${TEST%.*}.sta >> $resloc/$rtf
TEST=`echo $TEST | sed -e "s/ /_/g"`

# Get build date
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

# Get installer information 02/17/2009
instkind=`get_instkind.sh`

# Collect OS version information 02/03/2011 YK
os_ver=`get_osrev.sh`

[ -z "$CRRPRIORITY" ] && export CRRPRIORITY="0100"

# Get expected Suc count from test script
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
		
# Get APS version and build
[ -n "$APS_VERSION" ] && apsv=$APS_VERSION || apsv="-"
[ -n "$APS_BUILD" ] && apsb=$APS_BUILD || apsb="-"

# Get Start Time and End Time
cd $SXR_WORK
sttm=`cat anafile 2> /dev/null | grep "^Start Time:" | head -1`
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
edtm=`cat anafile 2> /dev/null | grep "^End   Time:" | head -1`
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
if [ -f "difs.rec" ]; then
	NEWDIF=`cat difs.rec 2> /dev/null | grep "New diff" | wc -l`
	let NEWDIF=NEWDIF
else
	NEWDIF="-"
fi

# Make result string
outstr="${BUILD}${tag}"
outstr="${outstr}|${_PLATNAME}|ignore|$TEST|$SUC|$DIF|${rtf}"
outstr="${outstr}|$bldrec|$instkind|$CRRPRIORITY|$os_ver|$secmode"
outstr="${outstr}|${LOGNAME}|$(hostname)|${sttm}|${edtm}|${apsv}|${apsb}"
outstr="${outstr}|${expsuc}|$NEWDIF"
echo "${outstr}" >> $resloc/results.wsp2
echo "${outstr}" >> $resloc/res.rec

########################################################################
# Add history
########################################################################
[ "$fromap" = "false" ] \
	&& echo "`date +%D_%T` $LOGNAME@$(hostname) : SEND_RESULT.SH $VERSION $BUILD $TEST (FROM_AP=${fromap})" \
	>> $aphis
