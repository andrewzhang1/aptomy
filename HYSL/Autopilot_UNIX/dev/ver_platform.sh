# !/usr/bin/ksh
# ver_platfrom.sh : Define the platform related variables
# Syntax: ver_platform.sh $ver
# History:
# 2013/06/25	YKono	First edition

plat=`get_platform.sh`
unset _LIBPATH
case $plat in
	aix*)	export _LIBPATH="LIBPATH";;
	solar*|linux*)	export _LIBPATH="LD_LIBRARY_PATH";;
	hpux*)	export _LIBPATH="SHLIB_PATH";;
	win*)	export _LIBPATH="PATH";;
esac
_PL_LIBLIST="\$ODBC_HOME/lib"
_PL_PATHLIST="\$JAVA_HOME/bin"
case $plat in)
	aix*)
		_JAVALIB="bin bin/classic"
		;;
	solaris)
		_JAVALIB="lib/sparc/server lib/sparc"
		;;
	solaris64)
		_PL_LIBLIST="$_PL_LIBLIST \$JAVA_HOME/lib/sparc/server \$JAVA_HOME/ib/sparc"
	


