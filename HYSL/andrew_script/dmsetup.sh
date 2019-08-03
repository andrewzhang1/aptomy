##################################################################################
# Setup JDK 1.4 for Data Mining
# Test Script: 		 dmsetup.sh (subset of agsycss_J14_new.sh)
# Purposes: 		 Test Data Mining.  This script will setup the JAVA
#                        environment for all the different platforms
#
# Updated:  
# By Van Gee 
#
# 12/03/04: Updated for set java env with verison 1.4.2 under HYPERION_HOME/common
# By Andrew Zhang 
#
# 3/22/05 Andrew Zhang: Update for 64bit Essbase 714
#			This one can be used for both 32bit and 64bits on all platforms.
#
#                       For 64bit HP, the jvm is pointed to:
#                       $HYPERION_HOME/common/JRE-IA64/HP/1.4.2/lib/IA64W/server/libjvm.so
#
#                       For 64bit Windows, the jvm is pointed to:
#                       $HYPERION_HOME/common/JRE-IA64/Sun/1.4.2/bin/server/jvm.dll
#                       
#			Other changes: the 64bit HP does not require the LD_PRELOAD settings
#			for starting Essbase.
#
# 06/14/2006 Andrew Zhang: Update for the jre 1.5.0 for beckett
#	     Note: Only Windows 64-bits still use JRE 1.4.2
#
# 01/30/2006 Rumitkar Kumar: Updated to support winamd64
#
# 05/29/2007 Van Gee:  Updated to support 64bit AIX and Solaris
# 
# 01/29/2008 Andrew Zhang: Modified to support 64bits LinuxAMD 
###################################################################################

sxr agtctl start

#  Save essbase.cfg if one exist 
sxr esscmd -q msxxcopycfgfile.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %OLDFILE=essbase.cfg \
                           %NEWFILE=essbase.cfg.sxr


##################################################################
# Set environment
##################################################################

if [ "`echo $PROCESSOR_ARCHITEW6432`" = "IA64" ]
then

export PROGPATH=`echo $HYPERION_HOME | tr '\\' '/'`
export JAVAHOME="$PROGPATH/common/JRE-IA64/Sun/1.4.2"
export PATH="$JAVAHOME/bin/server;$JAVAHOME/bin;$PATH"

echo "JVMModuleLocation  $JAVAHOME/bin/server/jvm.dll" >  append.cfg
elif  [ "${SXR_PLATFORM}" = "nta" ]; then
	export JAVAHOME="$HYPERION_HOME/common/JRE-AMD64/Sun/1.6.0"
	export PATH="$JAVAHOME/bin/server;$JAVAHOME/bin;$PATH"
	echo "JVMModuleLocation $JAVAHOME/bin/server/jvm.dll" > append.cfg
elif [ `uname` = Windows_NT ]
then

#  Found that NT doesn't use the ProgramFiles var
export PROGPATH=`echo $HYPERION_HOME | tr '\\' '/'`
export JAVAHOME="$PROGPATH/common/JRE/Sun/1.6.0"
export PATH="$JAVAHOME/bin/client;$JAVAHOME/bin;$PATH"

echo "JVMModuleLocation  $JAVAHOME/bin/client/jvm.dll" >  append.cfg

elif [ `uname -m` = "ia64" ]
then

export JAVAHOME="$HYPERION_HOME/common/JRE-IA64/HP/1.6.0"
export SHLIB_PATH="$JAVAHOME/lib/IA64W/server:$JAVAHOME/lib/IA64W:$SHLIB_PATH"
export PATH="$JAVAHOME/bin:$PATH"

echo "JVMModuleLocation   $JAVAHOME/lib/IA64W/server/libjvm.so" > append.cfg

elif [ `uname` = HP-UX ]
then
export JAVAHOME="$HYPERION_HOME/common/JRE/HP/1.6.0"

export SHLIB_PATH="$JAVAHOME/lib/PA_RISC2.0/server:$JAVAHOME/lib/PA_RISC2.0:$SHLIB_PATH"
export PATH="$JAVAHOME/bin:$PATH"

echo "JVMModuleLocation   $JAVAHOME/lib/PA_RISC2.0/server/libjvm.sl" > append.cfg

elif [ `uname` = SunOS ]
then
if [ $SXR_64BIT = 1 ]
then
export JAVAHOME="$HYPERION_HOME/common/JRE-64/Sun/1.6.0"
export LD_LIBRARY_PATH="$JAVAHOME/lib/sparcv9/server:$JAVAHOME/lib/sparcv9:$LD_LIBRARY_PATH"
echo "JVMModuleLocation   $JAVAHOME/lib/sparcv9/server/libjvm.so" > append.cfg
else
export JAVAHOME="$HYPERION_HOME/common/JRE/Sun/1.6.0"
export LD_LIBRARY_PATH="$JAVAHOME/lib/sparc/server:$JAVAHOME/lib/sparc:$LD_LIBRARY_PATH"
echo "JVMModuleLocation   $JAVAHOME/lib/sparc/server/libjvm.so" > append.cfg
fi
export PATH="$JAVAHOME/bin:$PATH"
export ESS_JVM_OPTION2=-Xusealtsigs 


elif [ `uname` = AIX ]
then
if [ $SXR_64BIT = 1 ]
then
export JAVAHOME="$HYPERION_HOME/common/JRE-64/IBM/1.6.0"
else
export JAVAHOME="$HYPERION_HOME/common/JRE/IBM/1.6.0"
fi
export LIBPATH="$JAVAHOME/bin/classic:$JAVAHOME/bin:$LIBPATH"
export PATH="$JAVAHOME/bin:$PATH"

echo "JVMModuleLocation   $JAVAHOME/bin/classic/libjvm.so" > append.cfg

elif [ `uname` = Linux ]
then
if [ $SXR_64BIT = 1 ]
then
export JRE_HOME="$HYPERION_HOME/common/JRE-64/Sun/1.6.0"
export LD_LIBRARY_PATH="$JRE_HOME/lib/amd64/server:$JRE_HOME/lib/amd64:$LD_LIBRARY_PATH"
export PATH="$JRE_HOME/bin:$PATH"
else
export JRE_HOME="$HYPERION_HOME/common/JRE/Sun/1.6.0"
export LD_LIBRARY_PATH="$JRE_HOME/lib/i386/server:$JRE_HOME/lib/i386:$LD_LIBRARY_PATH"
export PATH="$JRE_HOME/bin:$PATH"
#echo "JVMModuleLocation $JRE_HOME/lib/i386/server/libjvm.so" > append.cfg
fi

fi
#  Append JVMModuleLocation
sxr esscmd -q msxxsendcfgfile.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %CFGFILE=append.cfg

sxr agtctl stop

####################################################################
#
# This is to fix HP problem for some jre1.4 issues for 32bit ONLY!
#
######################################################################

if  [ `uname` = HP-UX ]  && [ `uname -m` != "ia64" ] 
then
export LD_PRELOAD="$JAVAHOME/lib/PA_RISC2.0/server/libjsig.sl:\
$JAVAHOME/lib/PA_RISC2.0/server/libjvm.sl"

ESSBASE password -b &
unset LD_PRELOAD

else
	sxr agtctl start
fi

