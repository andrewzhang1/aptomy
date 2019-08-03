#!/usr/bin/ksh
# mk_basefile.sh : Create the base file of the Essbase installation.
# 
# Description:
#   This command install the Essbase produts using CD/Install for the 
#   pre-9.x version and HIT installer for the post-9.x version.
#   And make a base file into $AUTOPILOT/prebas fodler with <plat>_<ver>.bas
#   format.
#   The dump-location, ignore-condition and dynamic-file-pattern are defined
#   in the $AUTOPILOT/bin(dev)/ver_mkbase.sh script for each versions.
#     _VER_DIRLIST: Dump location list.
#     _VER_DIRCMP:  Ignore file pattern in egrep-format.
#     _VER_DYNDIR:  Dynamic file pattern in egrep-format.
#   So, when you want to make a new version of the base file, please make
#   sure the ver_mkbase.sh has the target version.
#   This script dump file list by _VER_DIRLST. But ignore in the _VER_DIRCMP
# Syntax:
#   mk_basefile.sh [<options>] <ver> <bld> [<base-name>]
#   <ver> : The version number to the installation.
#           This number is based on "pre_rel" folder structure.
#           The version string is exact same as the folder name just under the
#           //pre_rel/essbase/builds folder.
#           If the version is located at sub folder like 9.2, you should define
#           this number with sub-folder name like 9.2/9.2.1.0.3.
#   <bld> : The build number to the installation.
#           You can use "latest" or "HIT[<hit-bld>]" for this parameter.
#   <base-name> : Base file name.
# 
# Options: [-h|-noinst|-nocmdgq|-server|-client|-d <bas>|-o <opt>]
#   -h      : Display this.
#   -d <bas>: Destination folder to create the base file.
#             When you skip this parameter, this script create a base
#             file under the $AUTOPILOT/prebas folder.
#   -noinst : Do not use the installer and use current installation.
#   -nocmdgq: Do not install ESSCMDG, ESSCMDQ and related files.
#   -server : Use "server" installer only for CD/install image.
#             For the old type installation, we should tell which installer
#             mk_basefile.sh should use.
#   -client : Use "client" installer only for CD/install image.
#   -o <opt>: Task option.
#   +dbg    : Debug message on
#   -dbg    : Debug message off
# 
# Sample:
# 1) Install typical server and client modules for Zola latest.
#   $ mk_basefile.sh zola latest
# 2) Not install ESSCMDQ and realted files.
#   $ mk_basefile.sh -nocmdgq zola 120
# 3) Use pre-installed image for the base file.
#   $ mk_basefile.sh -noinst zola 116
# 
# History:
# 07/01/08 YK - Use version.sh to get version information
# 02/15/12 YK - Add -d option.
# 02/16/12 YK - Change default output directory to prebas from bas
# 10/27/12 YK - Bug 14822330 - MK_BASEFILE.SH SUPPORT FA AND BI SECURITY MODE.
# 03/26/13 YK - Bug 16472865 - DIR COMPARISION SHOULD BE TAKEN OUT BEFORE COPY ANY FILES.
# 04/16/13 YK - Add -dbg option.

. apinc.sh

me=$0
dbg=false
orgpar=$@
unset ver bld bfile rspf knd instgq
basdest=$AUTOPILOT/prebas
inst=true
knd=
while [ $# -ne 0 ]; do
	case $1 in
		-d)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}: '$1' need second parameter as the destination folder."
				exit 1
			fi
			if [ ! -d "$1" ]; then
				echo "${me##*/}: You define the base target folder to $1."
				echo "${me##*/}: But couldn't access that location."
				exit 1
			fi
			basdest=$1
			;;
		+dbg)	dbg=true;;
		-dbg)	dbg=false;;
		-noinst|-skipinst)
			inst=false
			;;
		-server|-client)
			knd=$1
			;;
		-hs)
			display_help.sh $me -s
			exit 0
			;;
		-h|help|-help)
			display_help.sh $me
			exit 0
			;;
		-skipcmdgq|-nocmdgq)
			instgq=$1
			;;
		-rsp)
			shift
			if [ $# -lt 1 ]; then
				echo "${me##*/}: -rsp option need second parameter for the response file."
				display_help.sh $me
				exit 1
			fi
			rspf=$1
			;;
		-o)
			shift
			if [ $# -lt 1 ]; then
				echo "${me##*/}: -o option need second parameter for the task option."
				exit 1
			fi
			[ -z "$_OPTION" ] && export _OPTION="$1" || export _OPTION="$_OPTION $1"
			;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			elif [ -z "$bld" ]; then
				bld=$1
			elif [ -z "$bfile" ]; then
				bfile=$1
			else
				echo "${me##*/}: Too many parameter."
				display_help.sh $me
				exit 1
			fi
			;;
	esac
	shift
done

if [ -z "$ver" -o -z "$bld" ]; then
	echo "mk_basefile.sh : Need both <ver> and <bld> number."
	display_help.sh $me
	exit 1
fi

secmode=$(. se.sh $ver > /dev/null 2>&1; echo $AP_SECMODE)
case $secmode in
	fa)	bimode=_fa;;
	rep)	bimode=_bi;;
	*)	bimode=;;
esac
if [ -z "$bfile" ]; then
	if [ -n "$rspf" ]; then
		rspfbs=${rspf#win_}
		rspfbs=${rspfbs#unix_}
		rspfbs=${rspfbs#hit_}
		rspfbs=${rspfbs%.*}
		bfile="${basdest}/${plat}_${ver##*/}_${rspfbs}${bimode}.bas"
	else
		bfile="${basdest}/${plat}_${ver##*/}${bimode}.bas"
	fi
	unset rspfbs
else
	[ "$bfile" = "${bfile#*/}" ] && bfile="${basdest}/$bfile"
fi

[ -n "$rspf" ] && rspf="-rsp $rspf"

plat=`get_platform.sh`

if [ "$inst" = "true" ]; then
	hyslinst.sh -nocmdgq -noinit $instgq $knd $rspf $ver $bld
	if [ $? -ne 0 ]; then
		echo "Failed to install product($?)."
		exit 1
	fi
fi
. se.sh -nomkdir $ver > /dev/null 2>&1
ver=`get_ess_ver.sh`

. ver_mkbase.sh $ver 2> /dev/null
echo "# $ver base file for ${plat} (${LOGNAME}@`hostname` `date +%D_%T`)" > "$bfile"
[ "$dbg" = "true" ] && echo "# $ver base file for ${plat} (${LOGNAME}@`hostname` `date +%D_%T`)"

echo "# Dump Dir List:" >> "$bfile"
for one in $_VER_DIRLST; do
	echo "#   $one" >> "$bfile"
done
echo "# Ignore File Pattern:" >> "$bfile"
str=$_VER_DIRCMP
while [ -n "$str" ]; do
	one=${str%%\|*}
	if [ "$one" = "$str" ]; then
		str=
	else
		str=${str#*\|}
	fi
	echo "#   $one" >> "$bfile"
done
echo "# Dynamic File Pattern:" >> "$bfile"
str=$_VER_DYNDIR
while [ -n "$str" ]; do
	one=${str%%\|*}
	if [ "$one" = "$str" ]; then
		str=
	else
		str=${str#*\|}
	fi
	echo "#   $one" >> "$bfile"
done

echo "# AP_SECMODE=$AP_SECMODE" >> "$bfile"
echo "# INSTALLER =`get_instkind.sh -l`" >> "$bfile"

filesize.pl -attr $_VER_DIRLST -ign "${_VER_DIRCMP}" -dyn "${_VER_DYNDIR}" >> "$bfile"

bld=${ver#*:}
ver=${ver%:*}
cmdgqinst.sh $ver $bld

