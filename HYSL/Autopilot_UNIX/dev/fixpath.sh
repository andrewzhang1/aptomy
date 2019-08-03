#!/usr/bin/ksh
#########################################################################
# fixpath.sh : Fix PATH/LIBPATH setting.
# Description:
#   This script check the PATH and the library definition variables:
#     1) Contains not existed path.
#     2) Contains duplicated entry.
#   And fix(remove) those definition from each variables.
# Syntax: . fixpath.sh [-h|-v|-vv] [<extra-var>...]
#   -h:  Display help
#   -v:  Verbose mode.
#   -vv: Detail verbose mode.
#########################################################################
# History:
# 11/15/2011 YK First edition
# 02/28/2014 YK Bug 18324781 - SUPPORT SEPARATE CLIENT PATH/LIB AND SERVER PATH/LIB

me=$0
orgpar=$@
_exit=0
_verbose=false
_extpath=

while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			_exit=1
			;;
		-v)
			_verbose=true
			;;
		-vv)
			_verbose=detail
			;;
		*)
			[ -z "$_extpath" ] && _extpath=$1 || _extpath="$_extpath $1"
			;;
	esac
	shift
done

if [ $_exit -eq 0 ]; then
	unset _iswin
	_pathsep=":"
	case `uname` in
		Windows_NT)
			_varlist="PATH"
			_iswin=true
			_pathsep=";"
			;;
		AIX)
			_varlist="LIBPATH PATH"
			;;
		SunOS|Linux)
			_varlist="LD_LIBRARY_PATH PATH"
			;;
		HP-UX)
			_varlist="SHLIB_PATH PATH"
			;;
		*)
			echo "Unknown platform."
			exit 1
			;;
	esac
	
	for _var in $_varlist $_extpath; do
		_path=$(eval echo \$$_var)
		[ -z "$_path" ] && continue
		if [ "$_iswin" = "true" ]; then
			_pathtmp=$HOME/.fixpath.tmp.$$
			rm -f $_pathtmp > /dev/null 2>&1
			CMD.EXE /C echo "%$_var%"  > $_pathtmp
			_path=`cat $_pathtmp | sed -e "s/\\\\\\/\\//g"`
			rm -rf $_pathtmp
		else
			_path=$(eval echo \$$_var)
		fi
		[ "$_verbose" = "detail" ] && echo "# $_var:"
		_newpath=${_pathsep}
		while [ -n "$_path" ]; do
			_one=${_path%%${_pathsep}*}
			_path=${_path#*${_pathsep}}
			[ "$_verbose" = "detail" ] && echo "#   $_one"
			if [ -n "$_one" ]; then
				if [ -d "$_one" ]; then
					_fnd=`echo $_newpath | grep "${_pathsep}${_one}${_pathsep}" 2> /dev/null`
					if [ -z "$_fnd" ]; then
						_newpath="${_newpath}${_one}${_pathsep}"
					else
						[ "$_verbose" != "false" ] && echo "#     Duplicated $_one entry($_var)."
					fi
				else
					[ "$_verbose" != "false" ] && echo "#     Missing $_one folder($_var)."
				fi
			fi
			if [ "$_path" = "$_one" ]; then
				_newpath=${_newpath%${_pathsep}}
				_newpath=${_newpath#${_pathsep}}
				break;
			fi
		done
		export $_var="$_newpath"
	[ "$_verbose" = "detail" ] && echo "# -> New $_var=\"$_newpath\""
	done
fi

