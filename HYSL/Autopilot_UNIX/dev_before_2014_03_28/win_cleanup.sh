#!/usr/bin/ksh

# We need delete following enties:
# 	HKEY_LOCAL_MACHINE\SOFTWARE\ORACLE
#		KEY_OH####
#		KEY_EpmSystem_###
#		Performance Instrumentation
# 	HKEY_LOCAL_MACHINE\SOFTWARE\Hyperion Solutions
#		Hyperion Shared Services
# 	HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services
# 		OracleProcessManager_instance###
#		Oracle BI Server
# And delete following files
# 	C:\bea
# 	C:\Program Files\Oracle\Inventory
# And delete folliwng start menu items
# 	Oracle - OH######
#	Oracle Business Inteligence
#	Oracle Web Tier 11g - Home#
#	Oracle Common Home 11g - Home#
#	Oracle Application Developer 11g - Home#
#	Oracel EPM System -
#	Oracle WebLogic

H="HKEY_LOCAL_MACHINE\\SOFTWARE\\ORACLE"
registry -p -k "$H" | \
	sed -e "s/\\\\/\//g" | \
	sed -e "s!	!,!g" | \
	egrep "KEY_OH|KEY_EpmSystem|Performance Instrumentation" | \
while read one ; do
	one=`echo $one | awk -F, '{print $1}'`
	echo "${one##*/}"
done | uniq | while read one; do
	echo "Delete : \"$H\\$one\""
	reg delete "$H\\$one" /f > /dev/null 2>&1
done

H="HKEY_LOCAL_MACHINE\\SOFTWARE"
one="Hyperion Solutions"
registry -p -k "$H\\$one" > /dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "Delete : \"$H\\$one\""
	reg delete "$H\\$one" /f > /dev/null 2>&1
fi

H="HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services"
registry -p -k "$H" 2> /dev/null | \
	egrep "OracleProcessManager_instance|Oracle BI Server" | \
	grep -v "Eventlog" | \
	sed -e "s/\\\\/\//g" | \
	sed -e "s!	!,!g" | \
while read one ; do
	one=`echo $one | awk -F, '{print $1}'`
	echo "${one##*/}"
done | uniq | while read one; do
	echo "Delete : \"$H\\$one\""
	reg delete "$H\\$one" /f > /dev/null 2>&1
done

# Remove OraInventory
H="HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion"
prgdir=`registry -p -r -k "$H" -n "ProgramFilesDir" 2> /dev/null`
rm -rf "${prgdir}/Oracle/Inventory" > /dev/null 2>&1

# Remove BEA directory
drvlttr=${prgdir%%:*}
rm -rf "$drvlttr:/bea" > /dev/null 2>&1

# Delete Start menu
_crrdir=`pwd`
osr=`uname -r`
if [ "$osr" = "5" ]; then
	# Win2003
	cd "$USERPROFILE"
	cd ..
	cd "All Users"
else
	cd "$ProgramData"
	cd "Microsoft"
	cd "Windows"
fi
cd "Start Menu"
cd "Programs"
ls -1 | while read one; do
	# if [ "${one#Oracle Application Developer 11g}" != "$one" \
	#    -o "${one#Oracle Common Home 11g}" != "$one" \
	#    -o "${one#Oracle EPM System}" != "$one" \
	#    -o "${one#Oracle Web Tier 11g}" != "$one" \
	#    -o "${one#Oracle WebLogic}" != "$one" \
	#    -o "${one#Oracle - OH}" != "one" \
	#    -o "${one#Oracle Bussiness Inteligen}" != "$one" ]; then
	case $one in
		"Oracle Application Developer 11g"*|"Oracle Common Home 11g"*|"Oracle EPM System"*|"Oracle WebLogic"*|"Oracle - OH"*|"Oracle Business Intelligence"*|"Oracle Web Tier 11g"*|"Oracle Web Tier Instance - "*)
		echo "### Remove $one from 'Start Menu/Programs' folder."
		rm -rf "$one"
		;;
		*)
		# echo "### Skip $one."
		;;
	esac
done
cd "$_crrdir"

