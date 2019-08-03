#!/usr/bin/ksh
########################################################################################
# se.sh : Set environment variables for the regression test.
########################################################################################
# Syntax:
#  . se.sh [-bi|-h|-e <env>|-updt|-s <view>|-nomkdir] <ver>
#  Note: You may need to execute this command with '.' command if you want
#        to setup current environment.
# Option:
#   -nomkdir  : Do not create $ARBORPATH and $VIEW_PATH when those are not exist.
#   -e <env>  : Use <env-file>
#               Note: If you don't define -e <env> with -updt option, 
#               se.sh use $AUTOPILOT/env/<user>/<ver>_<host>.env file.
#   -updt     : Update <env>
#   -s <view> : Use <view> snapshot
#               If <view> doesn't include '/' character, se.sh use following path:
#                 $AUTOPILOT/../../<view>/vobs/essbase/latest
#               So, if you want to use zola view on dickens, use following syntax.
#                 $ . se.sh -s zola dickens
#   -bi       : Setup environment BI-repository mode of BISHIPHOME installation.
#   -fa       : Set evironemnt FA mode of BISHIPHOME installation.
#   -binat    : Set up environment Native mode using BISHIPHOME installation.
#   -hss      : Use HSS mode.
#   -h        : display this help
#   -o <opt>  : Define task option.
# Reference:
#   AP_VERSION: The default version number. When you set this variable and skip <ver>
#               parameter, this script set the envrionment for $AP_VERSION.
########################################################################################
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
# 05/11/2012 YK Support AP_SECMODE variable and HSS mode.
# 2012/05/14	YKono	Re-fine
#			Add forceArborpath(), secMode(), noOpmn(), snapshot() options
# 2012/06/15	YKono	Add HSS mode.
# 2012/08/01	YKono	Fix SXR_CLIENT_ARBORPATH definition in $PATH and no $AP_SECMODE.
# 2012/08/17	YKono	Bug 14510052 - CHANGE USER/PASSWORD OF BI INSTALLATION TO DEFAULT ONE
# 2012/08/23	YKono	Support instance<#> or epmnservice<#> for _INSTANCE_LOC
# 2012/11/29	YKono	Bug 14769831 - RE-RUN PASS:APBG2905.SH CAUSE ONE DIFF WHEN RUNNING IN SERIES OF AGTPORI1.SH
#			Add export SXR_AGTCTL_START_SLEEP=5.
# 2012/12/11	YKono	Add EXTVARS for ver_setenv.sh.

. apinc.sh

### FUNCTIONS
# normpath(<pdef>) : Display normalized path.
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

# setvar(var_name, var_value) : Set var_name to var_value with eval
# And if define _sc_env file, add definition to _sc_env file.
setvar() # $1:var_name, $:var_value with variable name
{
# 2012/07/18 YKono by Yuki's request
# Workaround for HSS System Configurator doesn't set
# ESSLANG value by silent.xml file.
# Just skip when target value is ESSLANG and it is
# from opmn.xml file.
_skipesslang=false
if [ "$_setpref" = "@OPMN:" -a "$1" = "ESSLANG" ]; then
	[ -n "$ESSLANG" ] && _skipesslang=true
fi
if [ "$_skipesslang" = "false" ]; then
	_v="$2"
	if [ "$_v" != "${_v#\$HYPERION_HOME/../}" ]; then
		if [ -n "$HYPERION_HOME" ]; then
			_v="${HYPERION_HOME%/*}/${_v#\$HYPERION_HOME/../}"
		fi
	fi
	if [ -n "`echo $_v | grep $1 2> /dev/null`" ]; then
		if [ "${2#\$$1}" != "$2" ]; then
			_mess="##   ${_setpref}Append ${_v#\$$1${pathsep}} to \$$1"
		elif [ "${_v%\$$1}" != "$_v" ]; then
			_mess="##   ${_setpref}Insert ${_v%${pathsep}\$$1} to \$$1"
		else
			_mess="##   ${_setpref}Set \$$1 to $_v."
		fi
	else
		_mess="##   ${_setpref}Set \$${1} to $_v"
	fi
	if [ "${_v#*\$}" != "$_v" ]; then
		if [ "${thisplat#win}" != "$thisplat" ]; then
			if [ "${_v#-}" != "$_v" ]; then
				_v="X$_v"
				_vv=`eval "print -r \"$_v\"" | sed -e "s/\\\\\/\\\//g"`
				_vv=${_vv#?}
			else
				_vv=`eval "print -r \"$_v\"" | sed -e "s/\\\\\\/\\\//g"`
			fi
		else
			_vv=`eval "echo \"$_v\""`
		fi
	else
		_vv="$_v"
	fi
	if [ -n "$_vv" ]; then
		export $1="$_vv"
		echo "$_mess"
		if [ -n "$_sc_env" ]; then
			echo "##   ${_setpref}Add export $1=\"$_v\" to ${_sc_env} file."
			echo "export $1=\"${_v}\"	# Added by ${_setpref}autopilot" >> ${_sc_env}
		fi
	else
		echo "##   ${_setpref}Unset $1 becuase value is <null>"
		unset $1
	fi
else
	echo "##   ${_setpref}Skip $1 to $2 because of HSS System Configurator won't set ESSLANG value correctly."
fi # end 2012/07/12 workaround
}

### Main start here

unset set_vardef; set_vardef AP_AGTPLIST AP_VERSION AP_VERSEPCH
[ ! -f "$AP_AGTPLIST" ] && touch $AP_AGTPLIST

me=`which se.sh`
[ $? -ne 0 -o "$me" != "${me#no }" ] && me="se.sh"
orgpar=$@
_sc_upd=
_sc_sst=
_nomkdir=
_sc_client=
_sc_force="true"
_sc_opmn="true"
_exitsts=
_setpref=
while [ -n "$1" ]; do
	case $1 in
		-opmn|opmn)
			_sc_opmn="true"
			;;
		-noopmn|noopmn)
			_sc_opmn="false"
			;;
		-cl|cl)
			_sc_client=true
			;;
		-f|-force|arbor|force)
			_sc_force="true"
			;;
		-nf|-nof|-noforce|noforce|noarbor)
			_sc_force="false"
			;;
		-binat|binat|-bin|bin)
			export AP_BISHIPHOME=true
			;;
		-fa|fa)
			export AP_BISHIPHOME=true
			export AP_SECMODE=fa
			;;
		-birep|birep|-rep|rep|-bi|bi)
			export AP_BISHIPHOME=true
			export AP_SECMODE=rep
			;;
		update|-updt|-update|updt)
			_sc_upd="true"
			;;
		-e|-env|env)
			if [ $# -lt 2 ]; then
				echo "${me##*/}:'$1' need second parameter"
				_exitsts=1
				break
			fi
			shift
			_sc_env=$1
			;;
		env=*|env:*)
			_sc_env=${1#env?}
			;;
		-nomkdir|nomkdir)
			_sc_nomkdir="true"
			;;
		-s|-snapshot|snapshot)
			shift
			_sc_sst=$1
			;;
		snap=*|snapshot=*)
			_sc_sst=${1#*=}
			;;
		snap:*|snapshot:*)
			_sc_sst=${1#*:}
			;;
		-h|help|-help)
			display_help.sh $me
			_exitsts=0
			break
			;;
		-o|-opt|opt)
			if [ $# -lt 2 ]; then
				echo "${me##*/}:'$1' need second parameter."
				_exitsts=1
				break
			fi
			shift
			[ -z "$_OPTION" ] && export _OPTION=$1 || export _OPTION="$_OPTION $1"
			;;
		-hss|hss)
			export AP_SECMODE="hss"
			export AP_BISHIPHOME=
			;;
		*)
			_sc_ver=$1
			;;
	esac
	shift
done

[ -z "$_sc_ver" -a -n "$AP_VERSION" ] && _sc_ver="$AP_VERSION"
if [ -z "$_exitsts" -a -z "$_sc_ver" ]; then
	echo "${me##*/} : No version parameter."
	_exitsts=1
fi

[ -n "$_exitsts" ] && return $_exitsts

[ -z "$_sc_env" -a -n "$AP_ENVFILE" -a -f "$AP_ENVFILE" ] && _sc_env="$AP_ENVFILE"
if [ -z "$_sc_env" ]; then # Use default env-setup file.
	_sc_env="$AUTOPILOT/env/${LOGNAME}/${_sc_ver##*/}_${thishost}"
	if [ "${ARCH}" = "64" ]; then
		[ "${thisplat}" = "${thisplat#win}" ] && _sc_env="${_sc_env}_64"
	elif [ "${ARCH}" = "32" ]; then
		_sc_env="${_sc_env}_32"
	fi
	_sc_ev=${_sc_env}.env
fi

if [ -f "$_sc_env" ]; then
	. "$_sc_env"
	echo "Setup environment usign ${_sc_env}"
else
	echo "No env file($_sc_env) is found."
fi

[ "$_sc_upd" != "true" ] && unset _sc_env
export _ENVFILEBASE=${_sc_env%.env}

# Read task options
# - BI(true)
_str=`chk_para.sh bi "$_OPTION"`; _str=${_str##* }
[ "$_str" = "true" ] && export AP_BISHIPHOME="true"
#   SecMode(hss|rep)
_str=`chk_para.sh secMode "$_OPTION"`; _str=${_str##* }; _str=`echo $_str | tr A-Z a-z`
if [ -n "$_str" ]; then
	case $_str in
		hss)
			export AP_BISHIPHOME=
			export AP_SECMODE="hss"
			;;
		fa)
			export AP_BISHIPHOME="true"
			export AP_SECMODE="fa"
			;;
		rep|bi|birep)
			export AP_BISHIPHOME="true"
			export AP_SECMODE="rep"
			;;
		*)
			export AP_BISHIPHOME=
			export AP_SECMODE=
			;;
	esac
fi
# - ForceArborpath(true)
_str=`chk_para.sh forcearborpath "$_OPTION"`; _str=${_str##* }
[ "$_str" = "true" ] && _sc_force=$_str
# - NoOPMN(true) # Don't use opmnx.ml environemnt.
_str=`chk_para.sh noopmn "$_OPTION"`; _str=${_str##* }
[ "$_str" = "true" ] && _sc_opmn=$_str
# - Snapshot(str)
_str=`chk_para.sh snapshot "$_OPTION"`; _str=${_str##* }
[ -n "$_str" ] && _sc_sst=$_str

### Set version depended variables
. ver_setenv.sh $_sc_ver > /dev/null 2>&1
# Check snaproot() task option
_str=`chk_para.sh snaproot "$_OPTION"`; _str=${_str##* }
[ -n "$_str" -a -d "$_str" ] && _ap_snaproot=$_str
# Replace architecture depended definition
unset _plat32 _rtc64
case $thisplat in
	solaris|aix)	_plat32="-32";;
	*64*)		_rtc64="-64";;
esac
for _var in _ESSDIR _ESSCDIR _SXR_CLIENT_ARBORPATH _PATH _LIB _ARBORPATH _INSTANCE_LOC; do
	_val=`eval echo \\$${_var}`
	_val=`echo $_val | sed -e "s/<plat32>/$_plat32/g" -e "s/<rtc64>/$_rtc64/g"`
	eval "$_var='$_val'"
done
## Set platform depended value
unset _JAVA_HOME _ODBC_HOME _LIBPATH _EXTRA_VARS _PATHLIST _LIBLIST
_thisplat=`realplat.sh $thisplat`
if [ -f "$AUTOPILOT/env/template/${_thisplat}.env2" ];then
	echo "## Execute $_thisplat.env2 script."
	. $AUTOPILOT/env/template/$_thisplat.env2 $_sc_ver
fi
unset _thisplat
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

## Check HOME directory
if [ -z "$HOME" ]; then
	echo "## \$HOME not defined"
	echo "## Use current directory (`pwd`) as HOME directory"
	_sc_hpath=`pwd`
	_sc_hdef=`pwd`
else
	_sc_hpath=$HOME
	_sc_hdef="\$HOME"
fi

## Check the ARCH on AIX/Solaris
if [ -z "$ARCH" ];then
	case "`ver_cmstrct.sh $_sc_ver`_${thisplat}" in
		new_solaris|new_aix|hyp_solaris|hyp_aix|new_linux)
			echo "## No \$ARCH defined"
			setvar ARCH 32
			;;
	esac
fi

## Check VIEW_PATH
if [ -z "$VIEW_PATH" ];then
	echo "## \$VIEW_PATH not defined"
	setvar VIEW_PATH "$_sc_hdef/views"
	if [ ! -d "$VIEW_PATH" ];then
		if [ -z "$_sc_nomkdir" ]; then
			echo "##   CREATE $_sc_hdef/views directory for \$VIEW_PATH"
			mkddir.sh $VIEW_PATH
		else
			echo "##   There is no $_sc_hdef/views directory."
		fi
	fi
elif [ ! -d "$VIEW_PATH" ];then
	echo "## $VIEW_PATH directory not found for \$VIEW_PATH"
	if [ -z "$_sc_nomkdir" ]; then
		echo "##   Create $VIEW_PATH directory"
		mkddir.sh "$VIEW_PATH"
		if [ ! -d "$VIEW_PATH" ];then
			echo "##   Failed to create $VIEW_PATH directory"
			setvar VIEW_PATH "$_sc_hdef/views"
			if [ ! -d "$_sc_hpath/views" ];then
				echo "##   CREATE $_sc_hdef/views directory for \$VIEW_PATH"
				mkddir.sh $VIEW_PATH
			fi
		fi
	fi
fi

## Check HYPERION_HOME
unset _bimode
if [ "$AP_BISHIPHOME" = "true" ]; then
	 [ "$AP_SECMODE" = "fa" -o -z "$AP_SECMODE" ] && _bimode="_FA" || _bimode="_BI"
fi
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
		if [ ! -d "$_sc_hpath/hyperion" ];then
			echo "##   Create $_sc_hdef/hyperion directory"
			mkdir $_sc_hpath/hyperion
			if [ $? -ne 0 ]; then
				prod_root="$_sc_hpath"
				hhome_def="$_sc_hdef"
			else
				prod_root="$_sc_hpath/hyperion"
				hhome_def="$_sc_hdef/hyperion"
			fi
		else
			prod_root="$_sc_hpath/hyperion"
			hhome_def="$_sc_hdef/hyperion"
		fi
	fi
	if [ -n "$ARCH" ]; then
		verdir="${_sc_ver}${_bimode}_${ARCH}"
	else
		verdir="${_sc_ver}${_bimode}"
	fi
	verdir=`echo $verdir | sed -e "s!\.!$AP_VERSEPCH!g"`
	if [ ! -d "$prod_root/${verdir}" ];then
		if [ -z "$_sc_nomkdir" ]; then
			echo "##   Create $prod_root/${verdir}"
			mkddir.sh $prod_root/${verdir}
		fi
		prod_root="$prod_root/$verdir"
		hhome_def="$hhome_def/$verdir"
	else
		prod_root="$prod_root/$verdir"
		hhome_def="$hhome_def/$verdir"
	fi
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
	setvar HYPERION_HOME "$hhome_def"
elif [ ! -d "$HYPERION_HOME" ];then
	echo "## $HYPERION_HOME directory not exist"
	if [ -z "$_sc_nomkdir" ]; then
		echo "##   Create \$HYPERION_HOME($HYPERION_HOME) directory"
		mkddir.sh $HYPERION_HOME
		if [ ! -d "$HYPERION_HOME" ];then
			echo "##   Failed to create $HYPERION_HOME directory($?)"
			echo "##   Use $_sc_hdef/hyperion/${_sc_ver} insted of $HYPERION_HOME"
			if [ -n "$ARCH" ]; then
				verdir="${_sc_ver}${_bimode}_${ARCH}"
			else
				verdir="${_sc_ver}${_bimode}"
			fi	
			if [ ! -d "$_sc_hpath/hyperion" ];then
				echo "##   Create $_sc_hdef/hyperion directory"
				mkdir $_sc_hpath/hyperion
			fi
			if [ ! -d "$_sc_hpath/hyperion/${verdir}" ];then
				echo "##   Create $_sc_hdef/hyperion/${verdir}"
				mkdir $_sc_hpath/hyperion/${verdir}
			fi
			setvar HYPERION_HOME "$_sc_hpath/hyperion/${verdir}"
		fi
	fi
fi
if [ -z "$ORACLE_HOME" ]; then
	echo "## \$ORACLE_HOME not defined."
	setvar ORACLE_HOME "\$HYPERION_HOME"
fi
# Adjust _INSTANCE_LOC location when it use <#> by real HYPERION_HOME
# echo "# _INSTANCE_LOC=$_INSTANCE_LOC"
if [ "${_INSTANCE_LOC#*\<\#\>}" != "$_INSTANCE_LOC" ]; then
	# Use instance<#> format.
	_instance_up=${_INSTANCE_LOC%/*}
	_instance_base=${_INSTANCE_LOC##*/}
	_instance_base=${_instance_base%%\<\#\>*}
# echo "# _instance_up=$_instance_up"
# echo "# _instance_base=$_instance_base"
	if [ -d "$HYPERION_HOME/$_instance_up" ]; then
		_crrloc=`pwd`
		cd $HYPERION_HOME/$_instance_up
		_last_instance=`ls -1r | grep ^${_instance_base} 2> /dev/null | head -1`
# echo "# _last_instance=<$_last_instance>"
		if [ -n "$_last_instance" ]; then
			_INSTANCE_LOC="$_instance_up/$_last_instance"
		else
			_INSTANCE_LOC="$_instance_up/${_instance_base}1"
		fi
		cd $_crrloc 2> /dev/null
	else
		_INSTANCE_LOC="$_instance_up/${_instance_base}1"
	fi
	unset _crrloc _instance_up _instance_base _last_instance
fi
# echo "# _INSTANCE_LOC=$_INSTANCE_LOC"
if [ "$AP_SECMODE" = "hss" -o "$AP_SECMODE" = "rep" -o "$AP_SECMODE" = "fa" -o "$AP_SECMODE" = "bi" ]; then
	if [ -z "$ORACLE_INSTANCE" ]; then
		echo "## \$ORACLE_INSTANCE not defined."
		setvar ORACLE_INSTANCE "\$HYPERION_HOME/$_INSTANCE_LOC"
	fi
	# 2012/06/19 YK For HSS mode, we require to have AP_SECMODE even if before initialization
	# if [ ! -d "$ORACLE_INSTANCE" -o -z "$_ARBORPATH" -o ! -d "$HYPERION_HOME/$_ARBORPATH" ]; then
	# 	echo "## There is no valid\ $ORACLE_INSTANCE folder."
	# 	[ ! -d "$ORACLE_INSTANCE" ] && echo "## - Missing \$ORACLE_INSTANCE folder."
	# 	[ -z "$_ARBORPATH" ] && echo "## - Missing \$_ARBORPATH definition in ver_setenv.sh."
	# 	[ ! -d "$HYPERION_HOME/$_ARBORPATH" ] && echo "## - Missing $HYPERION_HOME/$_ARBORPATH folder for \$ARBORPATH."
	# 	echo "## -> Reset the security mode to native."
	# 	export AP_SECMODE=
	# 	export ORACLE_INSTANCE=
	# 	export _ARBORPATH=
	# fi
fi
		
unset verdir prod_root hhome_def _sc_hpath

## Check EPM_ORACLE_HOME definition
if [ "$AP_BISHIPHOME" != "true" -a -z "$EPM_ORACLE_HOME" ]; then
	echo "## \$EPM_ORACLE_HOME not defnied"
	setvar EPM_ORACLE_HOME \$HYPERION_HOME
fi

## Check AP_SECMODE and product already installed.
unset SXR_ESSBASE_INST SXR_USER SXR_DBHOST
_psmode=
if [ "$AP_SECMODE" = "hss" ]; then
	echo "## Set Variables for HSS configured environment."
	setvar SXR_ESSBASE_INST 1
	setvar SXR_USER admin
	setvar SXR_PASSWORD password
	_psmode=":hss"
elif [ "$AP_SECMODE" = "fa" ]; then
	echo "## Set Variables for BISHIPHOME configured environment."
	setvar SXR_ESSBASE_INST 2
	setvar SXR_USER weblogic
	setvar SXR_PASSWORD welcome1
	_psmode=":fa"
elif [ "$AP_SECMODE" = "rep" ]; then
	echo "## Set Variables for BISHIPHOME configured environment."
	setvar SXR_ESSBASE_INST 3
	setvar SXR_USER weblogic
	setvar SXR_PASSWORD welcome1
	_psmode=":rep"
fi
[ "$_bimode" = "_BI" -a -z "$AP_SECMODE" ] && _psmode=":bi"
[ "$_sc_client" = "true" ] && _psmode="$_psmode:cl"
# Maintain prompt(PS1) with version number
if [ -n "$_apps1" -a "$_apps1" != "false" ]; then
	export PS1="[AP `apver.sh -s` $_apbin SE ${_sc_ver}${_psmode}]
$_aporgps1"
fi
unset _psmode _bimode

[ -z "$AP_SECMODE" ] && _sc_force="true" # Force define always ture when use native security

if [ "$_sc_client" = "true" ]; then
	# allways set ARBORPATH and ESSBASEPATH to _SXR_CLIENT_ARBORPATH or _ARBORPATH or _ESSCDIR or _ESSDIR
	if [ -z "$ARBORPATH" ]; then
		echo "## No \$ARBORPATH defined."
		for one in $_SXR_CLIENT_ARBORPATH $_ARBORPATH $_ESSCDIR $_ESSDIR; do
			setvar ARBORPATH "\$HYPERION_HOME/$one"
			break
		done
	fi
	if [ -z "$ESSBASEPATH" ]; then
		echo "## No \$ESSBASEPATH defined."
		setvar ESSBASEPATH "\$HYPERION_HOME/$_ESSDIR"
	fi
	for lpath in $_LIBPATH; do
		setvar ${lpath} "\$ESSBASEPATH/bin${pathsep}\$${lpath}"
	done
	setvar PATH "\$ESSBASEPATH/bin${pathsep}\$PATH"
	setvar PATH "\$ARBORPATH/bin${pathsep}\$PATH"
else
	if [ "$_sc_force" = "true" ]; then
		## Check ARBORPATH
		if [ "$AP_SECMODE" = "hss" -o "$AP_SECMODE" = "rep" -o "$AP_SECMODE" = "fa" ]; then
			_arb="\$HYPERION_HOME/$_ARBORPATH"
			_sc_opmnf="$ORACLE_INSTANCE/config/OPMN/opmn/opmn.xml"
			# Make COMPONENT_TYPE and COMPONENT_NAME from $_INSTANCE_LOC and $_ARBORPATH
			_sc_comptyp=${_INSTANCE_LOC#*/}
			_sc_comptyp=${_sc_comptyp%/*}
			if [ -z "$COMPONENT_TYPE" ]; then
				echo "## No \$COMPONENT_TYPE defined."
				setvar COMPONENT_TYPE "$_sc_comptyp"
			fi
			_sc_compnam=${_ARBORPATH##*/}
			if [ -z "$COMPONENT_NAME" ]; then
				echo "## No \$COMPONENT_NAME defined."
				setvar COMPONENT_NAME "$_sc_compnam"
			fi
			unset _sc_cimptyp _sc_compnam
			[ "$AP_SECMODE" = "hss" ] \
				&& _sc_srchess="<process-type id=\"EssbaseAgent\" module-id=\"ESS\">" \
				|| _sc_srchess="<process-type id=\"Essbase\" module-id=\"ESS\">"
			if [ -f "$_sc_opmnf" ]; then
				if [ "$_sc_opmn" = "true" ]; then
					echo "## Found opmn.xml file. Set variables from it."
					_setpref="@OPMN:"
					_sc_opmn_tmpf=$HOME/${LOGNAME}@${thishost}_opmn.tmp
					rm -rf "$_sc_opmn_tmpf}" 2> /dev/null
					_sc_total_lines=`cat $_sc_opmnf | wc -l`
					let _sc_total_lines=_sc_total_lines
					_sc_start_ess=`grep -n "$_sc_srchess" $_sc_opmnf`
					_sc_start_ess=${_sc_start_ess%:*}
					let _sc_start_ess=_sc_start_ess
					let _sc_skip_lines=_sc_total_lines-_sc_start_ess+1
					_sc_start_env=`tail -$_sc_skip_lines $_sc_opmnf | grep -n "<environment>" | head -1`
					_sc_end_env=`tail -$_sc_skip_lines $_sc_opmnf | grep -n "</environment>" | head -1`
					_sc_start_env=${_sc_start_env%:*}
					_sc_end_env=${_sc_end_env%:*}
					let _sc_start_env=_sc_start_env
					let _sc_end_env=_sc_end_env
					let _sc_tail_lines=_sc_total_lines-_sc_start_ess-_sc_start_env
					let _sc_body_lines=_sc_end_env-_sc_start_env-1
					tail -$_sc_tail_lines $_sc_opmnf \
					| head -$_sc_body_lines | sed -e "s!\\\\!/!g" > $_sc_opmn_tmpf
					while read -r _sc_line; do
						if [ "${_sc_line#*\<variable id=}" != "$_sc_line" ]; then
							_sc_tmp=${_sc_line#*\<variable id=\"}
							_sc_varname=${_sc_tmp%%\"*}
							_sc_tmp=${_sc_tmp#*value=\"}
							_sc_value=${_sc_tmp%%\"*}
							setvar "$_sc_varname" "$_sc_value"
						elif [ "${_sc_line#*\<variable append=\"true\" id=}" != "$_sc_line" ]; then
							_sc_tmp=${_sc_line#*\<variable append=\"true\" id=\"}
							_sc_varname=${_sc_tmp%%\"*}
							_sc_tmp=${_sc_tmp#*value=\"}
							_sc_value=${_sc_tmp%%\"*}
							_sc_value=`echo $_sc_value | sed -e "s!$:!:!g"`
							setvar "$_sc_varname" "\$$_sc_varname${pathsep}$_sc_value"
						elif [ "${_sc_line#*\<variable insert=\"true\" id=}" != "$_sc_line" ]; then
							_sc_tmp=${_sc_line#*\<variable insert=\"true\" id=\"}
							_sc_varname=${_sc_tmp%%\"*}
							_sc_tmp=${_sc_tmp#*value=\"}
							_sc_value=${_sc_tmp%%\"*}
							_sc_value=`echo $_sc_value | sed -e "s!$:!:!g"`
							setvar "$_sc_varname" "$_sc_value${pathsep}\$${_sc_varname}"
						fi
					done < $_sc_opmn_tmpf
					rm -rf $_sc_opmn_tmpf 2> /dev/null
					unset _sc_tmp _sc_varname _sc_value
					unset _setpref _sc_total_lines _sc_start_ess
					unset _sc_start_env _sc_end_env _sc_tail_lines 
					unset _sc_body_lines _sc_skip_lines _sc_opmn_tmpf
				else
					echo "## Found opmn.xml file. But \$_sc_opmn is set to false. Skip opmn.xml."
				fi
			fi
		else
			_arb="\$HYPERION_HOME/${_ESSDIR}"
		fi
		if [ -z "$ARBORPATH" ];then
			echo "## \$ARBORPATH not defined"
			setvar ARBORPATH $_arb
			if [ ! -d "$ARBORPATH" -a -z "$_sc_nomkdir" ];then
				echo "##   Create $_arb directory"
				mkddir.sh "$ARBORPATH"
			fi
		elif [ ! -d "$ARBORPATH" ];then
			echo "## \$ARBORPATH directory not found"
			if [ -z "$_sc_nomkdir" ]; then
				echo "##   Create $ARBORPATH directory"
				mkddir.sh $ARBORPATH
				if [ ! -d "$ARBORPATH" ];then
					echo "##   Failed to create $ARBORPATH directory"
					echo "##   Use $_arb instead of current \$ARBORPATH"
					setvar ARBORPATH ${_arb}
					if [ ! -d "$ARBORPATH" ];then
						echo "##   Create $ARBORPATH directory"
						mkddir.sh "$ARBORPATH"
					fi
				fi
			fi
		fi
		unset _arb
	
		## Check ESSBASEPATH
		if [ -z "$ESSBASEPATH" ]; then
			echo "## \$ESSBASEPATH not defined"
			setvar ESSBASEPATH "\$HYPERION_HOME/${_ESSDIR}"
		fi
	fi # $_sc_force=true
	## Check _SXR_CLIENT_ARBORPATH 08/31/2011 YK
	if [ -n "$_SXR_CLIENT_ARBORPATH" ]; then
		echo "## Found \$_SXR_CLIENT_ARBORPATH($_SXR_CLIENT_ARBORPATH) definition."
		[ -d "$HYPERION_HOME/$_SXR_CLIENT_ARBORPATH" ] \
			&& setvar SXR_CLIENT_ARBORPATH "\$HYPERION_HOME/$_SXR_CLIENT_ARBORPATH" \
			|| echo "##   But no target folder(\$HYPERION_HOME/$_SXR_CLIENT_ARBORPATH). Skip it."
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
			for fnd in $_ODBC_HOME; do
				echo "##   - \$HYPERION_HOME/$fnd"
			done
			echo "##   But there is no target folder under the \$HYPERION_HOME."
			fnd=`echo $_ODBC_HOME | awk '{print $1}'`
			echo "##   Use $fnd for now."
		fi
		setvar ODBC_HOME "\$HYPERION_HOME/$fnd"
		unset odbchome fnd
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
			for fnd in $_JAVA_HOME; do
				echo "##   - \$HYPERION_HOME/$fnd"
			done
			echo "##   But there is no target folder under the \$HYPERION_HOME."
			fnd=`echo $_JAVA_HOME | awk '{print $1}'`
			echo "##   Use $fnd for now."
		fi
		setvar JAVA_HOME "\$HYPERION_HOME/$fnd"
		unset fnd jrehome
	fi

	## Process $_LIBLIST (_LIB first, then _LIBLIST)
	tmplist=
	for item in $_LIB $_LIBLIST; do # reverse list
		[ -z "$tmplist" ] && tmplist=$item || tmplist="$item $tmplist" 
	done
	for lpath in $_LIBPATH; do
		[ -z "$tmplist" ] && continue
		echo "## Check \$$lpath"
		for item in $tmplist; do
			if [ -n "`echo $item | grep \\$ODBC_HOME`" -a -z "$ODBC_HOME" ]; then
				echo "## Found $item in the \$_LIBLIST."
				echo "##   But \$ODBC_HOME not defined."
				echo "##   Skip adding $item to \$$lpath environment variable."
				continue
			fi
			if [ -n "`echo $item | grep \\$JAVA_HOME`" -a -z "$JAVA_HOME" ]; then
				echo "## Found $item in the \$_LIBLIST."
				echo "##   But \$JAVA_HOME not defined."
				echo "##   Skip adding $item to \$$lpath environment variable."
				continue
			fi
			if [ -n "`echo $item | grep \\$ARBORPATH`" -a "$_sc_force" != "true" ]; then
				echo "## Found $item in the \$_LIBLIST."
				echo "##   But \$ARBORPATH not defined by -nf(NoForceDefine) parameter."
				echo "##   Skip adding $item to \$$lpath environment variable."
				continue
			fi
			if [ -n "`echo $item | grep \\$ESSBASEPATH`" -a "$_sc_force" != "true" ]; then
				echo "## Found $item in the \$_LIBLIST."
				echo "##   But \$ESSBASEPATH not defined by -nf(NoForceDefine) parameter."
				echo "##   Skip adding $item to \$$lpath environment variable."
				continue
			fi
			if [ "$thisplat" != "${thisplat#win}" ]; then
				_libpath=`eval print -r \\$$lpath | sed -e "s/\\\\\\/\\\//g" -e "s/;/:/g"`
			else
				_libpath=`eval echo \\$$lpath`
			fi
			[ -z "$_libpath" ] \
				&& setvar $lpath "$item" \
				|| setvar $lpath "${item}${pathsep}\$${lpath}"
		done
	done
	unset lpath item tmplist realpath added

	## Process $_PATHLIST
	if [ "$thisplat" != "${thisplat#win}" ]; then
		_path=`print -r $PATH | sed -e "s/\\\\\\/\\\//g"`
		export PATH="$_path"
	fi
	echo "## Check \$PATH"
	tmplist=
	for item in $_PATH $_PATHLIST; do # reverse list
		[ -z "$tmplist" ] && tmplist=$item || tmplist="$item $tmplist" 
	done
	for item in $tmplist; do
		if [ -n "`echo $item | grep \\$ODBC_HOME`" -a -z "$ODBC_HOME" ]; then
			echo "## Found $item in the \$_PATHLIST."
			echo "##   But \$ODBC_HOME not defined."
			echo "##   Skip adding $item to \$PATH environment variable."
			continue
		fi
		if [ -n "`echo $item | grep \\$JAVA_HOME`" -a -z "$JAVA_HOME" ]; then
			echo "## Found $item in the \$_PATHLIST."
			echo "##   But \$JAVA_HOME not defined."
			echo "##   Skip adding $item to \$PATH environment variable."
			continue
		fi
		if [ -n "`echo $item | grep \\$ARBORPATH`" -a "$_sc_force" != "true" ]; then
			echo "## Found $item in the \$_PATHLIST."
			echo "##   But \$ARBORPATH not defined."
			echo "##   Skip adding $item to \$PATH environment variable."
			continue
		fi
		if [ -n "`echo $item | grep \\$ESSBASEPATH`" -a "$_sc_force" != "true" ]; then
			echo "## Found $item in the \$_PATHLIST."
			echo "##   But \$ESSBASEPATH not defined."
			echo "##   Skip adding $item to \$PATH environment variable."
			continue
		fi
		setvar PATH "${item}${pathsep}\$PATH"
	done
	if [ -n "$SXR_CLIENT_ARBORPATH" -a -z "$AP_SECMODE" ]; then
		echo "## Found \$SXR_CLIENT_ARBORPATH definition. But \$AP_SECMODE is not set(=native)."
		setvar SXR_CLIENT_ARBORPATH ""
	fi
	unset item tmplist realpath
fi
## Check the ODBCINI on Unix platform
if [ "${thisplat#win}" = "$thisplat" -a -n "$ODBC_HOME" -a -z "$ODBCINI" ];then
	echo "## No \$ODBCINI defined"
	setvar ODBCINI "\$ODBC_HOME/odbc.ini"
fi

## Check the ODBCINST on Unix platform
if [ "${thisplat#win}" = "$thisplat" -a -n "$ODBC_HOME" -a -z "$ODBCINST" ];then
	echo "## No \$ODBCINST defined"
	setvar ODBCINST "\$ODBC_HOME/odbcinst.ini"
fi

## Check the $ESSLANG
if [ -z "$ESSLANG" ];then
	echo "## No \$ESSLANG defined"
	setvar ESSLANG "English_UnitedStates.Latin1@Binary"
fi

if [ -z "$SXR_AGTCTL_START_SLEEP" ]; then
	echo "## No \$SXR_AGTCTL_START_SLEEP defined."
	echo "## Set it to 5 seccond according to bug 14769831."
	setvar SXR_AGTCTL_START_SLEEP 5
fi

## Check the $SXR_HOME
if [ -n "$_sc_sst" ]; then
	if [ "x${_sc_sst#*/}" = "x${_sc_sst}" -a -d "$_ap_snaproot/$_sc_sst" ]; then
		_SXR_HOME="$_ap_snaproot/$_sc_sst/vobs/essexer/latest"
	elif [ -d "$_sc_sst/vobs/essexer/latest" ]; then
		_SXR_HOME="$_sc_sst/vobs/essexer/latest"
	else
		echo "## Found snapshot($_sc_sst) definition."
		echo "##   But not found $_sc_sst/vobs/essexer/latest."
		echo "##   Reset snapshot() definition."
	fi
fi
_SXR_HOME=`normpath "$_SXR_HOME"`
if [ -z "$SXR_HOME" ];then
	echo "## No \$SXR_HOME defined"
	if [ -d "$_SXR_HOME" ]; then
		setvar SXR_HOME "$_SXR_HOME"
	else
		echo $_SXR_HOME | grep vobs > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			_novobs=`echo $_SXR_HOME | sed -e "s!vobs/!!g" 2> /dev/null`
			if [ -d "$_novobs" ]; then
				setvar SXR_HOME "$_novobs"
			else
				echo "##   !!! No SXR_HOME is found."
				echo "##   \$_SXR_HOME=$_SXR_HOME."
			fi
		else
			echo "##   !!! No SXR_HOME is found."
			echo "##   \$_SXR_HOME=$_SXR_HOME."
		fi
	fi
fi
unset _novobs _sc_sst _ap_snaproot

## Check the SXR_HOME/bin in the PATH environment variable
[ "${thisplat#win}" != "$thisplat" ] \
	&& _sbin=`print -r "$SXR_HOME/bin" | sed -e "s/\\\\\\/\\\//g"` \
	|| _sbin="$SXR_HOME/bin"
## Get Current PATH value
[ "${thisplat#win}" != "$thisplat" ] \
	&& crrpath=`print -r $PATH | sed -e "s/\\\\\\/\\\//g"` \
	|| crrpath=`echo $PATH`
if [ -z "`echo $crrpath | grep ${_sbin}`" ];then
	echo "## No \$SXR_HOME/bin definition in the \$PATH environment variable"
	setvar PATH "\$PATH${pathsep}\$SXR_HOME/bin"
fi

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
			# Lock ${AP_AGTPLIST}
			while [ -f "${AP_AGTPLIST}.lck" ];do
				sleep 1	# debug
			done
			echo "Locked by $LOGNAME from `hostname` on `date +%D_%T`" > ${AP_AGTPLIST}.lck
			echo "##   No $LOGNAME entry in the ${AP_AGTPLIST} file."
			_myap=3000
			while [ $_myap -lt 32000 ];do
				if [ -z "`grep ${_myap} $AP_AGTPLIST`" ];then
					echo "##  Define the agent port of ${LOGNAME} to $_myap"
					echo "${LOGNAME}	$_myap" >> ${AP_AGTPLIST}
					break
				fi
				_myap=`expr $_myap + 5`
			done
			# Unlock the ${AP_AGTPLIST}
			rm -f ${AP_AGTPLIST}.lck
		else
			echo "##   $LOGNAME entry found in the ${AP_AGTPLIST} file."
			_myap=`echo $_myap | awk '{print $2}' | tr -d '\r'`
		fi
	fi
	setvar AP_AGENTPORT "$_myap"
fi
# # Adjust SXR_DBHOST
# if [ "$AP_SECMODE" = "hss" -o "$AP_SECMODE" = "rep" ]; then
# 	setvar SXR_DBHOST "${thishost}:$AP_AGENTPORT"
# fi

# if [ "$AP_SECMODE" = "fa" -o "$AP_SECMODE" = "rep" -o "$AP_SECMODE" = "bi" ]; then
# 	if [ -z "$WEBLOGIC_SERVER" ]; then
# 		setvar WEBLOGIC_SERVER "$(hostname):7001"
# 	fi
# fi

## 12/11/12 YK Support Extra variable for ver_setenv.sh
if [ -n "$_EXTRA_SETENVVARS" ]; then
	for varname in ${_EXTRA_SETENVVARS}; do
		varval=`eval "echo \\$${varname}"`
		if [ -z "$varval" ]; then
			varval=`eval echo \$\_${varname}`
			echo "## No \$${varname} is defined."
			setvar $varname "$varval"
			unset _${varname}
		else
			echo "## \$${varname} is already defined to \"$varval\"."
		fi
	done
fi

## 05/16/08 YK Extra variable setting
if [ -n "$_EXTRA_VARS" ]; then
	for varname in ${_EXTRA_VARS}; do
		varval=`eval "echo \\$${varname}"`
		if [ -z "$varval" ]; then
			varval=`eval echo \$\_${varname}`
			echo "## No \$${varname} is defined."
			setvar $varname "$varval"
			unset _${varname}
		else
			echo "## \$${varname} is already defined to \"$varval\"."
		fi
	done
fi

# For C API / Added $APIPATH/bin and $ARBORPATH/bin into Library Path variables.
if [ -n "$_APIPATH" -a -z "$APIPATH" ]; then
	echo "## No \$APIPATH defined."
	setvar APIPATH "$_APIPATH"
	for lpath in $_LIBPATH; do
		for item in "\$APIPATH/bin" "\$ARBORPATH/bin"; do
			[ "${thisplat#win}" != "$thisplat" ] \
				&& _libpath=`eval print -r \\$$lpath | sed -e "s/\\\\\\/\\\//g" -e "s/;/:/g"` \
				|| _libpath=`eval echo \\$$lpath`
			if [ -z "$_libpath" ]; then
				setvar $lpath "$item"
			else
				setvar $lpath "\$${lpath}${pathsep}${item}"
			fi
		done
	done
fi

if [ -n "$_sc_env" ]; then
	echo "##   Add \". fixpath.sh -v\" to ${_sc_env} file."
	echo ". fixpath.sh -v	# Added by autopilot" >> ${_sc_env}
fi

# Clean up temporary environment variables
unset prod_root	# This caused the failure of HIS Silent install
unset _myap _sc_hdef hhome_def _sc_hpath
unset _sbin _odbclib _libpath _javalib fnd
unset _ODBC_HOME _JAVA_HOME _PATH _LIB _LIBLIST _PATHLIST
unset _ESSDIR _ENVFILEBASE _LIBPATH lpath
unset crrpath _exitsts _opt
unset varname varval verdir _sc_ver _sc_env
unset _ESSCDIR _abin _clbin _SXR_HOME crr_dir path_str
unset _rtc64 _sc_client _sc_ev _sc_force
unset _sc_line _sc_upd _str _tmp
unset _val _var _varlist _verbose
unset _vv _nomkdir _one _path
unset _fnd _mess _newpath
unset _SXR_CLIENT_ARBORPATH _EXTRA_VARS _HYPERION_HOME _LPATH
unset _DUPCHK_LIST _IGNBIN_LIST _APIPATH _ARBOR_BI _ARBOR_HSS
unset vdf orgpar _setpref _fnd _crrval _sc_opmn me

# Check and fix the duplicate PATH or the library entry
echo "## Maintain duplicate or empty entries in PATH and library definitions."
. fixpath.sh -v

return 0
