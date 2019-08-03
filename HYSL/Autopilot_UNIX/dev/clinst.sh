#!/usr/bin/ksh
# clinst.sh : Install Essbase Client module for Windows platform
# Description:
#    This script check the pre-installed Essbase client and if there
#    is previous installation, this uninstall it. Then install 
#    Essbase client modeules.
# Syntax1: clinst.sh <exe> <hh>
# Syntax2: clinst.sh -d <exe> # Uninstall only.
# Parameters:
#   <exe> : EssbaseClient.exe location.
#   <hh>  : Install target HYPERION_HOME
# Option:
#   -d    : Uninstall only. No installation.
#   -h    : Display help.
#   -hs   : Display help with sample.
# Sample:
#   clinst.sh $HIT_ROOT/prodpost/11.1.2.2.0/build_7742/HIT_amd64/EssbaseClient/EssbaseClient.exe
#         C:/Users/regryk1/hyperion/11.1.2.2.100_AMD64/EPMSystem11R1
# History:
# 2012/02/01	YKONO	First edition.

me=$0
orgpar=$@
exemod=
hh=
uninstall_only=false
while [ $# -ne 0 ]; do
	case $1 in
		-uninstall|-d)
			uninstall_only=true
			;;
		-h)
			display_help.sh $me
			exit 0
			;;
		-hs)
			display_help.sh -s $me
			exit 0
			;;
		*)
			if [ -z "$exemod" ]; then
				exemod=$1
			elif [ -z "$hh" ]; then
				hh=$1
			else
				echo "clinst.sh : Too many parameter."
				echo "  params:[$orgpar]"
				display_help.sh $me
				exit 1
			fi
			;;
	esac
	shift
done

if [ "`uname`" != "Windows_NT" ]; then
	echo "clinst.sh : Not windows platform."
	display_help.sh $me
	exit 0
fi
if [ -z "$exemod" ]; then
	echo "clinst.sh : No execution module parameter."
	display_help.sh $me
	exit 1
fi

if [ ! -f "$exemod" ]; then
	echo "clinst.sh : Client installer($exemod) not found."
	exit 2
fi
if [ ! -x "$exemod" ]; then
	echo "clinst.sh : Client installer($exemod) couldn't execute."
	exit 3
fi

if [ "$uninstall_only" != "true" -a -z "$hh" ]; then
	echo "clinst.sh : No HYPERION_HOME parameter."
	display_help.sh $me
	exit 4
fi
if [ "$uninstall_only" != "true" -a ! -d "$hh" ]; then
	echo "clinst.sh : Destination folder($hh) not found."
	exit 4
fi

cnv()
{
	echo $1 | sed -e "s!/!\\\\!g"
}

h="HKEY_LOCAL_MACHINE/SOFTWARE/Classes/Installer/Products"
# exemod="$HOME/EssbaseClient.exe"
# HH="$HOME/hyperion/11.1.2.2.100_AMD64/EPMSystem11R1"

ec=$(registry -p -k "`cnv $h`" 2> /dev/null | grep "Essbase Client" | grep "ProductName" | head -1)

if [ -n "$ec" ]; then
	echo "Found Essbase Client installation."
	echo "($ec)"
	echo "Uninstall client product."
	rm -rf $HOME/ec_del.log 2> /dev/null
	$exemod /X /S /V"/qn DELETE_COMMONS=false /l* $HOME/ec_del.log" 2> /dev/null
	sts=$?
	if [ $sts -ne 0 ]; then
		echo "Failed to delete Essbase Client products($sts)."
		echo "Please check the $HOME/ec_del.log"
	else
		rm -rf $HOME/ec_del.log
	fi
	reg delete "HKEY_CLASSES_ROOT\\Installer\\Products\\CB8C4DCBA72AE4544BD7134D80DC299E" /F
fi

[ "$uninstall_only" = "true" ] && exit 0
echo "Install Essbase Client."
rm -rf $HOME/ec_inst.log 2> /dev/null
$exemod /S /V"/qn INSTALLDIR=$(cnv $hh) /l* $HOME/ec_ins.log" 2> /dev/null
sts=$?
if [ $sts -ne 0 ]; then
	echo "Filed to install Essbase Client products($sts)."
	echo "Please check the $HOME/ec_ins.log"
else
	rm -rf $HOME/ec_inst.log 2> /dev/null
fi

exit $sts

