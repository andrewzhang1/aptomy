#!/bin/ksh

##############################################################################
#
# Script Name: installer_7.2.5.0.sh
# Script Duty: Installs ESB, EDS, EAS, and SVP 7.2.5 builds. 
# Author: Tuan M. Mai
# Date: 06/28/2006
# Note: Only EAS is modified to install 7.2.5.0, since only EAS comparison is needed between
#       7.2.5.0 and 7.2.5.1
##############################################################################

export INSTALL_PRODUCT=$1
export INSTALL_BUILD=$2
export INSTALL_OSP=$3

INFILE_DIR="$HOME/bin/infiles/7.1"

#### install Essbase ####

if [ "$INSTALL_PRODUCT" = "ESB" ] ; then
	
	ESB_BUILD=$BUILD_ROOT/essbase/builds/7.2.5.0/$INSTALL_BUILD/cd/$INSTALL_OSP

	echo "Installing Essbase from $ESB_BUILD...."

	if [ "$INSTALL_OSP" = "win32" -o "$INSTALL_OSP" = "win64" ] ; then
		$ESB_BUILD/server/setup.exe -options $INFILE_DIR/esbinstsq_win.txt -silent
		$ESB_BUILD/client/setup.exe -console < $INFILE_DIR/esbclient_win.txt
	else
		if [ "$INSTALL_OSP" = "linux" ] ; then
			$ESB_BUILD/server/setup.bin -console < $INFILE_DIR/esbinstsq_linux.txt
			$ESB_BUILD/client/setup.bin -console < $INFILE_DIR/esbclient_linux.txt
		else	
			$ESB_BUILD/server/setup.bin -console < $INFILE_DIR/esbinstsq_unix.txt
			$ESB_BUILD/client/setup.bin -console < $INFILE_DIR/esbclient_unix.txt 
		fi
	fi	
	[ $? -ne 0 ] && exit $?
fi

#### install EAS ####

if [ "$INSTALL_PRODUCT" = "EAS" ] ; then
	EAS_BUILD=$BUILD_ROOT/EAS/builds/7.2.5.0/$INSTALL_BUILD/install/$INSTALL_OSP	
	echo "Installing EAS from $EAS_BUILD..."

	if [ "$INSTALL_OSP" = "win32" -o "$INSTALL_OSP" = "win64" ] ; then
		$EAS_BUILD/setup.exe -options $INFILE_DIR/easinstsq_win.txt -silent
	else
		$EAS_BUILD/setup.bin -console < $INFILE_DIR/easinstsq_unix.txt	
		#$EAS_BUILD/setup.bin -console
	fi
	[ $? -ne 0 ] && exit $?	
fi


##### install EDS #####

if [[ "$INSTALL_PRODUCT" = "EDS" ]] ; then
	EDS_BUILD=$BUILD_ROOT/eesdev/eds/builds/7.1.5.0/$INSTALL_BUILD/install/$INSTALL_OSP
	echo "Installing EDS from $EDS_BUILD..."


	if [ "$INSTALL_OSP" = "win32" -o "$INSTALL_OSP" = "win64" ] ; then
		$EDS_BUILD/setup.exe -options $INFILE_DIR/edsinstsq_win.txt -silent 
	else
		#if [ "$INSTALL_OSP" = "linux" ] ; then
		#	$EDS_BUILD/setup.bin -console < $INFILE_DIR/edsinstsq_linux.txt 
		#else
			$EDS_BUILD/setup.bin -console < $INFILE_DIR/edsinstsq_unix.txt
		#fi
	fi
	[ $? -ne 0 ] && exit $?	
fi


##### install SVP #####

if [[ "$INSTALL_PRODUCT" = "SVP" ]] ; then
	SVP_BUILD=$BUILD_ROOT/eesdev/provider/builds/7.1.5.0/$INSTALL_BUILD/install/$INSTALL_OSP
	echo "Installing SVP from $SVP_BUILD..."

	if [ "$INSTALL_OSP" = "win32" -o "$INSTALL_OSP" = "win64" ] ; then
		$SVP_BUILD/setup.exe -options $INFILE_DIR/svpinstsq_win.txt -silent
	else
		$SVP_BUILD/setup.bin -console < $INFILE_DIR/svpinstsq_unix.txt
	fi
	[ $? -ne 0 ] && exit $?
fi