#!/usr/bin/ksh
# ver_hitloc.sh : Display HIT base location for each version.
# 
# SYNTAX:
# ver_cmdgq.sh <ver#>
# <ver#> : Essbase version number
# 
# RETURN: HIT location
#
# CALL FROM:
# hitinst.sh
# get_hitlatest.sh
# chg_hit_essver.sh
#
# HISTORY
# 08/01/2008 YK - First Edition.
# 11/05/2008 YK - Add Dickens
# 12/22/2008 YK - Change HIT location with CM prodpost changes
# 01/30/2009 YK - Add Talleyland
# 03/20/2009 YK - Add Zola
# 01/24/2011 YK - Support AP_HITLOC variable
# 05/10/2011 YK - Add 11.1.2.2.000 support.
# 07/10/2013 YK - Support HIT folder name form ver_codename.sh then ver_hitver.sh

. apinc.sh
[ "${HIT_ROOT#${HIT_ROOT%?}}" = "/" ] && export HIT_ROOT=${HIT_ROOT%?}
if [ -n "$AP_HITLOC" ]; then
	if [ "${AP_HITLOC#/}" != "$AP_HITLOC" ]; then
		# Start with /  -- absolute path
		_hitloc=$AP_HITLOC
	else
		if [ "${AP_HITLOC#?:}" != "$AP_HITLOC" ]; then
			# Dos drive letter like C: -- absolute path
			_hitloc=$AP_HITLOC
		else
			# Relative path 
			_hitloc=$HIT_ROOT/$AP_HITLOC
		fi
	fi
else
	_hitloc=$HIT_ROOT/prodpost
fi
		
if [ $# -ne 1 ]; then
	echo "#PAR"
	echo "ver_hitloc.sh <ver#>"
	exit 1
fi
if [ "$1" = "baselocation" ]; then
	echo "$_hitloc"
else
	_codename=`ver_codename.sh $1`
	if [ -d "$_hitloc/$_codename" ]; then
		echo "$_hitloc/$_codename"
	else
		_codename=`ver_hitver.sh $_codename`
		if [ -d "$_hitloc/$_codename" ]; then
			echo "$_hitloc/$_codename"
		else
			echo "not_ready"
		fi
	fi
fi
unset _hitloc

