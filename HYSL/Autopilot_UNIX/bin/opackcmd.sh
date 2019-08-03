#!/usr/bin/ksh
#######################################################################
# File: opackcmd.sh
# Author: Yukio Kono
# Description: Run opack command in autopilot framework
#              -oh and -jre is automatically apply by this command.
# Syntax: opackcmd.sh <cmd>....
#######################################################################
# Out:
#    1: No HYPERION_HOME defined.
#    2: No hpatch or opatch command exists.
#######################################################################
# History:
# 02/26/2011 YK Fist edition.
# 05/24/2011 YK Add -invPtrLoc
# 04/17/2012 YK Fix AIX64 problem -> use 32 JRE

display_help()
{
	echo "opackcmd.sh <cmd>...."
	echo "Description: Run opatch command."
	echo "Parameter:"
	echo "  <cmd>  : opatch command."
}

# Check environment
if [ ! -d "$HYPERION_HOME" ]; then
	echo "No \$HYPERION_HOME($HYPERION_HOME) folder exists."
	exit 1
fi
if [ ! -d "$HYPERION_HOME/OPatch" ]; then
	echo "No \$HYPERION_HOME/OPatch fodler.($HYPERION_HOME)"
	exit 2
fi

#######################################################################
# Read parameter
if [ $# -eq 1 -a "$1" = "-h" ]; then
	display_help
	exit 0
fi

thisplat=`get_platform.sh`
mysts=0

cd $HYPERION_HOME/OPatch
# Check patch command file exist or not.
if [ "${thisplat#win}" != "$thisplat" ]; then
	patchcmds="opatch.bat hpatch.bat"
else
	patchcmds="opatch hpatch.sh"
fi
unset patchcmd
for one in $patchcmds; do
	if [ -x "$HYPERION_HOME/OPatch/$one" ]; then
		patchcmd=$one
		break
	fi
done
if [ -z "$patchcmd" ]; then
	echo "There is no $patchcmds files under $HYPERION_HOME/OPatch folder."
	exit 3
fi

if [ "${thisplat#win}" != "$thisplat" ]; then
	if [ -f "$HYPERION_HOME/oraInst.loc" ]; then
		invdir=`echo $HYPERION_HOME/oraInst.loc | sed -e "s/\//\\\\\/g"`
	elif [ -f "$HOME/oraInst.loc" ]; then
		invdir=`echo $HOME/oraInst.loc | sed -e "s/\//\\\\\/g"`
	else
		invdir=
	fi
	hhback=$HYPERION_HOME
	hhdir=`echo $HYPERION_HOME | sed -e "s/\//\\\\\/g"`
	export HYPERION_HOME=$hhdir
	jhdir=`echo $JAVA_HOME | sed -e "s/\//\\\\\/g"`
	if [ -n "$invdir" ]; then
		cmd.exe /c ${patchcmd} $@ \
			-oh "$hhdir" \
			-invPtrLoc "$invdir" \
			-jre "$jhdir" 
		sts=$?
	else
		cmd.exe /c ${patchcmd} $@ \
			-oh "$hhdir" \
			-jre "$jhdir" 
		sts=$?
	fi
	export HYPERION_HOME=$hhback
else
	# Set 32 bit JRE for AIX or Linuxx86_64 (This is came from hpatch.sh)
	unset _32mode
	if [ "`uname`" = "AIX" -o "`uname``uname -m`" = "Linuxx86_64" ]; then
		_jh=`echo $JAVA_HOME | sed -e "s!common/JRE-64!common/JRE!g"`
		if [ -d "$_jh" ]; then
			export JAVA_HOME="$_jh"
		fi
	fi
	if [ -r "$HYPERION_HOME/oraInst.loc" ]; then
echo "./${patchcmd} $@ -oh \"$HYPERION_HOME\" -jre \"$JAVA_HOME\" -invPtrLoc $HYPERION_HOME/oraInst.loc"
		./${patchcmd} $@ \
			-oh "$HYPERION_HOME" \
			-jre "$JAVA_HOME" \
			-invPtrLoc $HYPERION_HOME/oraInst.loc
		sts=$?
	elif [ -r "$HOME/oraInst.loc" ]; then
echo "./${patchcmd} $@ -oh \"$HYPERION_HOME\" -jre \"$JAVA_HOME\" -invPtrLoc $HOME/oraInst.loc"
		./${patchcmd} $@ \
			-oh "$HYPERION_HOME" \
			-jre "$JAVA_HOME" \
			-invPtrLoc $HOME/oraInst.loc
		sts=$?
	else
echo "./${patchcmd} $@ -oh \"$HYPERION_HOME\" -jre \"$JAVA_HOME\""
		./${patchcmd} $@ \
			-oh "$HYPERION_HOME" \
			-jre "$JAVA_HOME"
		sts=$?
	fi
fi
exit $sts

