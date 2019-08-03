#!/usr/bin/ksh
#########################################################################
# Filename: 	chk_filesize.sh
# Author:	Yukio Kono
# Description:	Check file size and structure between currnt installation
#				and base file.
#########################################################################
# Usage:
# chk_filesize.sh <Ver#>
# 
# Retrun value:
#   0:Success.
#   1:Environment setting error.
#   2:Invalid ESSBASE installation (from get_ess_ver.sh)
#   3:Failed to create current size file (from mk_filesize.sh)
#  10:Diff exists. $VIEW_PATH/sizcmp.dif created.
# NOTE: Before use this command, you should setup environment correctly
#       And install product correctly.
#########################################################################
# History:
# 12/13/2007 YK First edition
# 06/24/2009 YK Add no base file output
# 08/02/2010 YKono Change chk_filesize.sh to copy the previous base file 
#            when the current base file is missing.
# 08/04/2010 YKono Use sizediff.pl instead of sizediff.sh
# 10/23/2012 YKono Add BI to size file name when AP_BISHIPHOME is true.
# 11/01/2012 YKono Bug 14822330 - MK_BASEFILE.SH SUPPORT FA AND BI SECURITY MODE.
# 04/10/2013 YKono BUG 16630856 - DIRCMP NEEDS TO USE ESSBASEPATH INSTEAD OF ARBORPATH WHEN ESSBASE IS CONFIGURED
# 06/26/2013 YKono BUG 16948989 - ADD THE BASELINE INFO TO THE DIRCMP NOTIFICATION EMAIL. 
# 08/23/2013 YKono Bug 17354840 - DIRCMP COMPARE 11.1.2.2.104 SIZE FILE WITH 11.1.2.3.000 BASE FILE
# 08/26/2013 YKono Debug bug 17354840
# 09/05/2013 YKono Bug 17349226 - DIRCMP ISN'T GENERATING SIZ FILE FOR DIRCMP
umask 000
. apinc.sh

#######################################################################
# Check Environment Variable
#######################################################################
if [ -z "$ARBORPATH" ]; then
	echo "ARBORPATH not defined"
	exit 1
fi
if [ ! -d "$ARBORPATH" ]; then # exist it ?
	echo "ARBORPATH does exist, please create directory"
	exit 1
fi
if [ -z "$HYPERION_HOME" ]; then
	echo "HYPERION_HOME not defined"
	exit 1
fi
if [ ! -d "$HYPERION_HOME" ]; then
	echo "HYPERION_HOME directory doesn't exist"
	exit 1
fi

#######################################################################
# CHECK FILE SIZE AND DIRECTORY STRUCTURE
#######################################################################
verbld=`get_ess_ver.sh`
if [ $? = 0 ]; then
	ver=${verbld%:*}
	bld=${verbld#*:}
else
	echo "${verbld}"
	exit 2
fi

rm -rf "$AP_DEF_DIFFOUT"
plat=`get_platform.sh`
case $AP_SECMODE in
	fa)	_bi="_fa";;
	rep)	_bi="_bi";;
	*)	_bi=;;
esac
sizfile="$AUTOPILOT/bas/${plat}_${ver}${_bi}_${bld}.siz"
basfile="$AUTOPILOT/bas/${plat}_${ver}${_bi}.bas"
keepptn="$AUTOPILOT/bas/${plat}_${ver}${_bi}_[^_]+.siz"
basmsk="$AUTOPILOT/bas/${plat}_*${_bi}.bas"
# Check size file already created by some one
if [ -f "$sizfile" ]; then
	echo "${plat}_${ver}_${bld}.siz exists."
	echo "Skip compare file structure."
	exit 1
fi
if [ ! -f "$basfile" ]; then
	echo "#NO BASE FILE ($basfile)" > "${AP_DEF_DIFFOUT}"
	echo "No base file ($basfile) exist."
	# Decide base file
	bastmp="$HOME/.${LOGNAME}@$(hostname)_bastmp.txt"
	[ -f "$bastmp" ] && rm -f "$bastmp"
	if [ -z "$_bi" ]; then
		ls $basmsk | grep -v _bi.bas$ | grep -v _fa.bas$ | while read line; do
			line=$(basename $line)
			line=${line#${plat}_}
			line=${line%.bas}
			echo ${line}
		done | ver_vernum.sh -org | sort > $bastmp
	else
		ls $basmsk | while read line; do
			line=$(basename $line)
			line=${line#${plat}_}
			line=${line%${_bi}.bas}
			echo ${line}
		done | ver_vernum.sh -org | sort > $bastmp
	fi
	prevver=
	crrver=`ver_vernum.sh $ver`
	# echo "# crrver=$crrver"
	while read line; do
		sts=`cmpstr "${line%% *}" "${crrver}"`
		# echo "# ${line## } $sts ${ver} (${line%% *} vs ${crrver})"
		[ "$sts" = ">" ] && break
		prevver=${line##* }
	done < $bastmp
	[ -f "$bastmp" ] && rm -f "$bastmp"
	if [ -n "$prevver" ]; then
		echo "#FOUND PREV BASE FILE ($prevver)" > "${AP_DEF_DIFFOUT}"
		echo "#USE PREVIOUS BASE (${plat}_${prevver}${_bi}.bas)." > "${AP_DEF_DIFFOUT}"
		echo "Found ${plat}_${prevver}${_bi}.bas file."
		echo "Use it for this base."
		basfile=$AUTOPILOT/bas/${plat}_${prevver}${_bi}.bas
		# cp "$AUTOPILOT/bas/${plat}_${prevver}.bas" "${basflie}" 2> /dev/null
	else
		echo "#NO PREV BASE FILE ($basfile)" > "${AP_DEF_DIFFOUT}"
		echo "And couldn't find previous base file."
		exit 2
	fi
	unset prevver line bastmp sts
fi

wrtcrr "MAKING SIZEFILE"
echo "### Making size file($sizfile)."
unset _arb_back
if [ "$AP_SECMODE" = "hss" ]; then
	_arb_back=$ARBORPATH
	export ARBORPATH=$ESSBASEPATH
fi
mk_filesize.sh > "$sizfile"
cp $sizfile $HOME/${sizfile##*/}
sts=$?
[ -b "$_arb_back" ] && exprot ARBORPATH=$_arb_back
if [ "$sts" -ne 0 ]; then
	echo $sizfile
	rm $sizfile
	exit 3
fi
keepnth.sh "${keepptn}" 10
wrtcrr "DIRCMP"
# keepdir=
# sizediff.pl "$basfile" "$HOME/${sizfile##*/}" | while read f d fnm siz rest; do
# 	if [ "$f" = "a" -o "$f" = "d" ]; then
# 		if [ -n "$keepdir" ]; then
# 			if [ "${fnm#${keepdir}}" = "$fnm" ]; then
# 				echo "$f $d $fnm $siz $rest"
# 				[ "$siz" = "<dir>" ] && keepdir=$fnm || keepdir=
# 			fi
# 		else
# 			[ "$siz" = "<dir>" ] && keepdir=$fnm
# 			echo "$f $d $fnm $siz $rest"
# 		fi
# 	else
# 		echo "$f $d $fnm $siz $rest"
# 		keepdir=
# 	fi
# done > "${AP_DEF_DIFFOUT}"
sizediff.pl "$basfile" "$HOME/${sizfile##*/}"  > "${AP_DEF_DIFFOUT}"
if [ -f "${AP_DEF_DIFFOUT}" ]; then
	ret=`cat "${AP_DEF_DIFFOUT}"`
	if [ -n "$ret" ]; then
		echo " Diff exists."
		rm -f "${AP_DEF_DIFFOUT}.tmp"
		mv "${AP_DEF_DIFFOUT}" "${AP_DEF_DIFFOUT}.tmp"
		echo "# ${basfile} vs ${sizfile}" > "${AP_DEF_DIFFOUT}"
		echo "" >> "${AP_DEF_DIFFOUT}"
		echo "#############################################################" >> "${AP_DEF_DIFFOUT}"
		echo "# BASE file information:$basfile" >> "${AP_DEF_DIFFOUT}"
		cat $basfile 2> /dev/null | grep "^#" >> "${AP_DEF_DIFFOUT}"
		echo "" >> "${AP_DEF_DIFFOUT}"
		echo "#############################################################" >> "${AP_DEF_DIFFOUT}"
		echo "# SIZE file information:$sizfile" >> "${AP_DEF_DIFFOUT}"
		cat $sizfile 2> /dev/null | grep "^#" >> "${AP_DEF_DIFFOUT}"
		echo "" >> "${AP_DEF_DIFFOUT}"
		cat "${AP_DEF_DIFFOUT}.tmp" >> "${AP_DEF_DIFFOUT}"
		rm -f "${AP_DEF_DIFFOUT}.tmp"
		if [ -d "$AUTOPILOT/basedif" ]; then
			cp ${AP_DEF_DIFFOUT} $AUTOPILOT/basedif/${thisplat}_${ver}_${bld}.dif
		fi
		cp "${AP_DEF_DIFFOUT}" $HOME
		exit 10
	fi
	rm -rf "${AP_DEF_DIFFOUT}"
fi

exit 0

