#!/usr/bin/ksh
# gtlf.sh : Create gtlg XML file.
# Descrition:
# Syntax1: gtlf.sh [<options>] <ver> <bld> <test> <src> <dst>
# Syntax2: gtlf.sh <xml> # for uploading only
# Parameter:
#   <ver>  : Essbase version number
#   <bld>  : Essbase build number
#   <test> : Target test name
#   <src>  : The work folder.
#            When skip this parameter, this script uses a current folder.
#   <dst>  : XML put folder.
#            When skip this parameter, this script put created XML into
#            $AUTOPILOT/gtlf folder. And if $AUTOPILOT/gtlf directory
#            is not found, make gtlf folder under current folder and
#            use it as XML put destination folder.
#
# Options: -h|-j <java>|-p <plat>|-upld|-upldz|-upldn <difn>|-o <tskopt>
#   -h            : Display this help.
#   -j <java>     : The program which create XML is written as Java modules.
#                   Usually, this script search java program from below:
#                     1) From $PATH (which java)
#                     2) From $JAVA_HOME/bin/java if JAVA_HOME defined.
#                     3) <product install loc>/jdkXXX_XX/jre/bin/java
#                   If cannot find those program, this script will be failed.
#                   In that case, please define java program with this option.
#   -p <plat>     : Create XML for <plat> platoform. Otherwise, use current
#                   platform.
#   -upld         : Upload gtlf file.
#   -upldz        : Upload gtlf file when the result is 0 diff.
#   -upldn <difn> : Upload gtlf file when the diff count is less or equal 
#                   than <difn>
#   -o <tskopt>   : Define task option.
#   -s <src>      : Define source folder.
#   -d <dst>      : Define destination folder.
#   -xml <srcxml> : Define Source XML file for upload
#  NOTE: When the test has some parameter like agtpjlmain.sh or regression.sh,
#        please define <test> with "+" like below:
#        $ gtlf.sh 11.1.2.2.100 2122 ajtpjlmain.sh+parallel+buffer
#  NOTE2: This script create the testunit name with "#: GTLF_testunit:" tags
#         of the script. Then add a prefix string and postfix string like
#         below:
#           <prefix><base name of the test>_<GTLF_testunit tag><postfix>
#         The default value of the pre/postfixes are:
#           prefix="AUTO_EssbaseServer-"
#           postfix="LRG"
#         So, if the sdsvmain.sh has following header:
#           "#: GTLF_testunit:Substitution_variables"
#         Then this script uses following testunit name
#           "AUTO_EssbaseServer-sdsvmain_Substitution_variablesLRG"
#         If target script doesn't have GTLF_testunit tag or failed to
#         open target script, it just uses script name like below:
#           "AUTO_EssbaseServer-<script name wo/ extension>LRG"
#         If you want to change those pre/postfix string, please define
#         following task options:
#           GTLFprefix(<prefix string>)
#           GTLFpostfix(<postfix string>)
#         or define above in _OPTION variable or -o "GTLFprefix(<str>)"
#         option.
#  Note3: This script support following task options:
#         GTLFOS(), GTLFLoad(), GTLFRelease(), GTLFPrefix(),
#         GTLFPostFix(), GTLFTestUnit(), GTLFProduct(), GTLFRelProd(),
#         GTLFRunIDPref(), GTLFDiffLimit4Upload()
#     
# Sample:
# 1) Create GTLF file using current SXR_WORK folder.
#    $ gtlf.sh $SXR_WORK # Caliculate <ver> <bld> <tst> automatically
#                        # from $SXR_WORK/<test>.sog file.
# 2) Create GTLF file with specific ver/bld/test
#    $ gtlf.sh 11.1.2.2.100 2166 i18n_x.sh
# 3) Create GTLF file and upload it when diff count is zero
#    $ gtlf.sh -upldz 11.1.2.2.100 2166 i18n_x.sh
# 4) Upload specific GTLF file.
#    $ gtlf.sh 11.1.2.2.100_2166_winamd64_i18n_x.gtlf.xml
# 5) Upload specific GTLF file when diff count is less than 50
#    $ gtlf.sh 11.1.2.2.100_2166_winamd64_x.gtlf.xml -upldn 50
# 6) Create GTLF file and upload it when diff count is less or equal 10
#    $ gtlf.sh -upldn 10 11.1.2.2.100 2166 i18n_x.sh
#      or
#    $ gtlf.sh 11.1.2.2.100 2166 i18n_x.sh -o "GTLFDiffLimit4upLoad(10)"
#
# History:
# 2012/02/12    YKono   First edition
# 2012/03/08	YKono	Add GTLF_testunit tag support
# 2012/03/27	YKono	Support gtlfVer() and gtlfOS(), gtlfLoad(), gtlfRelease() , gtlfTestUnit() task option.
# 2012/05/04	YKono	Add I18N tstunit definition when there is no tag.
# 2012/05/21	YKono	Change Java search order to -j>INSTALLAITON>which java
#                       Make release is indipendent string from $ver
#                       Add GTLF_product, GTLF_relProd for "EssbaseTools" and "EssTools"
#                       And support GTLFProduct() and GTLFRelProd() options.
# 2012/05/21	YKono	Change ${runid} format to:
#                       essbase_<ver>_<bld>_<plat>_<bsname>_<testunit>_mmddyyHHMM
#                       ${GTLF_runidpref}${ver}_${bld}_${plt}_${bsname}_${testunit}_`date +%m%d%y%H%M`
# 2012/05/21    YKono   Add -upld option
# 2012/06/07	YKono	Move GTLF_testunit search part to get_gtlftu.sh
# 2013/01/31	YKono	Add gtlfload2() and gtlfrelease2() option.

. apinc.sh

msg()
{
	if [ "$dbg" = "true" ]; then
		( IFS=
		if [ -n "$dbglog" ]; then
			if [ $# -ne 0 ]; then
				echo "$@" >> $dbglog
			else
				while read linedata; do 
					echo "$linedata" >> $dbglog
				done
			fi
		else
			if [ $# -ne 0 ]; then
				echo "$@"
			else
				while read linedata; do 
					echo "$linedata"
				done
			fi
		fi
		)
	fi
}

gtlfunitf="GTLF_testunit.log"
GTLF_prefix="AUTO_EssbaseServer-"
GTLF_postfix="LRG"
GTLF_product="EssbaseTools"
GTLF_relprod="EssTools"
GTLF_runidpref="essbase_"

me=$0
orgpar=$@
unset ver bld rel plt tst src dst javapro
unset set_vardef; set_vardef AP_GTLFUPLOAD GTLF_load GTLF_release
echo "### AP_GTLFUPLOAD=$AP_GTLFUPLOAD"
[ -z "$GTLF_load" ] && GTLF_load="6"
[ -z "$GTLF_release" ] && GTLF_release="11.1.1.7.0"
upload=$AP_GTLFUPLOAD
dbg=false
dbglog=
srcxml=
while [ $# -ne 0 ]; do
	case $1 in
		-upld|-up|-upload)
			upload=true
			;;
		-upldz|-upz|-uplaodz)
			upload=0
			;;
		-upldn|-upn|-uploadn)
			if [ $# -lt 2 ]; then
				echo "${me##*/}:'$1' need second parameter."
				exit 1
			fi
			shift
			upload=$1
			;;
		-dbg)
			dbg=true
			;;
		-nodbg)
			dbg=false
			;;
		-h)
			display_help.sh $me
			exit 0
			;;
		-hs)
			display_help.sh $me -s
			exit 0
			;;
		`isplat $1`)
			plt=$1
			;;
		*.sh|*.ksh)
			tst=$1
			;;
		-o)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}:'-o' need second parameter."
				exit 1
			fi
			[ -z "$_OPTION" ] && export _OPTION="$1" || export _OPTION="$_OPTION $1"
			;;
		-p|-os)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}:'$1' need second parameter."
				exit 1
			fi
			plt=$1
			;;
		-t)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}:'$1' need second parameter."
				exit 1
			fi
			tst=$1
			;;
		-b)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}:'$1' need second parameter."
				exit 1
			fi
			bld=$1
			;;
		-v)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}:'$1' need second parameter."
				exit 1
			fi
			ver=$1
			;;
		-j)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}:'$1' need second parameter."
				exit 1
			fi
			if [ -x "$1" -a ! -d "$1" ]; then
				javapro=$1
			else
				echo "${me##*/}: $1 is not executable."
				exit 2
			fi
			;;
		-d)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}:'$1' need second parameter."
				exit 1
			fi
			if [ -d "$1" ]; then
				dst=$1
			else
				echo "${me##*/}: $1 is not directory."
				exit 2
			fi
			;;
		-s)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}:'$1' need second parameter."
				exit 1
			fi
			if [ -d "$1" ]; then
				src=$1
			else
				echo "${me##*/}: $1 is not directory."
				exit 2
			fi
			;;
		-xml|-srxcml|-sourcexml)
			if [ $# -lt 2 ]; then
				echo "${me##*/}:'$1' need second parameter."
				exit 2
			fi
			shift
			srcxml=$1
			;;
		*.xml)
			srcxml=$1
			;;
		*)
			if [ -d "$1" ]; then
				if [ -z "$src" ]; then
					src=$1
				else
					dst=$1
				fi
			elif [ -x "$1" -a ! -d "$1" ]; then
				javapro=$1
			else
				if [ "${1%.sh}" != "$1" -o "${1%.ksh}" != "$1" ]; then
					tst=$1
				elif [ -z "$ver" ]; then
					ver=$1
				elif [ -z "$bld" ]; then
					bld=$1
				else
					if [ -z "$tst" ]; then
						tst=$1
					else
						tst="$tst $1"
					fi
				fi
			fi
			;;
	esac
	shift
done

if [ "$dbg" = "true" ]; then
	(
	echo "`date +%D_%T` ========="
	echo "me=$me"
	echo "orgpar=$orgpar"
	echo "plt=$plt"
	echo "ver=$ver"
	echo "bld=$bld"
	echo "tst=$tst"
	echo "javapro=$javapro"
	echo "dbg=$dbg"
	echo "upload=$upload"
	echo "srcxml=$srcxml"
	echo "src=$src"
	echo "dst=$dst"
	echo "_OPTION=$_OPTION"
	) | msg
fi

[ -z "$src" ] && src=`pwd`
[ "${src%/}" != "$src" ] && src=${src%/} # Remove tailer / for folder name

if [ -n "$srcxml" ]; then
	if [ ! -f "$srcxml" ]; then
		if [ -f "$AUTOPILOT/gtlf/$srcxml" ]; then
			srcxml="$AUTOPILOT/gtlf/$srcxml"
		fi
	fi
	if [ ! -f "$srcxml" ]; then
		echo "${me##*/}: '$srcxml' couldn't find."
		exit 1
	fi
fi

if [ -z "$srcxml" ]; then
	if [ -z "$ver" -o -z "$bld" -o -z "$tst" ]; then
		# Search ver/bld and test script from biggest .sog file.
		sog=`ls -l ${src}/*.sog 2> /dev/null | while read d1 d2 d3 d4 siz d6 d7 d8 nm; do
			siz="0000000000$siz"
			siz=${siz#${siz%??????????}}
			echo "$siz $nm"
			done | sort | tail -1`
		sog=${sog#* }
		msg "# no ver/bld/tst. try to get it from .sog file.\n* sog=$sog"
		if [ -f "${sog}" ]; then
			tst=`cat $sog 2> /dev/null | grep "^+ sxr shell " | head -1 | tr -d '\r'`
			tst=${tst#+ sxr shell }
			msg "* tst=$tst"
			ver=`cat $sog 2> /dev/null | grep " Essbase MaxL Shell .*- Release" | head -1 | tr -d '\r'`
			[ -z "$ver" ] && ver=`cat $sog 2> /dev/null | grep "Essbase Command Mode Interface .*- Release" | head -1 | tr -d '\r'`
			if [ -n "$ver" ]; then
				ver=${ver#*\(}
				ver=${ver%\)*}
				ver=${ver#ESB}
				bld=${ver##*B}
				ver=${ver%B*}
				cdnm=`ver_codename.sh $ver 2> /dev/null`
				[ $? -eq 0 -a -n "$cdnm" ] && ver="$cdnm"
			fi
		fi
		if [ "$dbg" = "true" ]; then
			msg "* ver=$ver"
			msg "* bld=$bld"
			msg "* tst=$tst"
		fi
		if [ -z "$ver" ]; then
			echo "${me##*/}:Not enought parameter. Please define <ver>, <bld> and <test> parameter."
			echo "param:$orgpar"
			exit 4
		fi
	fi
else
	if [ "$upload" = "false" ]; then
		upload=true
		msg "# Upload flag set to true because of the XML file($srcxml) passed."
	fi
fi

### Check tag() option
str=`chk_para.sh tag "$_OPTION"`
str=${str##* }
[ -n "$str" ] && TAG=$str || TAG=

[ -z "$plt" ] && plt=`get_platform.sh -l`
if [ -z "$dst" ]; then
	if [ -d "$AUTOPILOT/gtlf" ]; then
		dst=$AUTOPILOT/gtlf
		[ -n "$TAG" ] && dst="${dst}/${ver}/${bld}_${TAG}" || dst="${dst}/${ver}/${bld}" ###
		mkddir.sh $dst ###
	else
		rm -rf gtlf 2> /dev/null
		mkdir gtlf 2> /dev/null
		if [ $? -ne 0 ]; then
			rm -rf $HOME/gtlf 2> /dev/null
			mkdir $HOME/gtlf 2> /dev/null
			dst=$HOME/gtlf
		else
			dst="`pwd`/gtlf"
		fi
	fi
fi

# Decide which JAVA to use
if [ -n "$javapro" -a ! -x "$javapro" ]; then
	echo "${me##*/}:$javapro is not executable."
	exit 5
fi
if [ -z "$javapro" ]; then
	j=$(. se.sh $ver > /dev/null 2>&1 ; echo $JAVA_HOME)
	[ -x "$j/bin/java" ] && javapro=$j/bin/java
fi
[ -z "$javapro" -a -x "$JAVA_HOME/bin/java" ] && javapro="$JAVA_HOME/bin/java"
if [ -z "$javapro" ]; then
	j=`which java 2> /dev/null`
	[ -x "$j" ] && javapro=$j
fi
if [ -z "$javapro" ]; then
	echo "${me##*/}: No java executable."
	exit 6
fi

### Check GTLF Task options.

# GTLFOS()
str=`chk_para.sh gtlfos "$_OPTION"`
str=${str## }
if [ -n "$str" ]; then
	plt=$str
	msg "plt=$plt(over-write by GTLFOS() task option)"
fi

# GTLFLoad()
str=`chk_para.sh gtlfload "$_OPTION"`
str=${str##* }
[ -n "$str" ] && GTLF_load="$str"

# GTLFLoad2()
str=`chk_para.sh gtlfload2 "$_OPTION"`
str=${str##* }
if [ -n "$str" ]; then
	GTLF_load="$str"
	msg "GTLF_load=$GTLF_load(over-write by GTLFLoad2() task option)"
fi

# GTLFPrefix()
str=`chk_para.sh gtlfprefix "$_OPTION"`
str=${str##* }
[ -n "$str" ] && GTLF_prefix="$str"

# GTLFPostfix()
str=`chk_para.sh gtlfpostfix "$_OPTION"`
str=${str##* }
[ -n "$str" ] && GTLF_postfix="$str"

# Make base name of the test script.
bsname=${tst%% *}
bsname=${bsname%%.*}

# Make abbr name
abbr=`cat $AUTOPILOT/data/shabbr.txt | grep "^$tst:" | awk -F: '{print $2}'`
[ -z "$abbr" ] && abbr=$tst
ot=${abbr%% *}
if [ "$ot" != "$abbr" ]; then
	ot=${ot%.sh}
	ot=${ot%.ksh}
	abbr="$ot ${abbr#* }"
else
	abbr=${abbr%.sh}
	abbr=${abbr%.ksh}
fi
[ "${abbr#* }" != "$abbr" ] && abbr=`echo $abbr | sed -e "s! !_!g"`

# Decide GTLF test unit name
tstunit=
[ -f "${src}/${gtlfunitf}" ] && tstunit=`cat ${src}/${gtlfunitf} | tr -d '\r'`
[ -z "$tstunit" ] && tstunit=`get_gtlftu.sh ${tst%% *}`
[ -z "$tstunit" ] && tstunit="$abbr"

# GTLFTestUnit()
str=`chk_para.sh gtlftestunit "$_OPTION"`
str=${str##* }
if [ -n "$str" ]; then
	# Over write it
	tstunit=$str
fi

# GTLFProduct()
str=`chk_para.sh gtlfProduct "$_OPTION"`
str=${str##* }
if [ -n "$str" ]; then
	GTLF_product=$str
	msg "GTLF_product=$GTLF_product(over-write by GTLFProduct() task option)"
fi

# GTLFRelProd()
str=`chk_para.sh gtlfRelProd "$_OPTION"`
str=${str##* }
if [ -n "$str" ]; then
	GTLF_relprod=$str
	msg "GTLF_relprod=$GTLF_relprod(over-write by GTLFRelProd() task option)"
fi

# GTLFRelProd()
str=`chk_para.sh gtlfRunIDPref "$_OPTION"`
str=${str##* }
if [ -n "$str" ]; then
	GTLF_runidpref=$str
	msg "GTLF_runidpref=$GTLF_runidpref(over-write by GTLFRunIDpref() task option)"
fi

[ -z "$GTLF_release" ] && GTLF_release="${GTLF_relprod}${ver}"

# GTLFRelease()
str=`chk_para.sh gtlfRelease "$_OPTION"`
str=${str##* }
if [ -n "$str" ]; then
	GTLF_release=$str
	msg "GTLF_release=$GTLF_release(over-write by GTLFRelease() task option)"
fi
str=`chk_para.sh gtlfRelease2 "$_OPTION"`
str=${str##* }
if [ -n "$str" ]; then
	GTLF_release=$str
	msg "GTLF_release=$GTLF_release(over-write by GTLFRelease2() task option)"
fi

# GTLFDiffLimit4upload()
str=`chk_para.sh gtlfDiffLimit4Upload "$_OPTION"`
str=${str##* }
if [ -n "$str" ]; then
	upload=$str
	msg "Diff threshold count for Upload=$upload(over-write by GTLFDiffLimit4upload() task option)"
fi

### Create GTLF

gtlfplt=`cnvplat.sh gtlf $plt`
if [ $? -ne 0 ]; then
	gtlfplt="NA"
fi
# 2012/05/23 YK Change runid by Eric's request
runid="${ver}_${bld}_${plt}_${bsname}_${tstunit}_`date +%m%d%y%H%M`"
fnm="${ver}_${bld}_${plt}_${abbr}_${tstunit}.gtlf.xml"
### New from here
lastfnm=`ls -r ${dst}/${ver}_${bld}_${plt}_${abbr}_${tstunit}_*.gtlf.xml 2> /dev/null | head -1`
if [ -n "$lastfnm" ]; then
	n=${lastfnm%.gtlf.xml}
	n=${n##*_}
	let n=n+1
else
	n=1
fi
n="000${n}"
n=${n#${n%??}}
fnm="${ver}_${bld}_${plt}_${abbr}_${tstunit}_${n}.gtlf.xml"
unit="${GTLF_prefix}${tstunit}_${bsname}${GTLF_postfix}"
sts=0
if [ -z "$srcxml" ]; then
	msg "# Create GTLF XML file."
	if [ "$dbg" = "true" ]; then
		(
		echo "me=$me"
		echo "orgpar=$orgpar"
		echo "_OPTION=$_OPTION"
		echo "plt=$plt"
		echo "ver=$ver"
		echo "bld=$bld"
		echo "tst=$tst"
		echo "javapro=$javapro"
		echo "dbg=$dbg"
		echo "tstunit=$tstunit"
		echo "gtlfplt=$gtlfplt"
		echo "GTLF_load=$GTLF_load"
		echo "${javapro}"
    		echo "    -Xms512m"
    		echo "    -Xmx512m"
    		echo "    -classpath $AUTOPILOT/tools/gtlf/gtlfutils-core.jar"
		echo "        org.testlogic.toolkit.gtlf.converters.file.Main"
    		echo "    -Dgtlf.toptestfile=unknown"
    		echo "    -Dgtlf.testruntype=unknown"
    		echo "    -Dgtlf.string=4"
    		echo "    -Dgtlf.env.NativeIO=true"
    		echo "    -Dgtlf.env.OS=${gtlfplt}"		# 03/27/2012 Add OS version
    		echo "    -Dgtlf.env.Primary_Config=${gtlfplt}"
    		echo "    -Dgtlf.branch=main"
    		echo "    -srcdir ${src}"
    		echo "    -destdir ${dst}"
    		echo "    -filename ${fnm}"
    		echo "    -testunit ${unit}"
    		echo "    -Dgtlf.product=${GTLF_product}"
    		echo "    -Dgtlf.release=${GTLF_release}"
    		echo "    -Dgtlf.load=${GTLF_load}"
    		echo "    -Dgtlf.runid=${GTLF_runidpref}${runid}"
    		echo "    -Dgtlf.env.RunKey=${GTLF_runidpref}${runid}_reg"
		) | msg
	fi

	${javapro} \
		-Xms512m \
		-Xmx512m  \
		-classpath $AUTOPILOT/tools/gtlf/gtlfutils-core.jar \
		    org.testlogic.toolkit.gtlf.converters.file.Main \
		-Dgtlf.toptestfile=unknown \
		-Dgtlf.testruntype=unknown \
		-Dgtlf.string=4 \
		-Dgtlf.env.NativeIO=true \
    		-Dgtlf.env.OS="${gtlfplt}" \
		-Dgtlf.env.Primary_Config="${gtlfplt}" \
		-Dgtlf.branch=main \
		-srcdir ${src} \
		-destdir ${dst} \
		-filename "${fnm}" \
		-testunit "${unit}" \
		-Dgtlf.product=${GTLF_product} \
		-Dgtlf.release="${GTLF_release}" \
		-Dgtlf.load="${GTLF_load}" \
		-Dgtlf.runid="${GTLF_runidpref}${runid}" \
		-Dgtlf.env.RunKey="${GTLF_runidpref}${runid}_reg"
	sts=$?
	rm -rf ${dst}/gtlf.tmp 2> /dev/null
	mv ${dst}/${fnm} ${dst}/gtlf.tmp 2> /dev/null
	cat ${dst}/gtlf.tmp | sed -e "s/$LOGNAME/Administrator/g" > ${dst}/${fnm} 2> /dev/null
	srcxml="${dst}/${fnm}"
fi

if [ "$sts" = "0" -a "$upload" != "false" ]; then
	msg "# Upload $srcxml."
	difcnt=`cat $srcxml 2> /dev/null | grep "testpath=\".*.dif\"" | wc -l`
	let difcnt=difcnt
	upf=false
	if [ "$upload" = "true" ]; then
		upf=true
	elif [ "$difcnt" -le "$upload" ]; then
		upf=true
	fi
	cp=
	for one in gtlf-libs.jar gtlf-uploader.jar jsch-0.1.41.jar mail.jar; do
		[ -z "$cp" ] && cp="$AUTOPILOT/tools/gtlf/$one" || cp="$cp$pathsep$AUTOPILOT/tools/gtlf/$one"
	done
	if [ "$upf" ]; then
		msg "${javapro} \\"
		msg "    -Xms512m \\"
		msg "    -Xmx512m \\"
		msg "    -Dtestmgr.validate=false \\"
		msg "    -Dnotify=First.Last@oracle.com \\"
		msg "    -classpath \"$cp\" \\"
		msg "        weblogic.coconutx.WLCustomGTLFUploader \\"
		msg "    ${srcxml}"
		${javapro} \
			-Xms512m \
			-Xmx512m \
			-Dtestmgr.validate=false \
			-Dnotify=First.Last@oracle.com \
			-classpath "$cp" \
				weblogic.coconutx.WLCustomGTLFUploader \
			${srcxml}
		sts=$?
	else
		msg "# Difcnt($difcnt) -gt Threshold#($upload). Skip upload."
	fi
fi
exit $sts
