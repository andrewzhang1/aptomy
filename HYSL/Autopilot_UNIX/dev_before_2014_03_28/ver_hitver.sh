#!/usr/bin/ksh
# ver_hitver.sh : Display the expected version string in essbase_version.xml
# 
# DESCRIPTION:
# Display the expected version string in essbase_version.xml
#
# SYNTAX:
# ver_cmdgq.sh <ver#>
# <ver#> : Essbase version number
# 
# RETURN:
# hit     : HIT installer
# cd      : $BUILD_ROOT/<ver>/<bld>/cd/<plat>
# install : $BUILD_ROOT/<ver>/<bld>/install/<plat>
#   = 0 : Normal
#   = 1 : Wrong parameter counts.
#
# CALL FROM:
# hitinst.sh
# 
# HISTORY
# 08/01/2008 YK - First Edition.
# 11/05/2008 YK - Add Dickens
# 03/20/2009 YK - Add Talleyrand and Zola
# 12/21/2012 YK - Add 11.1.2.3.000
# 07/10/2013 YK - Add support for #.#.#.#.000 to #.#.#.#.0
# 07/29/2013 YK - Bug 17236343 - FAILED TO GET CORRECT HIT BASE VERSION ON VER_HITVER.SH.

if [ $# -ne 1 ]; then
	echo "#PAR"
	echo "ver_hitver.sh <ver#>"
	exit 1
fi
unset _VER_HITVER
unset _VER_ESSBASECLIENT

case $1 in
	11.1.2.3.*)
		export _VER_HITVER="11.1.2.3.0"
		[ "`uname`" = "Windows_NT" ] && export _VER_ESSBASECLIENT=EssbaseClient/EssbaseClient.exe
		;;
	11.1.2.2.*)
		export _VER_HITVER="11.1.2.2.0"
		[ "`uname`" = "Windows_NT" ] && export _VER_ESSBASECLIENT=EssbaseClient/EssbaseClient.exe
		;;
	talleyrand_sp1_269a|talleyrand_sp1|11.1.2.1.0)
		export _VER_HITVER="11.1.2.1.0"
		;;
	talleyrand|11.1.2.0.0)
		export _VER_HITVER="11.1.2.0.0"
		;;
	11.1.1.3.500)
		export _VER_HITVER="11.1.1.4.0"
		;;
	zola|11.1.1.3.0)
		export _VER_HITVER="11.1.1.3.0"
		;;
	zola_staging|11.1.1.3.1)
		export _VER_HITVER="11.1.1.3.1"
		;;
	dickens|11.1.1.2.0)
		export _VER_HITVER="11.1.1.2.0"
		;;
	kennedy2|11.1.1.1.0)
		export _VER_HITVER="11.1.1.1.0"
		;;
	kennedy|9.5.0.0.0|11.1.1.0.0)
		export _VER_HITVER="9.5.0.0.0 11.1.1.0.0"
		;;
	5*|6*|7*|9*|\
	joyce|london|tide|tsunami|vista|zephyr|woodstock|beckett)
		export _VER_HITVER=not_ready
		;;
	*)
		lastdig=${1##*.}
		if [ "$lastdig" = "000" ]; then	# This support x.x.x.x.000 to x.x.x.x.0
			export _VER_HITVER="${1%.000}.0"
		else
			export _VER_HITVER=$1
		fi
		[ "`uname`" = "Windows_NT" ] && export _VER_ESSBASECLIENT=EssbaseClient/EssbaseClient.exe
		;;
esac
echo $_VER_HITVER | tr -d '\r'

