#!/usr/bin/ksh
# hyslinst.sh : Install Essbase product
# Description:
#   This command install Essbase product and ESSCMDQ/ESSCMDG.
#   This command use CD or HIT installer for the specific ver/bld
#   into $HYPERION_HOME localtion. If you have your own environment setup file in
#   the $AUTOPILOT/env/${LOGNAME} folder, this command get the $HYPERION_HOME
#   location from there.
#   When CD or HIT installer failed to install, this command attempt to use 
#   "refresh" command. If you don't want to use "refresh" command, you need use
#   "cd" parameter.
#
# Syntax:
#   hyslinst.sh [cd|refresh|both] [<option>] <ver> <bld>
#    <option>:=-h|-keep|-noinit|-nocmdgq|-clear|-rsp <rsp-file>|-server|-client
#              |-opack <opack-bld#>|-base <base-ver#>:<base-bld#>|-icm
#              |-hitloc <hit-loc> <label>:<bi-loc>
# Parameter:
#   <ver>    : Version number described under the pre_rel/essbase/builds folder.
#                ex.) hyslinst.sh zola 078
#              When the version has a sub-folder like 9.2, you need to define it
#              with a sub-folder name.
#                ex.) hyslinst.sh 9.2/9.2.1.0.3 001
#   <bld>    : Build number of Essbase.
#              <ess-bld> or hit(<hit-bld>) or bi(<bi-brch>[/<bi-lbl>])
#              <ess-bld> : Build folder name under pre_rel/essbase/builds/<ver>
#              <hit-bld> : HIT build string after "build_" under prodpos/<ver>
#              <bi-brch> : BISHIPHOME branch name under AP_ADEROOT folder.
#                          like MAIN, 11.1.1.6.1, etc...
#                          "BISHIPHOME_<bi-brnch>_<platform>.rdd"
#                          If you want to use another label instead of BISHIPHOME 
#                          like BIFNDNEPM, BIFNDN, etc..., please use 
#                          "<label>/<branch>[/<label>]" format.
#                          You can confirm "srch_bi.sh -lp" for another labels.
#                          You also check the branch names with "srch_bi.sh".
#                          You can see the labels for specific version with
#                          "srch_bi.sh bi <branch>" command.
#                          $ srch_bi.sh bi MAIN
#              <bi-lbl>  : BISHIPHOME label.
#              When use latest for each build parameter, Essbase uses latest build
#              contents, HIT uses latest build_XXXXX and BI uses MAIN:LATEST.
#   cd       : Use CD or HIT, BI installer only.
#   refresh  : User "refresh" command for the installation.
#   both     : Use CD or HIT, BI installer first, then try "refresh" command.
# OPtions:
#   -h       : Display help.
#   -keep    : Keep previous Application, config and security file.
#   -clear   : Clear \$HYPERION_HOME contents before installation.
#   -noclear : Not clear \$HYPERION_HOME contents before installation.
#   -noinit  : No initialization. (No inst test)
#   -nocmdgq : No ESSCMDQ/G installation. (No inst test)
#   -rsp     : Use <rsp-file> for the response file for the installation.
#   -server  : Install Srver module only.
#   -client  : Install Client module only.
#              Note) If you don't use -server and -client, hyslinst.sh install
#                    Both server and client modules.
#   -opack   : User <opack-bld#> for the installation.
#   -base    : Install <base-ver#>:<base-bld#> first, then use refresh to install
#              the target version.
#                ex.) Following command install Zola hit[latest] first then use
#                     \"refresh\" command to install Talleyrand modules.
#                  $ hyslinst.sh -base zola:hit[latest] talleyrand latest
#   -icm     : Ignore CM acceptance result.
#   -hitloc  : Set the AP_HITLOC.
#              When you define it with absolute path, hitinst.sh uses that path
#              for the search location for the HIT installer.
#              If it isn't absolute path, hitinst.sh uses it instead of prodpost.
#              Ex.)
#                1) Use qepost for the HIT installer.
#                   hitinst.sh -hitloc qepost 11.1.2.2.000 hit[latest]
#
# This shell program install the Essbase Server and Client modules using
# the installer image or cd image files. If it fail, this program try to
# use "refresh" command. 
#
# Exit value:
#   0 : Installation success 
#       (if .error.sts exists, it mean the installer failed but success on refresh)
#   1 : Parameter error
#   2 : Env Var not defined
#   3 : Error
#   4 : No HIT Base version
#
# Sample:
# 1) Use Essbase build 2166. This may use HIT/build_7790 becuase it contains 2166.
#   $ hyslinst.sh 11.1.2.2.100 2166
# 2) Use Essbase latest build for the kennedy version.
#   $ hyslinst.sh kennedy latest # Use build 473
# 3) Use HIT/buid_7790 installer.
#   $ hyslinst.sh 11.1.2.2.100 hit[7790] # HIT build_7790
# 4) Use latest for the HIT build number.
#   $ hyslinst.sh talleyrand_sp1 hit[latest] # Use HIT build_6765_rtm
# 5) Use BISHIPHOME latest installer.
#   $ hyslinst.sh 11.1.2.2.001 "bi(latest)" # Use BISHIPHOME/MAIN:LATEST
# 6) Use BISHIPHOME/MAIN/120502.2000 installer.
#   $ hyslinst.sh 11.1.2.2.001 bi[MAIN/120502.2000]
#     note: BISHIPHOME/MAIN/120502.200(Essbase 11.1.2.2.001:3009)
#######################################################################
# History:
# 06/21/2007 YK Fist edition. Made new installer shell program from hyslinst2.sh
# 07/12/2007 YK Add saving environment variables feature
# 07/18/2007 YK Change the error status file location
# 09/18/2007 YK Add agent port setup when AP_AGENTPORT is set.
# 10/24/2007 YK Add Third parameter for cd|refresh|both.
# 11/20/2007 YK Remove calling get_envfile.sh. Use _ENVFILEBASE variable instead.
# 01/17/2008 YK Change to use cdinst.sh
# 05/19/2008 YK Add HIT installer
# 06/24/2008 YK Add copying the wrapper.so for the refresh command.
# 07/16/2008 YK Use build value returned by vresion.sh
# 09/23/2008 YK Add refresh record into HYPERION_HOME
# 02/20/2009 YK Add -k|keep option.
# 05/20/2009 YK Add -noinit and -nocmdgq option.
# 08/06/2009 YK Add OPACK installation and -opack and -back options.
# 12/20/2009 YK Change HIT behavior
# 09/17/2010 YK Change Talleyrand OPACK installation.
#               Case of no hpatch.bat.
# 10/15/2010 YK Add Ignore CM acceptance result option.
# 10/18/2010 YK Ignore Talleyrnad PS1 OPACK folder.
# 10/29/2010 YK Separate OPACK installation part to opackinst.sh
#               Add status check after calling normbld.sh
# 11/24.2010 YK Add same ver opack support. (refresh opack from Talleyrand PS1)
# 01/24/2011 YK Support AP_HITPREFIX
# 06/16/2011 YK Add -hitloc parameter
# 07/08/2011 YK Use get_opackbase.sh to determine the opack base version.
# 07/29/2011 YK Remove error output.
# 08/26/2011 YK Change refresh call method.
# 01/17/2012 YK Support -bi and BISHIPHOME installer.
# 04/12/2012 YK Support basehit
# 06/11/2012 YK Support bi(), secmode() and cmdgqbld()
# 04/03/2013 YK BUG 16590342 - AUTOPILOT NEEDS TO KEEP THE INSTALL FLAG LOCKED UNTIL OPACK IS COMPLETE 
# 04/04/2013 YK Bug 16324848 - 11.1.2.3.000 ESSBASE INSTALL ORDER
# 04/15/2013 YK Support basehit() option.

. apinc.sh

_backuploc_="$HOME/${LOGNAME}@`hostname`_hyslinst.backup"

save_prev_app()
{
	echo "### Save previous Applications and security files."
	[ -d "$_backuploc_" ] && rm -rf "$_backuploc_"
	mkddir.sh "$_backuploc_"
	[ -d "$HYPERION_HOME/logs/essbase/app" ] && cp -R "$HYPERION_HOME/logs/essbase/app" "$_backuploc_/logs_app"
	[ -d "$ARBORPATH/app" ] && cp -R "$ARBORPATH/app" "$_backuploc_/app"
	[ -f "$ARBORPATH/bin/essbase.cfg" ] && cp "$ARBORPATH/bin/essbase.cfg" "$_backuploc_"
	[ -f "$ARBORPATH/bin/essbase.sec" ] && cp "$ARBORPATH/bin/essbase.sec" "$_backuploc_"
}

restore_prev_app()
{
	if [ -d "$_backuploc_" ]; then
		echo "### Restore saved Applications and security files."
		[ -f "$_backuploc_/essbase.cfg" ] && cp "$_backuploc_/essbase.cfg" "$ARBORPATH/bin"
		[ -f "$_backuploc_/essbase.sec" ] && cp "$_backuploc_/essbase.sec" "$ARBORPATH/bin"
		if [ -d "$_backuploc_/app" ]; then
			rm -rf "$ARBORPATH/app"
			cp -R "$_backuploc_/app" "$ARBORPATH/app"
		fi
		if [ -d "$_backuploc_/logs_app" ]; then
			rm -rf "$HYPERION_HOME/logs/essbase/app"
			cp -R "$_backuploc_/logs_app" "$HYPERION_HOME/logs/essbase/app"
		fi
		rm -rf "$_backuploc_"
	fi
}

#######################################################################
# Main
#######################################################################
[ -n "$AP_HITPREFIX" ] && _hitpref=$AP_HITPREFIX || _hitpref=build_

# Check the Parameter
me=$0
inst=BOTH
keep_prev_app=false
orgpar=$@
instgq=true
noinit=false
clrdsk=true
opbld=latest
dbg=false
unset ver bld biver ignCM exacthit basevsn knd rspf use_zip instkind opbase basehit
while [ $# -ne 0 ]; do
	case $1 in
		+d|-dbg|dbg|debug)	dbg=true ;;
		keep|-keep|-k)		keep_prev_app=true ;;
		cd|installer|hit)	inst=CD ;;
		refresh)		inst=REFRESH ;;
		both)			inst=BOTH ;;
		-skipcmdgq|-nocmdgq)	instgq=false; noinit=true ;;
		-noinit)		noinit=true ;;
		-clear)			clrdsk=true ;;
		-noclear)		clrdsk=false ;;
		-server|-client)	knd=$1 ;;
		-hitloc)
			if [ $# -lt 2 ]; then
				echo "${me##*/}:\"-hitloc\" parameter need a second parameter for AP_HITLOC."
				exit 1
			fi
			shift
			export AP_HITLOC=$1
			;;
		-rsp)
			if [ $# -lt 2 ]; then
				echo "${me##*/}:\"-rsp\" parameter need a second parameter for <rsp-file>."
				exit 1
			fi
			shift
			rspf=$1
			;;
		-opack|opack)
			if [ $# -lt 2 ]; then
				echo "${me##*/}:\"-opack\" parameter need a build number for opack."
				exit 1
			fi
			shift
			opbld=$1
			;;
		-base|base)
			if [ $# -lt 2 ]; then
				echo "${me##*/}:\"-base\" parameter need a base version and build number for pre-installation."
				exit 1
			fi
			shift
			basevsn=$1
			inst=BASE
			;;
		zip|-zip|cmp|-cmp)	use_zip="-zip" ;;
		-icm|-igncm|-ignCM)	ignCM="-icm" ;;
		-h|help|-help)
			display_help.sh $me
			exit 0
			;;
		-o|-opt)
			if [ $# -lt 2 ]; then
				echo "${me##*/}:\"$1\" need a second parameter."
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
				echo "${me##*/}:Too many parameters defined."
				echo "  parm=\"$orgpar\""
				exit 1
			fi
			;;
	esac
	shift
done

if [ -z "$ver" ]; then
	echo "${me##*/}:No version is defined."
	echo "  parm=\"$orgpar\""
	exit 1
fi

[ -z "$bld" ] && bld="latest"

# Check if required environment variables are defined
if [ -z "$BUILD_ROOT" ]; then
	echo "${me##*/}:BUILD_ROOT not defined"
	exit 2
fi

# Setup version sub folder variables like 7.1/7.1.5.0
if [ "${ver##*/}" = "$ver" ]; then
	mver="${ver}"
	sver=""
else
	mver=${ver%/*}
	sver="${ver##*/}/"
fi

# Read task option
optstr=`chk_para.sh BI "$_OPTION"`; optstr=${optstr##* }
[ -n "$optstr" ] && export AP_BISHIPHOME="$optstr"

optstr=`chk_para.sh SecMode "$_OPTION"`; optstr=${optstr##* }
[ -n "$optstr" ] && export AP_SECMODE="$optstr"
[ "$AP_SECMODE" = "rep" -o "$AP_SECMODE" = "fa" ] && export AP_BISHIPHOME="true"

optstr=`chk_para.sh CmdGQBld "$_OPTION"`; optstr=${optstr##* }
[ -n "$optstr" ] && cmdgqbld=$optstr || cmdgqbld=

optstr=`chk_para.sh noCleanHH "$_OPTION"`; optstr=${optstr##* }
[ -n "$optstr" ] && clrdsk=$optstr 

optstr=`chk_para.sh bizip "$_OPTION"`; optstr=${optstr##* }
if [ -n "$optstr" ]; then
	export AP_BISHIPHOME="true"
	instkind=opackbi
	[ -n "_OPTION" ] \
		&& export _OPTION="$_OPTION bi(true) opackver(bi)" \
		|| export _OPTION="bi(true) opackver(bi)"
	opbase=bizip
fi

optstr=`chk_para.sh biimg "$_OPTION"`; optstr=${optstr##* }
if [ -n "$optstr" ]; then
	export AP_BISHIPHOME="true"
	instkind=opackbi
	[ -n "_OPTION" ] \
		&& export _OPTION="$_OPTION bi(true) opackver(bi)" \
		|| export _OPTION="bi(true) opackver(bi)"
	opbase=biimg
fi

optstr=`chk_para.sh basehit "$_OPTION"`; optstr=${optstr##* }
if [ -n "$optstr" ]; then
	basehit=$optstr
fi

if [ "$dbg" = "true" ]; then
	echo "### hyslinst.sh initial variables."
	echo "# - me=$me"
	echo "# - inst=$inst"
	echo "# - keep_prev_app=$keep_prev_app"
	echo "# - orgpar=$orgpar"
	echo "# - instgq=$instgq"
	echo "# - noinit=$noinit"
	echo "# - clrdsk=$clrdsk"
	echo "# - opbld=$opbld"
	echo "# - dbg=$dbg"
	echo "# - ver=$ver"
	echo "# - bld=$bld"
	echo "# - biver=$biver"
	echo "# - ignCM=$ignCM"
	echo "# - exacthit=$exacthit"
	echo "# - basevsn=$basevsn"
	echo "# - knd=$knd"
	echo "# - rspf=$rspf"
	echo "# - use_zip=$use_zip"
	echo "# - instkind=$instkind"
	echo "# - opbase=$opbase"
	echo "# - mver=$mver"
	echo "# - sver=$sver"
	echo "# - basehit=$basehit"
fi

# Check version and build number
plat=`get_platform.sh`
nbld=`normbld.sh -w $ignCM $ver $bld`
sts=$?
echo "### normbld.sh -w $ignCM $ver $bld = $sts"
if [ $sts -ne 0 ]; then
	case $sts in
		1)	echo "${me##*/}:Parameter error from normbld.sh."
			echo "  call: normbld.sh -w $ignCM $ver $bld"
			;;
		2)	echo "${me##*/}:No \$BUILD_ROOT defined from normbld.sh.";;
		3)	echo "${me##*/}:No \$HIT_ROOT defined from normbld.sh.";;
		4)	echo "${me##*/}:Invalid ver/bld numner."
			echo "  ver=$ver, bld=$bld"
			(IFS=; normbld.sh -w $ignCM $ver $bld | while read line; do echo "  > $line"; done)
			;;
		5)	echo "${me##*/}:Failed CM acceptance."
			echo "  ver=$ver, bld=$bld, plat=$plat"
			(IFS=; normbld.sh -w $ignCM $ver $bld | while read line; do echo "  > $line"; done)
			;;
		*)	echo "${me##*/}:normbld.sh returned $sts."
			echo "  call: normbld.sh -w $ignCM $ver $bld"
			(IFS=; normbld.sh -w $ignCM $ver $bld | while read line; do echo "  > $line"; done)
			;;
	esac
	exit 3
fi
# $bld keep original build definition
# $nbld keep normalized build number

# normbld.sh -w returned following format
# pre_rel : <ess-bld>
# HIT     : <ess-bld>_<hit-bld>
# BI      : <ess-bld>_<bi-lbl>_bi
# normbld.sh -w 11.1.2.3.000 latest
#   4410
# normbld.wh -w 11.1.2.3.000 hit[latest]
#   4409_8710
# normbld.sh -w 11.1.2.2.200 bi[11.1.1.7.0/LATEST]
#   5027_11.1.1.7.0/LATEST_bi

ebld=${nbld%%_*}	# $ebld keep real Essbase build number

if [ "$dbg" = "true" ]; then
	echo "### After normbld.sh -w $ignCM $ver $bld"
	echo "# - plat=$plat"
	echo "# - bld=$bld"
	echo "# - nbld=$nbld"
	echo "# - ebld=$ebld"
fi

# Define installer kind
if [ "$inst" = "REFRESH" ]; then
	instkind=refresh
elif [ "${nbld%_bi}" != "$nbld" ]; then # BI
	instkind=bi
elif [ "${nbld#*_}" != "$nbld" ]; then # HIT
	instkind=hit
elif [ -z "$instkind" ]; then
	instkind=`ver_installer.sh $ignCM $ver $bld` # cd/install/hit/opack
	if [ $? -ne 0 ]; then
		echo "${me##*/}:Unknowm installer kind($instkind)"
		exit 3
	fi
	if [ "$instkind" = "opack" ]; then
		opbase=`get_opackbase.sh $ver $ebld -opack $opbld`
		if [ "$?" -eq 0 ]; then
			[ "${opbase#bi:}" != "$opbase" ] \
				&& instkind=opackbi \
				|| instkind=opackhit
		else
			echo "${me##*/}:This version is 'opack'."
			echo "  But couldn't find the base version for $ver $bld."
			echo "$opbase"
			instkind=refresh
		fi
	fi
fi
if [ "$dbg" = "true" ]; then
	echo "### After instkind check."
	echo "# - instkind=$instkind"
	echo "# - opbase=$opbase"
fi

[ -z "$cmdgqbld" ] && cmdgqbld=$ebld

if [ "$instgq" = "true" ]; then
	cmdgqloc=`ver_cmdgq.sh $ver`
	if [ $? -ne 0 -o ! -d "$BUILD_ROOT/$ver/$cmdgqbld/$cmdgqloc" ]; then
		echo "${me##*/}:There is no valid build folder for ESSCMDQ/G under the pre_rel."
		echo "  ver=$ver, bld=$cmdgqbld, plat=$plat."
		exit 3
	fi
fi

[ "$bld" != "$ebld" ] && blds="$bld($ebld)" || blds=$bld
[ -n "$rspf" ] && rspf="-rsp $rspf"

_str="Installation of $ver build $blds on $plat"
_dstr=
while [ ${#_dstr} -lt ${#_str} ]; do _dstr="-${_dstr}"; done
echo "#${_dstr}#"
echo " ${_str}"
echo "#${_dstr}#"

[ "$keep_prev_app" = "true" ] && ( . se.sh $ver > /dev/null 2>&1; save_prev_app )

# Run installer

if [ "$inst" = "BASE" ]; then
	basever=${basevsn%:*}
	basebld=${basevsn#*:}
	echo "Install base product($basever:$basebld)"
	hyslinst.sh cd -nocmdgq $ignCM $basever $basebld
	sts=$?
	echo "## Base Installation status for $basevsn = $sts"
	clrdsk=false
	inst=BOTH
fi

echo "Terminating Essbase related processes."
if [ `uname` = "Windows_NT" ]; then
	win_kill_relproc.sh oci.dll
	win_kill_relproc.sh dbghlp.dll
fi
kill_essprocs.sh -all

echo "Trying to Clean up Temp Space"
if [ `uname` = "Windows_NT" ]; then
	echo "No Need to Clean Temp Space"
elif [ `uname` = "AIX" ]; then
	ls -l /tmp | grep -i $LOGNAME | while read line; do
		MYTMP=`echo $line | awk '{print $9}'`
		chmod -R 0777 /tmp/$MYTMP
		rm -rf /tmp/$MYTMP 
	done	
else
	ls -l /var/tmp | grep -i $LOGNAME | while read line; do
		MYTMP=`echo $line | awk '{print $9}'`
		chmod -R 0777 /var/tmp/$MYTMP
		rm -rf /var/tmp/$MYTMP
	done
fi
sleep 5

( . se.sh $ver -nomkdir > /dev/null 2>&1; [ ! -d "$HYPERION_HOME" ] && mkddir.sh $HYPERION_HOME )

if [ "$clrdsk" = "true" ]; then
	if [ "$AP_CLEANPRODROOT" = "true" ]; then
		if [ -d "$PROD_ROOT" ]; then
			echo "Clean up $PROD_ROOT folder."
			crrdir=`pwd`
			cd $PROD_ROOT
			[ "`pwd`" = "$PROD_ROOT" ] && rmfld.sh *
			( . se.sh $ver -nomkdir > /dev/null 2>&1; mkddir.sh $HYPERION_HOME )
			cd $crrdir
		fi
	else
		( . se.sh $ver > /dev/null 2>&1;rm -rf $HYPERION_HOME/* > /dev/null 2>&1 )
	fi
	clrdsk=false
fi

instlock.sh $$
if [ "$instkind" = "bi" ]; then
	sts=0
	hh=`. se.sh $ver -nomkdir > /dev/null 2>&1; echo $HYPERION_HOME`
	# BI installer need empty HYPEIRON_HOME contents
	rm -rf ${hh%/*}/* 2>&1 > /dev/null
	bilbl=${nbld%_bi}; bilbl=${bilbl##*_}
	echo "Use BISHIPHOME installer $bilbl."
	[ "$dbg" = "true" ] && echo "### biinst.sh $bilbl ${hh%/*}"
	biinst.sh $bilbl ${hh%/*}
	sts=$?
	if [ $sts -ne 0 ]; then
		export AP_SECMODE=
		export AP_BISHIPHOME=
	fi
elif [ "$instkind" = "hit" ]; then
	echo "Using HIT installer."
	(. se.sh $ver > /dev/null 2>&1; hitinst.sh $rspf $use_zip $ver $bld)
	sts=$?
elif [ "$instkind" = "cd" -o "$instkind" = "install" ]; then
	echo "Using CD installer."
	(. se.sh $ver > /dev/null 2>&1; cdinst.sh $rspf $knd $ignCM $ver $bld)
	sts=$?
elif [ "$instkind" = "opackbi" ]; then
	echo "This version is BI OPACK."
	sts=0
	if [ -n "$opbase" ]; then
		if [ "${opbase#bi}" = "$opbase" ]; then
			srch_bi.sh in $opbase > /dev/null 2>&1
			if [ $? -eq 0 ]; then
				opbase=`srch_bi.sh in $opbase | grep -v "# NO VER XML" | tail -1`
				opbase=${opbase%% *}
			else
				echo "${me##*/}:Failed to get BI installer."
				unset opbase
				sts=421
			fi
		else
			opbase="dummy/$opbase"
		fi
	fi
	if [ -n "$opbase" ]; then
		(
		hh=`. se.sh $ver -nomkdir > /dev/null 2>&1; echo "${HYPERION_HOME}:${AP_SECMODE}"`
		export AP_BISHIPHOME=true
		if [ -z "$AP_SECMODE" ]; then
			export AP_SECMODE=${hh#*:}
		fi
		hh=${hh%:*}
		echo "Use \"biinst.sh $opbase ${hh%/*} -essver $ver\" command."
		biinst.sh $opbase ${hh%/*} -essver $ver
		)
		hh=`. se.sh $ver -nomkdir > /dev/null 2>&1; echo "${HYPERION_HOME}"`
		sts=$?
		if [ "$sts" -eq 0 ]; then
			if [ -f "$hh/bipatch_version.txt" ]; then
				echo "### Found bipatch_version.txt."
				cat $hh/bipatch_version.txt 2> /dev/null | while read line; do
					echo "### > $line"
				done
				echo "### This installation already has a BI patch."
				echo "### Skip apply opatch."
			else
				( . se.sh $ver > /dev/null 2>&1
				crressv=`get_ess_ver.sh`
				if [ "$crressv" != "$ver:$ebld" ]; then
					echo "### Stop service."
					# stop_service.sh > /dev/null 2>&1
					stop_service.sh 
					kill_essprocs.sh -all
					opackinst.sh $ver $ebld -opack $opbld
					sts=$?
					echo "### Start service again."
					start_service.sh > /dev/null 2>&1
					if [ "$sts" -eq 0 ]; then
						bilbl=`cat $HYPERION_HOME/bi_label.txt 2> /dev/null`
						echo "$ver:$ebld(base:bi[$bilbl])" \
							> $HYPERION_HOME/opack_version.txt
					else
						echo "### Failed to apply opack $ver:$ebld ($sts)."
					fi
				else
                      			echo "### Installed version of Essbase($crressv) is same as target build($ver:$ebld)."
                        		echo "### Skip applying opack."
					sts=0
				fi
				exit $sts
				); sts=$?
			fi
		else
			echo "### Failed to install BISHIPHOME($opbase) to ${hh%/*} ($sts)."
		fi
echo "### _OPTION=$_OPTION"
	fi
	if [ "$sts" -ne 0 ]; then
		sts=4
		export AP_SECMODE=
		export AP_BISHIPHOME=
	fi
elif [ "$instkind" = "opackhit" ]; then
	echo "This version is EPM OPACK."
	skipbld=
	while [ 1 ]; do
		if [ -n "$basehit" ]; then
			hitbld=$basehit
			unset basehit
			sts=0
		else
			hitbld=`get_hitlatest.sh $opbase $skipbld`
			sts=$?
		fi
		if [ "$sts" -ne 0 ]; then
			echo "### Failed to get base HIT($opbase) for Essbase $ver."
			break
		fi
		echo "Install base product - $opbase HIT(${hitbld})."
		(. se.sh $ver > /dev/null 2>&1; hitinst.sh $rspf $use_zip $opbase hit[${hitbld}]; exit $?)
		sts=$?
		if [ "$sts" -ne 0 ]; then
			[ -z "$skipbld" ] && skipbld=${hitbld} || skipbld="$skipbld ${hitbld}"
			echo "### Failed to install base HIT $opbase hit[${hitbld}]."
			echo "### Will try previous build(skipbld=$skipbld)."
		else
			break
		fi
	done
	if [ "$sts" -eq 0 ]; then
		(	. se.sh $ver > /dev/null 2>&1
			crressv=`get_ess_ver.sh`
			if [ "$crressv" != "$ver:$ebld" ]; then
				opackinst.sh $ver $ebld -opack $opbld
				sts=$?
				if [ "$sts" -eq 0 ]; then
					echo "$ver:$ebld(base:`ver_hitver.sh $opbase` hit[${hitbld}])" > $HYPERION_HOME/opack_version.txt
				else
					echo "### Failed to apply opack($sts)."
				fi
			else
				echo "### Installed version of Essbase($crressv) is same as target build($ver:$ebld)."
				echo "### Skip applying opack."
				sts=0
			fi
			if [ "$sts" -eq 0 -a "$thisplat" != "${thisplat#win}" \
			    -a -f "$BUILD_ROOT/$ver/$ebld/client/EssbaseClient.exe" ]; then
				echo "### Install MSI client"
				clinst.sh $BUILD_ROOT/$ver/$ebld/client/EssbaseClient.exe $HYPERION_HOME 2>&1 | \
				while read -r line; do print -r "MSI:$line"; done
			fi
			return $sts
		); sts=$?
	fi
fi
if [ "$instkind" != "refresh" ]; then
	echo "### cd/hit/bi install status=$sts (`date +%D_%T`)"
	if [ "$sts" -eq 0 ]; then
		if [ "$instgq" = "true" ]; then
			cmdgqinst.sh $ignCM $ver $cmdgqbld
			[ $? -ne 0 ] && echo "Failed to install ESSCMDG/Q ($?)."
		fi
		if [ "$noinit" = "true" ]; then
			echo "hyslinst.sh terminate by -noinit or -nocmdgq parameter without an installation test."
			[ "$keep_prev_app" = "true" ] && (. se.sh $ver > /dev/null; restore_prev_app)
			exit 0
		fi
		(. se.sh $ver > /dev/null 2>&1; chk_essinst.sh $ver;sts=$?;echo "# chk_essinit.sh sts=$sts"; stop_service.sh; exit $sts)
		sts=$?
		kill_essprocs.sh -all
		if [ $? -eq 0 ]; then
			[ "$keep_prev_app" = "true" ] && (. se.sh $ver > /dev/null; restore_prev_app)
			exit 0
		else
			echo "Installer check failed($?) for CD/HIT Installation."
		fi
	else
		echo "Failed cd/hit/biinst.sh($sts)"
	fi
fi
instunlock.sh $$

if [ "$inst" = "CD" ]; then
	[ "$keep_prev_app" = "true" ] && (. se.sh $ver > /dev/null 2>&1; restore_prev_app)
	kill_essprocs.sh -all
	exit 3
fi

#######################################################################
# Run refresh command
#######################################################################
echo "Using refresh command.(${mver}:${sver}${ebld})"
(
. se.sh $ver > /dev/null 2>&1
if [ "$clrdsk" = "true" ]; then
	echo "## CLEAR HYPERION_HOME CONTENTS"
	rm -rf $HYPERION_HOME/* 2> /dev/null
fi
[ -n "$ARBORPATH" -a ! -d "$ARBORPATH" ] && mkddir.sh "$ARBORPATH"
[ -f "$refver" ] && rm -f "$refver"
echo "${mver}:${sver}${ebld}" > "$HYPERION_HOME/refresh_version.txt" 2>&1
case "`get_platform.sh`" in
	aix|solaris|linux)	echo "32" | refresh ${_AP_REFRESHOPT} ${mver}:${sver}${ebld} ;;
	win32|hpux|hpux64)	refresh ${_AP_REFRESHOPT} ${mver}:${sver}${ebld} ;;
	*)			echo "64" | refresh ${_AP_REFRESHOPT} ${mver}:${sver}${ebld} ;;
esac
)
sts=$?
# cmdgqinst.sh ${ver} ${ebld}
if [ "$sts" -ne 0 ]; then
	echo "Refresh command failed($sts)."
	[ "$keep_prev_app" = "true" ] && restore_prev_app
	exit 3
fi
. se.sh $ver > /dev/null 2>&1
if [ "$noinit" = "true" ]; then
	echo "hyslinst.sh terminate by -noinit or -nocmdgq parameter without an install test." 
	[ "$keep_prev_app" = "true" ] && restore_prev_app
	exit 0
fi

chk_essinst.sh $ver
if [ "$?" -ne 0 ]; then
	echo "Install check after refresh command failed($sts)."
	[ "$keep_prev_app" = "true" ] && restore_prev_app
	exit 3
fi

[ "$keep_prev_app" = "true" ] && restore_prev_app
exit 0
