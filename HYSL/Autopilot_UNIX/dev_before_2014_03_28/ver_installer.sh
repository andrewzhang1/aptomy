#!/usr/bin/ksh
# ver_installer.sh : Return the installer kind.
# 
# DESCRIPTION:
# Display the installer kind for each version and build.
#
# SYNTAX:
# ver_installer.sh <ver#> <bld#>
# <ver#> : Essbase version number
# <bld#> : Essbase build number
# -icm   : Ignore CM acceptance result
# 
# RETURN:
# hit     : HIT installer
# cd      : $BUILD_ROOT/<ver>/<bld>/cd/<plat>
# opack   : $BUILD_ROOT/<ver>/<bld>/opack
# install : $BUILD_ROOT/<ver>/<bld>/install/<plat>
#   = 0 : Normal
#   = 1 : Wrong parameter counts.
#
# HISTORY
# 08/01/2008 YK - First Edition.
# 11/05/2008 YK - Add Dickens
# 01/30/2008 YK - Add Talleyrand
# 03/20/2009 YK - Add Zola
# 07/17/2009 YK - New check logic and Add OPACK check
# 06/13/2011 YK - Support incompatible version name like 11.1.1.3.500 and 11.1.1.4
# 07/01/2011 YK - Patch 11.1.2.2.000 to opack

. apinc.sh

v=
b=
icm=
while [ $# -ne 0 ]; do
	case $1 in
		-icm)
			icm="-icm"
			;;
		*)
			if [ -z "$v" ]; then
				v=$1
			else
				b=$1
			fi
			;;
	esac
	shift
done
bld=`normbld.sh $icm $v $b`
if [ $? -ne 0 ]; then
	exit 2
fi
if [ "$1" = "talleyrand_ps1" ]; then
	ver=talleyrand_sp1
else
	ver=$v
fi
if [ -d "$BUILD_ROOT/$ver/$bld/cd" ]; then
	inst=cd
elif [ -d "$BUILD_ROOT/$ver/$bld/install" ]; then
	inst=install
else
	hitloc=`ver_hitloc.sh $v`
	if [ "$hitloc" != "${hitloc%11.1.1.4.0}" ]; then
		inst=hit
	elif [ "$hitloc" != "${hitloc%11.1.2.2.0}" ]; then
		inst=opack
	else
		if [ -d "$BUILD_ROOT/$ver/$bld/opack" ]; then
			inst=opack
		elif [ -d "$BUILD_ROOT/$ver/HIT" ]; then
			inst=hit
		else
			exit 3
		fi
	fi
fi

print -n $inst
exit 0
