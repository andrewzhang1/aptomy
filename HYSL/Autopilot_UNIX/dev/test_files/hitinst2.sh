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

trap 'restore_win_env;exit 1' 2

. apinc.sh


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
# Backup Windows environment variables.
#######################################################################
# backup_wenv [ -a ] <file> <env-var> [ <env-var>...]
# -a        : Append back-up to <file>
# <file>    : Back up destination
# <env-var> : [<env-knd>:]<var>
# <env-knd> : sys|s = System environment variable
#             usr|u = User environment variable
#             both|b = Both System and User envrionment variable
# <var>     : Environment variable name with out "%" or "$"

backup_wenv()
{
	varlist=
	append=false
	filename=
	ret=0
	while [ $# -ne 0 ]; do
		case $1 in
			-a)
				append=true
				;;
			*)
				if [ -z "$filenaem" ]; then
					filename=$1
				else
					[ -z "$varlist" ] && varlist=$1 || varlist="$varlist $1"
				fi
				;;
		esac
		shift
	done
	[ "$append" = "false" -a -f "$filename" ] && rm -rf "$filename"
	echo "# Backup $varlist" >> "$filename"
	echo "# on `date +%D_%T`" >> "$filename"
	for one in $varlist; do
		knd=user
		if [ "$one" = "${one%:*}" ]; then
			knd=user
		else
			case $one in
				s:*|sys:*)			knd=sys;;
				u:*|usr:*|user:*)	knd=user;;
				b:*|both:*)			knd=both;;
				*:)
					echo "# Invalid prefix ($one)." >> "$filename"
					ret=-1
					continue
					;;
			esac
			if [ -z "${one#*:}" ]; then
				echo "# Invalid variable name ($one)." >> "$filename"
				ret=-1
				continue
			fi
			one=${one#*:}
		fi
		if [ "$knd" = "user" -o "$knd" = "both" ]; then
			H="HKEY_CURRENT_USER\\Environment"
			value=`registry -p -r -k "$H" -n "$one" 2> /dev/null`
			echo "USR $one $value" >> "$filename"
		fi
		if [ "$knd" = "sys" -o "$knd" = "both" ]; then
			H="HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment"
			value=`registry -p -r -k "$H" -n "$one" 2> /dev/null`
			echo "SYS $one $value" >> "$filename"
		fi
	done
	return $ret
}

#######################################################################
# Restore Windows environment variables.
#######################################################################
# restore_wenv <file>
# <file>    : Back up file
# Out:  0 = Normal end. restored.
#      -1 > <file> not found.
#
restore_env()
{
	if [ -f "$1" ]; then
		while read knd var val; do
			if [ "$knd" = "${kind#\#}" ]; then
				[ "$knd" = "USR" ] && H="HKEY_CURRENT_USER\\Environment" \
					|| H="HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment"
				[ -z "$val" ] && registry -d -k "$H" -n "$var" 2> /dev/null \
					|| registry -s -k "$H" -n "$var" -v "$val" > /dev/null 2>&1
			fi
		done < "$1"
	else
		return -1
	fi
	return 0
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

#######################################################################
# Help
#######################################################################
display_help()
{
	echo "hitinst.sh [-zip|-keepzip|-rsp <rsp-file>] <ver#> <bld#>"
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
}

#######################################################################
# Read parameter
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
while [ $# -ne 0 ]; do
	case $1 in
		-zip|-cmp)
			zip=true
			;;
		-keepzip)
			keepzip=true
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
# Check install lock
#######################################################################
if [ `uname` = "Windows_NT" ]; then
	H="HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsfot\\Windows\\CurrentVersion"
	prgdir=`registry -p -r -k "$H" -n "ProgramFilesDir" 2> /dev/null`
	instlck="$prgdir/.autopilot_HIT_install.lck"
else
	# instlck="$HOME/.autopilot_HIT_install.lck"
	instlck="/nfshome/$LOGNAME/.autopilot_HIT_install.lck"
fi
if [ -f "$instlck" ]; then
	echo "# Foune lock file($instlck)."
	cat "$instlck"
	_whosehit=`cat $instlck`
	echo "Waiting for other installer done."
	while [ -f "$instlck" ]; do
		sleep 5
		_hitnow=`cat $instlck`
		if [ "$_whosehit" != "$_hitnow" ]; then
			_whosehit=$_hitnow
			echo "# ($instlck)."
			cat "$instlck"
		fi
	done
	unset _whosehit _hitnow
fi

#######################################################################
# Backup environment variable (win32)
#######################################################################
if [ `uname` = "Windows_NT" ] then
	bckf="$VIEW_PATH/
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

# echo "### $ver $bld"
vbld=`normbld.sh $ver $bld`
if [ $? -ne 0 ]; then
	echo "Invalied version($ver $bld)."
	echo "$vbld"
	exit 1
fi
hitvers=`ver_hitver.sh $ver`
plat=`get_platform.sh`
thishost=`hostname`
# echo "### vbld=$vbld"
# echo "### hitvers=$hitvers"
# echo "### plat=$plat"
# echo "### thishost=$thishost"

#######################################################################
# Check if AUTOPILOT is defined
#######################################################################

if [ -z "$AUTOPILOT" ]; then
	echo "AUTOPILOT is not defined."
	exit 2
fi

if [ -z "$HIT_ROOT" ]; then
	echo "HIT_ROOT is not defined."
	exit 2
fi
if [ -z "$BUILD_ROOT" ]; then
	echo "BUILD_ROOT not defined."
	exit 2
fi

if [ -z "$HYPERION_HOME" ]; then
	echo "HYPERION_HOME not defined"
	exit 2
fi

[ ! -d "$HYPERION_HOME" ] && mkdir $HYPERION_HOME


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
	_thisplat=`get_platform.sh`
	hit=`srch_hit.sh $_thisplat $ver $bld`
	[ $? -eq 0 ] && hit="build_${hit}" || hit=
	unset _thisplat
elif [ "$hit" = "latest" ]; then
	hit="build_`get_hitlatest.sh $ver`"
else
	hit="build_${hit}"
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
	*)
		arch=32
		;;
esac
hitn=${hit#*_}
[ "${hitn#*_}" != "$hitn" ] && hitn=${hitn%%_*}
# Check pre-defined RSPFILE and define it
if [ -z "$RSPFILE" ]; then
	if [ -f "$AP_DEF_RSPPATH/hit_${ver##*/}_${LOGNAME}_$(hostname).xml" ]; then
		RSPFILE=$AP_DEF_RSPPATH/hit_${ver##*/}_${LOGNAME}_$(hostname).xml
	elif [ -f "$AP_DEF_RSPPATH/hit.xml" ]; then
		################################
		# Decide which RSP file to use #
		################################
		crrpwd=`pwd`
		cd $AP_DEF_RSPPATH
		rsplst=`ls -1 hit*.xml | grep -v hit.xml`
		unset bldext
		for one in $rsplst; do
			one=${one%.xml}
			one=${one#*_}
# echo "one=$one, hitn=$hitn"
			if [ "$one" != "server" -a  "$one" != "client" ]; then
				if [ -n "$one" -a "$hitn" -le "$one" ]; then
					bldext=$one
					break
				fi
			fi
		done
		if [ -n "$bldext" ]; then
			RSPFILE=$AP_DEF_RSPPATH/hit_$bldext.xml
		else
			RSPFILE=$AP_DEF_RSPPATH/hit.xml
		fi
		cd $crrpwd
		unset crrpwd rsplst bldext
	fi
fi
unset hitn

# Check the response file is exist
if [ ! -f "$RSPFILE" ]; then
	echo "No Response File Found($RSPFILE)."
	exit 3
else
	# replace the HYPEIRON_HOME
	orgrspfile=$RSPFILE
	cat "$RSPFILE" | sed -e "s|HYPERION_HOME_CHANGE|${HYPERION_HOME}|" | \
	sed -e "s|ARCH_CHANGE|${arch}|"  > $AP_DEF_TMPPATH/$(hostname)_${LOGNAME}.xml
	RSPFILE=$AP_DEF_TMPPATH/$(hostname)_${LOGNAME}.xml
fi

#######################################################################
# Check COMPRESSED installer 
#######################################################################
if [ ! "$zip" = "true" ]; then
	# For Talleyrand new installer
	# Make HIT platform spec
	hitplat=`ver_hitplat.sh | crfilter`
	if [ -d "$HIT_ROOT/$hitloc/${hit}/HIT_${hitplat}" ]; then
		hitdir="HIT_${hitplat}"
	else
		hitdir="HIT"
	fi
	hit_inst_loc="$HIT_ROOT/$hitloc/${hit}/${hitdir}"
	unset hitplat hitdir
else
	if [ ! -d "$HIT_ROOT/$hitloc/$hit/COMPRESSED" ]; then
		echo "No COMPRESSED folder under $HIT_ROOT/$hitloc/$hit."
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

touch "$instlck"
echo "HIT installer locked by ${LOGNAME}@${thishost} at `date +%D_%T`" > "$instlck"


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

	if [ "$LOGNAME" = "ykono" ]; then
		rm -rf $HOME/backup.env > /dev/null 2>&1
		echo "USR_ARBORPATH=$backup_usr_arborpath" >> $HOME/backup.env
		echo "USR_ESSBASEPATH=$backup_usr_essbasepath" >> $HOME/backup.env
		echo "USR_HYPERION_HOME=$backup_usr_hyperion_home" >> $HOME/backup.env
		echo "USR_ESSLANG=$backup_usr_esslang" >> $HOME/backup.env
		echo "USR_ORACLE_HOME=$backup_usr_oracle_home" >> $HOME/backup.env
		echo "USR_PATH=$backup_usr_path" >> $HOME/backup.env
		echo "SYS_ARBORPATH=$backup_sys_arborpath" >> $HOME/backup.env
		echo "SYS_ESSBASEPATH=$backup_sys_essbasepath" >> $HOME/backup.env
		echo "SYS_HYPERION_HOME=$backup_sys_hyperion_home" >> $HOME/backup.env
		echo "SYS_ESSLANG=$backup_sys_esslang" >> $HOME/backup.env
		echo "SYS_ORACLE_HOME=$backup_sys_oracle_home" >> $HOME/backup.env
		echo "SYS_PATH=$backup_sys_path" >> $HOME/backup.env
		echo "## REG HYSL" >> $HOME/backup.env
		cat $reg_hysl >> $HOME/backup.env
		echo "## REG UNINST" >> $HOME/backup.env
		cat $reg_uninst >> $HOME/backup.env
	fi

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
	rm -rf $HYPERION_HOME/.oracle.products 2> /dev/null
	rm -rf $HYPERION_HOME 2> /dev/null
	[ `uname` = "Windows_NT" ] && \
		 registry -d -k "HKEY_LOCAL_MACHINE\\SOFTWARE\\Hyperion Solutions" > /dev/null 2>&1
fi

# # Check JDK installation before running HIT
# ls $HYPERION_HOME/.. | grep ^jdk | while read jdkdir; do
# 	echo "### Found $HYPERION_HOME/../${jdkdir}."
# 	rm -rf $HYPERION_HOME/../$jdkdir > /dev/null 2>&1
# done
# echo "### ls $HYPERION_HOME/.."
# ls $HYPERION_HOME/..
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
if [ ! `uname` = "Windows_NT" ]; then
	cp $HOME/.profile $HOME/.profile_${thishost}_${LOGNAME}.backup > /dev/null 2>&1
	if [ -d "/nfshome/$LOGNAME/oraInventory" ]; then
		rm -rf "/nfshome/$LOGNAME/oraInventory" > /dev/null 2>&1
	fi
else
	# Remove OraInventory
	H="HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsfot\\Windows\\CurrentVersion"
	prgdir=`registry -p -r -k "$H" -n "ProgramFilesDir" 2> /dev/null`
	rm -rf "${prgdir}/Oracle" > /dev/null 2>&1

	H="HKEY_CURRENT_USER\\Environment"
	registry -d -k "$H" -n "EPM_ORACLE_HOME" 2> /dev/null
	H="HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment"
	registry -d -k "$H" -n "EPM_ORACLE_HOME" 2> /dev/null
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
if [ `uname` != "Windows_NT" ]; then
	case $plat in
		aix32|aix64) tmploc=/tmp;;
		*) tmploc=/var/tmp;;
	esac
	tmpfree=`get_free.sh $tmploc`
	if [ "$tmpfree" -lt 1048576 ]; then
		echo "### Not enough temp space.($tmploc)"
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
			cat ${hit_inst_loc}/${instimg} | \
				sed -e "s!^SCRIPT_DIR=.*!SCRIPT_DIR=${_tmp}!g" \
				-e "s!\(^[ 	]*\${JAVA_CMD}.*\)\( -jar .*\)!\1 -Djava.io.tmpdir=${tmploc} \2!g" \
				> ${VIEW_PATH}/${instimg}
			hit_inst_loc=${VIEW_PATH}
			chmod +x ${VIEW_PATH}/${instimg}
		else
			echo "### This installation might fail."
		fi
	fi
	unset tmploc tmpfree
fi

"$hit_inst_loc/${instimg}" -silent "$RSPFILE"
cp "$RSPFILE" $VIEW_PATH
hit_sts=$?
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

unset thishost
# echo "Installation Complete."
# echo "HIT result =$hit_sts"
# echo "ARBORPATH  =$ARBORPATH"
# echo "ESSBASEPATH=$ESSBASEPATH"


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
echo $hit > $HYPERION_HOME/hit_version.txt

rm -rf "$instlck" 2> /dev/null
rm -rf $RSPFILE 2> /dev/null
[ -d "$VIEW_PATH/ziptmp" -a "$keepzip" = "false" ] && rm -rf $VIEW_PATH/ziptmp 2> /dev/null

exit 0
