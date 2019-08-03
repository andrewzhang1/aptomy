#!/usr/bin/ksh
# ver_hitloc.sh : Display HIT base location for each version.
# 
# SYNTAX:
# ver_cmdgq.sh <ver#>
# <ver#> : Essbase version number
# 
# RETURN: HIT relative location from $HIT_ROOT/prodpost
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
	case $_codename in
		11.1.2.3.000)
			_codename=11.1.2.3.0;;
		11.1.2.2.000|11.1.2.2.0|11.1.2.2.100)
			_codename=11.1.2.2.0;;
	esac
	if [ -d "$_hitloc/$_codename" ]; then
		echo "$_hitloc/$_codename"
	else
		echo "not_ready"
	fi
fi
unset _hitloc

## case $1 in
## 	kennedy|9.5.0.0.0|11.1.1.0.0)
## 		echo "prodpost/kennedy" | tr -d '\r'
## 		;;
## 	5*|6*|7*|9*|\
## 	joyce|london|tide|tsunami|vista|zephyr|woodstock|beckett)
## 		echo not_ready | tr -d '\r'
## 		;;
## 	kennedy2|11.1.1.1.0)
## 		# echo "prodpost" | tr -d '\r'
## 		echo "prodpost/kennedy2" | tr -d '\r'
## 		;;
## 	dickens|11.1.1.2.0)
## 		echo "prodpost/dickens" | tr -d '\r'
## 		;;
## 	talleyrand|11.1.2.0.0)
## 		echo "prodpost/talleyrand" | tr -d '\r'
## 		;;
## 	talleyrand_sp1|11.1.2.1.0)
## 		echo "prodpost/talleyrand_sp1" | tr -d '\r'
## 		;;
## 	zola|11.1.1.3.0.0)
## 		echo "prodpost/zola" | tr -d '\r'
##  		;;
## 	*)
## 		echo "prodpost" | tr -d '\r'
## 		;;
## esac
