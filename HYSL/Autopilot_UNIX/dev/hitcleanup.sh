#!/usr/bin/ksh
#######################################################################
# File: hitinst_cleanup.sh
# History:
# 06/24/2008 YK Fist edition. 
# 12/24/2008 YK Add deleting vpd.properties file.

. apinc.sh

#######################################################################
# Clean up the installer temporary files
#######################################################################

if [ `uname` = "Windows_NT" ]; then
	H="HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion"
	prgdir=`registry -p -r -k "$H" -n "ProgramFilesDir" # 2> /dev/null`
	drv=${prgdir%%:*}
	if [ "$ARCH" = "64" -o "$ARCH" = "AMD64" -o "$ARCH" = "64M" ]; then
		chmod -Rf 0777 "${drv}:/Documents and Settings/${LOGNAME}/.hyperion.products"
		rm -rf "${drv}:/Documents and Settings/${LOGNAME}/.hyperion.products" # 2> /dev/null
		chmod -Rf 0777 "${drv}:/Documents and Settings/${LOGNAME}/.oracle.products"
		rm -rf "${drv}:/Documents and Settings/${LOGNAME}/.oracle.products" # 2> /dev/null
		chmod -Rf 0777 "${drv}:/Documents and Settings/${LOGNAME}/set_hyphome_1.bat"
		rm -rf "${drv}:/Documents and Settings/${LOGNAME}/set_hyphome_1.bat" # 2> /dev/null
		chmod -Rf 0777 "${prgdir}/Common Files/InstallShield/Universal/common"
		rm -rf "${prgdir}/Common Files/InstallShield/Universal/common" # 2> /dev/null
		chmod -Rf 0777 "${prgdir}/Oracle"
		rm -rf "${prgdir}/Oracle/Inventory" # 2> /dev/null

		chmod -Rf 0777 "${drv}:/Documents and Settings/$LOGNAME/Windows/vpd.properties"
		rm -rf "${drv}:/Documents and Settings/$LOGNAME/Windows/vpd.properties"
		chmod -Rf 0777 $windir/vpd.properties
		rm -rf $windir/vpd.properties
	else
		rm -rf "${drv}:/Documents and Settings/${LOGNAME}/.hyperion.products" 2> /dev/null
		rm -rf "${drv}:/Documents and Settings/${LOGNAME}/.oracle.products" 2> /dev/null
		rm -rf "${drv}:/Documents and Settings/${LOGNAME}/set_hyphome_1.bat" 2> /dev/null
		rm -rf "${prgdir}/Common Files/InstallShield/Universal/common" 2> /dev/null
		rm -rf "${prgdir}/Oracle/Inventory" 2> /dev/null

		rm -rf "$windir/vpd.properties"
		rm -rf "${drv}:/Documents and Settings/${LOGNAME}/Windows/vpd.properties"
	fi
	if [ $# -eq 0 ]; then
		rm -f "$prgdir/.autopilot_HIT_install.lck" 2> /dev/null
		rm -f $HOME/.autopilot_HIT_install.lck 2> /dev/null
	fi
else
	thishost=`hostname`
	# for $HOME
	rm -rf "$HOME/.hyperion.$(hostname)" 2> /dev/null
	rm -rf "$HOME/.hyperion.$(hostname).products" 2> /dev/null
	rm -rf "$HOME/.oracle.$(hostname)" 2> /dev/null
	rm -rf "$HOME/.oracle.$(hostname).products" 2> /dev/null
	rm -rf "$HOME/set_hyphome_$(hostname)_1.sh" 2> /dev/null

	rm -rf "$HOME/.hyperion.$(uname -n)" 2> /dev/null
	rm -rf "$HOME/.hyperion.$(uname -n).products" 2> /dev/null
	rm -rf "$HOME/.oracle.$(uname -n)" 2> /dev/null
	rm -rf "$HOME/.oracle.$(uname -n).products" 2> /dev/null
	rm -rf "$HOME/set_hyphome_$(uname -n)_1.sh" 2> /dev/null

	rm -rf "$HOME/InstallShield" 2> /dev/null
	rm -rf "$HOME/oraInventory" 2> /dev/null
	[ -f "$HOME/.profileback" ] && rm -rf "$HOME/.profileback" 2> /dev/null
	[ -f "$HOME/.profile~0~" ] && rm -rf "$HOME/.profile~0~" 2> /dev/null
	rm -rf "$HOME/.profile_${thishost}_${LOGNAME}.backup 2> /dev/null
	rm -rf "$HOME/.profile_${thishost}_${LOGNAME}_autopilot 2> /dev/null
	[ $# -eq 0 ] && rm -f $HOME/.autopilot_HIT_install.lck 2> /dev/null

	rm -rf $HOME/vpd.properties 2> /dev/null
	# for nfshome/$LOGNAME
	rm -rf "/nfshome/$LOGNAME/.oracle.$(uname -n)" 2> /dev/null
	rm -rf "/nfshome/$LOGNAME/.oracle.$(uname -n).products" 2> /dev/null
	rm -rf "/nfshome/$LOGNAME/.hyperion.$(uname -n)" 2> /dev/null
	rm -rf "/nfshome/$LOGNAME/.hyperion.$(uname -n).products" 2> /dev/null
	rm -rf "/nfshome/$LOGNAME/set_hyphome_$(uname -n)_1.sh" 2> /dev/null

	rm -rf "/nfshome/$LOGNAME/.oracle.$(hostname)" 2> /dev/null
	rm -rf "/nfshome/$LOGNAME/.oracle.$(hostname).products" 2> /dev/null
	rm -rf "/nfshome/$LOGNAME/.hyperion.$(hostname)" 2> /dev/null
	rm -rf "/nfshome/$LOGNAME/.hyperion.$(hostname).products" 2> /dev/null
	rm -rf "/nfshome/$LOGNAME/set_hyphome_$(hostname)_1.sh" 2> /dev/null

	rm -rf "/nfshome/$LOGNAME/InstallShield" 2> /dev/null
	rm -rf "/nfshome/$LOGNAME/oraInventory" 2> /dev/null
	[ -f "/nfshome/$LOGNAME/.profileback" ] && rm -rf "/nfshome/$LOGNAME/.profileback" 2> /dev/null
	[ -f "/nfshome/$LOGNAME/.profile~0~" ] && rm -rf "/nfshome/$LOGNAME/.profile~0~" 2> /dev/null
	rm -rf "/nfshome/$LOGNAME/.profile_${thishost}_${LOGNAME}.backup 2> /dev/null
	rm -rf "/nfshome/$LOGNAME/.profile_${thishost}_${LOGNAME}_autopilot 2> /dev/null

	rm -rf /nfshome/$LOGNAME/vpd.properties 2> /dev/null
	if [ $# -eq 0 ]; then
		rm -f /nfshome/${LOGNAME}/.autopilot_HIT_install.lck 2> /dev/null
		rm -f /$HOME/.autopilot_HIT_install.lck 2> /dev/null
	fi
fi
