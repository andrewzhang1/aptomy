#!/usr/bin/ksh
# ver_cmdgq.sh : Return the location where contains ESSCMDQ/G.
# 
# DESCRIPTION:
# Display the location where contains ESSCMDQ/G relateed modules.
# (tar file's relative location from $VER folder.)
# The retuned path is relative path from $BUILD_ROOT/<ver>/<bld>
#
# SYNTAX:
# ver_cmdgq.sh <ver#>
# <ver#> : Essbase version number
# 
# RETURN:
#   = 0 : Normal
#   = 1 : Wrong parameter counts.
#
# CALL FROM:
# hyslinsst.sh : (Check build folder)
# 
# HISTORY
# 08/01/2008 YK - First Edition.
# 11/05/2008 YK - Add Dickes
# 01/30/2009 YK - Add talleyrand
# 03/20/2009 YK - Add Zola
# 12/22/2009 YK - Modify hpux->hpuxia32

if [ $# -ne 1 ]; then
	echo "#PAR"
	echo "ver_cmdgq.sh <ver#>"
	exit 1
fi

plat=`get_platform.sh`
case $1 in
	5*|6*|7*| \
	london|joyce|joyce_dobuild|tide| \
	zephyr|tsunami|woodstock|9.0*|9.2*)
		if [ `uname` = "Windows_NT" ]; then
			if [ "$ARCH" = "64" -o "$ARCH" = "64M" ]; then
				echo "server/win64/opt"
			else
				echo "server/Nti/opt"
			fi
		else
			echo "server/$plat/opt"
		fi
		;;
	9.3*|zola_staging|beckett|kennedy2|kennedy|9.5.0.0.0|11.1.1.0.*|dickens|11.1.1.2.*|11.1.1.1.*|zola|11.1.1.3.*)
		echo $plat | tr -d '\r'
		;;

	*)	# Other version
	# talleyrand|11.1.2.0.0)
		# if [ "$plat" = "hpux" ]; then
		# 	plat=hpuxia32
		# fi
		echo $plat 
		;;
esac

