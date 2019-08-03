#!/usr/bin/ksh
#_
# DESCRIPTION:
# hitcmptest.sh : HIT COMPRESSED component test progran V1.0
#_
# SYNTAX:
#   hitcmptest.sh [-h] <hit_loc>
#_
# PARAMETER:
#   -h        : Display help.
#   <hit_loc> : HIT installer location.
#               ex.) "prodpost/build_914" or "syspost/drop32H"
#_
# DESCRIPTION:
#   This script do:
#     1) Copy whole HIT installer to ./HIT folder.
#        This folder will be erased after step #2.
#     2) Make a size-structure file fro HIT folder.
#     3) Expand whole zip files under the COMPRESS folder to ./COMPRESSED folder.
#     4) Make size-structure files for COMPRESSED folder.
#     5) Dif those two files.
#_
# HISTORY:
# 2008/10/24 YKono	First Edition

me=`which $0`

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

crrdir=`pwd`

# Check parameter.
if [ $# -ne 1 ]; then
	echo "No HIT build location."
	display_help
	exit 1
else
	src="$1"
	if [ "$src" = "-h" -o "$src" = "-help" ]; then
		display_help
		exit 1
	fi
fi

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

### We can't check network drive now. SKIP
### # Check current free
### echo "Check free size of the target location."
### srcsize=`du -k -t "${src}/HIT" | tail -1 | awk '{print $1}'`
### trgsize=`get_free.sh "$crrdir"`
### echo "Source HIT size  = $srcsize"
### echo "Target free size = $trgsize"
### if [ $trgsize -lt $srcsize ]; then
### 	echo "There is not enough space on $trg location."
### 	exit 4
### fi

	[ -d "$crrdir/COMPRESSED" ] && rm -rf "$crrdir/COMPRESSED"
	cd "$crrdir"
	mkdir COMPRESSED

allplat=`ver_hitplat.sh all`
for oneplat in $allplat; do

echo "[[[[[[[ $oneplat ]]]]]]]]]]]]"
#	# Create work folders.
#	[ -d "$crrdir/HIT_${oneplat}" ] && rm -rf "$crrdir/HIT_${oneplat}"

#	# 1. Copy HIT contents to local place
#	echo "1. COPY HIT_${oneplat} CONTENTS."
#	cp -r "${src}/HIT_${oneplat}" "$crrdir"

	# 2. Make size file for HIT
	export HITDIR="$src/HIT_${oneplat}"
	echo "2. Making size-structure file for HIT_${oneplat} folder with cksum."
	filesize2.sh -cksum "\$HITDIR" > "$crrdir/HIT_${oneplat}.cksum"
#	echo "   Removing copied HIT_${oneplat} folder."
#	rm -rf "$crrdir/HIT_${oneplat}"

	# 3. Expand ZIP files under the COMPRESS folder.
	echo "3. Expand ZIP files under the COMPRESS folder."
	hitunzip2.sh "$src" "$crrdir/COMPRESSED" $oneplat

	# 4. Make size file for COMPRESSED
	echo "4. Making size-structure file for expanded COMPRESSED/HIT_${oneplat} folder with cksum."
	export HITDIR="$crrdir/COMPRESSED/HIT_${oneplat}"
	filesize2.sh -cksum "\$HITDIR" > "$crrdir/COMPRESSED_${oneplat}.cksum"

	# 5. Dif HIT and CMP cksum size files.
	echo "5. Dif HIT and COMPRESSED cksum size files."
	echo "$1 HIT_${oneplat} -> COMPRESSED/HIT_${oneplat}" > "$crrdir/HIT_COMPRESSED_${oneplat}.dif"
	sizediffex.sh +cksum HIT_${oneplat}.cksum COMPRESSED_${oneplat}.cksum >> "$crrdir/HIT_COMPRESSED_${oneplat}.dif"

	echo "Done ${oneplat}."
done
echo "Done All."
exit 0
