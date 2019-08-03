#######################################################################
# File: chk_version.sh
# Author: Yukio Kono
# Description: Check the directory structure is old or new by version
#######################################################################
# History:
# 09/06/2007 YK Fist edition. 

if [ $# -ne 1 ]; then
	exit 1
else
	case ${1##*/} in
		5*|6*|7*| \
		london|joyce|joyce_dobuild|tide| \
		zephyr|tsunami|woodstock|9.0*|9.2*)
			echo "OLD"
			;;
		*)	# 9.3|beckett|kennedy ...
			echo "NEW"
	esac
	exit 0
fi
