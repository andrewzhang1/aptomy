#!/usr/bin/ksh
# DESCRIPTION:
#    hitunzip.sh : Unzip HIT COMPRESSED files tool ver. 1.0
#_
# SYNTAX:
#    hitunzip.sh [ -esb | +sizecheck ] [ -p <plat>|all ] <hit-loc> [ <trg-loc> ]
#    ex.) Expand build_914 compressed files.
#      $> hitunzip.sh prodpost/build_914
#_
# PARAMETER:
#    -esb     : Expand Essbase related files only.
#    +sizechk : Check the target free space before expand zip files.
#    <hit_loc>: HIT source folder. This should contains HIT and COMPRESSED.
#               This path is relative path from $HIT_ROOT location. If you define
#               a full path for this parameter, hitunzip.sh just uses it without
#               adding $HIT_ROOT.
#               ex.)
#                 prodpost/build_914, syspost/drop32G, prodpost2/build_1847,
#                 U:/prodpost/build_801, /nar200/hit/syspost/drop32H, 
#                 /net/nar200/vol/vol3/hit/prodpost2/build_1852
#    <trg_loc>: The target location to expand.
#               When you skip this parameter, hitunzip uses current folder.
# HISTORY:
# 2008/10/24 YKono	First Edition.

# display_help
display_help()
{
	descloc=`grep -n "^# DESCRIPTION:" $me | head -1`
	histloc=`grep -n "^# HISTORY:" $me | head -1`
	descloc=${descloc%%:*}
    histloc=${histloc%%:*}
	let lcnt="$histloc - $descloc"
	let tcnt="$histloc - 1"
	head -${tcnt} $me | tail -${lcnt} | while read line; do
		echo "${line##??}"
	done
}

# Set Initial value
me=`which $0`
fltr=
src=
trg="."
sizecheck=false
plat=
esbonly=true
fltr=
# Parse parameters
while [ $# -ne 0 ]; do
	case $1 in
		+sizecheck)
			sizecheck=true
			;;
		-sizecheck)
			sizecheck=false
			;;
		-p)	
			shift
			plat=$1
			;;
		-h)
			display_help
			exit 0
			;;
		-esb|esb)   esbonly=true;;
		-all|all)   esbonly=false;;
		-f)
			shift
			if [ $# -eq 0 ]; then
				echo "There is no filter string for -f option."
				display_help
				exit 1;
			else
				fltr="$1"
			fi
			;;
		*)
			if [ -z "$src" ]; then
				src="$1"
			else
				trg="$1"
			fi
			;;
	esac
	shift
done
[ -z "$plat" ] && plat=`get_platform.sh`
# echo "me=$me"
# echo "fltr=$fltr"
# echo "src=$src"
# echo "trg=$trg"
# echo "sizecheck=$sizecheck"
# echo "plat=$plat"

# Get HIT_ROOT location
apinc=`which apinc.sh`
if [ -z "$apinc" ]; then
	[ `uname` = "Windows_NT" ] \
		&& hitroot="//nar200/hit" \
		|| hitroot="/net/nar200/vol/vol3/hit"
else
	hitroot=`(. apinc.sh;echo $HIT_ROOT)`
fi
## echo "hitroot=$hitroot"

# Remove path delimiter at the end of $hitroot
[ "x${hitroot%/}" != "x${hitroot}" ] && hitroot="${hitroot%/}"
[ "x${hitroot%\\}" != "x${hitroot}" ] && hitroot="${hitroot%\\}"

# Check the source is defined.
if [ -z "$src" ]; then
	echo "No source location deinfed."
	display_help
	exit 2
fi

# Check the source location is a full path.
# And if not, add $HIT_ROOT to the source location.
if [ `uname` = "Windows_NT" ]; then
	# Not start with "?:", "/" and "\" => relative path 
	[ "x${src#?:}" = "x${src}" -a "x${src#/}" = "x${src}" \
		-a "x${src#\\}" = "x${src}" ] && src="${hitroot}/${src}"
else
	[ "x${src#/}" = "x${src}" ] && src="${hitroot}/$src"
fi
## echo "src=$src"

# Check source folder exist.
if [ -d "$src" ]; then
	if [ ! -d "${src}/COMPRESSED" ]; then
		echo "No \"${src}/COMPRESSED\" folder exist."
		exit 3
	fi
	if [ "$skipsizecheck" = "false" -a ! -d "${src}/HIT" ]; then
		echo "No \"${src}/HIT\" folder exist."
		exit 3
	fi
else
	echo "No \"$src\" folder exist."
	exit 3
fi

# Check and set target folder.
if [ ! -d "$trg" ]; then
	echo "No \"$trg\" folder exist."
	exit 4
fi
crr=`pwd`
cd "$trg"
trg=`pwd` # Convert to the full path expression.
cd "$crr"
## echo "trg=$trg"

# Check unzip command present.
unzipcmd=`which unzip`

if [ "x${unzipcmd#no}" != "x${unzipcmd}" ]; then
	case `uname` in
		HP-UX)
			unzipcmd=`which unzip_hpx32`
			;;
		Linux)
			unzipcmd=`which unzip_lnx`
			;;
		SunOS)
			unzipcmd=`which unzip_sparc`
			;;
		AIX)
			unzipcmd=`which unzip_aix`
			;;
		*)
			;;
	esac	
fi
if [ -z "${unzipcmd}" ]; then
	echo "I couldn't find the unzip command."
	echo "Please install 'unzip' command into your machine."
	exit 5
fi
echo "unzipcmd=$unzipcmd"

# Check current free
if [ "$sizecheck" = "true" ]; then
	echo "Check free size of the target location."
	srcsize=`du -k -t "${src}/HIT" | tail -1 | awk '{print $1}'`
	trgsize=`get_free.sh "$trg"`
	echo "Source HIT size  = $srcsize"
	echo "Target free size = $trgsize"
	if [ $trgsize -lt $srcsize ]; then
		echo "There is not enough space on $trg location."
		exit 6
	fi
fi

# Expand each zip file.
cd "$src/COMPRESSED"
plats=
allplats=`ver_hitplat.sh all`
for one in $allplats; do
	[ -z "$plats" ] && plats=$one || plats="${plats}|$one"
done
[ "$plat" != "all" ] && plat=`ver_hitplat.sh -p $plat`
echo "plats=$plats"
echo "plat=$plat"
ziplist=
if [ "$esbonly" = "true" ]; then
	if [ "$plat" = "all" ]; then
		ziplist=$(
			ls *.zip \
			| egrep "^Essbase-*|^EPM-FoundationServices-*|^EPM-SystemInstaller-*|Foundation-*|OHS-*|ClientInstall*" 
		)
	else
		ziplist=$(
			ls *.zip \
			| egrep "^Essbase-*|^EPM-FoundationServices-*|^EPM-SystemInstaller-*|Foundation-*|OHS-*|ClientInstall*" \
			| while read one; do
				if [ "$one" != "${one#Client}" ]; then
					if [ "$plat" != = "win32" -o "$plat" = "amd64" ]; then
						echo $one
					fi
				elif [ -z "`echo $one | egrep $plats`" ]; then
					echo $one
				else
					if [ -n "`echo $one | grep $plat`" ]; then
						echo $one
					fi
				fi
			done
		)
	fi
else
	if [ "$plat" = "all" ]; then
		ziplist=`ls *.zip`
	else
		ziplist=$(
			ls *.zip | while read one; do
				if [ "${one#Client}" != "$one" ]; then
					if [ "$plat" = "win32" -o "$plat" = "amd64" ]; then
						echo $one
					fi
				else
					if [ -z "`echo $one | egrep $plats`" ]; then
						echo $one
					else
						if [ -n "`echo $one | grep $plat`" ]; then
							echo $one
						fi
					fi
				fi
			done
		)
	fi
fi

# echo $ziplist | while read onezip; do
for onezip in $ziplist; do
	echo "# cp $onezip"
	cp "$onezip" "$trg"
done
cd $trg
for onezip in $ziplist; do
	echo "# unzip $onezip"
	${unzipcmd} -o "$onezip"
	# rm -f "$onezip"
done
