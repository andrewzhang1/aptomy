#!/bin/ksh

##############################################################################
#
# Script Name: installer_beckett_beta.sh
# Script Duty: Installs ESB, EDS, EAS, and SVP Beckett Beta builds. 
# Author: Tuan M. Mai
# Date: 05/05/2006
#
##############################################################################

export INSTALL_PRODUCT=$1
export INSTALL_BUILD=$2
export INSTALL_OSP=$3
export ESB_INSTALL_OSP=$INSTALL_OSP

if [ "$INSTALL_OSP" = "solaris" ] ; then
	echo "Switching solaris to sol64 for Essbase Beckett Beta..."
	export ESB_INSTALL_OSP="sol64"	
fi

if [ "$INSTALL_OSP" = "aix" ] ; then
	echo "Switch aix to aix64 for Essbase Beckett Beta..."
	export ESB_INSTALL_OSP="aix64"
fi

if [ "$INSTALL_OSP" = "linux" ] ; then
	echo "Switch linux to lnx for Essbase Beckett Beta..."
	export ESB_INSTALL_OSP="lnx"
fi

INFILE_DIR="$HOME/bin/infiles/9.2"

#### install Essbase ####

if [ "$INSTALL_PRODUCT" = "ESB" ] ; then
	ESB_BUILD=$BUILD_ROOT/essbase/builds/beckett_beta/$INSTALL_BUILD/install/$ESB_INSTALL_OSP

	echo "Installing Essbase from $ESB_BUILD...."

	if [ "$INSTALL_OSP" = "win32" -o "$INSTALL_OSP" = "win64" ] ; then
		$ESB_BUILD/server/setup.exe -options $INFILE_DIR/esbinstsq_win.txt -silent
		$ESB_BUILD/client/setup.exe -console < $INFILE_DIR/esbclient_win.txt
	else
		$ESB_BUILD/server/setup.bin -console < $INFILE_DIR/esbinstsq_unix.txt
		#$ESB_BUILD/server/setup.bin -console
		#$ESB_BUILD/client/setup.bin -console < $INFILE_DIR/esbclient_unix.txt 
		$ESB_BUILD/client/setup.bin -console < $INFILE_DIR/esbclientNoToAll_unix.txt
		#$ESB_BUILD/client/setup.bin -console
	fi	
	[ $? -ne 0 ] && exit $?
fi

#### install EAS ####

if [ "$INSTALL_PRODUCT" = "EAS" ] ; then
	EAS_BUILD=$BUILD_ROOT/EAS/builds/beckett_beta/$INSTALL_BUILD/install/$INSTALL_OSP
	
	echo "Installing EAS from $EAS_BUILD..."

	if [ "$INSTALL_OSP" = "win32" -o "$INSTALL_OSP" = "win64" ] ; then
		$EAS_BUILD/setup.exe -options $INFILE_DIR/easinstsq_win.txt -silent
	else
		$EAS_BUILD/setup.bin -options $INFILE_DIR/easinstsq_unix.txt -silent
	fi
	[ $? -ne 0 ] && exit $?	
fi

##### install APS #####

if [ "$INSTALL_PRODUCT" = "APS" ] ; then
        APS_BUILD=$BUILD_ROOT/eesdev/aps/beckett_beta/$INSTALL_BUILD/install/$INSTALL_OSP
       
	echo "Installing APS from $APS_BUILD..."


        if [ "$INSTALL_OSP" = "win32" -o "$INSTALL_OSP" = "win64" ] ; then
                $APS_BUILD/setup.exe -options $INFILE_DIR/apsinstsq_win.txt -silent
        else
                $APS_BUILD/setup.bin -console < $INFILE_DIR/apsinstsq_unix.txt
        fi
        [ $? -ne 0 ] && exit $?
fi

