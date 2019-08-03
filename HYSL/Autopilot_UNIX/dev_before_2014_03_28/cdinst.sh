#!/usr/bin/ksh
#######################################################################
# File: cdinst.sh
# Author: Yukio Kono
# Description: Installs Essbase product using cd image
#######################################################################
# Syntax:
#    cdinst.sh [-h|-server|-client] <ver> <bld>
# Related Environment Variable:
#   ARBORPATH (*must*)
#   HYPERION_HOME (*must*)
#   AUTOPILOT (*must*)
#   RSPFILE (optional)
#   RSPFILE_CL (optional)
#
# Related exernal shell script:
#   chk_version.sh : Check CM structure
#   get_latest.sh : Get latest build number
#   get_platfrom.sh : Get platform
#
# Exit value:
#   0 : Installation success 
#       (if .error.sts exists, it mean the installer failed but success on refresh)
#   1 : Parameter error
#   2 : Env Var not defined (AUTOPILOT/BUILD_ROOT/HYPERION_HOME/ARBORPATH)
#   3 : No response file
#   4 : Missing installer file
#   5 : Version miss match (The version require HIT installer)
#
#  When product uses the old type installer (InstallShield) like 7.X 
#  or 9.X for Windows, you can create the response file using following
#  syntax.
#    C:\> setup.exe -options-record <response-file-name>
#######################################################################
# History:
# 01/17/2008 YK Fist edition. 
# 05/07/2008 YK Save ESSBASEPATH environment variable
# 06/24/2008 YK Add wrapper.so copy
# 06/18/2009 YK Add -server/-client/-rst options.
# 07/28/2009 YK Fix the "RSP file not found" problem on Unix platform.
# 07/29/2009 YK Add historical choosing logic for RSP file.
# 11/01/2011 YK Save essbase.cfg to $HYPERION_HOME

. apinc.sh

#######################################################################
# hack : rename test.pl to test.pl.bak
#######################################################################
hack()
{
	test_pl=`which test`
	test_plb=`echo ${test_pl##*/}`
	[ "$test_plb" = "test.pl" ] && mv "$test_pl" "${test_pl}.bak" > /dev/null 2>&1
}

#######################################################################
# Clean up the installer temporary files
#######################################################################
cleanup_insttmp()
{
	if [ "${plat}" = "win32" ]; then
		rm -rf $windir/vpd.properties > /dev/null 2>&1
		rm -rf "C:/Documents and Settings/${LOGNAME}/Windows/vpd.properties" > /dev/null 2>&1
	elif [ "${plat}" = "win64" ] || [ "${plat}" = "winamd64" ] || [ "${plat}" = "winmonte" ]; then
		chmod -Rf 0777 $HOME/Windows/vpd.properties > /dev/null 2>&1
		rm -rf $HOME/Windows/vpd.properties > /dev/null 2>&1
		chmod -Rf 0777 "C:/Documents and Settings/$LOGNAME/Windows/vpd.properties" > /dev/null 2>&1
		rm -rf "C:/Documents and Settings/$LOGNAME/Windows/vpd.properties" > /dev/null 2>&1
		chmod -Rf 0777 $windir/vpd.properties > /dev/null 2>&1
		rm -rf $windir/vpd.properties > /dev/null 2>&1
	else
		rm -rf $HOME/vpd.properties > /dev/null 2>&1
		rm -rf $HOME/.hyperion* > /dev/null 2>&1
		rm -rf $HOME/.hyperion.$(hostname) > /dev/null 2>&1
		rm -rf /nfshome/$LOGNAME/vpd.properties > /dev/null 2>&1
		rm -rf /nfshome/$LOGNAME/.hyperion* > /dev/null 2>&1
		rm -rf /nfshome/$LOGNAME/.hyperion.$(hostname) > /dev/null 2>&1
	fi
}

#######################################################################
# help
#######################################################################
display_help()
{
cat << ENDHELP
cdinst.sh : Essbase product installer(pre-9.x).

Description:
  Install Essbase Server and Client software using CD or installer image.
  This script only work with pre-9.x version. Please make sure that
  pre_rel/essbase/builds/<ver>/<bld> folder should has CD or installer
  folder.

Syntax:
  cdinst.sh [-h|-server|-client|-nc|-rsp <rsp-file>] <ver> <bld>

Option:
  <ver> : Installed version number. If the version has sub-version folder like
          9.2 branch, please use <main-ver>/<sub-ver> name like 9.2/9.2.1.0.3.
          example) 9.3.1.4.0, 9.2/9.2.1.0.3, kennedy, dickens, zola...
  <bld> : Installed build number or 'latst
  -h      : Display this help.
  -server : Use server installer only.
  -client : Use client installer only.
  -nc     : Not clear \$HYPERION_HOME and \$ARBORPATH fodler befor installation.
  -icm    : Ignore CM acceptance result.
  -rsp    : Use <rsp-file> response file for the installation.
            If <rsp-file> doesn't include folder name, this script read it from
           \$AUTOPILOT/rsp folder.
            example)
              -rsp RTC.rsp         # use \$AUTOPILOT/rsp/RTC.rsp.
              -rsp ./svr_only.rsp  # use svr_only.rsp in the current folder.
              -rsp C:/work/api.rsp # use C:/work/api.rsp file.

Note:
  This script use "CD" or "install" folder under the 
  $BUILD_ROOT/builds folder.
  Please make sure that \$BUILD_ROOT, \$HYPERION_HOME and \$ARBORPATH are defined 
  correct locations before running this script.
  And also check that version has correct build folder under \$BUILD_ROOT.
ENDHELP
if [ $# -ne 0 ]; then
cat << ENDUSAGE

Examples:
  1) Install Essbase 9.3.1.4.0 build 029.
    $ cdinst.sh 9.3.1.4.0 029
  2) Install latest build of Essbase 9.3.1.3.0.
    $ cdinst.sh 9.3.1.3.0 latest
  3) Install Essbase 9.2.1.0.3 build 001.
    $ cdinst.sh 9.2/9.2.1.0.3 001
  4) Install the runtime module for 9.2.1.0.2.
    $ cdinst.sh -client -rsp RTC.rsp 9.2/9.2.1.0.2 latest
    Note: You need to prepare the runtime only option into 
          "\$AUTOPILOT/rsp/RTC.rsp" file.
  5) Install the server module only for 9.3.1.4.0.
    $ cdinst.sh -server -rsp ./server_only.rsp 9.3.1.4.0 latest
    Note: This option uses "server_only.rsp" file at your current folder.
          You need to prepare this file which contains the server only option.
  6) Install server then install runtime client module.
    $ cdinst.sh -server -rsp unix_server.rsp 9.3.1.4.0 latest
    $ cdinst.sh -nc -client -rsp unix_RTC.tsp 9.3.1.4.0 latest
ENDUSAGE
fi
}

#######################################################################
# Read parameter
#######################################################################
# echo "cdinst.sh : $@"
orgpar=$@
ver=
bld=
rspf=
knd=both
nclnup=false
icm=
while [ $# -ne 0 ]; do
	case $1 in
		-h|help)
			display_help with usage
			exit 0
			;;
		-server)
			knd=server
			;;
		-client)
			knd=client
			;;
		-icm)
			icm="-icm"
			;;
		-rsp)
			if [ $# -lt 2 ]; then
				echo "cdinst.sh : \"-rsp\" parameter need second parameter."
				echo "Parameter : $orgpar"
				display_help
				exit 1
			fi
			shift
			rspf=$1
			;;
		-nc|-nocleanup)
			nclnup=true
			;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			elif [ -z "$bld" ]; then
				bld=$1
			else
				echo "cdinst.sh : Too many parameter."
				echo "Parameter : $orgpar"
				display_help
				exit 1
			fi
			;;
	esac
	shift
done

if [ -z "$ver" -o -z "$bld" ]; then
	echo "cdinst.sh : Parameter error."
	echo "Parameter : $orgpar"
	display_help
	exit 1
fi

# echo "knd=$knd"
# echo "rspf=$rspf"


if [ -n "$rspf" ]; then
	if [ "$knd" = "both" ]; then
		echo "cdinst.sh : '-rsp' option couldn't work with both(server/client) installation."
		echo "Parameter : $orgpar"
		display_help
		exit 1
	fi
	extpath.sh $rspf
	[ $? -ne 2 ] && rspf=$AUTOPILOT/rsp/$rspf
	echo "use $rspf response file."
fi

#######################################################################
# Get installation related variable from se.sh
#######################################################################
. settestenv.sh $ver HYPERION_HOME BUILD_ROOT ARBORPATH ESSBASEPATH ESSLANG


#######################################################################
# Check if AUTOPILOT is defined
#######################################################################
if [ -z "$AUTOPILOT" ]; then
	echo "AUTOPILOT not defined."
	exit 2
fi

if [ -z "$BUILD_ROOT" ]; then
	echo "BUILD_ROOT not defined."
	exit 2
fi

if [ -z "$ARBORPATH" ]; then
	echo "ARBORPATH not defined"
	exit 2
fi

if [ -z "$HYPERION_HOME" ]; then
	echo "HYPERION_HOME not defined"
	exit 2
fi


#######################################################################
# Setup variables
#######################################################################

bld=`normbld.sh $icm $ver $bld`
plat=`get_platform.sh`
inst=`ver_installer.sh $icm $ver $bld`

if [ -z "$inst" -o "$inst" = "hit" ]; then
	echo "$ver:$bld miss match for CD installer($inst)."
	exit 5
fi


#######################################################################
# Get Response File if not already Provided & Modify Install Location
#######################################################################
# Determine whether Machine is Windows Based or UNIX
if [ "$plat" = "winamd64" -o "$plat" = "winmonte" -o "$plat" = "win64" ]; then
	rsplat=$plat
elif [ "$plat" = "win32" ]; then
	rsplat=$plat
else
	rsplat="unix"
fi


#================================================
# Find RSP file for closer version

crr=`pwd`
tarver=`ver_vernum.sh ${ver##*/}`
tmpfile=$AUTOPILOT/tmp/${LOGNAME}@`hostname`_cdinst_srch_rsp.tmp
rm -rf $tmpfile > /dev/null 2>&1
cd $AUTOPILOT/rsp
ls *_${rsplat}_gen.rsp 2> /dev/null | while read line; do
	echo ${line%%_*}
done | ver_vernum.sh -org | sort > $tmpfile
prevver=
while read line; do
	sts=`cmpstr "${line%% *}" "${tarver}"`
	[ "$sts" = ">" ] && break
	prevver=${line##* }
done < $tmpfile
rm -rf $tmpfile > /dev/null 2>&1
if [ -n "$prevver" ]; then
	rsplat2="${prevver}_${rsplat}_gen"
	echo "Found $rsplat2.rsp file."
fi
cd $crr
unset crr tarver prevver line tmpfile sts
#================================================

# FOR SERVER

if [ "$knd" = "both" -o "$knd" = "server" ]; then
	
	[ -z "$RSPFILE" -a -n "$rspf" ] && RSPFILE=$rspf
	# Check pre-defined RSPFILE and define it
	if [ -z "$RSPFILE" ]; then
		if [ -f "$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_${LOGNAME}_$(hostname).rsp" ]; then
			RSPFILE=$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_${LOGNAME}_$(hostname).rsp
		elif [ -f "$AP_DEF_RSPPATH/${rsplat2}.rsp" ]; then
			RSPFILE=$AP_DEF_RSPPATH/${rsplat2}.rsp
		elif [ -f "$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_gen.rsp" ]; then
			RSPFILE=$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_gen.rsp
		fi
	fi

	# Check the response file is exist
	if [ ! -f "$RSPFILE" ]; then
		echo "No Response File Found($RSPFILE)."
		exit 3
	fi

	# replace the ARBORPATH/HYPEIRON_HOME/LICENSE
	if [ `uname` = "Windows_NT" ]; then
		cat "$RSPFILE" | sed -e "s|ARBORPATH_CHANGE|${ARBORPATH}|" | \
		sed -e "s|HYPERION_HOME_CHANGE|${HYPERION_HOME}|" | \
		sed -e "s|LICENSE_CHANGE|${LICENSE}|" > $AP_DEF_TMPPATH/$(hostname)_${LOGNAME}.rsp
		# RSPFILE=$AP_DEF_TMPPATH/$(hostname)_${LOGNAME}.rsp
	else
		cat "$RSPFILE" | sed -e "s|ARBORPATH_CHANGE|${ARBORPATH}|" |  \
		grep -v "^#" | \
		sed -e "s|HYPERION_HOME_CHANGE|${HYPERION_HOME}|" | \
		sed -e "s|LICENSE_CHANGE|${LICENSE}|" | \
		sed -e "s|#.*$||g" > $AP_DEF_TMPPATH/$(hostname)_${LOGNAME}.rsp
		# RSPFILE=$AP_DEF_TMPPATH/$(hostname)_${LOGNAME}.rsp
	fi
fi

# FOR CLIENT

if [ "$knd" = "client" -o "$knd" = "both" ]; then

	[ -z "$RSPFILE_CL" -a "$knd" = "client" -a -n "$rspf" ] && RSPFILE_CL=$rspf
	if [ `uname` = "Windows_NT" ]; then
		if [ -z "${RSPFILE_CL}" ]; then
			if [ -f "$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_${LOGNAME}_$(hostname)_cl.rsp" ]; then
				RSPFILE_CL=$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_${LOGNAME}_$(hostname)_cl.rsp
			elif [ -f "$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_${LOGNAME}_$(hostname).rsp" ]; then
				RSPFILE_CL=$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_${LOGNAME}_$(hostname).rsp
			elif [ -f "$AP_DEF_RSPPATH/${rsplat2}_cl.rsp" ]; then
				RSPFILE_CL=$AP_DEF_RSPPATH/${rsplat2}_cl.rsp
			elif [ -f "$AP_DEF_RSPPATH/${rsplat2}_client.rsp" ]; then
				RSPFILE_CL=$AP_DEF_RSPPATH/${rsplat2}_client.rsp
			elif [ -f "$AP_DEF_RSPPATH/${rsplat2}.rsp" ]; then
				RSPFILE_CL=$AP_DEF_RSPPATH/${rsplat2}.rsp
			elif [ -f "$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_gen_cl.rsp" ]; then
				RSPFILE_CL=$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_gen_cl.rsp
			elif [ -f "$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_gen.rsp" ]; then
				RSPFILE_CL=$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_gen.rsp
	        fi
		fi

		# Check the response file is exist
		if [ ! -f "$RSPFILE_CL" ]; then
			echo "No defined Client Response File($RSPFILE_CL:$rsplat:${ver##*/}) Found."
			exit 3
		fi
		cat "${RSPFILE_CL}" | sed -e "s|ARBORPATH_CHANGE|${ARBORPATH}|" | \
		sed -e "s|HYPERION_HOME_CHANGE|${HYPERION_HOME}|" | \
		sed -e "s|LICENSE_CHANGE|$LICENSE|"  > $AP_DEF_TMPPATH/$(hostname)_${LOGNAME}_client.rsp
		# RSPFILE_CL=$AP_DEF_TMPPATH/$(hostname)_${LOGNAME}_client.rsp
	else
		if [ `ver_cmstrct.sh $ver` != "old" ]; then
			if [ -z "${RSPFILE_CL}" ]; then
				if [ -f "$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_${LOGNAME}_$(hostname)_cl.rsp" ]; then
					RSPFILE_CL=$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_${LOGNAME}_$(hostname)_cl.rsp
				elif [ -f "$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_${LOGNAME}_$(hostname).rsp" ]; then
					RSPFILE_CL=$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_${LOGNAME}_$(hostname).rsp
				elif [ -f "$AP_DEF_RSPPATH/${rsplat2}_cl.rsp" ]; then
					RSPFILE_CL=$AP_DEF_RSPPATH/${rsplat2}_cl.rsp
				elif [ -f "$AP_DEF_RSPPATH/${rsplat2}.rsp" ]; then
					RSPFILE_CL=$AP_DEF_RSPPATH/${rsplat2}.rsp
				elif [ -f "$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_gen_cl.rsp" ]; then
					RSPFILE_CL=$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_gen_cl.rsp
				elif [ -f "$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_gen.rsp" ]; then
					RSPFILE_CL=$AP_DEF_RSPPATH/${ver##*/}_${rsplat}_gen.rsp
				fi
			fi

			# Check the response file is exist
			if [ ! -f "$RSPFILE_CL" ]; then
				echo "No defined Client Response File($RSPFILE_CL:$rsplat:${ver##*/}) Found."
				exit 3
			fi
			cat "${RSPFILE_CL}" | sed -e "s|ARBORPATH_CHANGE|${ARBORPATH}|" | \
			grep -v "^#" | \
			sed -e "s|HYPERION_HOME_CHANGE|${HYPERION_HOME}|" | \
			sed -e "s|LICENSE_CHANGE|$LICENSE|" | \
			sed -e "s|#.*$||g" > $AP_DEF_TMPPATH/$(hostname)_${LOGNAME}_client.rsp
			# RSPFILE_CL=$AP_DEF_TMPPATH/$(hostname)_${LOGNAME}_client.rsp
		fi
	fi
fi


#######################################################################
# Check installer files exists
#######################################################################
flag=0K

# echo "### $BUILD_ROOT/$ver/$bld/$inst/$plat/server"
if [ "$knd" = "both" -o "$knd" = "server" ]; then
	if [ -d "$BUILD_ROOT/$ver/$bld/$inst/$plat/server" ]; then
		cd $BUILD_ROOT/$ver/$bld/$inst/$plat/server
		if [ `uname` = "Windows_NT" ]; then
			[ ! -f "setup.exe" ] && flag=ERR
	#	elif [ `uname` = "Linux" ]; then
	#		[ ! -f "setup.bin"  -o ! -f "setup.sh" ] && flag=ERR 
		else	
			[ ! -f "setup.bin" ] && flag=ERR
		fi
		[ ! -f "setup.jar" ] && flag=ERR
		[ ! -f "media.inf" ] && flag=ERR
	else
		flag=ERR
	fi
	if [ "${flag}" = "ERR" ]; then
		echo "Server Installation is missing Files using CD image"
		exit 5
	fi
fi

if [ "$knd" = "both" -o "$knd" = "client" ]; then
	if [ -d "$BUILD_ROOT/$ver/$bld/$inst/$plat/client" ]; then
		cd $BUILD_ROOT/$ver/$bld/$inst/$plat/client
		if [ `uname` = "Windows_NT" ]; then
			[ ! -f "setup.exe" ] && flag=ERR
	#	elif [ `uname` = "Linux" ]; then
	#		[ ! -f "setup.bin" -o ! -f "setup.sh" ] && flag=ERR
		else
			[ ! -f "setup.bin" ] && flag=ERR
		fi
		[ ! -f "setup.jar" ] && flag=ERR
		[ ! -f "media.inf" ] && flag=ERR
	else
		flag=ERR
	fi
	if [ "${flag}" = "ERR" ]; then
		echo "Client Installation is missing Files using CD image"
		exit 4
	fi
fi


#######################################################################
# Save environment variable
#######################################################################
if [ `uname` = "Windows_NT" ]; then
	echo "Back up usr env."
	H="HKEY_CURRENT_USER\\Environment"
	backup_usr_arborpath=`registry -p -r -k "$H" -n "ARBORPATH"`
	backup_usr_essbasepath=`registry -p -r -k "$H" -n "ESSBASEPATH"`
	backup_usr_hyperion_home=`registry -p -r -k "$H" -n "HYPERION_HOME"`
	backup_usr_esslang=`registry -p -r -k "$H" -n "ESSLANG"`
	backup_usr_path=`registry -p -r -k "$H" -n "PATH"`
	echo "Back up sys env."
	H="HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment"
	backup_sys_arborpath=`registry -p -r -k "$H" -n "ARBORPATH"`
	backup_sys_essbasepath=`registry -p -r -k "$H" -n "ESSBASEPATH"`
	backup_sys_hyperion_home=`registry -p -r -k "$H" -n "HYPERION_HOME"`
	backup_sys_esslang=`registry -p -r -k "$H" -n "ESSLANG"`
	backup_sys_path=`registry -p -r -k "$H" -n "PATH"`
fi


#######################################################################
# Perform Cleanup
#######################################################################
echo "Performing other cleanup"
cleanup_insttmp
if [ "$nclnup" = "true" ]; then
	echo "No clean up the current ARBORPATH and HYPERION_HOME folder."
	[ ! -d "$HYPERION_HOME" ] && mkddir.sh $HYPERION_HOME
	[ ! -d "$ARBORPATH" ] && mkddir.sh $ARBORPATH
else
	echo "Removing Old Essbase Installation"
	echo "ARBORPATH: $ARBORPATH"
	rm -rf $HYPERION_HOME/*
	[ -d "$ARBORPATH" ] && rm -rf $ARBORPATH/* || mkddir.sh $ARBORPATH
fi


#######################################################################
# Install Essbase Server
#######################################################################
if [ "$knd" = "both" -o "$knd" = "server" ]; then
	cd $BUILD_ROOT/$ver/$bld/$inst/$plat/server
	echo "Installing Server"
	echo "Using Response file $RSPFILE\n"
	if [ `uname` = "Windows_NT" ]; then
		./setup.exe -options $AP_DEF_TMPPATH/$(hostname)_${LOGNAME}.rsp -silent
	elif [ `uname` = "Linux" ]; then
		[ -f "setup.sh" ] \
			&& ./setup.sh -console < $AP_DEF_TMPPATH/$(hostname)_${LOGNAME}.rsp \
			|| ./setup.bin -console < $AP_DEF_TMPPATH/$(hostname)_${LOGNAME}.rsp
	else
		./setup.bin -console < $AP_DEF_TMPPATH/$(hostname)_${LOGNAME}.rsp 
		chmod -R 0777 $ARBORPATH/bin/*
	fi
	hack
	[ `uname` != "Windows_NT" ] && mv $ARBORPATH/hyperionenv.doc $ARBORPATH/hyperionenv_server.doc > /dev/null 2>&1
	echo "Server Installation Complete"
fi

#######################################################################
# Install Essbase Client
#######################################################################
if [ "$knd" = "both" -o "$knd" = "client" ]; then
	cd $BUILD_ROOT/$ver/$bld/$inst/$plat/client
	if [ -z "$RSPFILE_CL" ]; then
		echo "Skipping Client Installation"
	else 
		echo "Installing Client"
		echo "Using Response file $RSPFILE_CL\n"
		if [ `uname` = "Windows_NT" ]; then
			./setup.exe -options $AP_DEF_TMPPATH/$(hostname)_${LOGNAME}_client.rsp -silent
		elif [ `uname` = "Linux" ]; then
			[ -f "setup.sh" ] \
				&& ./setup.sh -console < $AP_DEF_TMPPATH/$(hostname)_${LOGNAME}_client.rsp \
				|| ./setup.bin -console < $AP_DEF_TMPPATH/$(hostname)_${LOGNAME}_client.rsp
		else
			./setup.bin -console < $AP_DEF_TMPPATH/$(hostname)_${LOGNAME}_client.rsp
			chmod -R 0777 $ARBORPATH/bin/*
		fi
		hack
		[ `uname` != "Windows_NT" ] && mv $ARBORPATH/hyperionenv.doc $ARBORPATH/hyperionenv_client.doc > /dev/null 2>&1
		echo "Client Installation Complete"
	fi
fi

#######################################################################
# Copy essbase.cfg gile to $HYPERION_HOME
#######################################################################
if [ -f "$ARBORPATH/bin/essbase.cfg" ]; then
	cp $ARBORPATH/bin/essbase.cfg $HYPERION_HOME > /dev/null 2>&1
fi

#######################################################################
# Perform Post CleanUp 
#######################################################################
cleanup_insttmp

#######################################################################
# Restore environment variable
#######################################################################
if [ `uname` = "Windows_NT" ]; then
	echo "Restore usr env."
	H="HKEY_CURRENT_USER\\Environment"
	[ -n "$backup_usr_arborpath" ] \
		&& registry -s -k "$H" -n "ARBORPATH" -v "$backup_usr_arborpath" \
		|| registry -d -k "$H" -n "ARBORPATH"
	[ -n "$backup_usr_essbasepath" ] \
		&& registry -s -k "$H" -n "ESSBASEPATH" -v "$backup_usr_essbasepath" \
		|| registry -d -k "$H" -n "ESSBASEPATH"
	[ -n "$backup_usr_hyperion_home" ] \
		&& registry -s -k "$H" -n "HYPERION_HOME" -v "$backup_usr_hyperion_home" \
		|| registry -d -k "$H" -n "HYPERION_HOME"
	[ -n "$backup_usr_esslang" ] \
		&& registry -s -k "$H" -n "ESSLANG" -v "$backup_usr_esslang" \
		|| registry -d -k "$H" -n "ESSLANG"
	[ -n "$backup_usr_path" ] \
		&& registry -s -k "$H" -n "PATH" -v "$backup_usr_path" \
		|| registry -d -k "$H" -n "PATH"
	echo "Restore sys env."
	H="HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment"
	[ -n "$backup_sys_arborpath" ] \
		&& registry -s -k "$H" -n "ARBORPATH" -v "$backup_sys_arborpath" \
		|| registry -d -k "$H" -n "ARBORPATH"
	[ -n "$backup_sys_essbasepath" ] \
		&& registry -s -k "$H" -n "ESSBASEPATH" -v "$backup_sys_essbasepath" \
		|| registry -d -k "$H" -n "ESSBASEPATH"
	[ -n "$backup_sys_hyperion_home" ] \
		&& registry -s -k "$H" -n "HYPERION_HOME" -v "$backup_sys_hyperion_home" \
		|| registry -d -k "$H" -n "HYPERION_HOME"
	[ -n "$backup_sys_esslang" ] \
		&& registry -s -k "$H" -n "ESSLANG" -v "$backup_sys_esslang" \
		|| registry -d -k "$H" -n "ESSLANG"
	[ -n "$backup_sys_path" ] \
		&& registry -s -k "$H" -n "PATH" -v "$backup_sys_path" \
		|| registry -d -k "$H" -n "PATH"
fi

#######################################################################
# Clean up work files 
#######################################################################
rm -rf $AP_DEF_TMPPATH/$(hostname)_${LOGNAME}_client.rsp 2> /dev/null
rm -rf $AP_DEF_TMPPATH/$(hostname)_${LOGNAME}.rsp 2> /dev/null

echo "CD $ver/$bld/$inst/$plat" > $HYPERION_HOME/cd_version.txt

exit 0
