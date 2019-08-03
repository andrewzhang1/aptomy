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
#              |-opack <opack-bld#>|-base <base-ver#>:<base-bld#>|-x|-icm
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
#   -x       : Use HIT exact installer.
#              By change of Dec. 09, HIT installer option uses HIT generic build
#              for the installation. Then if some platform doesn't match that 
#              generic build, hyslinst.sh uses a refresh command against that 
#              platform, even if HIT inatller is ready for that platform with 
#              different build.
#              This option forcely use exact HIT installer with different build #.
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

. apinc.sh

_backuploc_="$AUTOPILOT/tmp/${LOGNAME}@`hostname`_hyslinst.backup"

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
			cp -R "$_backuploc_/app" "$HYPERION_HOME/logs/essbase/app"
		fi
		rm -rf "$_backuploc_"
	fi
}

#######################################################################
# Main
#######################################################################
[ -n "$AP_HITPREFIX" ] && _hitpref=$AP_HITPREFIX || _hitpref=build_

#######################################################################
# Check the Parameter
#######################################################################
me=$0
inst=BOTH
keep_prev_app=false
orgpar=$@
use_zip=
instgq=true
noinit=false
clrdsk=true
rspf=
knd=
basevsn=
opbld=latest
exacthit=
ignCM=
dbg=false
unset ver bld biver
while [ $# -ne 0 ]; do
	case $1 in
		+d|-dbg|dbg|debug)
			dbg=true
			;;
		keep|-keep|-k)
			keep_prev_app=true
			;;
		cd|installer|hit)
			inst=CD
			;;
		refresh)
			inst=REFRESH
			;;
		both)
			inst=BOTH
			;;
		-skipcmdgq|-nocmdgq)
			instgq=false
			noinit=true
			;;
		-noinit)
			noinit=true
			;;
		-clear)
			clrdsk=true
			;;
		-noclear)
			clrdsk=false
			;;
		-server|-client)
			knd=$1
			;;
		-hitloc)
			if [ $# -lt 2 ]; then
				echo "\"-hitloc\" parameter need a second parameter for AP_HITLOC."
				display_help.sh $me
				exit 1
			fi
			shift
			export AP_HITLOC=$1
			;;
		-rsp)
			if [ $# -lt 2 ]; then
				echo "\"-rsp\" parameter need a second parameter for <rsp-file>."
				display_help.sh $me
				exit 1
			fi
			shift
			rspf=$1
			;;
		-opack|opack)
			if [ $# -lt 2 ]; then
				echo "\"-opack\" parameter need a build number for opack."
				display_help.sh $me
				exit 1
			fi
			shift
			opbld=$1
			;;
		-base|base)
			if [ $# -lt 2 ]; then
				echo "\"-base\" parameter need a base version and build number for pre-installation."
				display_help.sh $me
				exit 1
			fi
			shift
			basevsn=$1
			inst=BASE
			;;
		zip|-zip|cmp|-cmp)	# this option for HIT installer
			use_zip="-zip"
			;;
		-h|help|-help)
			display_help.sh $me
			exit 0
			;;
		-x)
			exacthit=true
			;;
		-icm|-igncm|-ignCM)
			ignCM="-icm"
			;;
		-o|-opt)
			if [ $# -lt 2 ]; then
				echo "'$1' need a second parameter."
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
			inst=BAD
		fi
		;;
	esac
	shift
done

if [ "$dbg" = "true" ]; then
	echo "inst=$inst"
	echo "ver=$ver"
	echo "bld=$bld"
	echo "use_zip=$use_zip"
	echo "rspf=$rspf"
	echo "keep_prev_app=$keep_prev_app"
	echo "noinit=$noinit"
	echo "knd=$knd"
	echo "opbld=$opbld"
	echo "basevsn=$basevsn"
	echo "exacthit=$exacthit"
	echo "AP_BISHIPHOME=$AP_BISHIPHOME"
	echo "biver=$biver"
fi

if [ "$inst" = "BAD" ]; then
	echo "Too many parameter."
	echo "current param:$orgpar"
	display_help.sh $me
	exit 1
fi

if [ -z "$ver" -o -z "$bld" ]; then
	echo "Too few paramete."
	echo "current param:$orgpar"
	display_help.sh $me
	exit 1
fi

# echo "BUILD_ROOT=$BUILD_ROOT"

#######################################################################
# Check if required environment variables are defined
#######################################################################
if [ -z "$AUTOPILOT" ]; then
	echo "AUTOPILOT not defined."
	exit 2
fi

# echo "BUILD_ROOT=$BUILD_ROOT"
if [ -z "$BUILD_ROOT" ]; then
	echo "BUILD_ROOT not defined"
	exit 2
fi

#######################################################################
# Setup version sub folder variables
#######################################################################

_tmp_=${ver##*/}
if [ "$_tmp_" = "$ver" ]; then
	mver="${ver}"
	sver=""
else
	mver=${ver%/*}
	sver="${_tmp_}/"
fi

#######################################################################
# Read task option
#######################################################################
optstr=`chk_para.sh BI "$_OPTION"`; optstr=${optstr##* }
[ -n "$optstr" ] && export AP_BISHIPHOME="$optstr"
optstr=`chk_para.sh SecMode "$_OPTION"`; optstr=${optstr##* }
[ -n "$optstr" ] && export AP_SECMODE="$optstr"
[ "$AP_SECMODE" = "rep" -o "$AP_SECMODE" = "fa" ] && export AP_BISHIPHOME="true"
optstr=`chk_para.sh CmdGQBld "$_OPTION"`; optstr=${optstr##* }
[ -n "$optstr" ] && cmdgqbld=$optstr || cmdgqbld=
optstr=`chk_para.sh noCleanHH "$_OPTION"`; optstr=${optstr##* }
[ -n "$optstr" ] && clrdsk=$optstr || clrdsk=
optstr=`chk_para.sh bizip "$_OPTION"`; optstr=${optstr##* }
[ -n "$optstr" ] && export AP_BISHIPHOME="true"
optstr=`chk_para.sh biimg "$_OPTION"`; optstr=${optstr##* }
[ -n "$optstr" ] && export AP_BISHIPHOME="true"

#######################################################################
# Install start here
#######################################################################
plat=`get_platform.sh`
bhit=
vbld=`normbld.sh -w $ignCM $ver $bld`
vsts=$?
if [ $vsts -ne 0 ]; then
	echo "debug(\$@=$orgpar)"
	echo "debug(\$ver(\$mver:\$sver)=$ver($mver:$sver) \$bld=$bld \$vbld=$vbld \$vsts=$vsts)"
	echo "There is no valid version/build for $ver $bld."
	echo "\"normbld.sh -w $ver $bld\" returned \"$vbld\"."
	exit 3
fi

if [ "${vbld%_bi}" != "$vbld" ]; then # target is BI
echo "# Target is BI $vbld"
	bhit=${vbld%_bi}
	bhit=${bhit##*_}
	vbld=${vbld%%_*}
	vins=bi
	export AP_BISHIPHOME=true
elif [ "${vbld%%_*}" != "$vbld" ]; then # target is HIT
	bhit=${vbld#*_}
	vbld=${vbld%%_*}
	vtmp1=`chg_hit_essver.sh -p $plat $ver $bhit`
	_sts=$?
	if [ $_sts -eq 0 ]; then
		if [ "$exacthit" != "true" ]; then
			vtmp1=${vtmp1%%_*}
			if [ $vtmp1 -ne $vbld ]; then
				echo "HIT $bhit($vbld) doesn't contains this platfroms' build($vtmp1)."
				echo "Use refresh command." 
				inst=REFRESH
			fi
		fi
	else	# No platform in HIT installer
		echo "\"chg_hit_essver.sh -p $plat $ver $bhit\" returned \"$vtmp1\" and sts=$_sts."
		echo "No valid HIT for this platform($plat)."
		echo "Use refresh command." 
		inst=REFRESH
	fi
fi
[ -z "$cmdgqbld" ] && cmdgqbld=$vbld

#######################################################################
# Get installation related variable from se.sh
#######################################################################
. settestenv.sh $ver HYPERION_HOME BUILD_ROOT HIT_ROOT ARBORPATH ESSBASEPATH ESSLANG
if [ "$dbg" = "true" ]; then
	echo "# Version environment variables for $ver($AP_SECMODE:$AP_BISHIPHOME)"
	echo "# BUILD_ROOT    = $BUILD_ROOT"
	echo "# HIT_ROOT      = $HIT_ROOT"
	echo "# ESSLANG       = $ESSLANG"
	echo "# HYPERION_HOME = $HYPERION_HOME"
	echo "# ARBORPATH     = $ARBORPATH"
	echo "# ESSBASEPATH   = $ESSBASEPATH"
fi

if [ -z "$HYPERION_HOME" ]; then
	echo "HYPERION_HOME not defined"
	exit 2
fi

[ ! -d "$HYPERION_HOME" ] && mkddir.sh "$HYPERION_HOME"

[ "$bld" != "$vbld" ] && blds="$bld($vbld)" || blds=$bld

_str="Installation of $ver build $blds on $plat"
_dstr=
while [ ${#_dstr} -lt ${#_str} ]; do
	_dstr="-${_dstr}"
done
echo "#${_dstr}#"
echo " ${_str}"
echo "#${_dstr}#"
[ "$ver" = "talleyrand_ps1" ] && _tver=talleyrand_sp1 || _tver=$ver
_vins=`ver_installer.sh $ignCM $_tver $bld`
if [ -n "$_vins" -a -n "$bhit" -a "$_vins" = "opack" ]; then
	if [ "$AP_BISHIPHOME" = "true" ]; then
		vins=bi
	else
		vins=hit
	fi
elif [ -z "$vins" ]; then
	vins=$_vins
fi

if [ "$instgq" = "true" ]; then
	cmdgqloc=`ver_cmdgq.sh $ver`
	if [ $? -ne 0 -o ! -d "$BUILD_ROOT/$_tver/$cmdgqbld/$cmdgqloc" ]; then
		echo "There is no valid build folder for $ver $blds\n  for $plat platform under the pre_rel location."
		echo "hyslint.sh couldn't install ESSCMDQ/G programs."
		exit 3
	fi
fi

if [ "$dbg" = "true" ]; then
	echo "# \$vsts=$vsts"
	echo "# \$inst=$inst"
	echo "# \$ver=$ver"
	echo "# \$bld=$bld"
	echo "# \$vbld=$vbld"
	echo "# \$vins=$vins"
	echo "# \$bhit=$bhit"
	echo "# \$clrdsk=$clrdsk"
	echo "# \$cmdgqloc=$cmdgqloc"
	echo "# \$cmdgqbld=$cmdgqbld"
	echo "# \$AP_BISHIPHOME=$AP_BISHIPHOME"
	echo "# \$AP_SECMODE=$AP_SECMODE"
fi

unset vsts cmdgqloc vtmp1
[ "$keep_prev_app" = "true" ] && save_prev_app

#######################################################################
# Kill and Clean up for Installation
#######################################################################
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

#######################################################################
# Run CD installation
#######################################################################
if [ "$inst" = "BASE" ]; then
	basever=${basevsn%:*}
	basebld=${basevsn#*:}
	echo "Install base product($basever:$basebld)"
	hyslinst.sh cd -nocmdgq $ignCM $basever $basebld
	sts=$?
	echo "## Base Installation status for $basevsn = $sts"
	clrdsk=false
	if [ $sts -ne 0 ]; then
		inst=REFRESH
	else
		inst=BOTH
	fi
fi
if [ "$inst" = "CD" -o "$inst" = "BOTH" ]; then
	[ "$clrdsk" = "true" ] && rm -rf $HYPERION_HOME/*
	clrdsk=false
	[ -n "$rspf" ] && rspf="-rsp $rspf"
	if [ "$vins" = "bi" ]; then
		sts=0
		echo "Use BISHIPHOME installer."
		echo "BI version=$bhit"
		rm -rf ${HYPERION_HOME%/*}/* 2>&1 > /dev/null
		echo "biinst.sh $bhit ${HYPERION_HOME%/*}"
		biinst.sh $bhit ${HYPERION_HOME%/*}
		sts=$?
		if [ $sts -ne 0 ]; then
			echo "# biinst.sh $bhit ${HYPERION_HOME%/*} failed($sts)."
			export AP_SECMODE=
		fi
	elif [ "$vins" = "hit" ]; then
		echo "Using HIT installer."
		hitinst.sh $rspf $use_zip $ver $bld
		sts=$?
	elif [ "$vins" = "opack" ]; then
		hver=`get_opackbase.sh $ver $vbld -opack $opbld`
		if [ "$?" -eq 0 ]; then
			if [ "${hver#bi:}" != "$hver" ]; then
				echo "This version is BI OPACK."
				bibasever=
				hver=${hver#bi:}
				balt=`chk_para.sh bizip "$_OPTION"`
				balt=${balt##* }
				if [ -z "$balt" ]; then
					balt=`chk_para.sh biimg "$_OPTION"`
					balt=${balt##* }
					if [ -n "$balt" ]; then
echo "# Found biimg($balt) option."
						balt="dummy_label/by_BiImg"
					else
						srch_bi.sh in $hver > /dev/null 2>&1
						[ $? -eq 0 ] && bibasever=`srch_bi.sh in $hver | grep -v "# NO VER XML" | tail -1`
					fi
				else
echo "# Found bizip($balt) option."
					balt="dummy_label/by_BiZip"
				fi
				[ -z "$bibasever" ] && bibasever=$balt
				bists=false
echo "# bibasever=$bibasever"
				if [ -n "$bibasever" ]; then
					biver=${bibasever%% *}
					# BIINST here with bibasever
					export AP_BISHIPHOME=true
					export AP_SECMODE=rep
					echo "Use \"biinst.sh $biver ${HYPERION_HOME%/*}\" command."
					biinst.sh $biver ${HYPERION_HOME%/*}
					if [ $? -eq 0 ]; then
						bists=true
						# Reset environment variables
						unset HYPERION_HOME ARBORPATH ESSBASEPATH
						. settestenv.sh $ver \
							HYPERION_HOME \
							ARBORPATH \
							ESSBASEPATH \
							SXR_CLIENT_ARBORPATH \
							SXR_USER SXR_PASSWORD \
							ORACLE_INSTANCE
					else
						export AP_SECMODE=
					fi
				fi
				if [ "$bists" = "false" ]; then
					echo "Failed to get BI installer for $hver."
					exit 4
				else
					crressv=`. se.sh $ver > /dev/null 2>&1; get_ess_ver.sh`
					if [ "$crressv" != "$ver:$vbld" ]; then

					stop_service.sh
				#	bidomloc=${HYPERION_HOME%/*}/user_projects/domains/bifoundation_domain
				##	rm -f $bidomloc/servers/AdminServer/security/boot.properties
				#	echo "username=$SXR_USER" >> $bidomloc/servers/AdminServer/security/boot.properties
				#	echo "password=$SXR_PASSWORD" >> $bidomloc/servers/AdminServer/security/boot.properties
				#	if [ "`uname`" = "Windows_NT" ]; then
				#		kill_essprocs.sh all
				#	fi
					opackinst.sh $ver $vbld -opack $opbld; sts=$?
				#	if [ "`uname`" = "Windows_NT" ]; then
				#		# Prepare the boot.properties file
				#		bidomloc=${HYPERION_HOME%/*}/user_projects/domains/bifoundation_domain
				#		rm -f $bidomloc/servers/AdminServer/security/boot.properties
				#		echo "username=$SXR_USER" >> $bidomloc/servers/AdminServer/security/boot.properties
				#		echo "password=$SXR_PASSWORD" >> $bidomloc/servers/AdminServer/security/boot.properties
				#		# if [ -f "$ORACLE_INSTANCE/bifoundation/OracleBIApplication/coreapplication/StartStopServices.cmd" ]; then
				#		# 	crrdirbk=`pwd`
				#		# 	cd $ORACLE_INSTANCE/bifoundation/OracleBIApplication/coreapplication
				#		# 	$ORACLE_INSTANCE/bifoundation/OracleBIApplication/coreapplication/StartStopServices.cmd start_all
				#		# 	cd $crrdirbk
				#		if [ -f "$ORACLE_INTANCE/bin/startWebLogic.cmd" ]; then
				#			$ORACLE_INSTANCE/bin/startWebLogic.cmd &
				#		fi
				#		# Start Web logic
				#	fi
					start_service.sh
					
                                        else
                                                echo "### Installed version of Essbase($crressv) is same as target build($ver:$vbld)."
                                                echo "### Skip applying opack."
                                        fi

					if [ "$sts" -ne 0 ]; then
						echo "Failed to apply opack($sts)."
						sts=4
					else
						echo "$ver:$vbld(base: bi[`cat $HYPERION_HOME/bi_label.txt 2> /dev/null`])" \
							> $HYPERION_HOME/opack_version.txt
					fi
				fi
			else
				echo "This version is EPM OPACK."
				hbld=`get_hitlatest.sh -w $hver`
				sts=$?
				basebld=${hbld#*:}
				basebld=${basebld%%_*}
				if [ $sts -eq 0 ]; then
					echo "Install base HIT ($hver $hbld)."
					hbld=${hbld%%:*}
					echo "# hitinst.sh $rspf $use_zip $hver hit[$hbld]"
					hitinst.sh $rspf $use_zip $hver "hit[$hbld]"
					sts=$?
					if [ "$hver" = "$ver" -a "$vbld" = "$basebld" ]; then
						echo "Base installation is exact same as target."
						echo "   Base: $hver $basebld"
						echo "   Targ: $ver $vbld"
						echo "Skip opack installation."
					elif [ $sts -eq 0 ]; then
						echo "# opackinst.sh $ver $vbld -opack $opbld"
						opackinst.sh $ver $vbld -opack $opbld
						if [ $? -ne 0 ]; then
							echo "Failed to apply opack."
							sts=4
						else
							echo "$ver:$vbld(base:$hver hit[$hbld])" > $HYPERION_HOME/opack_version.txt
						fi
					fi
				else
					echo "Failed to get HIT latest for $hver."
					sts=4
				fi
			fi
		else
			echo "This version is 'opack'. But couldn't find the base version for $ver $bld."
			sts=4
		fi
	else
		echo "Using CD installer."
		cdinst.sh $rspf $knd $ignCM $ver $bld
		sts=$?
	fi
	if [ "$sts" -eq 0 ]; then
		if [ "$instgq" = "true" ]; then
			cmdgqinst.sh $ignCM $ver $cmdgqbld
			[ $? -ne 0 ] && echo "Failed to install ESSCMDG/Q ($?)."
		fi
		if [ "$noinit" = "true" ]; then
			echo "hyslinst.sh terminate by -noinit or -nocmdgq parameter without an install test."
			[ "$keep_prev_app" = "true" ] && restore_prev_app
			exit 0
		fi
		# (. se.sh $ver > /dev/null 2>&1; chk_essinst.sh $ver)
		(. se.sh $ver; set ; chk_essinst.sh $ver)
		if [ $? -eq 0 ]; then
			[ "$keep_prev_app" = "true" ] && restore_prev_app
			exit 0
		else
			echo "Installer check failed($?) for CD/HIT Installation."
		fi
	else
		echo "Failed cd/hitinst.sh($sts)"
	fi
fi

if [ "$inst" = "CD" ]; then
	[ "$keep_prev_app" = "true" ] && restore_prev_app
	exit 3
fi

if [ ! "$inst" = "REFRESH" ]; then
	echo "### Failed to install using CD/HIT."
	(
	echo ""
	echo "### ls \$HYPERION_HOME"
	ls -l $HYPERION_HOME
	echo ""
	echo "### ls \$HYPERION_HOME/.."
	ls -l $HYPERION_HOME/..
	echo ""
	echo "### ls \$ARBORPATH"
	ls -l $ARBORPATH
	echo ""
	echo "### ls \$ARBORPATH/.."
	ls -l $ARBORPATH/..
	echo ""
	if [ -d "$ARBORPATH/bin" ]; then
		echo "### ls -l \$ARBORPATH/bin"
		ls -l $ARBORPATH/bin
	else
		echo "### There is no \$ARBORPATH/bin folder."
	fi
	) | while read line; do
		echo "> $line"
	done
fi

#######################################################################
# Run refresh command
#######################################################################
echo "Using refresh command.(${mver}:${sver}${vbld})"
if [ "$clrdsk" = "true" ]; then
	echo "## CLEAR HYPERION_HOME CONTENTS"
	rm -rf $HYPERION_HOME/* 2> /dev/null
fi
[ -n "$ARBORPATH" -a ! -d "$ARBORPATH" ] && mkddir.sh "$ARBORPATH"
refver="$HYPERION_HOME/refresh_version.txt"
[ -f "$refver" ] && rm -f "$refver"
echo "${mver}:${sver}${vbld}" > "$refver" 2>&1
case "`get_platform.sh`" in
	aix|solaris|linux)
		echo "32" | refresh ${_AP_REFRESHOPT} ${mver}:${sver}${vbld}
		sts=$?
		;;
	win32|hpux|hpux64)
		refresh ${_AP_REFRESHOPT} ${mver}:${sver}${vbld}
		sts=$?
		;;
	*)
		echo "64" | refresh ${_AP_REFRESHOPT} ${mver}:${sver}${vbld}
		sts=$?
		;;
esac
cmdgqinst.sh ${ver} ${vbld}
if [ $sts -ne 0 ]; then
	echo "Refresh command failed($sts)."
	[ "$keep_prev_app" = "true" ] && restore_prev_app
	exit 3
fi

if [ "$noinit" = "true" ]; then
	echo "hyslinst.sh terminate by -noinit or -nocmdgq parameter without an install test." 
	[ "$keep_prev_app" = "true" ] && restore_prev_app
	exit 0
fi

(. se.sh $ver > /dev/null 2>&1; chk_essinst.sh $ver)
if [ "$?" -ne 0 ]; then
	echo "Install check after refresh command failed($sts)."
	[ "$keep_prev_app" = "true" ] && restore_prev_app
	exit 3
fi

[ "$keep_prev_app" = "true" ] && restore_prev_app
exit 0
