#!/usr/bin/ksh
# ver_cmstrct.sh : Get CM structure mode.
# 
# DESCRIPTION:
# Some scripts need to access to some files under the pre_rel foler.
# This script tell them the CM structure mode is old or new.
#
# SYNTAX:
# ver_cmstrct.sh <ver#>
# <ver#> : Version number in fulll/short format.
#
# RETURN:
#   = 0 : Normal
#   = 1 : Wrong parameter counts.
#
# CALL FROM:
# cdinst.sh : (check old)
#   Check the Unix platform has the client installer or not.
#   Old Unix platfrom doesn't has the client installer.
#   We don't care aobut most recent installer. Because most recent product
#   uses HIT installer. HIT is not covered by this script.
# setchk_env.sh: (check old/hyp)
#   Check $ARCH value on Solaris and AIX platforms, when it's not old.
#   Check $ARCH value on Linux platform.
# 
# HISTORY
# 08/01/2008 YK - First Edition.
# 11/05/2008 YK - Add dickens (new)

if [ $# -ne 1 ]; then
	echo "#PAR"
	echo "ver_codename.sh <ver#>"
	exit 1
fi

case $1 in
	5*|6*|7*| \
	london|joyce|joyce_dobuild|tide| \
	zephyr|tsunami|woodstock|9.0*|9.2*)
		echo old ;;	# for old Arbor and early Hyperion day
	kennedy|9.3*|11.1.1.1.1)
		echo hyp ;;	# for Hyperion day - 64/32 for Solaris/AIX
	*)	echo new ;;	# Add linuxamd64 from Kennedy2 to Dickens
								# Talleyrand 11.1.2.0.0
								# Zola 11.1.1.3.0
esac

exit 0
