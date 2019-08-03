#!/usr/bin/ksh
#######################################################################
# File: hitinst.sh
# Author: Yukio Kono
# Description: Installs Essbase product using HIT build
#######################################################################
# Related Environment Variable:
#   HYPERION_HOME (*must*)
#   AUTOPILOT (*must*)
#   HIT_ROOT
#   RSPFILE (optional)
#   RSPFILE_CL (optional)
#
# Related exernal shell script:
#   get_latest.sh : Get latest build number
#   get_platfrom.sh : Get platform
#
# Exit value:
#   0 : Installation success 
#       (if .error.sts exists, it mean the installer failed but success on refresh)
#   1 : Parameter error
#
#######################################################################
# History:
# 05/22/2008 YK Fist edition. 
# 05/28/2008 YK Add HIT_ROOT check
# 06/04/2008 YK Add installer lock logic.
#            This is a workaround when the $HOME(/nfshome) is shared with
#            another regression and wait for other installation done.
# 06/24/2008 YK Add copying the wrapper.so file
# 07/16/2008 YK move installation part of ESSCMDQ/G to cmdqginst.sh
# 06/18/2009 YK Add -rsp option.
# 08/13/2009 YK Add Talleyrand HIT_<plat> installer location.
# 10/22/2009 YK Add new platform for the Talleyrand's HIT_<plat>.
# 02/19/2009 YK Add workaround for /tmp or /var/tmp problem of HIT.
# 08/02/2010 YK Use lock.sh for locking HIT lock state file.
# 08/30/2010 YK Add temporary to the HYPERION_HOME definiton for talleyrand_sp1
# 09/17/2010 YK Change the arch of AIX and Solaris always in 64.
# 10/29/2010 YK Change allways use copied installTool.sh script on Unix platform.
# 01/24/2011 YK Support AP_HITPREFIX
# 02/04/2011 YK Change HIT installer lock file location from local of nfshome to
#               $AUTOPILOT/lck/<user>[@<win-host>].hit_install.lck
# 06/07/2011 YK Support AP_HITCACHE for the product cache 
# 06/08/2011 YK Work around for BUG 12318235
# 06/16/2011 YK Add -hitloc parameter
# 11/01/2011 YK Save essbase.cfg file to $HYPEIRON_HOME
# 02/01/2012 YK Support EssbaseClient.exe MSI installer on Windows platform.
#               Bug 13651825 - HYSLINST.SH NEED TO INSTALL CLIENT MODULE ON WINDOWS PLATFORM.
# 08/03/2012 YK Change file names for machine and user HIT lock.
# 02/15/2013 YK Add work around for
#               Bug 16344856 - HIT PS3 DOESN'T CREATE APP FOLDER UNDER ESSBASESERVER FOLDER.
#               Bug 16494870 - AUTOPILOT NEEDS TO DELETE ESSCLSN.DLL IN ESSBASE SERVER BIN
# 04/04/2013 YK BUG 16590342 - AUTOPILOT NEEDS TO KEEP THE INSTALL FLAG LOCKED UNTIL OPACK IS COMPLETE 

trap 'restore_win_env;exit 1' 2

. apinc.sh


cnv()
{
	echo $1 | sed -e "s!/!\\\\!g"
}

#######################################################################
# Backup registry keys
#######################################################################
# backup_reg <key> <fname>
backup_reg()
{
	registry -p -k "$1" 2> /dev/null | sed -e "s/\\\/\\\\\\\\/g" > "$2"
	siz=`ls -l $2 | awk '{print $5}'`
	if [ -n "$siz" -a $siz -ne 0 ]; then
		return 0
	else
		rm -f "$2"
		return 0
	fi
}


#######################################################################
# Restore registry keys
#######################################################################
# Restore_reg <key> <fname>
restore_reg()
{
	registry -d -k "$1" 2> /dev/null
	if [ -f "$2" ]; then
		cat $2 | while read line; do
			h=${line%%	*}; v=${line#*	}
			n=${v%%	*}; v=${v##*	}
			if [ "${v#\"}" = "${v}" ]; then
				registry -s -k "$h" -n "$n" -V dword:$v
			else
				v=${v%?}; v=${v#?}
				registry -s -k "$h" -n "$n" -v "$v"
			fi
		done
		rm -f "$2"
	fi
}

#######################################################################
# Restore environment variable
#######################################################################
restore_win_env()
{
	if [ `uname` = "Windows_NT" ]; then
		echo "Restore usr env."
		H="HKEY_CURRENT_USER\\Environment"
		[ -n "$backup_usr_arborpath" ] \
			&& registry -s -k "$H" -n "ARBORPATH" -v "$backup_usr_arborpath" > /dev/null 2>&1 \
			|| registry -d -k "$H" -n "ARBORPATH" 2> /dev/null
		[ -n "$backup_usr_essbasepath" ] \
			&& registry -s -k "$H" -n "ESSBASEPATH" -v "$backup_usr_essbasepath" > /dev/null 2>&1 \
			|| registry -d -k "$H" -n "ESSBASEPATH" 2> /dev/null
		[ -n "$backup_usr_hyperion_home" ] \
			&& registry -s -k "$H" -n "HYPERION_HOME" -v "$backup_usr_hyperion_home" > /dev/null 2>&1 \
			|| registry -d -k "$H" -n "HYPERION_HOME" 2> /dev/null
		[ -n "$backup_usr_esslang" ] \
			&& registry -s -k "$H" -n "ESSLANG" -v "$backup_usr_esslang" > /dev/null 2>&1 \
			|| registry -d -k "$H" -n "ESSLANG" 2> /dev/null
		[ -n "$backup_usr_oracle_home" ] \
			|| registry -s -k "$H" -n "EPM_ORACLE_HOME" -v "$backup_usr_oracle_home" > /dev/null 2>&1 \
			&& registry -d -k "$H" -n "EPM_ORACLE_HOME" 2> /dev/null
		[ -n "$backup_usr_path" ] \
			&& registry -s -k "$H" -n "PATH" -v "$backup_usr_path" > /dev/null 2>&1 \
			|| registry -d -k "$H" -n "PATH" 2> /dev/null
		echo "Restore sys env."
		H="HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment"
		[ -n "$backup_sys_arborpath" ] \
			&& registry -s -k "$H" -n "ARBORPATH" -v "$backup_sys_arborpath" > /dev/null 2>&1 \
			|| registry -d -k "$H" -n "ARBORPATH" 2> /dev/null
		[ -n "$backup_sys_essbasepath" ] \
			&& registry -s -k "$H" -n "ESSBASEPATH" -v "$backup_sys_essbasepath" > /dev/null 2>&1 \
			|| registry -d -k "$H" -n "ESSBASEPATH" 2> /dev/null
		[ -n "$backup_sys_hyperion_home" ] \
			&& registry -s -k "$H" -n "HYPERION_HOME" -v "$backup_sys_hyperion_home" > /dev/null 2>&1 \
			|| registry -d -k "$H" -n "HYPERION_HOME" 2> /dev/null
		[ -n "$backup_sys_esslang" ] \
			|| registry -s -k "$H" -n "ESSLANG" -v "$backup_sys_esslang" > /dev/null 2>&1 \
			&& registry -d -k "$H" -n "ESSLANG" 2> /dev/null
		[ -n "$backup_sys_oracle_home" ] \
			|| registry -s -k "$H" -n "EPM_ORACLE_HOME" -v "$backup_sys_oracle_home" > /dev/null 2>&1 \
			&& registry -d -k "$H" -n "EPM_ORACLE_HOME" 2> /dev/null
		[ -n "$backup_sys_path" ] \
			&& registry -s -k "$H" -n "PATH" -v "$backup_sys_path" > /dev/null 2>&1 \
			|| registry -d -k "$H" -n "PATH" 2> /dev/null
		echo "Restore registry."
		restore_reg "HKEY_LOCAL_MACHINE\\SOFTWARE\\Hyperion Solutions" $reg_hysl
		restore_reg "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Hyperion System 9" $reg_uninst
		[ -d "$prg_menu" ] && rm -rf "prg_menu" 2> /dev/null
		[ -d "$prg_menu_back" ] && mv "$prg_menu_back" "$prg_menu"
	fi
}

display_help()
{
	echo "hitinst.sh [-zip|-keepzip|-rsp <rsp-file>|-hitloc <hit-loc>] <ver#> <bld#>"
	echo " Parameter :"
	echo "  <ver#> : Product version."
	echo "  <bld#> : HIT build number."
	echo " Options:"
	echo " -zip     : Using zipped installer."
	echo "            Notice: This option expand zipped contents to $VIEW_PATH/ziptmp folder."
	echo "                    If you don't have enough space on there, you might fail."
	echo " -keepzip : Keep expanded installer when using -zip option."
	echo " -rsp     : Use <rsp-file> response file for the installation."
	echo " -nc      : Not cleaup product fodler before installation."
	echo " -hitloc  : Set the AP_HITLOC."
	echo "            When you define it with absolute path, hitinst.sh uses that path for"
	echo "            the search location for the HIT installer."
	echo "            If it isn't absolute path, hitinst.sh uses it instead of the prodpost."
	echo "            Ex.)"
	echo "              1) Use qepost for the HIT installer."
	echo "                 hitinst.sh -hitloc qepost 11.1.2.2.000 hit[latest]"
	echo " -noclient: Not install client module on Windows platform."
	echo " +dbg     : Debug print on."
}

[ -n "$AP_HITPREFIX" ] && _hitpref=$AP_HITPREFIX || _hitpref=build_
#######################################################################
# Check the Parameter (err=1)
#######################################################################
if [ $# -lt 2 ]; then
	echo "Parameter error."
	display_help
	exit 1
fi

orgpar=$@
unset ver bld rspf
zip=false
keepzip=false
nocleanup=false
noclient=false
dbg=false
while [ $# -ne 0 ]; do
	case $1 in
		+dbg)	dbg=true;;
		-dbg)	dbg=false;;
		-noclient)
			noclient=true
			;;
		-zip|-cmp)
			zip=true
			;;
		-keepzip)
			keepzip=true
			;;
		-hitloc)
			shift
			if [ $# -eq 0 ]; then
				echo "hitinst.sh : -hitloc need second parameter for the alternate HIT locaiton."
				display_help
				exit 1
			fi
			export AP_HITLOC=$1
			;;
		-rsp)
			shift
			if [ $# -eq 0 ]; then
				echo "hitinst.sh : -rsp need second parameter for the response file."
				display_help
				exit 1
			fi
			rspf=$1
			;;
		-nc|-nocleanup)
			nocleanup=true
			;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			else
				if [ -z "$bld" ]; then
					bld=$1
				else
					echo "hitinst.sh : Too many parameter."
					display_help
					echo "current parameter : $orgpar"
					exit 1
				fi
			fi
			;;
	esac
	shift
done


#######################################################################
# Check rsp file.
#######################################################################
if [ -n "$rspf" ]; then
	extpath.sh $rspf
	[ $? -ne 2 ] && rspf=$AUTOPILOT/rsp/$rspf
	RSPFILE=$rspf
fi

#######################################################################
# Get installation related variable from se.sh
#######################################################################
. settestenv.sh $ver \
	HYPERION_HOME \
	BUILD_ROOT \
	HIT_ROOT \
	ARBORPATH \
	ESSBASEPATH \
	ESSLANG

#######################################################################
# Normalize the build number
#######################################################################
[ "$dbg" = "true" ] && echo "### $ver $bld"
vbld=`normbld.sh $ver $bld`
if [ $? -ne 0 ]; then
	echo "Invalied version($ver $bld)."
	echo "$vbld"
	exit 1
fi
# Get _VER_HITVER and _VER_ESSBASECLIENT
. ver_hitver.sh $ver
hitvers=$_VER_HITVER
plat=`get_platform.sh`
thishost=`hostname`
if [ "$dbg" = "true" ]; then
	echo "### vbld=$vbld"
	echo "### hitvers=$hitvers"
	echo "### plat=$plat"
	echo "### thishost=$thishost"
	echo "### _VER_ESSBASECLIENT=$_VER_ESSBASECLIENT"
fi

#######################################################################
# Check required variables difned.
#######################################################################
if [ -z "$AUTOPILOT" ]; then
	echo "AUTOPILOT is not defined."
	exit 2
fi

if [ -z "$HIT_ROOT" ]; then
	echo "HIT_ROOT is not defined."
	exit 2
fi
[ "${HIT_ROOT#${HIT_ROOT%?}}" = "/" ] && export HIT_ROOT=${HIT_ROOT%?}

if [ -z "$HYPERION_HOME" ]; then
	echo "HYPERION_HOME not defined"
	exit 2
fi

[ ! -d "$HYPERION_HOME" ] && mkddir.sh $HYPERION_HOME

#######################################################################
# Check the HIT ready by version
#######################################################################
hittmp="$AUTOPILOT/tmp/${thishost}_${LOGNAME}_hit.tmp"
if [ "$hitvers" = "not_ready" ]; then
	echo "HIT is not ready for $ver."
	exit 3
fi

#######################################################################
# Check the HIT isntaller by Essbase build
#######################################################################
hitloc=`ver_hitloc.sh $ver`
hit=`chk_para.sh hit "$bld"`
if [ -z "$hit" ]; then
	hit=${bld#hit_}
	[ "$hit" = "$bld" ] && hit=
fi
if [ -z "$hit" ]; then
	_thisplat=`get_platform.sh`
	hit=`srch_hit.sh $_thisplat $ver $bld`
	[ $? -eq 0 ] && hit="${_hitpref}${hit}" || hit=
	unset _thisplat
elif [ "$hit" = "latest" ]; then
	hit="${_hitpref}`get_hitlatest.sh $ver`"
else
	hit="${_hitpref}${hit}"
fi
unset tmpbld tmpplt crrdir lno tmpver
if [ -z "$hit" ]; then
	echo "There is no HIT build for $ver build $bld"
	exit 4
fi
bld=$vbld
echo "hit=$hit"

#######################################################################
# Get Response File if not already Provided & Modify Install Location
#######################################################################
# Determine whether Machine is 64 or 32
case $plat in
	*64|winmonte)
		arch=64
		;;
	solaris|aix)
		[ "`cmpstr $hit ${_hitpref}6000`" = ">" ] && arch=64 || arch=32
		;;
	*)
		arch=32
		;;
esac
hitn=${hit#*_}
[ "${hitn#*_}" != "$hitn" ] && hitn=${hitn%%_*}
hitn="000000${hitn}"; hitn=${hitn#${hitn%??????}}
# Check pre-defined RSPFILE and define it
if [ -z "$RSPFILE" ]; then
	[ "$dbg" = "true" ] && echo "# Search response file."
	if [ -f "$AP_DEF_RSPPATH/hit_${ver##*/}_${LOGNAME}_$(hostname).xml" ]; then
		RSPFILE=$AP_DEF_RSPPATH/hit_${ver##*/}_${LOGNAME}_$(hostname).xml
		[ "$dbg" = "true" ] && echo "# -> Found $RSPFILE."
	elif [ -f "$AP_DEF_RSPPATH/hit.xml" ]; then
		################################
		# Decide which RSP file to use #
		################################
		crrpwd=`pwd`
		cd $AP_DEF_RSPPATH
		rsplst=`ls -1 hit_*.xml \
			| grep -v hit_server.xml | grep -v hit_client.xml \
			| while read one; do
				nm=${one%.xml}; nm=${nm#hit_}
				nm="000000${nm}"; nm=${nm#${nm%??????}}
				echo "${nm}_${one}"
			done | sort`
		unset bldext
		for oneitem in $rsplst; do
			one=${oneitem%%_*}
			[ "$dbg" = "true" ] &&  echo "# ... one=$one, hitn=$hitn"
			if [ -n "$one" -a "$hitn" -le "$one" ]; then
				bldext=${oneitem#*_}
				break
			fi
		done
		if [ -n "$bldext" ]; then
			RSPFILE=$AP_DEF_RSPPATH/$bldext
		else
			RSPFILE=$AP_DEF_RSPPATH/hit.xml
		fi
		[ "$dbg" = "true" ] && echo "# -> Found $RSPFILE."
		cd $crrpwd
		unset crrpwd rsplst bldext
	fi
fi
unset hitn

myrspf=$VIEW_PATH/$(hostname)_${LOGNAME}.xml
rm -rf $myrspf 2> /dev/null
# Check the response file is exist
if [ ! -f "$RSPFILE" ]; then
	echo "No Response File Found($RSPFILE)."
	exit 3
else
	# replace the HYPEIRON_HOME
	# 08/30/2010 YK Temporary workaround for talleyrand_sp1
	_tallver=`ver_vernum.sh talleyrand_sp1`
	_myver=`ver_vernum.sh $ver`
	_cmpsts=`cmpstr $_myver $_tallver`
	if [ "$_cmpsts" = ">" -o "$_cmpsts" = "=" ]; then
		_hyperion_home=${HYPERION_HOME%/*}
	else
		_hyperion_home=$HYPERION_HOME
	fi
	orgrspfile=$RSPFILE
	cat "$RSPFILE" | sed -e "s|HYPERION_HOME_CHANGE|${_hyperion_home}|g" | \
	sed -e "s|ARCH_CHANGE|${arch}|g"  > $myrspf
	RSPFILE=$myrspf
	if [ "$dbg" = "true" ]; then
		echo "RSPFILE  =$RSPFILE"
		echo "_tallver =$_tallver(tps1)"
		echo "_myver   =$_myver($ver)"
		echo "_cmpsts  =\"$_cmpsts\""
		echo "_hyperion=$_hyperion_home"
	fi
fi

#######################################################################
# Check COMPRESSED installer 
#######################################################################
if [ ! "$zip" = "true" ]; then
	# For Talleyrand new installer
	# Make HIT platform spec
	hitplat=`ver_hitplat.sh | tr -d '\r'`
        if [ -n "$AP_HITCACHE" -a -d "$AP_HITCACHE" ]; then
                if [ -d "${AP_HITCACHE}${hitloc#${HIT_ROOT}}/${hit}" ]; then
                        hitloc="${AP_HITCACHE}${hitloc#${HIT_ROOT}}"
                        echo "# Use \$AP_HITCACHE($AP_HITCACHE) folder."
                fi
        fi
	if [ -d "$hitloc/${hit}/HIT_${hitplat}" ]; then
		hitdir="HIT_${hitplat}"
	else
		hitdir="HIT"
	fi
	hit_inst_loc="$hitloc/${hit}/${hitdir}"
	unset hitplat hitdir
else
	if [ ! -d "$hitloc/$hit/COMPRESSED" ]; then
		echo "No COMPRESSED folder under $hitloc/$hit."
		exit 6
	fi
	_crrdir=`pwd`
	cd $VIEW_PATH
	[ -d "ziptmp" ] && rm -rf ziptmp 2> /dev/null
	mkdir ziptmp
	hitunzip.sh -esb "$hitloc/$hit" ziptmp
	hit_inst_loc="$VIEW_PATH/ziptmp"
	cd $_crrdir
	unset _crrdir
fi

#######################################################################
# Check installer files exists
#######################################################################
flag="0K"

if [ -d "$hit_inst_loc" ]; then
	if [ `uname` = "Windows_NT" ]; then
		instimg="installTool.cmd"
	else	
		instimg="installTool.sh"
	fi
	for fl in "$instimg" "installTool.jar" "InstallTool.properties" "setup.jar"; do
		if [ ! -f "$hit_inst_loc/$fl" ]; then
			flag="$hit_inst_loc/$fl"
			break
		fi
	done
	unset fl
else
	flag="HIT folder($hit_inst_loc)"
fi
if [ "$flag" != "0K" ]; then
	echo "Missing $flag."
	exit 5
fi

#######################################################################
# Make Install Lock file
#######################################################################
trap 'instunlock.sh $$;restore_win_env' EXIT
instlock.sh $$

#######################################################################
# Save environment variable
#######################################################################
if [ `uname` = "Windows_NT" ]; then
	echo "Back up usr env."
	H="HKEY_CURRENT_USER\\Environment"
	backup_usr_arborpath=`registry -p -r -k "$H" -n "ARBORPATH" 2> /dev/null`
	backup_usr_essbasepath=`registry -p -r -k "$H" -n "ESSBASEPATH" 2> /dev/null`
	backup_usr_hyperion_home=`registry -p -r -k "$H" -n "HYPERION_HOME" 2> /dev/null`
	backup_usr_esslang=`registry -p -r -k "$H" -n "ESSLANG" 2> /dev/null`
	backup_usr_oracle_home=`registry -p -r -k "$H" -n "EPM_ORACLE_HOME" 2> /dev/null`
	backup_usr_path=`registry -p -r -k "$H" -n "PATH" 2> /dev/null`
	echo "Back up sys env."
	H="HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment"
	backup_sys_arborpath=`registry -p -r -k "$H" -n "ARBORPATH" 2> /dev/null`
	backup_sys_essbasepath=`registry -p -r -k "$H" -n "ESSBASEPATH" 2> /dev/null`
	backup_sys_hyperion_home=`registry -p -r -k "$H" -n "HYPERION_HOME" 2> /dev/null`
	backup_sys_esslang=`registry -p -r -k "$H" -n "ESSLANG" 2> /dev/null`
	backup_sys_oracle_home=`registry -p -r -k "$H" -n "EPM_ORACLE_HOME" 2> /dev/null`
	backup_sys_path=`registry -p -r -k "$H" -n "PATH" 2> /dev/null`
	echo "Back up registry."
	reg_hysl="$AUTOPILOT/tmp/${LOGNAME}@${thishost}_reg_hysl.tmp"
	reg_uninst="$AUTOPILOT/tmp/${LOGNAME}@${thishost}_reg_uninst.tmp"
	H="HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\Explorer\\Shell Folders"
	# prg_menu=`registry -p -r -k "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders" -n "Common Programs"`
	# prg_menu="$prg_menu/Oracle EPM System"
	# prg_menu_back="$prg_menu - back"
	# [ -d "$prg_menu" ] && mv "$prg_menu" "$prg_menu_back"
	backup_reg "HKEY_LOCAL_MACHINE\\SOFTWARE\\Hyperion Solutions" $reg_hysl
	backup_reg "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Hyperion System 9" $reg_uninst
fi
export PATHBACK="$PATH"

#######################################################################
# Perform Cleanup
#######################################################################
cd $VIEW_PATH
if [ "$nocleanup" = "false" ]; then
	echo "Performing other cleanup"
	hitcleanup.sh no_delete_lock_file
	echo "Removing Old Essbase Installation"
	echo "  HYPERION_HOME:$HYPERION_HOME"
	echo "  ARBORPATH:    $ARBORPATH"
	echo "  ESSBASEPATH:  $ESSBASEPATH"
	rm -rf $HYPERION_HOME/* 2> /dev/null
	ls $HYPERION_HOME
	rm -rf $HYPERION_HOME/.oracle.products 2> /dev/null
	rm -rf $HYPERION_HOME 2> /dev/null
	if [ `uname` = "Windows_NT" ]; then
		 registry -d -k "HKEY_LOCAL_MACHINE\\SOFTWARE\\Hyperion Solutions" > /dev/null 2>&1
	fi
fi

unset jdkdir

#######################################################################
# Install Products
#######################################################################

echo "Installing Product"
echo "Using Response file:"
echo "    $RSPFILE"
echo "    $orgrspfile"
unset orgrspfile

# Temporary clean up ## BUG 9240467
unset EPM_ORACLE_HOME
if [ "`uname`" != "Windows_NT" ]; then
	cp $HOME/.profile $HOME/.profile_${thishost}_${LOGNAME}.backup > /dev/null 2>&1
	if [ -d "/nfshome/$LOGNAME/oraInventory" ]; then
		rm -rf "/nfshome/$LOGNAME/oraInventory" > /dev/null 2>&1
	fi
else
	win_cleanup.sh
fi

# MKS toolkit redefine the PROCESSOR_ARCHITECTURE to Intel 32 bit
# Because MKS toolkit run in 32-bit compatible mode.
# Restore original settings to PROCESSOR_ARCHITECTURE
# Becase HIT installer check this variable to decide platform.
if [ "$plat" = "winamd64" ]; then
	back_processor_architecture=$PROCESSOR_ARCHITECTURE
	export PROCESSOR_ARCHITECTURE="AMD64"
elif [ "$plat" = "win64" ]; then
	back_processor_architecture=$PROCESSOR_ARCHITECTURE
	export PROCESSOR_ARCHITECTURE="IA64"
else
	unset back_processor_architecture
fi
unset hitvers

# Workaround for low /tmp or /var/tmp free space
hit_inst_exeloc=$hit_inst_loc
if [ `uname` != "Windows_NT" ]; then
	case $plat in
		aix32|aix64) tmploc=/tmp;;
		*) tmploc=/var/tmp;;
	esac
	tmpfree=`get_free.sh $tmploc`
#	if [ "$tmpfree" -lt 1048576 ]; then
#		echo "### Not enough temp space.($tmploc)"
tmpfree=0
		unset tmploc
		if [ -n "$TMP" ]; then
			tmpfree=`get_free.sh $TMP`
			if [ "$tmpfree" -ge 1048576 ]; then
				tmploc=$TMP
			fi
		else
			echo "### No TMP definition."
		fi
		if [ "$tmpfree" -lt 1048576 ]; then
			tmpfree=`get_free.sh $HOME`
			if [ "$tmpfree" -ge 1048576 ]; then
				echo "### \$HOME has enough space and use it as TMP."
				export TMP=$HOME
				export TMPDIR=$HOME
				tmploc=$HOME
			fi
		fi
		if [ -n "$tmploc" ]; then
			echo "### Use $tmploc for the temporary directory."
			echo "### and use edited script($VIEW_PATH/$instimg)."
			rm -f ${VIEW_PATH}/${instimg} > /dev/null 2>&1
			_tmp=`echo ${hit_inst_loc} | sed -e "s/\//\\\//g"`
			# print -r "tmp=$_tmp"
			rm -rf ${VIEW_PATH}/scr_tmp > /dev/null 2>&1
			rm -rf ${VIEW_PATH}/cr_tmp > /dev/null 2>&1
			echo " " > ${VIEW_PATH}/cr_tmp
			cat ${hit_inst_loc}/${instimg} ${VIEW_PATH}/cr_tmp > ${VIEW_PATH}/scr_tmp
			cat ${VIEW_PATH}/scr_tmp | \
				sed -e "s!^SCRIPT_DIR=.*!SCRIPT_DIR=${_tmp}!g" \
				-e "s!\(\${JAVA_CMD}.*\)\( -jar .*\)!\1 -Djava.io.tmpdir=${tmploc} -Duser.home=$HOME \2!g" \
				> ${VIEW_PATH}/${instimg}
			rm -rf ${VIEW_PATH}/scr_tmp > /dev/null 2>&1
			rm -rf ${VIEW_PATH}/cr_tmp > /dev/null 2>&1
			hit_inst_exeloc=${VIEW_PATH}
			chmod +x ${VIEW_PATH}/${instimg}
		else
			echo "### This installation might fail."
		fi
#	fi
	unset tmploc tmpfree
fi
echo "HITCMD: $hit_inst_exeloc/$instimg -silent $RSPFILE"
unset myrspf
arborpath_backup=$ARBORPATH
unset ARBORPATH
[ "`uname`" = "Windows_NT" ] && clinst.sh -d $hit_inst_loc/$_VER_ESSBASECLIENT
$hit_inst_exeloc/${instimg} -silent $RSPFILE 2>&1 | while read -r line; do
	print -r "HIT:$line"
done
# hit_sts=$?
export ARBORPATH="$arborpath_backup"
ckhitinst.sh
hit_sts=$?
echo "HIT: Done sts=$hit_sts"
[ $hit_sts -gt 4 ] && echo "Please check log files under $HYPERION_HOME/diagnostics/logs/install folder."
ec_sts=0
if [ "$noclient" != "true" -a $hit_sts -eq 0 -a -n "$_VER_ESSBASECLIENT" -a -f "$hit_inst_loc/$_VER_ESSBASECLIENT" ]; then
	clinst.sh $hit_inst_loc/$_VER_ESSBASECLIENT $HYPERION_HOME
	# ec_sts=$?
fi

if [ -n "$back_processor_architecture" ]; then
	export PROCESSOR_ARCHITECTURE="$back_processor_architecture"
	unset back_processor_architecture
fi
if [ `uname` != "Windows_NT" ]; then
	[ -f "$HOME/.profile_${thishost}_${LOGNAME}_autopilot" ] \
		&& rm -f "$HOME/.profile_${thishost}_${LOGNAME}_autopilot" > /dev/null 2>&1
	[ -f "$HOME/.profile" ] \
		&& mv $HOME/.profile $HOME/.profile_${thishost}_${LOGNAME}_autopilot > /dev/null 2>&1
	[ -f "$HOME/.profile_${thishost}_${LOGNAME}.backup" ] \
		&& mv $HOME/.profile_${thishost}_${LOGNAME}.backup $HOME/.profile > /dev/null 2>&1
fi

# # Copy essbase.cfg file to $HYPERION_HOME
# if [ -f "$ARBORPATH/bin/essbase.cfg" ]; then
# 	cp $ARBORPATH/bin/essbase.cfg $HYPERION_HOME > /dev/null 2>&1
# fi

unset thishost
# echo "Installation Complete."
# echo "HIT result =$hit_sts"
# echo "ARBORPATH  =$ARBORPATH"
# echo "ESSBASEPATH=$ESSBASEPATH"

#######################################################################
# Temporary work around for BUG 12318235
# Bug 12318235 : DXSSQMAIN.SH GOT ESSCMDG CRASH
# Bug 12797208 : OPACK FOR SERVER DOESN'T OVERWRITE SOME DLLS
#######################################################################
if [  "$ver" = "talleyrand_sp1" ]; then
	workaround=$HYPERION_HOME/workaround.txt
	rm -f $ARBORPATH/bin/essgapinu.dll > /dev/null 2>&1
	rm -f $ARBORPATH/bin/esscsln.dll > /dev/null 2>&1 # Bug 12797208
	rm -f $ARBORPATH/bin/essdtu.dll > /dev/null 2>&1 # Bug 12797208
	rm -f $ARBORPATH/bin/essviscn.dll > /dev/null 2>&1 # Bug 12797208
	echo "hitinst.sh:BUG 12797208 - OPACK FOR SERVER DOESN'T OVERWRITE SOME DLLS" >> $workaround
	echo "# rm -f $ARBORPATH/bin/essgapinu.dll" >> $workaround
	echo "# rm -f $ARBORPATH/bin/esscsln.dll" >> $workaround
	echo "# rm -f $ARBORPATH/bin/essdtu.dll" >> $workaround
	echo "# rm -f $ARBORPATH/bin/essviscn.dll" >> $workaround
fi

#######################################################################
# Restore environment variable
#######################################################################
if [ `uname` = "Windows_NT" ]; then
	echo "Restore usr env."
	H="HKEY_CURRENT_USER\\Environment"
	[ -n "$backup_usr_arborpath" ] \
		&& registry -s -k "$H" -n "ARBORPATH" -v "$backup_usr_arborpath" > /dev/null 2>&1 \
		|| registry -d -k "$H" -n "ARBORPATH" 2> /dev/null
	[ -n "$backup_usr_essbasepath" ] \
		&& registry -s -k "$H" -n "ESSBASEPATH" -v "$backup_usr_essbasepath" > /dev/null 2>&1 \
		|| registry -d -k "$H" -n "ESSBASEPATH" 2> /dev/null
	[ -n "$backup_usr_hyperion_home" ] \
		&& registry -s -k "$H" -n "HYPERION_HOME" -v "$backup_usr_hyperion_home" > /dev/null 2>&1 \
		|| registry -d -k "$H" -n "HYPERION_HOME" 2> /dev/null
	[ -n "$backup_usr_esslang" ] \
		&& registry -s -k "$H" -n "ESSLANG" -v "$backup_usr_esslang" > /dev/null 2>&1 \
		|| registry -d -k "$H" -n "ESSLANG" 2> /dev/null
	[ -n "$backup_usr_path" ] \
		&& registry -s -k "$H" -n "PATH" -v "$backup_usr_path" > /dev/null 2>&1 \
		|| registry -d -k "$H" -n "PATH" 2> /dev/null
	echo "Restore sys env."
	H="HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment"
	[ -n "$backup_sys_arborpath" ] \
		&& registry -s -k "$H" -n "ARBORPATH" -v "$backup_sys_arborpath" > /dev/null 2>&1 \
		|| registry -d -k "$H" -n "ARBORPATH" 2> /dev/null
	[ -n "$backup_sys_essbasepath" ] \
		&& registry -s -k "$H" -n "ESSBASEPATH" -v "$backup_sys_essbasepath" > /dev/null 2>&1 \
		|| registry -d -k "$H" -n "ESSBASEPATH" 2> /dev/null
	[ -n "$backup_sys_hyperion_home" ] \
		&& registry -s -k "$H" -n "HYPERION_HOME" -v "$backup_sys_hyperion_home" > /dev/null 2>&1 \
		|| registry -d -k "$H" -n "HYPERION_HOME" 2> /dev/null
	[ -n "$backup_sys_esslang" ] \
		|| registry -s -k "$H" -n "ESSLANG" -v "$backup_sys_esslang" > /dev/null 2>&1 \
		&& registry -d -k "$H" -n "ESSLANG" 2> /dev/null
	[ -n "$backup_sys_path" ] \
		&& registry -s -k "$H" -n "PATH" -v "$backup_sys_path" > /dev/null 2>&1 \
		|| registry -d -k "$H" -n "PATH" 2> /dev/null
	echo "Restore registry."
	restore_reg "HKEY_LOCAL_MACHINE\\SOFTWARE\\Hyperion Solutions" $reg_hysl
	restore_reg "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Hyperion System 9" $reg_uninst
	[ -d "$prg_menu" ] && rm -rf "prg_menu" 2> /dev/null
	[ -d "$prg_menu_back" ] && mv "$prg_menu_back" "$prg_menu"
fi

export PATH="$PATHBACK"
echo "${hitloc#${hitloc%/*/*}?}/${hit}" > $HYPERION_HOME/hit_version.txt 2> /dev/null

instunlock.sh $$

# rm -rf $RSPFILE 2> /dev/null
[ -d "$VIEW_PATH/ziptmp" -a "$keepzip" = "false" ] && rm -rf $VIEW_PATH/ziptmp 2> /dev/null

if [ $hit_sts -eq 0 ]; then
	sts=$ec_sts
else
	sts=$hit_sts
fi
# Workaround for HIT 11.1.2.3.000
#   Bug 16344856 - HIT PS3 DOESN'T CREATE APP FOLDER UNDER ESSBASESERVER FOLDER.
if [ ! -d "$ARBORPATH/app" ]; then
	workaround=$HYPERION_HOME/workaround.txt
	echo "hitinst.sh:BUG 16344856 - HIT PS3 DOESN'T CREATE APP FOLDER UNDER ESSBASESERVER FOLDER" >> $workaround
	cd $ARBORPATH
	echo "# \$ARBORPATH($ARBORPATH) contents" >> $workaound
	ls -l >> $workaound
	echo "# mkddir.sh $ARBORPATH/app" >> $workaround
	mkddir.sh $ARBORPATH/app
fi
exit $sts
