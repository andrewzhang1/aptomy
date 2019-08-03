#!/usr/bin/ksh
# opackinst.sh : Apply opack
# Description:
#   This script extract target opack and apply to the current
#   installation.
#   1) Copy and extract opack zip file
#   2) Apply each opacks.
#   3) Do rollback
#   4) Compare the version is same after the rollback
#   5) Compare opack binaries with refresh binaries.
# Syntax:
#    opackinst.sh [<options>] <ver> <bld>.
# Parameter:
#  <ver>  : Version number.
#  <bld>  : Build number.
# Options: [-opack <opack-bld>|-norollback|-nocmpzip|-cmpzip|-skip <mod>|-v <ver>|-o <opt>]
#   -opack      : Use <opack-bld> build.
#   -norollback : Don't test the rollback feature.
#   -rollback   : Do test the rollback feature.
#   -nocmpzip   : No comparison test between OPACK zip and refresh .tar.Z.
#   -cmpzip     : Compare the OPACK zip and refresh .tar.Z.
#   -skip <mod> : Skip <mod> opack. <mod> can be below combination.
#                 <mod> := {rtc|server|client}
#   -ver <ver>  : Version filter string.
#                 When the opack has multiple versions, Use <ver> opack for install.
#                 Usually, opackinst.sh use same <ver> number for the filter <ver>.
#                 But when the version has multiple version like 111.1.3.502, which
#                 contains opacks for 11.1.1.3.502 and 11.1.1.4, and want to use
#                 11.1.1.4, use this option like below:
#                 $ opackinst.sh 11.1.1.3.502 003 -ver 11.1.1.4
#   -opt <opt>  : Task option.
#                 This script read following task options:
#               OpackVer(<str>) : Filter string for opack zip files.
#                            When it start with "!", it exclude *<str>*.zip
#               OpackSkip(client|server|rtc) : Tell program which opack should be skipped.
#               OPRollback() : Control rollback test
#                     true:  Do rollback test. (default)
#                     false: Do not execute rollback test.
#               OPCmpZip()   : Control comparison of refresh/bin contents
#                     true:  Do comparison between installed modules and refresh/bin modules.(Default)
#                     false: Do not execute comparison.
#               OPCmpAttr()  : Control attibute comparison on CmpZip test.
#                     true:  Do attribute comparison.
#                     false: Do not compare attribute.
#
# 
# Returned status:
#    1: Parameter error.
#    2: No BUILD_ROOT defined or folder
#    3: No VIEW_PATH defined or folder.
#    4: No target opack folder under $BUILD_ROOT
#    5: No .zip files.
#    6: No unzip command.
#    7: Unzip failed.
#    8: No OPatch folder under $HYPERION_HOME
#    9: No opatch.bat command.
#   10: Compare failed between OPACK and refresh binaries.
#   50- : opack failure (return code + 50)
#######################################################################
# History:
# 10/15/2010 YK Fist edition.
# 01/27/2011 YK Check opatch return code
# 02/28/2011 YK Add hpatch check and if exist, use hpatch instead of
#               opatch command.
# 04/11/2011 YK Correspond to the new OPACK structure from 11.1.2.1.102 B031
#               like esb11.1.2.1.102_client_solaris_031.zip...
# 05/25/2011 YK Add rollback test.
# 05/25/2011 YK Add binaries compare between OPCK zip and refresh .tar.Z
# 07/20/2011 YK Change the test order to 1) Rollback test, 2) Dup compare
# 07/20/2011 YK Add duplicate check in the ARBORPATH/bin, 
#               HYPERION_HOME/common/EssbaseRTC(-64)/<ver>/bin and HYPERION_HOME/lib(bin)
# 10/04/2011 YK Support $ver/$bld/*.zip folder
# 03/13/2012 YK Add -skip option
# 03/20/2012 YK Support opackSkip() option same as -skip parameter.
# 04/10/2012 YK Fix duplicated message.
# 04/10/2012 YK Add version filter to copy zip file.
# 04/10/2012 YK Add -ver option.
# 06/11/2012 YK Change fltver logic (Support BI 11.1.1.7 format on 11.1.2.2.500)
# 06/21/2012 YK Kill emagent which uses dbghelp on windows RTC
# 07/03/2012 YK Support numerized plat zip format (from 11.1.2.2.500 4135)
#               <ver>/<bld>/opack/<num>/*_<plat>_*.zip
# 10/26/2012 YK Support OPRollback(true|false), OPCmpZip(true|false), OPCmpAttr(true|false)
#               options.
#               OPRollback() : Control rollback test
#                     true:  Do rollback test. (default)
#                     false: Do not execute rollback test.
#               OPCmpZip()   : Control comparison of refresh/bin contents
#                     true:  Do comparison between installed modules and refresh/bin modules.(Default)
#                     false: Do not execute comparison.
#               OPCmpAttr()  : Control attibute comparison on CmpZip test.
#                     true:  Do attribute comparison.
#                     false: Do not compare attribute.
# 07/29/2013 YK Bug 17236987 - GET_OPACKBASE.SH SHOULD SUPPORT INVENTORY.XML FILE ALSO
# 08/08/2013 YK Bug 17294006 - FAILED TO APPLY OPACK ON WINDOWS PLATFOEMS.
# 08/22/2013 YK Bug Bug 17272333 - AUTOPILOT SUPPORT APPLY OPACK AND CONFIGURE PRODUCT MODE FOR APS
# 11/07/2013 YK Bug 17459743 - AUTOPILOT FRAMEWORK NEED TO APPLY EPM OPACK 
# 12/10/2013 YK Bug 17861364 - AUTOPILOT BE UPDATED TO ONLY KILL THE CURRENT USER'S PROCESSES USING DBGHELP.DLL
# 01/05/2014 YK Bug 18019330 - LINUX32 EAS OPACK MAKE WEBLOGIC SERVER HANGS AT STATING SERVICE

. apinc.sh

# Function: apply_one_opack <opdir>
apply_one_opack()
{
	_pwd=`pwd`
	cd $HYPERION_HOME/OPatch
	rm -rf _tmpimp_ 
	rm -rf _sts_ 
	echo "y" > _tmpimp_
	echo "y" >> _tmpimp_
	echo "OPATCH FOLDER=$1."
	# Check pre-applied module exists
	## Get patch ID
	invf=$1/etc/config/inventory
	[ -f "${invf}.xml" ] && invf="${invf}.xml"
	refid=`cat ${invf} 2> /dev/null | grep "reference_id number"`
	refid=${refid#*=\"}
	refid=${refid%\"*}
	## Get current applied patch
	crrid=`opackcmd.sh lsinv 2> /dev/null | grep ^Patch | awk '{print $2}' | grep -v history`
	## Check current ID is in the output of lsinventory
	echo $crrid | grep $refid > /dev/null
	if [ $? -eq 0 ]; then # exists
		## Rollback current patch ID
		echo "- Found pre-applied opack for $refid. Rollback it."
		opackcmd.sh rollback -id $refid < _tmpimp_ > /dev/null 2>&1
	fi
	# Apply opack
	echo "opackcmd.sh apply \"$1\""
	(	if [ "${thisplat#win}" != "$thisplat" ]; then
			# win_kill_relproc.sh dbghelp.dll
			win_kill_relproc.sh oci.dll
			win_kill_relproc.sh msvcp100.dll
			win_kill_relproc.sh msvcr100.dll
		fi
		opackcmd.sh apply "$1" < _tmpimp_
		echo $? > _sts_
	) | while read -r line; do print -r "APPLY:$line"; done
	lsts=`cat _sts_ 2> /dev/null`
	rm -rf _tmpimp_
	rm -rf _sts_ 
	[ -z "$lsts" ] && lsts=0
	cd $_pwd
	return $lsts
}

apply_opack()
{
	for opdir in $opdirs; do
		echo "# OPACK $opdir"
		whichOpack=${opdir#*:}
		skipf="false"
		echo $_IGNORE_OPACK | grep $whichOpack > /dev/null
		if [ $? -eq 0 ]; then
			skipf="true"
		else
			echo $skipmod | grep $whichOpack > /dev/null
			[ $? -eq 0 ] && skipf="true"
		fi
		if [ "$skipf" = "false" ]; then
			# WORKAROUND for BISHIPHOME installation
			rm -rf $HOME/.essbase_sso.cfg.saved
			if [ "$whichOpack" = "server" -a -f "$ESSBASEPATH/bin/essbase_sso.cfg" ]; then
				echo "### Save \$ESSBASEPATH/bin/essbase_sso.cfg."
				cp -p $ESSBASEPATH/bin/essbase_sso.cfg $HOME/.essbase_sso.cfg.saved
			fi
			_opdir=`echo $opdir | sed -e "s!:!/!g"`
			opdir=${opdir%:*}
			opdir="$VIEW_PATH/opack/$opdir"
			apply_one_opack $opdir
			sts=$?
			if [ -f "$HOME/.essbase_sso.cfg.saved" ]; then
				[ -f "$ESSBASEPATH/bin/essbase_sso.cfg" ] \
					&& mv $ESSBASEPATH/bin/essbase_sso.cfg $ESSBASEPATH/bin/essbase_sso.cfg.replaced.by.opatch
				cp -p $HOME/.essbase_sso.cfg.saved $ESSBASEPATH/bin/essbase_sso.cfg 2> /dev/null
				rm -rf $HOME/.essbase_sso.cfg.saved
				echo "### Restore \$ESSBASEPATH/bin/essbase_sso.cfg."
			fi
			if [ $sts -eq 0 ]; then
				echo "### Applied $tarzip(sts=0)."
			else
				echo "### Failed to apply $tarzip(sts=$sts)."
				let sts=sts+10
				break
			fi
		else
			echo "Skip $opdir."
		fi
	done
} # apply_opack

# Check environment
if [ -z "$BUILD_ROOT" ]; then
	echo "No \$BUILD_ROOT defined."
	exit 2
fi
if [ ! -d "$BUILD_ROOT" ]; then
	echo "No \$BUILD_ROOT($BUILD_ROOT) folder exists."
	exit 2
fi

if [ -z "$VIEW_PATH" ]; then
	echo "No \$VIEW_PATH defined."
	exit 3
fi
if [ ! -d "$VIEW_PATH" ]; then
	echo "No \$VIEW_PATH($VIEW_PATH) folder exists."
	exit 3
fi

#######################################################################
# CHECK Default variable
#######################################################################
set_vardef=
set_vardef AP_OPACK_ROLLBACKTEST AP_OPACK_CMPZIPBIN AP_OPACK_CMPATTR

#######################################################################
# Check the Parameter (err=1)
#######################################################################
me=$0
orgpar=$@
opbld=latest
unset ver bld
[ -z "$AP_OPACK_ROLLBACKTEST" ] && rollbacktest=true || rollbacktest=$AP_OPACK_ROLLBACKTEST
[ -z "$AP_OPACK_CMPZIPBIN" ] && cmpzipbin=true || cmpzipbin=$AP_OPACK_CMPZIPBIN
[ -z "$AP_OPACK_CMPATTR" ] && cmpattr= || cmpattr=$AP_OPACK_CMPATTR
skipmod=
fltver=
while [ $# -ne 0 ]; do
	case $1 in
		-norollback|-norollbacktest|-norb)
			rollbacktest=false
			;;
		-rollback|-rollbacktest|-rb)
			rollbacktest=true
			;;
		-cmpzip|-cmpzipbin|-cb)
			cmpzipbin=true
			;;
		-nocmpzip|-nocmpzipbin|-nocb)
			cmpzipbin=false
			;;
		-cmpattr|-ca)
			cmpattr="-attr"
			;;
		skip:*|skip=*)
			[ -z "$skipmod" ] && skipmod=${1#skip?} || skipmod="$skipmod ${1#skip?}"
			;;
		-skip|-s)
			if [ $# -lt 2 ]; then
				echo "${me##/}: \"$1\" parameter need a skip module name as second parameter."
				echo " $1 {rtc|client|server}"
				exit 1
			fi
			shift
			[ -z "$skipmod" ] && skipmod=$1 || skipmod="$skipmod $1"
			;;
		ver:*|ver=*)
			fltver=${1#????}
			;;
		-v|-ver)
			if [ $# -lt 2 ]; then
				echo "${me##/}: \"$1\" parameter need a filter version number."
				exit 1
			fi
			shift
			fltver=$1
			;;
		opack:*|opack=*)
			opbld=${1#opack?}
			;;
		-opack|opack|-ob|-opackbuild)
			if [ $# -lt 2 ]; then
				echo "${me##*/}: \"$1\" parameter need a build number for opack."
				display_help
				exit 1
			fi
			shift
			opbld=$1
			;;
		-h|help|-help)
			display_help.sh $me
			exit 0
			;;
		-o|-opt)
			if [ $# -lt 2 ]; then
				echo "${me##*/}: \"$1\" parameter need a second parameter."
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
				echo "Too many parameter."
				display_help
				exit 1
			fi
			;;
	esac
	shift
done

if [ -z "$ver" -o -z "$bld" ]; then
	echo "Not enough parameter."
	echo "current param:$orgpar"
	display_help
	exit 1
fi

# [ -z "$fltver" ] && fltver="$ver"

# Read Task option
if [ -n "$_OPTION" ]; then
	 _opt=`chk_para.sh opackskip "$_OPTION"`
	if [ -n "$_opt" ]; then
		[ -n "$skipmod" ] && skipmod="$skipmod $_opt" || skipmod="$_opt"
	fi
	_opt=`chk_para.sh opackver "$_OPTION"`
	[ -n "$_opt" ] && fltver="${_opt##* }"
	_opt=`chk_para.sh oprollback "$_OPTION"`
	[ -n "$_opt" ] && rollbacktest="${_opt##* }"
	_opt=`chk_para.sh opcmpzip "$_OPTION"`
	[ -n "$_opt" ] && cmpzipbin="${_opt##* }"
	_opt=`chk_para.sh opcmpattr "$_OPTION"`
	[ "${_opt##* }" = "true" ] && cmpattr="-attr" || cmpattr=""
fi

[ -z "$skipmod" -a `uname` = "Windows_NT" ] && skipmod="client"

. settestenv.sh $ver HYPERION_HOME JAVA_HOME

if [ "$bld" = "latest" ]; then 
	bld=`get_latest.sh $ver`
	if [ $? -ne 0 ]; then
		echo $bld
		exit 1
	fi
fi
echo "Apply OPACK($ver/$bld/$opbld)."
thisplat=`get_platform.sh`
dupchk_list=$(. ver_setenv.sh $ver 2> /dev/null; echo $_DUPCHK_LIST)
ignbin_list=$(. ver_setenv.sh $ver 2> /dev/null; echo $_IGNBIN_LIST)
_IGNORE_OPACK=$(. ver_setenv.sh $ver 2> /dev/null; echo $_IGNORE_OPACK)
[ -z "$ignbin_list" ] && ignbin_list="XXXXXXXXXXXXXXX"
unset rtc plt
[ ! "${thisplat%64}" = "${thisplat}" ] && rtc="-64"
[ "$thisplat" = "solaris" -o "$thisplat" = "aix" ] && plt="-32"
dupchk_list=`echo $dupchk_list | sed -e "s/<rtc64>/$rtc/g"`
dupchk_list=`echo $dupchk_list | sed -e "s/<plat32>/$plt/g"`
unset rtc plt
dupchk_list=`eval "echo $dupchk_list" 2> /dev/null`
sts=0
mysts=0
crrdir=`pwd`
targ="$VIEW_PATH/opack"
cd $VIEW_PATH
[ -d "opack" ] && rm -rf $targ/* > /dev/null 2>&1 || mkdir $targ > /dev/null 2>&1

# define which kind
# $ver/$vbld/opack/001/<plat>/*.zip -> 11.1.1.2.1, 11.1.1.2.2 -> platform specific patch
# $ver/$vbld/opack/001/*.zip  -> 11.1.1.2.3 -> All platforms
# $ver/$bld/opack/<plat>/*.zip -> Refresh opack
# $ver/$bld/opack/*<plat>*.zip -> From 11.1.2.1.102/031
# $ver/$bld/opack/*.zip -> 11.1.2.1.000_12962507

if [ ! -d "$BUILD_ROOT/$ver" ]; then
	echo "No $ver folder under \$BUILD_ROOT($BUILD_ROOT)."
	exit 4
fi
if [ ! -d "$BUILD_ROOT/$ver/$bld" ]; then
	echo "No $ver/$bld folder under \$BUILD_ROOT($BUILD_ROOT)."
	exit 4
fi

if [ ! -d "$BUILD_ROOT/$ver/$bld/opack" ]; then
	echo "No $ver/$bld/opack folder under $BUILD_ROOT($BUILD_ROOT)."
	exit 4
fi

# Check patch command file exist or not.
if [ ! -d "$HYPERION_HOME/OPatch" ]; then
	echo "No \$HYPERION_HOME/OPatch fodler.($HYPERION_HOME)"
	exit 8
fi
crrver=`(. se.sh $ver > /dev/null 2>&1;get_ess_ver.sh)`
if [ $? -ne 0 ]; then
	crrver="missing-version"
fi

# Copy zip files into $VIEW_PATH/opack.
if [ -d "$BUILD_ROOT/$ver/$bld/opack/$thisplat" ]; then
	# Case Refresh opack
	echo "Found $thisplat folder."
	cp $BUILD_ROOT/$ver/$bld/opack/$thisplat/*.zip $targ > /dev/null 2>&1
	echo "$ver/$bld/opack/$thisplat" > $HYPERION_HOME/opack_location.txt
else
	# Add version filter to the zip file name 2012/04/10 YK
	crrd=`pwd`
	cd $BUILD_ROOT/$ver/$bld/opack
	if [ "${fltver#!}" != "$fltver" ]; then
		fl=`ls *_${thisplat}_*.zip 2> /dev/null | grep -v "${fltver#!}"`
	else
		fl=`ls *_${thisplat}_*.zip 2> /dev/null | grep "$fltver"`
	fi
	cd $crrd
	if [ -n "$fl" ]; then
		# New format from 11.1.2.1.102 B031
		echo "Found $fltver and $thisplat zip files."
		for onezip in $fl; do
			cp $BUILD_ROOT/$ver/$bld/opack/$onezip $targ 2>&1
		done
		# cp $BUILD_ROOT/$ver/$bld/opack/*${fltver}*_${thisplat}_*.zip $targ > /dev/null 2>&1
		echo "$ver/$bld/opack/\*_${thisplat}_\*.zip" > $HYPERION_HOME/opack_location.txt
	else
		echo "Use opbld=$opbld opack."
		if [ "$opbld" = "latest" ]; then
			cd $BUILD_ROOT/$ver/$bld/opack
			opblds=`ls -1r | grep "^[0-9][0-9]*$"`
			for one in $opblds; do
				ls $one/$thisplat/*.zip > /dev/null 2>&1
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
			cd $crrdir
			echo "OPack(latest)=$opbld"
		fi
		if [ "$opbld" = "latest" ]; then
			# New for 11.1.2.1.000_12962507
			echo "No latest opack build folder. Check the zip file just under $ver/$bld/opack folder."
			ls $BUILD_ROOT/$ver/$bld/opack/*.zip > /dev/null 2>&1
			if [ $? -eq 0 ]; then
				crrd=`pwd`
				cd $BUILD_ROOT/$ver/$bld/opack
				if [ "${fltver#!}" != "$fltver" ]; then
					fl=`ls *_${thisplat}_*.zip 2> /dev/null | grep -v "${fltver#!}"`
				else
					fl=`ls *_${thisplat}_*.zip 2> /dev/null | grep "$fltver"`
				fi
				cd $crrd
				if [ -n "$fl" ]; then
					echo "Found $fltver and $thisplat zip files under $ver/$bld/opack folder."
					for onezip in $fl; do
						cp $BUILD_ROOT/$ver/$bld/opack/$onezip $targ 2>&1
					done
					echo "$ver/$bld/opack/\*_${thisplat}_\*.zip" > $HYPERION_HOME/opack_location.txt
				else
					cp $BUILD_ROOT/$ver/$bld/opack/*.zip $targ > /dev/null 2>&1
					echo "$ver/$bld/opack/\*.zip" > $HYPERION_HOME/opack_location.txt
				fi
			else
				echo "No ZIP file under the $BUILD_ROOT/$ver/$bld/opack fodler."
				exit 4
			fi
		else
			if [ ! -d "$BUILD_ROOT/$ver/$bld/opack/$opbld" ]; then
				echo "No $opbld folder under the $BUILD_ROOT/$ver/$bld/opack folder."
				exit 4
			fi
			# ls $BUILD_ROOT/$ver/$bld/opack/$opbld/$thisplat/*.zip > /dev/null 2>&1
			if [ -d "$BUILD_ROOT/$ver/$bld/opack/$opbld/$thisplat" ]; then
				crrd=`pwd`
				cd $BUILD_ROOT/$ver/$bld/opack/$opbld/$thisplat
				if [ "${fltver#!}" != "$fltver" ]; then
					fl=`ls *.zip 2> /dev/null | grep -v "${fltver#!}"`
				else
					fl=`ls *.zip 2> /dev/null | grep "$fltver"`
				fi
				cd $crrd
			fi
			if [ -n "$fl" ]; then
				echo "Found zip files under $ver/$bld/opack/$opbld/$thisplat folder."
				for one in $fl; do
					cp $BUILD_ROOT/$ver/$bld/opack/$opbld/$thisplat/$one $targ 2> /dev/null
				done
				# cp $BUILD_ROOT/$ver/$bld/opack/$opbld/$thisplat/*.zip $targ > /dev/null 2>&1
				echo "$ver/$bld/opack/$opbld/$thisplat/\*.zip" > $HYPERION_HOME/opack_location.txt
			else
				crrd=`pwd`
				cd $BUILD_ROOT/$ver/$bld/opack/$opbld
				if [ "${fltver#!}" != "$fltver" ]; then
					fl=`ls *_${thisplat}_*.zip 2> /dev/null \
						| grep -v "${fltver#!}"`
				else
					fl=`ls *_${thisplat}_*.zip 2> /dev/null \
						| grep "$fltver"`
				fi
				cd $crrd
				if [ -n "$fl" ]; then
					echo "Found $fltver and $thisplat zip files under $ver/$bld/opack/$opbld folder."
					for onezip in $fl; do
						echo "  cp $onezip to $targ."
						cp $BUILD_ROOT/$ver/$bld/opack/$opbld/$onezip $targ 2>&1
					done
					echo "$ver/$bld/opack/$opbld/\*_${thisplat}_\*.zip" > $HYPERION_HOME/opack_location.txt
				else
					cp $BUILD_ROOT/$ver/$bld/opack/$opbld/*.zip $targ > /dev/null 2>&1
					echo "$ver/$bld/opack/$opbld/\*.zip" > $HYPERION_HOME/opack_location.txt
				fi
			fi
		fi
	fi
fi

ls $targ/*.zip > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "There is no .zip file for this opack."
	exit 5
fi

unzipcmd=`which unzip 2> /dev/null`
if [ $? -ne 0 -o "x${unzipcmd#no}" != "x${unzipcmd}" ]; then
	case `uname` in
		HP-UX)	unzipcmd=`which unzip_hpx32`;;
		Linux)	unzipcmd=`which unzip_lnx`;;
		SunOS)	unzipcmd=`which unzip_sparc`;;
		AIX)	unzipcmd=`which unzip_aix`;;
	esac	
fi
if [ $? -ne 0 -o -z "${unzipcmd}" ]; then
	echo "Couldn't find the unzip command."
	exit 6
fi
echo "unzipcmd=$unzipcmd"

# extract each zip file
cd $VIEW_PATH/opack
opdirs=
while [ 1 ]; do
	tarzip=`ls -r *.zip 2> /dev/null | head -1`
	zipbase=${tarzip%.zip}
	[ -z "$tarzip" ] && break
	[ -f unzip.log ] && rm -rf unzip.log > /dev/null 2>&1
	${unzipcmd} -o ${tarzip} > unzip.log
	rm -f ${tarzip}
	opdir=`grep "creating" unzip.log | head -1 | awk '{print $2}'`
	opdir=${opdir%?}
	whichOpack=`grep "EssbaseServer" unzip.log`
	if [ $? -eq 0 ]; then
		whichOpack="server"
	else
		whichOpack=`echo "$tarzip" | grep "_server_"`
		[ -n "$whichOpack" ] && whichOpack="server" || whichOpack=
	fi
	if [ -z "$whichOpack" ]; then
		whichOpack=`grep "EssbaseClient" unzip.log`
		if [ $? -eq 0 ]; then
			whichOpack="client"
		else
			whichOpack=`echo "$tarzip" | grep "_client_"`
			[ -n "$whichOpack" ] && whichOpack="client" || whichOpack=
		fi
	fi
	if [ -z "$whichOpack" ]; then
		whichOpack=`grep "EssbaseRTC" unzip.log`
		if [ $? -eq 0 ]; then
			whichOpack="rtc"
		else
			whichOpack=`echo "$tarzip" | grep "_rtc_"`
			[ -n "$whichOpack" ] && whichOpack="rtc" || whichOpack="unknown"
		fi
	fi
	if [ -z "$opdir" -o ! -d "$opdir" ]; then
		echo "Failed to unzip opack($tarzip) file."
		cat $ unzip.log 2> /dev/null | while read -r line; do print -r "> $line"; done
		rm -rf unzip.log > /dev/null 2>&1
		exit 7
	fi
	rm -rf unzip.log > /dev/null 2>&1
	[ -z "$opdirs" ] && opdirs="$opdir:$whichOpack" || opdirs="$opdirs $opdir:$whichOpack"
	echo "- $tarzip $opdir:$whichOpack"
done
# echo "opdirs=$opdirs"

apply_opack

# Test rollback command
if [ $sts -eq 0 -a "$rollbacktest" = "true" ]; then
	cd $VIEW_PATH/opack
	echo ""
	echo "ROLLBACK TEST..."
	rm -rf applied.lst > /dev/null 2>&1
	echo "Applied opack list:"
	opackcmd.sh lsinv | while read -r line; do print -r "LSINV:$line"; done
	opackcmd.sh lsinv | grep "^Patch" | grep "applied" > applied.lst
	rm -rf _tmpimp_ > /dev/null 2>&1
	rm -rf _sts_ > /dev/null 2>&1
	echo "y" > _tmpimp_
	echo "y" >> _tmpimp_
	while read dmy id rest; do
		echo "# Rollback for $id"
		(
			opackcmd.sh rollback -id $id < _tmpimp_
			echo $? > _sts_
		) | while read -r line; do print -r "ROLLBACK:$line"; done
		sts=`cat _sts_ 2> /dev/null`; [ -z "$sts" ] && sts=0
		[ $sts -ne 0 ] && break
	done < applied.lst
	sts=`cat _sts_ 2> /dev/null`; [ -z "$sts" ] && sts=0
	rm -rf _sts_ > /dev/null 2>&1
	rm -rf _tmpimp_ > /dev/null 2>&1
	echo "y" > _tmpimp_
	echo "Applied opack list after rollback:"
	opackcmd.sh lsinv | while read -r line; do print -r "LSINV:$line"; done
	if [ $sts -ne 0 ]; then
		echo "### There is problem on rollback(sts=$sts)."
	else
		essver=`(. se.sh $ver > /dev/null 2>&1;get_ess_ver.sh)`
		if [ "$crrver" = "$essver" ]; then
			echo "### Rollbacked($essver) and previous($crrver) versions are same."
		else
			echo "### Rollbacked($essver) and previous($crrver) versions are different."
		fi
	fi
	rm -rf applied.lst
	echo "Re-apply opack again..."
	apply_opack > /dev/null 2>&1
fi

# Compare the binaries with refresh binaries
if [ $sts -eq 0 -a "$cmpzipbin" = "true" ]; then
	echo ""
	echo "COMPARE OPACK BINARY -> REFRESH BINARY"
	cd $VIEW_PATH/opack
	rm -rf refresh.siz > /dev/null 2>&1
	rm -rf refreshbin.siz > /dev/null 2>&1
	rm -rf opack.siz > /dev/null 2>&1
	rm -rf opackbin.siz > /dev/null 2>&1
	rm -rf refresh > /dev/null 2>&1
	mkdir refresh
	cd refresh
	ext_reftar.sh $ver $bld
	filesize.pl $cmpattr -cksum -igndir ARBORPATH HYPERION_HOME > ../refresh.siz
	grep "^ARBORPATH/bin" ../refresh.siz > ../refreshbin.siz
	cd ..
	# rm -rf refresh > /dev/null 2>&1
	(
		. ver_setenv.sh $ver
		unset _plat32 _rtc64
		case $thisplat in
        		solaris|aix)    _plat32="-32";;
        		*64*)                    _rtc64="-64";;
		esac
		_ESSDIR=`echo $_ESSDIR | sed -e "s/<plat32>//g" -e "s/<rtc64>/$_rtc64/g"`
		_ESSCDIR=`echo $_ESSCDIR | sed -e "s/<plat32>//g" -e "s/<rtc64>/$_rtc64/g"`
		rm -rf opack.siz > /dev/null 2>&1
		for opdir in $opdirs; do
			opdir=${opdir%:*}
			echo "Create file size for $opdir..."
			export HYPERION_HOME=$VIEW_PATH/opack/$opdir/files
			rm -f $opdir.siz > /dev/null 2>&1
			rm -f $opdir.tmp > /dev/null 2>&1
			filesize.pl $cmpattr -cksum -igndir \$HYPERION_HOME > $opdir.tmp
			if [ -n "$_ESSCDIR" ]; then
				cat $opdir.tmp | sed -e "s!^HYPERION_HOME/$_ESSDIR!ARBORPATH!g" \
					-e "s!^HYPERION_HOME/$_ESSCDIR!ARBORPATH!g" > $opdir.siz
			else
				cat $opdir.tmp | sed -e "s!^HYPERION_HOME/$_ESSDIR!ARBORPATH!g" > $opdir.siz
			fi
			cat $opdir.siz >> opack.siz
			rm -f $opdir.tmp > /dev/null 2>&1
			# rm -f $opdir.siz > /dev/null 2>&1
		done
		rm -rf opack.tmp > /dev/null 2>&1
		sort opack.siz > opack.tmp
		uniq opack.tmp > opack.siz
		rm -rf opack.tmp > /dev/null 2>&1
	)
	isrtc=`grep EssbaseRTC opack.siz`
	if [ -n "$isrtc" ]; then	# When opack include HH/common/EssbaseRTC...
		rm -f opack_siz.tmp > /dev/null 2>&1
		cat opack.siz | sed -e "s!^.*EssbaseRTC.*/bin!ARBORPATH/bin!g" \
			-e "s!^.*EssbaseRTC.*/locale!ARBORPATH/locale!g" > opack_siz.tmp
		rm -f opack.siz > /dev/null 2>&1
		cat opack_siz.tmp | egrep -v "$ignbin_list" | sort | uniq > opack.siz
	fi
	rm -rf opack.dif > /dev/null 2>&1
	sizediff.pl opack.siz refresh.siz | grep -v "^a >" | tee opack.dif
	dnum=`cat opack.dif | wc -l`
	let dnum=dnum
	if [ $dnum -eq 0 ]; then
		echo "### There is no differences between refresh and OPACK binaries."
	else
		echo "### $dnum diff exists between refresh and OPACK binaries."
	#	exit 10
	fi

	# Duplicate file check
	if [ -n "$dupchk_list" ]; then

	echo ""
	echo "CHECK DUPLICATED EXECUTABLE FILES BETWEEN ..."
	for one in $dupchk_list; do
		echo "  $one"
	done
	trgdir=$VIEW_PATH/opack/opackbin
	frmlst=$VIEW_PATH/opack/opb_from.lst
	cd $VIEW_PATH/opack
	rmdir -rf opackbin > /dev/null 2>&1
	rmdir -rf $frmlst > /dev/null 2>&1
	mkdir opackbin 2> /dev/null
	unset svdir _sv 
	for one in $dupchk_list; do
		if [ -z "$svdir" ]; then
			svdir=$one
			_sv=`echo $svdir | sed -e "s!$HYPERION_HOME!HH!g"`
		fi
		if [ -d "$one" ]; then
			cd $one
			_one=`echo $one | sed -e "s!$HYPERION_HOME!HH!g"`
			ls | while read fname; do
				if [ -d "$fname" ]; then
					cp -pR $fname $trgdir
					echo "$fname $_one # Directory" >> $frmlst
				elif [ -h "$fname" ]; then
					lnksrc=`ls -l $fname`
					lnksrc=${lnksrc##*-\> }
					ln -s $lnksrc $trgdir/$fname
					echo "$fname $_one # Symbolick link to $lnksrc" >> $frmlst
				elif [ -f "$trgdir/$fname" ]; then
					unset oinf osiz ochsm tinf tsiz tchsm
					oinf=`cksum $trgdir/$fname 2> /dev/null`
					if [ $? -eq 0 ]; then
						osiz=`echo $oinf | awk '{print $2}'`
						ocksm=`echo $oinf | awk '{print $1}'`
					fi
					tinf=`cksum $fname 2> /dev/null`
					if [ $? -eq 0 ]; then
						tsiz=`echo $tinf | awk '{print $2}'`
						tcksm=`echo $tinf | awk '{print $1}'`
					fi
					if [ ! "$tsiz" = "$osiz" -o ! "$tcksm" = "$ocksm" ]; then
						echo "# Dup $fname $_one($tsiz:$tcksm) <- $_sv($osiz/$ocksm)"
						echo "$fname $_one($tsiz:$tcksm)." >> $frmlst
						# cp -p $fname $svdir 2> /dev/null
						# cp -p $fname $trgdir 2> /dev/null
					else
						echo "$fname $_one # Dup of $_sv." >> $frmlst
					fi
				else
					oinf=`cksum $fname 2> /dev/null`
					if [ $? -eq 0 ]; then
						osiz=`echo $oinf | awk '{print $2}'`
						ocksm=`echo $oinf | awk '{print $1}'`
					fi
					cp -p $fname $trgdir 2> /dev/null
					echo "$fname $_one($osiz:$ocksm)" >> $frmlst
				fi
			done
		else
			echo "# Directory $_one not found."
		fi
	done
	cd $VIEW_PATH/opack
	filesize.pl $cmpattr -cksum -igndir opackbin | sed -e "s!^opackbin!ARBORPATH/bin!g" > opackbin.siz
	echo ""
	echo "Compare execution moduels between refresh/bin and installations..."
	sizediff.pl refreshbin.siz opackbin.siz | egrep -v "$ignbin_list" | grep -v "^a > " | tee bin.dif | while read line; do
		cord=`echo $line | awk '{print $1}'`
		mod=`echo $line | awk '{print $3}'`
		mod=${mod##*/}
		echo $line
		if [ "$cord" = "c" ]; then
			grep "$mod" $frmlst 2> /dev/null | while read ltmp; do
				echo "  dup of:$ltmp"
			done
		fi
	done
	dnum=`cat bin.dif | wc -l`
	let dnum=dnum
	if [ $dnum -eq 0 ]; then
		echo "### There is no differences between refresh/bin and OPACK/bin binaries."
	else
		echo "### $dnum diff exists between refresh/bin and OPACK/bin binaries."
		# exit 10
	fi

	else # dupchk_list
		echo "### No dupchk_list defined. Skip dup file check."
	fi
fi

### cd $VIEW_PATH
### rm -rf opack > /dev/null 2>&1

cd $crrdir
# WORKAROUND BUG 12743474
# if [ "$ver" = "11.1.2.2.000" ]; then
# 	if [ "$thisplat" = "win32" ]; then
# 		cp $AUTOPILOT/data/MSRTC100/win32/* $HYPERION_HOME/products/Essbase/EssbaseServer/bin
# 		cp $AUTOPILOT/data/MSRTC100/win32/* $HYPERION_HOME/common/EssbaseRTC/11.1.2.0/bin
# 	elif [ "$thisplat" = "winamd64" ]; then
# 		cp $AUTOPILOT/data/MSRTC100/winamd64/* $HYPERION_HOME/products/Essbase/EssbaseServer/bin
# 		cp $AUTOPILOT/data/MSRTC100/winamd64/* $HYPERION_HOME/common/EssbaseRTC-64/11.1.2.0/bin
# 	fi
# fi

# Apply other opatch
otp=`chk_para.sh opackOther "$_OPTION"`
otp=`echo "$otp" | tr A-Z a-z`
if [ "$sts" -eq 0 ]; then
	# Variables
        if [ "$otp" = "false" ]; then
		target=
	elif [ -n "$otp" ]; then
		for one in aps studio eas; do
			[ -n "`echo $otp | grep $one`" ] && target="${target} $one"
		done
	else
		# Bug 18019330 - LINUX32 EAS OPACK MAKE WEBLOGIC SERVER HANGS AT STATING SERVICE
		# target="aps studio eas"
		target="aps studio"
	fi
	aps_reloc="../../eesdev/aps"		# Relative location for APS from $BUILD_ROOT
	studio_reloc="../../bailey/builds"	# Relative location for Studio from $BUILD_ROOT
	eas_reloc="../../eas/builds"		# Relative locaiton for EAS from $BUILD_ROOT
	bld=latest
	[ "$AP_BISHIPHOME" = "true" ] && kind=bi || kind=epm
	# Set each product root directory to <prod>_root
	for one in $target; do
		str=`echo $one | tr a-z A-Z`
		val=`eval echo \\$AP_${str}ROOT`
		[ -n "$val" -a -d "$val" ] && eval "${one}_root=\"$val\""
		val=`eval echo \\$${one}_root`
		if [ -z "$val" ]; then
			if [ -d "$BUILD_ROOT" ]; then
				val=`eval echo \\$${one}_reloc`
				if [ -n "$val" ]; then
					if [ -d "$BUILD_ROOT/$val" ]; then
						crr=`pwd`
						cd $BUILD_ROOT/$val
						val=`pwd`
						cd $crr
						eval "${one}_root=\"$val\""
					fi
				fi
			else
				echo "${me##*/}: Cannot access \$BUILD_ROOT($BUILD_ROOT)."
				exit 3
			fi
		fi
	done
	# Re-create target list by each root location.
	_tmplist=$target
	target=
	for one in $_tmplist; do
		val=`eval echo \\$${one}_root`
		if [ -d "$val" ]; then
			[ -z "$target" ] && target=$one || target="$target $one"
		fi
	done
	# Apply each opatch
	for one in $target; do
		echo "### Start $one opack. ###"
		rootf=`eval echo \\$${one}_root`
		optmpf="$VIEW_PATH/${one}opack"
		rm -rf $optmpf
		rm -f $HYPERION_HOME/${one}_version.txt
		# Decide build number for each products
		tarbld=$bld
		val=`chk_para.sh ${one}bld "$_OPTION"` # APSBld() StudioBld() option
		val=${val##* }
		[ -n "$val" ] && tarbld=$val
		if [ "$tarbld" = "latest" ]; then
			[ -f "$rootf/$ver/latest/bldnum.txt" ] \
				&& tarbld=`cat $rootf/$ver/latest/bldnum.txt | tail -1 | tr -d '\r'` \
				|| tarbld=`ls $rootf/$ver | egrep ^[0-9][0-9]*$ | tail -1 | tr -d '\r'`
		fi
		opkdir="$rootf/$ver/$tarbld/opack"
		if [ -d "$opkdir" ]; then
			crr=`pwd`
			mkddir.sh $optmpf
			cd $optmpf 2> /dev/null
			if [ "$one" = "eas" ]; then
				pl=`get_platform.sh`
				cp $opkdir/$pl/server/*.zip $optmpf 2> /dev/null
				[ -d "$opkdir/$pl/console" ] && cp $opkdir/$pl/console/*.zip $optmpf 2> /dev/null
			else
				cp $opkdir/*.zip $optmpf 2> /dev/null
			fi
			while [ 1 ]; do
				tarzip=`ls -r *.zip 2> /dev/null | head -1`
				[ -z "$tarzip" ] && break
				zipbase=${tarzip%.zip}
				rm -rf zip.log
				${unzipcmd} -o ${tarzip} > zip.log
				rm -rf ${tarzip}
				opdir=`cat zip.log | grep "creating" | head -1 | awk '{print $2}'`
				opdir=${opdir%?}
				invf=$opdir/etc/config/inventory
				[ -f "$invf.xml" ] && invf="${invf}.xml"
				comp=`cat $invf 2> /dev/null | grep "<component internal_name=" | tail -1`
				finddir=
				if [ -n "$comp" ]; then
					if [ "$one" = "studio" ]; then
						mode=`cat zip.log | grep "EssbaseStudio/Server"`
						[ -z "$mode" ] && continue
					fi
					[ "$kind" = "bi" ] && gstr="oracle.bi" || gstr="oracle.epm"
					mode=`echo $comp | grep "$gstr"`
					if [ -n "$mode" ]; then
						finddir="`pwd`/$opdir"
					fi
				fi
				if [ -n "$finddir" ]; then
	echo "### APPLYOTHER $one $tarzip(${kind}:$finddir)"
					apply_one_opack $finddir
					echo "$ver:$tarbld" > $HYPERION_HOME/${one}_version.txt
				fi
			done
			cd $crr
		fi
	done
fi

echo "opackinst.sh(sts=$sts)"
exit $sts
