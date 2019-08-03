#!/bin/ksh

##############################################################################
#
# Script Name: installer_manual.sh
# Script Duty: Installs ESB, EDS, EAS, and SVP builds manually.
# Author: Tuan M. Mai
# Date: 07/24/2006
#
##############################################################################

export INSTALL_PRODUCT=$1
export INSTALL_BRANCH=$2
export INSTALL_BUILD=$3
export INSTALL_OSP=$4
export INSTALL_ESB_OSP=$4

#### install Essbase ####

if [ "$INSTALL_PRODUCT" = "ESB" ] ; then
	
	if [ "$INSTALL_BRANCH" = "beckett" -o "$INSTALL_BRANCH" = "beckett_beta" ] ; then
		if [ "$INSTALL_OSP" = "solaris" ] ; then
			INSTALL_OSP
		ESB_BUILD=$BUILD_ROOT/essbase/builds/$INSTALL_BRANCH/$INSTALL_BUILD/install/$INSTALL_OSP
	else
		ESB_BUILD=$BUILD_ROOT/essbase/builds/$INSTALL_BRANCH/$INSTALL_BUILD/cd/$INSTALL_OSP
	fi

	echo "Installing Essbase from $ESB_BUILD...."

	if [ "$INSTALL_OSP" = "win32" -o "$INSTALL_OSP" = "win64" ] ; then
		$ESB_BUILD/server/setup.exe -options $INFILE_DIR/esbinstsq_win.txt -silent
		$ESB_BUILD/client/setup.exe -console < $INFILE_DIR/esbclient_win.txt
	else
		if [ "$INSTALL_OSP" = "linux" ] ; then
			$ESB_BUILD/server/setup.bin -console
			$ESB_BUILD/client/setup.bin -console
		else	
			$ESB_BUILD/server/setup.bin -console
			$ESB_BUILD/client/setup.bin -console
		fi
	fi	
	[ $? -ne 0 ] && exit $?
fi

#### install EAS ####

if [ "$INSTALL_PRODUCT" = "EAS" ] ; then
	EAS_BUILD=$BUILD_ROOT/EAS/builds/$INSTALL_BRANCH/$INSTALL_BUILD/install/$INSTALL_OSP	
	echo "Installing EAS from $EAS_BUILD..."

	echo "HYPERION_HOME=$HYPERION_HOME"


	if [ "$INSTALL_OSP" = "win32" -o "$INSTALL_OSP" = "win64" ] ; then
		$EAS_BUILD/setup.exe -options $INFILE_DIR/easinstsq_win.txt -silent
	else
		#if [ "$INSTALL_OSP" = "linux" ] ; then
		#	echo "Installing on Linux system..."
		#	$EAS_BUILD/setup.bin -console < $INFILE_DIR/easinstsq_linux.txt	
		#else
			$EAS_BUILD/setup.bin -console
		#fi
	fi
	[ $? -ne 0 ] && exit $?	
fi


##### install EDS #####

if [[ "$INSTALL_PRODUCT" = "EDS" ]] ; then
	EDS_BUILD=$BUILD_ROOT/eesdev/eds/builds/$INSTALL_BRANCH/$INSTALL_BUILD/install/$INSTALL_OSP
	echo "Installing EDS from $EDS_BUILD..."


	if [ "$INSTALL_OSP" = "win32" -o "$INSTALL_OSP" = "win64" ] ; then
		$EDS_BUILD/setup.exe -options $INFILE_DIR/edsinstsq_win.txt -silent 
	else
		#if [ "$INSTALL_OSP" = "linux" ] ; then
		#	$EDS_BUILD/setup.bin -console < $INFILE_DIR/edsinstsq_linux.txt 
		#else
			$EDS_BUILD/setup.bin -console
		#fi
	fi
	[ $? -ne 0 ] && exit $?	
fi


##### install SVP #####

if [[ "$INSTALL_PRODUCT" = "SVP" ]] ; then
	SVP_BUILD=$BUILD_ROOT/eesdev/provider/builds/$INSTALL_BRANCH/$INSTALL_BUILD/install/$INSTALL_OSP
	echo "Installing SVP from $SVP_BUILD..."

	if [ "$INSTALL_OSP" = "win32" -o "$INSTALL_OSP" = "win64" ] ; then
		$SVP_BUILD/setup.exe -options $INFILE_DIR/svpinstsq_win.txt -silent
	else
		$SVP_BUILD/setup.bin -console
	fi
	[ $? -ne 0 ] && exit $?
fi
