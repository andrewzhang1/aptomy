#!/usr/bin/ksh
# ver_essinit.sh : Set variables for essbase initialization.
# 
# DESCRIPTION:
# Set following variables which are required for initializing Essbase.
# _VER_LICMODE : License mode (reg/none or lic-filename)
# _VER_DBL_PWD : The double password flag for the Essbase
#                initilalization on Unix platforms.
#
# SYNTAX:
# ver_essinit.sh <ver#> <bld#>
# <ver#> : Essbase version number
# <bld#> : Essbase build number
# note: Those are numbers are returned from get_ess_ver.sh
# 
# CALL FROM:
# ap_essinit.sh:
#
# HISTORY
# 08/01/2008 YK - First Edition.
# 11/05/2008 YK - Add Dickens
# 03/20/2009 YK - Add Talleyrand and Zola

# _VER_LICMODE
case $1 in
	9.2.1.0.0|9.2/9.2.1.0.0)
		_VER_LICMODE="reg"
		;;
	#7.1.6*|7.1/7.1.6*)
	#	_VER_LICMODE="none"
	#	;;
	5*|6*|7*|tide|zephyr|tsunami|woodstock)
		_VER_LICMODE="hyslinternal.71"
		;;
	9.3*|beckett)
		if [ "$1" = "9.3.1.0.0" ]; then
			if [ "$2" -lt 118 ]; then
				_VER_LICMODE="hyslinternal.90"
			elif [ "$2" -lt 182 ]; then
				_VER_LICMODE="reg"
			else
				_VER_LICMODE="none"
			fi
		else
			_VER_LICMODE="hyslinternal.90"
		fi
		;;
	london|joyce|joyce_dobuild|9.0*|9.2*)
		_VER_LICMODE="hyslinternal.90"
		;;
	kennedy|9.5.0.0.0)
		if [ "$$2" -lt 200 ]; then
			_VER_LICMODE="reg"
		else
			_VER_LICMODE="none"
		fi
		;;
	*)	# default
		# kennedy2n 11.1.1.1.1
		# dickens
		# talleyrand 11.1.2.0.0
		# zola 11.1.1.3.0
		_VER_LICMODE="none"
		;;
esac

# _VER_DBL_PWD
case $1 in
	5*|6*|7*| \
	london|joyce|joyce_dobuild|tide| \
	zephyr|tsunami|woodstock|beckett|9.0*|9.2*|9.3.1.*)
		_VER_DBL_PWD=false
		;;
	9.3*)
		_VER_DBL_PWD=true
		;;
	kennedy|9.5.*|11.1.1.0.0)
		if [ "$2" -ge 438 ]; then
			_VER_DBL_PWD=true
		else
			_VER_DBL_PWD=false
		fi
		;;
	*)	# other new version
		# kennedy2 11.1.1.1.1
		# dickens
		# talleyrand
		# zola
		_VER_DBL_PWD=true
		;;
esac

