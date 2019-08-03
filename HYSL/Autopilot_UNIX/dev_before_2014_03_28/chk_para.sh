#!/usr/bin/ksh
# chk_para.sh <ptn> <string>
# Check and get parameter part from string
# 06/15/2007 YKono - First edition
# 04/09/2008 YKono - Add "[" "]" for the valid param def parentheses
# 07/18/2008 YKono - Add Ignore case feature on srch word.
# 02/11/2009 YKono - Fix the SunOS problem.
#                    SunOS tr command can't accept "a-z" "A-Z" syntax.

# $? = 0:normal
#    = 1:paramter error

[ $# -ne 2 ] && exit 1
_ret=$1; shift; _str=$@
_str=`echo ${_str%%#*} | sed -e "s/(/</g" -e "s/)/>/g" -e "s/\[/</g" -e "s/\]/>/g"`
_str=" ${_str}"
_ochr="<"; _cchr=">"
_ptn=
while [ -n "$_ret" ]; do
	_chr=${_ret%${_ret#?}}
	_ret=${_ret#?}
	_ptn="$_ptn[`echo $_chr | \
		tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz``echo $_chr | \
		tr abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ`]"
done
_ptn=" ${_ptn}${_ochr}"; _ret=

while [ 1 ]; do
	_fnd=${_str#*${_ptn}}
	[ "$_fnd" = "$_str" ] && break
	_par=${_fnd%%${_cchr}*}
	_rst=${_fnd#*${_cchr}}
	if [ "$_par" != "$_fnd" ]; then
		[ -n "$_ret" ] && _ret="$_ret $_par" || _ret=$_par
	fi
	_str=$_rst
done

echo $_ret
