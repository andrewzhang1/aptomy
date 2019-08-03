#!/usr/bin/ksh
# ver_codename.sh : Convert version number to code name.
# 
# DESCRIPTION:
# This script convert the version number to the real folder name 
# (code name) in the pre_rel/essbase/builds.
#
# SYNTAX:
# ver_codename.sh <ver#>
# <ver#> : Version number in essbase_version.xml or from ESSCMD
#
# RETURN:
#   = 0 : Normal
#   = 1 : Wrong parameter counts.
#
# CALL FROM:
# chg_hit_essver.sh :
#   Convert the version number described in HIT/essbase_version.xml
# get_ess_ver.sh :
#   Convert the version number displayed by ESSCMD's openning MSG
#   followed "(ESB" prefix.
#   > Essbase Command Mode Interface - Release 11.1.1 (ESB11.1.1.1.0B033)
#   in Some version, it's displayed without dot characters as below:
#   > Essbase Command Mode Interface - Release 7.1.6 (ESB7167B002)
#   but caller add the dot characters between each digits like this:
#   > 7.1.6.7
#
# HISTORY
# 08/01/2008 YK - First Edition.
# 11/05/2008 YK - Add Dickens
# 03/20/2009 YK - Add Talleyrand and Zola
# 12/26/2012 YK - Add 11.1.2.3.0
# 07/10/2013 YK - Add 11.1.2.4.0

if [ $# -ne 1 ]; then
	echo "#PAR"
	echo "ver_codename.sh <ver#>"
	exit 1
fi

case $1 in
	11.1.2.4.000|11.1.2.4.0)	echo 11.1.2.4.000 ;;
	11.1.2.3.000|11.1.2.3.0)	echo 11.1.2.3.000 ;;
	11.1.2.2.000|11.1.2.2.0)	echo 11.1.2.2.000 ;;
	11.1.2.1.0)			echo talleyrand_sp1 ;;
	11.1.2.0.0)			echo talleyrand ;;
	11.1.1.3.50*)			echo 11.1.1.4.0 ;;
	11.1.1.3.1)			echo zola_staging ;;
	11.1.1.3.0)			echo zola ;;
	11.1.1.2.0)			echo dickens ;;
	11.1.1.1.0)			echo kennedy2 ;;
	9.5.0.0.0|11.1.1.0.0)	echo kennedy ;;
	9.3)					echo beckett ;;
	9.0.1.0)				echo london ;;
	9.0)					echo joyce ;;
	6.1)					echo tide ;;
	6.2)					echo tsunami ;;
	7.0)					echo zephyr ;;
	6.5)					echo woodstock ;;
	*)					echo $1 | tr -d '\r';;
esac
