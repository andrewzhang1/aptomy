#!/usr/bin/ksh
# Make size file list for the current Essbase installation
#
# 05/14/08 YK Add dirlist from parameter
#
# 08/02/2010 YKono Use filesize.pl in the mk_filesize.sh

display_help()
{
cat << ENDUSAGE
SYNTAX: 
mk_filesize.sh [-cksum|-lower|-i <ptn>] [ <path>... ]
INPUT:
 -cksum   : Add cksum value
 -lower   : Make all alphabet in lower case.
 -i <ptn> : Ignore pattern.
 <path>   : The folder location to make a size file.
            If you don't define <path> parameter, this
            command uses following folders for <path>.
              $ARBORPATH
              $HYPERION_HOME/common
            Note: If you define <path> with $ARBORPATH,
                This script output exact path for it
                like below:
                  C:/Hyperion/products/essbase/EssbaseServer/bin/ESSBASE.EXE 22222
                  ...
                This might be problem when you compare
                with base file.
                So, if you don't want this kind output,
                please use \$ARBORPATH for the <path>.
                Then this script create following output:
                  ARBORPATH/bin/ESSBASE.EXE 22222
                  ...
ENDUSAGE

if [ $# -ne 0 ]; then

cat << ENDSAMPLE
OUTPUT:
  The whole file list under the <path> location.
SAMPLE:
  Dump current installation(kennedy2).
    $ mk_filesize.sh > kennedy2_091.siz
  Dump entire EAS folder.
    $ mk_filesize.sh \$HYPERION_HOME/products/eas > kennedy2_eas.siz
  Dump current installation in lower case characters.
    $ mk_filesize.sh -lower # Dump file name in lower case
  Dump current installation except app folder.
   $ mk_filesize.sh -i "^ARBORPATH/app.*" > zola.siz
ENDSAMPLE
fi
}

. apinc.sh

if [ -z "$ARBORPATH" ]; then
	echo "ARBORPATH not defined"
	exit 2
fi

if [ -z "$HYPERION_HOME" ]; then
	echo "HYPERION_HOME not defined"
	exit 2
fi

if [ ! -d "$HYPERION_HOME" ]; then
	echo "HYPERION_HOME directory doesn't exist"
	exit 2
fi

# if [ ! -d "$ARBORPATH" ]; then
# 	echo "ARBORPATH does exist, please create directory"
# 	exit 2
# fi

host=`hostname`
tmpfile="$AUTOPILOT/tmp/${LOGNAME}@${host}_mkfilesize1.tmp"
tmpfile2="$AUTOPILOT/tmp/${LOGNAME}@${host}_mkfilesize2.tmp"

rm -rf $tmpfile
rm -rf $tmpfile2

debug=off
unset dirlist
file_lower=false
cksumf=false
ignptn=
while [ $# -ne 0 ]; do
	case $1 in
		-debug)
			debug=on
			;;
		-cksum)
			cksumf=true
			;;
		-lower)
			file_lower=true
			;;
		-i)
			if [ $# -lt 2 ]; then
				echo "\"-i\" option need the pattern string."
				display_help
				exit 1
			fi
			shift
			[ -z "$ignptn" ] && ignptn=$1 || ignptn="${1}|${ignptn}"
			;;
		-h)
			display_help with sample
			;;
		*)
			if [ -z "$dirlist" ]; then
				dirlist=$1
			else
				dirlist="$dirlist $1"
			fi
			;;
	esac
	shift
done

ver=`get_ess_ver.sh`
ret=$?
plat=`get_platform.sh`

. ver_mkbase.sh ${ver%:*}
# Get search location
if [ -z "$dirlist" ]; then
	if [ -f "$AUTOPILOT/data/dircmp_pattern.txt" ]; then
		dirlist=`tail -1 "$AUTOPILOT/data/dircmp_pattern.txt"`
	else
		dirlist="$_VER_DIRLST"
	fi
fi


if [ -n "$ignptn" ]; then
	AP_DIRCMP_IGNORE=$ignptn
elif [ -f "$AUTOPILOT/data/dircmp_ignore_${LOGNAME}@${host}.txt" ]; then
	AP_DIRCMP_IGNORE=`tail "$AUTOPILOT/data/dircmp_ignore_${LOGNAME}@${host}.txt"`
	AP_DIRCMP_IGNORE=${AP_DIRCMP_IGNORE%AP_DIRCMP_IGNORE=}
elif [ -f "$AUTOPILOT/data/dircmp_ignore_${plat}.txt" ]; then
	AP_DIRCMP_IGNORE=`tail -1 "$AUTOPILOT/data/dircmp_ignore_${plat}.txt"`
	AP_DIRCMP_IGNORE=${AP_DIRCMP_IGNORE%AP_DIRCMP_IGNORE=}
elif [ -f "$AUTOPILOT/data/dircmp_ignore.txt" ]; then
	AP_DIRCMP_IGNORE=`tail -1 "$AUTOPILOT/data/dircmp_ignore.txt"`
	AP_DIRCMP_IGNORE=${AP_DIRCMP_IGNORE%AP_DIRCMP_IGNORE=}
else
	if [ -z "$AP_DIRCMP_IGNORE" ]; then
		AP_DIRCMP_IGNORE=$_VER_DIRCMP
	fi
fi

echo "# $ver base file for ${plat} (${LOGNAME}@`hostname` `date +%D_%T`)"
echo "# Dump dir List:"
for one in $dirlist; do
	echo "#   $one"
done
echo "# IgnoreFilePtn:"
str=$AP_DIRCMP_IGNORE
while [ -n "$str" ]; do
	one=${str%%\|*}
	if [ "$one" = "$str" ]; then
		str=
	else
		str=${str#*\|}
	fi
	echo "#   $one"
done

echo "# AP_SECMODE=$AP_SECMODE"
echo "# INSTALLER =`get_instkind.sh -l`"
if [ "$plat" != "${plat#win}" ]; then
	mks=`which mksinfo`
	mks=${mks%/*}
	${mks}/perl.exe `which filesize.pl` -attr $dirlist -ign "${AP_DIRCMP_IGNORE}"
else
	filesize.pl -attr $dirlist -ign "${AP_DIRCMP_IGNORE}"
fi

exit 0
