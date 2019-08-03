#!/usr/bin/ksh
# setchk_env.sh : Set and check the Essbase envrionment v1.0
# Syntax:
#   setchk_env.sh [-nomkdir] <ver>
# Option:
#   -nomkdir : Do not make the target directory
#
# History:
# 10/20/2007 YK First Edition
# 05/16/2008 YK Add extra setting _EXTRA_VARS
# 05/19/2008 YK Add multiple LIBPATH
# 05/20/2008 YK Add EssbaseClient/bin directory to path when ARBORPATH not defined and Kennedy.
# 06/25/2008 YK Add kennedy2
# 07/01/2008 YK Use version.sh
# 08/01/2008 YK User ver_cmstrct.sh and ver_setenv.sh instead of version.sh 
#               for supporting linuxamd64's ARCH definition.
# 02/05/2009 YK Refine the LIBPATH and PATH definition method.
# 05/28/2009 YK Support -nomkdir option
# 02/05/2010 YK CHeck EssbaseServer-32 and EsbaseClient-32
# 06/29/2010 YK Get default value from vardef.txt
# 08/10/2010 YK Add C API support (APIPATH/bin and ARBORPATH/bin into LibraryPATH)
# 08/16/2010 YK Support X: definition on 32 bit solaris and aix for Both (add -32).
#               And Y: definition on 64 bit platforms for RTC folder (add -64).
# 09/15/2010 YK Add ESSBASEPATH definition to the env file.
# 01/10/2011 YK Move LIB and PATH definition to ver_setenv.sh
#               _PATH, _LIB in the ver_setenv.sh
# 02/16/2011 YK Add ODBCINST definition on Unix platforms by Chi request
# 08/31/2011 YK ADD _SXR_CLIENT_ARBORPATH handling.
# 01/17/2012 YK Support AP_BISHIPHOME variable
#               When AP_BISHIPHOME defined to true, use <ver>_BI_<$ARCH> for the
#               HYPERION_HOME

. apinc.sh

### FUNCTION
normpath()
{
	if [ -d "$1" ]; then
		_crrpath=`pwd`
			cd "$1"
			pwd
			cd "$_crrpath"
		unset _crrpath
	else
		echo $1
	fi
}

### MAIN PART

[ `uname` = "Windows_NT" -a -z "$LOGNAME" ] && export LOGNAME="$USERNAME"

export _sce_err=
_orgpar=$@
_sc_ver=
_sc_env=
_sc_nomkdir=
while [ $# -ne 0 ]; do
	case $1 in
		-nomkdir)	_sc_nomkdir=true;;
		*)
			if [ -z "$_sc_ver" ]; then
				_sc_ver=${1##*/}
			elif [ -z "$_sc_env" ]; then
				_sc_env=$1
			else
				echo "setchk_env.sh : Too man parameter"
				echo "setchk_env.sh [-nomkdir] <ver> [<env-file>]"
				echo "crr_parm : $_orgpar"
				exit 1
			fi
			;;
	esac
	shift
done
if [ -z "$_sc_ver" ]; then
	echo "setchk_env.sh : No version parameter."
	echo "setchk_env.sh [-nomkdir] <ver> [<env-file>]"
	echo "crr_parm : $_orgpar"
	exit 1
fi

[ -z "$AP_AGTPLIST" ] && AP_AGTPLIST="$AP_DEF_AGENTPORTLIST"
[ ! -f "$AP_AGTPLIST" ] && touch $AP_AGTPLIST

## Check HOME directory
if [ -z "$HOME" ]; then
	echo "## \$HOME not defined"
	echo "## Use current directory (`pwd`) as working directory"
	hpath=`pwd`
	hdef=`pwd`
else
	hpath=$HOME
	hdef="\$HOME"
fi

## Decide "-32" or "-64"
plat=`get_platform.sh`
unset _plat32 _rtc64
case $plat in
	solaris|aix)	_plat32="-32";;
	*64)			_rtc64="-64";;
esac

# Set version depended value
unset _ESSDIR _HYPERION_HOME _ESSCDIR _PATH _LIB _SXR_HOME
# _ESSDIR = ARBORPATH location from HYPERION_HOME
# _ESSCDIR = CLIENT ARBORPATH location from HYPERION_HOME
# _PATH = Additional path definition (separated by space)
# _LIB = Additional Library definition (separated by space)
# echo "_ESSDIR=$_ESSDIR, _ESSCDIR=$_ESSCDIR, _plat32=$_plat32, _rtc64=$_rtc64"
. ver_setenv.sh $_sc_ver > /dev/null 2>&1
# Replace architecture depended definition
_ESSDIR=`echo $_ESSDIR | sed -e "s/<plat32>/$_plat32/g" -e "s/<rtc64>/$_rtc64/g"`
_ESSCDIR=`echo $_ESSCDIR | sed -e "s/<plat32>/$_plat32/g" -e "s/<rtc64>/$_rtc64/g"`
if [ -n "$_SXR_CLIENT_ARBORPATH" ]; then
	_SXR_CLIENT_ARBORPATH=`echo $_SXR_CLIENT_ARBORPATH | sed -e "s/<rtc64>/$_rtc64/g"`
fi
_PATH=`echo $_PATH | sed -e "s/<plat32>/$_plat32/g" -e "s/<rtc64>/$_rtc64/g"`
_LIB=`echo $_LIB | sed -e "s/<plat32>/$_plat32/g" -e "s/<rtc64>/$_rtc64/g"`

echo "[ env=$_sc_env, ver=$_sc_ver($ver), cmstrct=`ver_cmstrct.sh $_sc_ver`, plat=$plat ]"

crrdir=`pwd`

## Change $_SXR_HOME to absolute path
if [ -n "$_SXR_HOME" -a -d "$_SXR_HOME" ];then
	cd "$_SXR_HOME"
	_SXR_HOME=`pwd`
	cd "$crrdir"
fi

## Set platform depended value
unset _JAVA_HOME _ODBC_HOME
unset _LIBPATH _EXTRA_VARS
unset _PATHLIST _LIBLIST
if [ -f "$AUTOPILOT/env/template/${plat}.env2" ];then
	echo "## Execute $plat.env2 script."
	. $AUTOPILOT/env/template/$plat.env2 $_sc_ver
fi

## Check the environment setting up file is exist or not
if [ -n "$_sc_env" -a ! -f "$_sc_env" ];then
	# Check the $AUTOPILOT/env/${LOGNAME}
	if [ ! -d "$AUTOPILOT/env/${LOGNAME}" ];then
		echo "## CREATE the env directory for ${LOGNAME}"
		mkdir $AUTOPILOT/env/${LOGNAME}
	fi
	echo "# Environmnet setup file created by autopilot" > ${_sc_env}
	echo "#   for User    : ${LOGNAME}" >> ${_sc_env}
	echo "#   for Machine : `hostname`" >> ${_sc_env}
	echo "#   for Version : ${_sc_ver}" >> ${_sc_env}
fi

## Check the ARCH on AIX/Solaris
if [ -z "$ARCH" ];then
	if [ `ver_cmstrct.sh $_sc_ver` != "old" ];then
		if [ "$plat" = "solaris" -o "$plat" = "aix" ];then
			echo "## No \$ARCH defined"
			export ARCH=32
			if [ -n "$_sc_env" ];then
				echo "##   Add export ARCH=32 to ${_sc_env} file."
				echo "export ARCH=32 # Make sure this value is correct to your platform" >> ${_sc_env}
			fi
		elif [ `ver_cmstrct.sh $_sc_ver` != "hyp" -a "$plat" = "linux" ]; then
			echo "## No \$ARCH defined"
			export ARCH=32
			if [ -n "$_sc_env" ];then
				echo "##   Add export ARCH=32 to ${_sc_env} file."
				echo "export ARCH=32 # Make sure this value is correct to your platform" >> ${_sc_env}
			fi
		fi
	fi
fi

## Check VIEW_PATH
if [ -z "$VIEW_PATH" ];then
	echo "## \$VIEW_PATH not defined"
	if [ ! -d "$hpath/views" ];then
		if [ -z "$_sc_nomkdir" ]; then
			echo "##   CREATE $hdef/views directory for \$VIEW_PATH"
			mkdir $hpath/views
		else
			echo "##   There is no $hdef/views directory."
		fi
	fi
	echo "##   USE $hdef/views fodler for \$VIEW_PATH"
	export VIEW_PATH="$hpath/views"
	if [ -n "$_sc_env" ];then
		echo "##   Add export VIEW_HOME=\"$hdef/views\" to ${_sc_env} file." 
		echo "export VIEW_PATH=\"$hdef/views\"	# Added by autopilot" >> ${_sc_env}
	fi
elif [ ! -d "$VIEW_PATH" ];then
	echo "## $VIEW_PATH directory not found for \$VIEW_PATH"
	if [ -z "$_sc_nomkdir" ]; then
		echo "##   Create $VIEW_PATH directory"
		mkddir.sh "$VIEW_PATH"
		if [ ! -d "$VIEW_PATH" ];then
			echo "##   Failed to create $VIEW_PATH directory"
			echo "##   USE $hdef/views insted of \$VIEW_PATH"
			if [ ! -d "$hpath/views" ];then
				echo "##   CREATE $hdef/views directory for \$VIEW_PATH"
				mkdir $hpath/views
			fi
			export VIEW_PATH=$hpath/views
			if [ -n "$_sc_env" ];then
				echo "##   Add export VIEW_HOME=\"$hdef/views\" to ${_sc_env} file."
				echo "export VIEW_PATH=\"$hdef/views\"	# Added by autopilot" >> ${_sc_env}
			fi
		fi
	fi
else
	set_vardef VIEW_PATH
fi

## Check HYPERION_HOME
if [ -z "$HYPERION_HOME" ];then
	echo "## \$HYPERION_HOME not defnied"
	prod_root=
	hhome_def=
	if [ -n "$PROD_ROOT" ]; then
		echo "##   found \$PROD_ROOT variable."
		if [ -d "$PROD_ROOT" ]; then
			prod_root="$PROD_ROOT"
			hhome_def="\$PROD_ROOT"
		else
			echo "##   but not exist. Create $PROD_ROOT"
			mkddir.sh "$PROD_ROOT"
			if [ ! -d "$PROD_ROOT" ]; then
				echo "##   but failed to create it."
			else
				prod_root="$PROD_ROOT"
				hhome_def="\$PROD_ROOT"
			fi
		fi
	fi
	if [ -z "$prod_root" ]; then
		if [ ! -d "$hpath/hyperion" ];then
			echo "##   Create $hdef/hyperion directory"
			mkdir $hpath/hyperion
			if [ $? -ne 0 ]; then
				prod_root="$hpath"
				hhome_def="$hdef"
			else
				prod_root="$hpath/hyperion"
				hhome_def="$hdef/hyperion"
			fi
		else
			prod_root="$hpath/hyperion"
			hhome_def="$hdef/hyperion"
		fi
	fi
	unset _bimode
	if [ "$AP_BISHIPHOME" = "true" ]; then
		_bimode="_BI"
		export _HYPERION_HOME=Oracle_BI1
	fi
	if [ -n "$ARCH" ]; then
		verdir="${_sc_ver}${_bimode}_${ARCH}"
	else
		verdir="${_sc_ver}${_bimode}"
	fi
	unset _bimode
	if [ ! -d "$prod_root/${verdir}" ];then
		if [ -z "$_sc_nomkdir" ]; then
			echo "##   Create $prod_root/${verdir}"
			mkddir.sh $prod_root/${verdir}
		fi
		prod_root=$prod_root/${verdir}
		hhome_def="$hhome_def/$verdir"
	else
		prod_root=$prod_root/$verdir
		hhome_def="$hhome_def/$verdir"
	fi
	# For Talleyrand work around of EPMSystem11R1
	if [ -n "$_HYPERION_HOME" ]; then
		prod_root="$prod_root/$_HYPERION_HOME"
		hhome_def="$hhome_def/$_HYPERION_HOME"
		if [ ! -d "${prod_root}" ]; then
			if [ -z "$_sc_nomkdir" ]; then
				echo "##   Create $prod_root"
				mkddir.sh $prod_root
			fi
		fi
	fi
	echo "##   Use $hhome_def for \$HYPERION_HOME"
	export HYPERION_HOME="$prod_root"
	if [ -n "$_sc_env" ];then
		echo "##   Add export HYPERION_HOME=\"$hhome_def\" to ${_sc_env} file."
		echo "export HYPERION_HOME=\"$hhome_def\"	# Added by autopilot" >> ${_sc_env}
	fi
elif [ ! -d "$HYPERION_HOME" ];then
	echo "## $HYPERION_HOME directory not exist"
	if [ -z "$_sc_nomkdir" ]; then
		echo "##   Create \$HYPERION_HOME($HYPERION_HOME) directory"
		mkddir.sh $HYPERION_HOME
		if [ ! -d "$HYPERION_HOME" ];then
			echo "##   Failed to create $HYPERION_HOME directory($?)"
			echo "##   Use $hdef/hyperion/${_sc_ver} insted of $HYPERION_HOME"
			if [ -n "$ARCH" ]; then
				verdir="${_sc_ver}_${ARCH}"
			else
				verdir=${_sc_ver}
			fi	
			if [ ! -d "$hpath/hyperion" ];then
				echo "##   Create $hdef/hyperion directory"
				mkdir $hpath/hyperion
			fi
			if [ ! -d "$hpath/hyperion/${verdir}" ];then
				echo "##   Create $hdef/hyperion/${verdir}"
				mkdir $hpath/hyperion/${verdir}
			fi
			export HYPERION_HOME="$hpath/hyperion/${verdir}"
			if [ -n "$_sc_env" ];then
				echo "##   Add export HYPERION_HOME=\"$hdef/hyperion/${verdir}\" to ${_sc_env} file."
				echo "export HYPERION_HOME=\"$hdef/hyperion/${verdir}\"	# Added by autopilot" >> ${_sc_env}
			fi
		fi
	fi
else
	set_vardef HYPERION_HOME
fi

## Check ARBORPATH
if [ -z "$ARBORPATH" ];then
	echo "## \$ARBORPATH not defined"
	echo "##   Use \$HYPERION_HOME/${_ESSDIR} for \$ARBORPATH"
	if [ ! -d "${HYPERION_HOME}/${_ESSDIR}" -a -z "$_sc_nomkdir" ];then
		echo "##   Create $HYPERION_HOME/$_ESSDIR directory"
		mkddir.sh "${HYPERION_HOME}/${_ESSDIR}"
	fi
	export ARBORPATH="${HYPERION_HOME}/${_ESSDIR}"
	if [ -n "$_sc_env" ];then
		echo "##   Add export ARBORPATH=\"\$HYPERION_HOME/${_ESSDIR}\" to ${_sc_env} file."
		echo "export ARBORPATH=\"\$HYPERION_HOME/${_ESSDIR}\"	# Added by autopilot" >> ${_sc_env}
	fi
elif [ ! -d "$ARBORPATH" ];then
	echo "## \$ARBORPATH directory not found"
	if [ -z "$_sc_nomkdir" ]; then
		echo "##   Create $ARBORPATH directory"
		mkddir.sh $ARBORPATH
		if [ ! -d "$ARBORPATH" ];then
			echo "##   Failed to create $ARBORPATH directory"
			echo "##   Use \$HYPERION_HOME/${_ESSDIR} for \$ARBORPATH"
			if [ ! -d "${HYPERION_HOME}/${_ESSDIR}" ];then
				echo "##   Create $HYPERION_HOME/$_ESSDIR directory"
				mkddir.sh "${HYPERION_HOME}/${_ESSDIR}"
			fi
			export ARBORPATH="${HYPERION_HOME}/${_ESSDIR}"
			if [ -n "$_sc_env" ];then
				echo "##   Add export ARBORPATH=\"\$HYPERION_HOME/${_ESSDIR}\" to ${_sc_env} file."
				echo "export ARBORPATH=\"\${HYPERION_HOME}/${_ESSDIR}\"	# Added by autopilot" >> ${_sc_env}
			fi
		fi
	fi
else
	set_vardef ARBORPATH
fi

## Check ESSBASEPATH 1/29/08 YK
#  Change to HYPERION_HOME/_ESSCDIR 08/16/2010 YK Support RTC folder
if [ -z "$ESSBASEPATH" ]; then
	export ESSBASEPATH=$ARBORPATH
	echo "##   Use \$ARBORPATH for \$ESSBASEPATH"
	if [ -n "$_sc_env" ];then
		echo "##   Add export ESSBASEPATH=\"\$ARBORPATH\" to ${_sc_env} file."
		echo "export ESSBASEPATH=\"\$ARBORPATH\"	# Added by autopilot" >> ${_sc_env}
	fi
else
	set_vardef ESSBASEPATH
fi

## Check _SXR_CLIENT_ARBORPATH 08/31/2011 YK
if [ -n "$_SXR_CLIENT_ARBORPATH" ]; then
	export SXR_CLIENT_ARBORPATH=`eval echo "$_SXR_CLIENT_ARBORPATH"`
	echo "## Found \$_SXR_CLIENT_ARBORPATH definition."
	echo "##   Define \$SXR_CLIENT_ARBORPATH to $SXR_CLIENT_ARBORPATH."
	if [ -n "$_sc_env" ];then
		echo "##   Add export SXR_CLIENT_ARBORPATH=\"\$SXR_CLIENT_ARBORPATH\" to ${_sc_env} file."
		echo "export SXR_CLIENT_ARBORPATH=\"\$SXR_CLIENT_ARBORPATH\"	# Added by autopilot" >> ${_sc_env}
	fi
fi

## Check the $ODBC_HOME path
if [ -z "$ODBC_HOME" -a -n "$_ODBC_HOME" ];then
	echo "## No \$ODBC_HOME defined"
	fnd=
	for odbchome in $_ODBC_HOME; do
		if [ -d "$HYPERION_HOME/$odbchome" ]; then
			fnd=$odbchome
			break
		fi
	done
	if [ -z "$fnd" ]; then
		echo "##   But there is no '$_ODBC_HOME' folder"
		echo "##     under the \$HYPERION_HOME($HYPERION_HOME)."
		echo "##   Use $odbchome for now."
		fnd=`echo $_ODBC_HOME | awk '{print $1}'`
	fi
	echo "##  export ODBC_HOME=\$HYPERION_HOME/$fnd"
	export ODBC_HOME="$HYPERION_HOME/$fnd"
	if [ -n "$_sc_env" ];then
		echo "##   Add export ODBC_HOME=\"\$HYPERION_HOME/$fnd\" into ${_sc_env}"
		echo "export ODBC_HOME=\"\$HYPERION_HOME/$fnd\"	# Added by autopilot" >> ${_sc_env}
	fi
	unset odbchome fnd
else
	set_vardef ODBC_HOME
fi

## Check the JAVA_HOME path
if [ -z "$JAVA_HOME" -a -n "$_JAVA_HOME" ];then
	echo "## No \$JAVA_HOME defined."
	fnd=
	for jrehome in $_JAVA_HOME; do
		if [ -d "$HYPERION_HOME/$jrehome" ]; then
			fnd=$jrehome
			break
		fi
	done
	if [ -z "$fnd" ]; then
		echo "##   But there is no '$_JAVA_HOME' folder"
		echo "##     under the \$HYPERION_HOME($HYPERION_HOME)."
		echo "##   Use $jrehome for now."
		fnd=`echo $_JAVA_HOME | awk '{print $1}'`
	fi
	echo "##   export JAVA_HOME=\$HYPERION_HOME/$fnd"
	export JAVA_HOME=`normpath "$HYPERION_HOME/$fnd"`
	if [ -n "$_sc_env" ];then
		echo "##   Add export JAVA_HOME=\"\$HYPERION_HOME/$fnd\" into $_sc_env"
		echo "export JAVA_HOME=\"\$HYPERION_HOME/$fnd\"	# Added by autopilot" >> ${_sc_env}
	fi
	unset fnd jrehome
else
	set_vardef JAVA_HOME
fi

## Process $_LIBLIST
tmplist=
# _LIB first, then _LIBLIST
for item in $_LIB $_LIBLIST; do # reverse list
	[ -z "$tmplist" ] && tmplist=$item || tmplist="$item $tmplist" 
done
[ "$AP_BISHIPHOME" = "true" ] && tmplist="\$ARBORPATH/refbin $tmplist"
if [ -n "$_LIBPATH" ]; then
	for lpath in $_LIBPATH; do
		added=
		for item in $tmplist; do
			_tmp_=`echo $item | grep "\\$ODBC_HOME"`
			if [ -n "$_tmp_" -a -z "$ODBC_HOME" ]; then
				echo "## Found $item in the \$_LIBLIST."
				echo "##   But \$ODBC_HOME not defined."
				echo "##   Skip adding $item to \$$lpath environment variable."
				continue
			fi
			_tmp_=`echo $item | grep "\\$JAVA_HOME"`
			if [ -n "$_tmp_" -a -z "$JAVA_HOME" ]; then
				echo "## Found $item in the \$_LIBLIST."
				echo "##   But \$JAVA_HOME not defined."
				echo "##   Skip adding $item to \$$lpath environment variable."
				continue
			fi
			[ "`uname`" = "Windows_NT" ] \
				&& realpath=`eval print -r $item | sed -e "s/\\\\\\/\\\//g"` \
				|| realpath=`eval echo $item`
			if [ "`uname`" = "Windows_NT" ]; then
				_libpath=`eval print -r \\$$lpath | sed -e "s/\\\\\\/\\\//g" -e "s/;/:/g"`
				_libpath=":$_libpath:"
			else
				_libpath=`eval echo \\$$lpath`
				_libpath=":$_libpath:"
			fi
	#		_tmp_=`echo $_libpath | grep ":$realpath:"`
	#		if [ -z "$_tmp_" ]; then
	#			echo "## No $item in the \$$lpath."
				echo "##   Add $item into \$$lpath environment variable."
				if [ -z "$_libpath" -a -z "$added" ]; then
					eval export $lpath=\"${realpath}\"
					if [ -n "$_sc_env" ]; then
						echo "##   Add export $lpath=\"${item}\" into $_sc_env"
						echo "export $lpath=\"${item}\"	# Added by autopilot" >> ${_sc_env}
					fi
					added=true
				else
					eval export $lpath=\"${realpath}${pathsep}\$${lpath}\"
					if [ -n "$_sc_env" ]; then
						echo "##   Add export $lpath=\"${item}${pathsep}\$${lpath}\" into $_sc_env"
						echo "export $lpath=\"${item}${pathsep}\$${lpath}\"	# Added by autopilot" >> ${_sc_env}
					fi
				fi
	#		else
	#			echo "## $item already in the \$${lpath}."
	#			echo "##   Skip adding $item \$${lpath} environment variable."
	#		fi
		done
	done
fi
unset lpath item tmplist realpath added

## Process $_PATHLIST
tmplist=
for item in $_PATH $_PATHLIST; do # reverse list
	[ -z "$tmplist" ] && tmplist=$item || tmplist="$item $tmplist" 
done
[ "$AP_BISHIPHOME" = "true" ] && tmplist="\$ARBORPATH/refbin $tmplist"
# echo "# items=$tmplist($_PATH,$_PATHLIST)"
# echo "# crrpath=$crrpath"
for item in $tmplist; do
	_tmp_=`echo $item | grep "\\$ODBC_HOME"`
	if [ -n "$_tmp_" -a -z "$ODBC_HOME" ]; then
		echo "## Found $item in the \$_PATHLIST."
		echo "##   But \$ODBC_HOME not defined."
		echo "##   Skip adding $item to \$PATH environment variable."
		continue
	fi
	_tmp_=`echo $item | grep "\\$JAVA_HOME"`
	if [ -n "$_tmp_" -a -z "$JAVA_HOME" ]; then
		echo "## Found $item in the \$_PATHLIST."
		echo "##   But \$JAVA_HOME not defined."
		echo "##   Skip adding $item to \$PATH environment variable."
		continue
	fi
	# Expand item to real path
	[ `uname` = "Windows_NT" ] \
		&& realpath=`eval print -r $item | sed -e "s/\\\\\\/\\\//g"` \
		|| realpath=`eval echo $item`
	## Get Current PATH value
	[ `uname` = "Windows_NT" ] \
		&& crrpath=`print -r $PATH | sed -e "s/\\\\\\/\\\//g"` \
		|| crrpath=`echo $PATH`
#	_tmp_=`echo $crrpath | grep $realpath`
#	if [ -z "$_tmp_" ]; then
#		echo "## No $item in the \$PATH."
		echo "##   Add $item into \$PATH environment variable."
		export PATH="${realpath}${pathsep}$PATH"
		if [ -n "$_sc_env" ]; then
			echo "##   Add export PATH=\"${item}${pathsep}\$PATH\" into $_sc_env"
			echo "export PATH=\"${item}${pathsep}\$PATH\"	# Added by autopilot" >> ${_sc_env}
		fi
#	else
#		echo "## $item($realpath) already in the \$PATH."
#		echo "##   Skip adding $item into \$PATH environment variable."
#	fi
done
unset item tmplist realpath


## Check the ODBCINI on Unix platform
if [ `uname` != "Windows_NT" -a -n "$ODBC_HOME" -a -z "$ODBCINI" ];then
	echo "## No \$ODBCINI defined"
	export ODBCINI="${ODBC_HOME}/odbc.ini"
	if [ -n "$_sc_env" ];then
		echo "##   Add export ODBCINI=\"\$ODBC_HOME/odbc.ini\" to $_sc_env file "
		echo "export ODBCINI=\"\$ODBC_HOME/odbc.ini\"	# Added by autopilot" >> ${_sc_env}
	fi
else
	set_vardef ODBCINI
fi

## Check the ODBCINST on Unix platform
if [ `uname` != "Windows_NT" -a -n "$ODBC_HOME" -a -z "$ODBCINST" ];then
	echo "## No \$ODBCINST defined"
	export ODBCINST="${ODBC_HOME}/odbcinst.ini"
	if [ -n "$_sc_env" ];then
		echo "##   Add export ODBCINST=\"\$ODBC_HOME/odbcinst.ini\" to $_sc_env file "
		echo "export ODBCINST=\"\$ODBC_HOME/odbcinst.ini\"	# Added by autopilot" >> ${_sc_env}
	fi
else
	set_vardef ODBCINST
fi


## Check the $ESSLANG
if [ -z "$ESSLANG" ];then
	echo "## No \$ESSLANG defined"
	export ESSLANG="English_UnitedStates.Latin1@Binary"
	if [ -n "$_sc_env" ];then
		echo "##   Add export ESSLANG=\"English_UnitedStates.Latin1@Binary\" to ${_sc_env} file."
		echo "export ESSLANG=\"English_UnitedStates.Latin1@Binary\"	# Added by autopilot" >> ${_sc_env}
	fi
else
	set_vardef ESSLANG
fi


## Check the $SXR_HOME
if [ -z "$SXR_HOME" ];then
	echo "## No \$SXR_HOME defined"
	if [ -d "$_SXR_HOME" ]; then
		export SXR_HOME="$_SXR_HOME"
		echo "##   export SXR_HOME=$_SXR_HOME"
		if [ -n "$_sc_env" ];then
			echo "##   Add export SXR_HOME=\"$SXR_HOME\" to ${_sc_env}"
			echo "export SXR_HOME=\"$SXR_HOME\"	# Added by autopilot" >> ${_sc_env}
		fi
	else
		echo $_SXR_HOME | grep vobs > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			_novobs=`echo $_SXR_HOME | sed -e "s!vobs/!!g" 2> /dev/null`
			if [ -d "$_novobs" ]; then
				export SXR_HOME="$_novobs"
				echo "##   export SXR_HOME=$_novobs"
				if [ -n "$_sc_env" ];then
					echo "##   Add export SXR_HOME=\"$SXR_HOME\" to ${_sc_env}"
					echo "export SXR_HOME=\"$SXR_HOME\"	# Added by autopilot" >> ${_sc_env}
				fi
			else
				echo "##   !!! No SXR_HOME is found."
				echo "##   \$_SXR_HOME=$_SXR_HOME."
			fi
		else
			echo "##   !!! No SXR_HOME is found."
			echo "##   \$_SXR_HOME=$_SXR_HOME."
		fi
	fi
else
	set_vardef SXR_HOME
fi


## Check the SXR_HOME/bin in the PATH environment variable
[ `uname` = "Windows_NT" ] \
	&& _sbin=`print -r "$SXR_HOME/bin" | sed -e "s/\\\\\\/\\\//g"` \
	|| _sbin="$SXR_HOME/bin"
_tmp_=`echo $crrpath | grep "${_sbin}"`
if [ -z "$_tmp_" ];then
	echo "## No \$SXR_HOME/bin definition in the \$PATH environment variable"
	export PATH="$PATH${pathsep}$SXR_HOME/bin"
	if [ -n "$_sc_env" ];then
		echo "##   Add export PATH=\"\$PATH${pathsep}\$SXR_HOME/bin\" to ${_sc_env} file."
		echo "export PATH=\"\$PATH${pathsep}\$SXR_HOME/bin\"	# Added by autopilot" >> ${_sc_env}
	fi
fi
unset _tmp_

## Check the AgentPort value for this user
if [ -z "$AP_AGENTPORT" ];then
	echo "## No \$AP_AGENTPORT defined"
	# Check the <user name>.cfg file in the snapshot.
	if [ -d "$SXR_HOME/../base/data" ];then
		if [ -f "${SXR_HOME}/../base/data/${LOGNAME}.cfg" ];then
			echo "##   Found ${LOGNAME}.cfg file under the snapshot directory."
			_myap=`grep -i "^AGENTPORT" "${SXR_HOME}/../base/data/${LOGNAME}.cfg" | awk '{print $2}'`
			echo "##   Value of the agent port is $_myap"
		else
			echo "##   $LOGNAME.cfg not found under the snapshot directory."
			_myap=
		fi
	else
		echo "##   No snap shot directory."
		_myap=
	fi
	if [ -z "$_myap" ];then
		_myap=`grep "^${LOGNAME}[ 	]" "$AP_AGTPLIST"`
		
		if [ -z "$_myap" ];then
			# Lock ${AP_AGETPLIST}
			while [ -f "${AP_AGTPLIST}.lck" ];do
				sleep 1	# debug
			done
			echo "Locked by $LOGNAME from `hostname` on `date +%D_%T`" > ${AP_AGTPLIST}.lck
			echo "##   No $LOGNAME entry in the ${AP_AGTPLIST} file."
			ap=3000
			while [ $ap -lt 32000 ];do
				_p=`grep ${ap} "$AP_AGTPLIST"`
				if [ -f "$AP_DEF_SXRAGENTPORTLIST" ]; then
					_p2=`grep ${ap} "$AP_DEF_SXRAGENTPORTLIST"`
				else
					_p2=
				fi
				if [ -z "$_p" -a -z "$_p2" ];then
					echo "##  Define the agent port of ${LOGNAME} to $ap"
					echo "${LOGNAME}	$ap" | tr -d '\r' >> ${AP_AGTPLIST}
					break
				fi
				ap=`expr $ap + 5`
			done
			# Unlock the ${AP_AGTPLIST}
			rm -f ${AP_AGTPLIST}.lck
			export AP_AGENTPORT=$ap
		else
			echo "##   $LOGNAME entry found in the ${AP_AGTPLIST} file."
			export AP_AGENTPORT=`echo $_myap | awk '{print $2}' | tr -d '\r'`
		fi
	else
		export AP_AGENTPORT=$_myap
	fi
	if [ -n "$_sc_env" ];then
		echo "##   ADD export AP_AGENTPORT=$AP_AGENTPORT to ${_sc_env}"
		echo "export AP_AGENTPORT=$AP_AGENTPORT	# Added by autopilot" >> ${_sc_env}
	fi
else
	set_vardef AP_AGENTPORT
fi

## 05/16/08 YK Extra variable setting
if [ -n "$_EXTRA_VARS" ]; then
	for varname in ${_EXTRA_VARS}; do
		varval=`eval echo \$"${varname}"`
		if [ -z "$varval" ]; then
			varval=$(eval echo \$_${varname})
			echo "## No \$${varname} is defined."
			echo "##   export $varname=\"$varval\""
			export $varname="$(eval echo $varval)"
			if [ -n "$_sc_env" ]; then
				echo "##   ADD export $varname=\"$varval\" to ${_sc_env}"
				echo "export $varname=\"$varval\"" >> "$_sc_env"
			fi
		fi
	done
fi

# For C API / Added $APIPATH/bin and $ARBORPATH/bin into Library Path variables.
if [ -n "$_APIPATH" -a -z "$APIPATH" ]; then
	if [ -n "$_sc_env" ]; then
		echo "##   Add export APIPATH=\"$_APIPATH\" into $_sc_env"
		echo "export APIPATH=\"$_APIPATH\"	# Added by autopilot" >> ${_sc_env}
	fi
	export APIPATH="$(eval echo $_APIPATH)"
	for lpath in $_LIBPATH; do
		added=
		[ "`uname`" = "Windows_NT" ] \
			&& _libpath=`eval print -r \\$$lpath | sed -e "s/\\\\\\/\\\//g"` \
			|| _libpath=`eval echo \\$$lpath`
		for item in "\$APIPATH/bin" "\$ARBORPATH/bin"; do
			[ "`uname`" = "Windows_NT" ] \
				&& realpath=`eval print -r $item | sed -e "s/\\\\\\/\\\//g"` \
				|| realpath=`eval echo $item`
			_tmp_=`echo $_libpath | grep $realpath`
			if [ -z "$_tmp_" ]; then
				echo "## No $item in the \$$lpath."
				echo "##   Add $item into \$$lpath environment variable."
				if [ -z "$_libpath" -a -z "$added" ]; then
					eval export $lpath=\"${realpath}\"
					if [ -n "$_sc_env" ]; then
						echo "##   Add export $lpath=\"${item}\" into $_sc_env"
						echo "export $lpath=\"${item}\"	# Added by autopilot" >> ${_sc_env}
					fi
					added=true
				else
					eval export $lpath=\"\$${lpath}${pathsep}${realpath}\"
					if [ -n "$_sc_env" ]; then
						echo "##   Add export $lpath=\"\$${lpath}${pathsep}${item}\" into $_sc_env"
						echo "export $lpath=\"\$${lpath}${pathsep}${item}\"	# Added by autopilot" >> ${_sc_env}
					fi
				fi
			fi
		done
	done
fi

# Clean up temporary environment variables
unset prod_root	# This caused the failure of HIS Silent install
unset ap _myap _p _p2
unset hdef hhome_def hpath
unset _sbin _odbclib _libpath _javalib fnd
unset _ODBC_HOME _JAVA_HOME _PATH _LIB _LIBLIST _PATHLIST
unset _ESSDIR _ENVFILEBASE _LIBPATH lpath
unset crrdir crrpath
unset varname varval verdir _sc_ver _sc_env
unset _ESSCDIR _abin _clbin _SXR_HOME crr_dir path_str

# Duplicate PATH or the library entry check
fixpath.sh -v

