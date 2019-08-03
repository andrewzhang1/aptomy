#!/usr/bin/ksh
###########################################################
# Filename: ext_reftar.sh
# Author: Y.Kono
# Description: Extract the .tar.Z file which is used by 
#              refresh coomand.
# Syntax: ext_reftar.sh [-h|-c|-p <plt>] <ver> <bld>
#  <ver> : Version number in full format
#  <bld> : Build number
# Options:
#  -client  : Extract client files.
#  -cmdgq   : Not extract ESSCMDQ/G
#  -h       : Display help
#  -l       : List up part
#  -d <dst> : Destination folder
#  -p <plt> : Extract specific platform file.
# Out:
#  0 : Extract success
#  1 : Parameter error
#  2 : No BUILD_ROOT definition
#  3 : No BUILD_ROOT/ver/bld/plat/ folder
#  4 : No .tar.Z(.gz) file under the target folder
#  5 : Failed to convert "latest" to real build number
#  6 : No client list file..
# Note: This script copy the .tar.Z(.gz) file from
#       $BUILD_ROOT/<ver>/<bld>/<plat>/*.tar.Z(.gz).
#       If the version lower than 9x and it has
#       $BUILD_ROOT/<ver>/<bld>/server/<plat> format
#       or has $BUILD_ROOT/<ver>/<bld>/server/<plat>/opt
#       format, this may not work correctly.
###########################################################
# History:
# 05/25/2011 YK First edition

. apinc.sh
umask 000
me=$0
orgpar=$@
ver=
bld=
cl=
lp=
dst=
cmdgq=true
plt=${thisplat}
while [ $# -ne 0 ]; do
	case $1 in
		-h)	display_help.sh $me
			exit 0
			;;
		`isplat $1`)
			plt=$1
			;;
		-p)
			if [ $# -eq 1 ]; then
				echo "-p option need second parameter as platform."
				display_help.sh $me
				exit 1
			fi
			shift
			plt=$1
			;;
		-l)	lp=true;;
		-cmdgq)	cmdgq=false;;
		-d)	
			if [ $# -lt 2 ]; then
				echo "\"-d\" parameter need 2nd parameter as the destination location."
				echo "orgpar: $orgpar"
				exit 1
			fi
			shift
			dst=$1
			;;
		-*)	cl=${1#-};;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			elif [ -z "$bld" ]; then
				bld=$1
			else
				dst=$1
			fi
			;;
	esac
	shift
done

[ -z "$dst" ] && dst=`pwd`
if [ ! -d "$dst" ]; then
	mkddir.sh $dst 2> /dev/null
	if [ $? -ne 0 ]; then
		echo "Destination fodler($dst) not found and failed to create it."
		exit 7
	fi
fi
cd $dst
if [ $? -ne 0 ]; then
	echo "Failed to change directory to \"$dst\"."
	exit 1
fi

if [ -z "$ver" -o -z "$bld" ]; then
	echo "Not enough parameter."
	echo "OrgPar: $orgpar"
	display_help.sh $me
	exit 1
fi

if [ -z "$BUILD_ROOT" -o ! -d "$BUILD_ROOT" ]; then
	echo "No BUILD_ROOT definition or folder."
	exit 2
fi

if [ "$bld" = "latest" ]; then
	bld=`get_latest.sh $plt $ver`
	if [ $? -ne 0 ]; then
		echo $bld
		exit 5
	fi
fi

if [ ! -d "$BUILD_ROOT/$ver/$bld/$plt" ]; then
	echo "There is no $BUILD_ROOT/$ver/$bld/$plt folder."
	exit 3
fi

ls $BUILD_ROOT/$ver/$bld/$plt/*.tar.* > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "There is no tar.Z(.gz) file under"
	echo "$BUILD_ROOT/$ver/$bld/$plt/ folder."
	ls $BUILD_ROOT/$ver/$bld/$plt
	exit 4
fi

if [ "$lp" = "true" ]; then
	ls $BUILD_ROOT/$ver/$bld/$plt/extract/*.txt 2> /dev/null | \
	while read one; do
		echo "  $one"
	done
	exit 0
fi

if [ -n "$cl" -a ! -f "$BUILD_ROOT/$ver/$bld/$plt/extract/${cl}_list_essbase_${plt}.txt" ]; then
	echo "Partial list for $cl and $plt not found."
	exit 6
fi
echo "Copying .tar.${ext} file..."
cp $BUILD_ROOT/$ver/$bld/$plt/*.tar.* . > /dev/null 2>&1
case `uname` in
	HP-UX)
		wt=`which gtar 2> /dev/null`
		if [ "${wt#no}" = "$wt" ]; then
			tarcmd=$wt
		else
			tarcmd=`which gtar_hpx32`
			if [ "${tarcmd#no}" != "$tarcmd" ]; then
				tarcmd=tar
			fi
		fi
		;;
	AIX)
		wt=`which gtar 2> /dev/null`
		if [ $? -ne 0 ]; then
			tarcmd=`which gtar_aix`
			if [ $? -ne 0 ]; then
				tarcmd=tar
			fi
		elwe
			tarcmd=$wt
		fi
		;;
	SunOS)
		wt=`which gtar 2> /dev/null`
		if [ "${wt#no}" = "$wt" ]; then
			tarcmd=$wt
		else
			tarcmd=`which gtar_sparc`
			if [ "${tarcmd#no}" != "$tarcmd" ]; then
				tarcmd=tar
			fi
		fi
		;;
	*)
		# Win and Linux doesn't need gtar command because...
		# The default tar command of Linux is equivalent to gtar
		# MKS tar doesn't have a limitation to the file name.
		tarcmd=tar;;
esac

while [ 1 ]; do
	tar=`ls *.tar.* 2> /dev/null | head -1 2> /dev/null`
	if [ -f "$tar" ]; then
		echo "Extracting $tar..."
		if [ "${tar##*.}" = "Z" ]; then
			uncompress -f $tar
		elif [ "${tar##*.}" = "gz" ]; then
			gunzip -f $tar
		fi
		${tarcmd} xf ${tar%.*}
		rm -f ${tar%.*} > /dev/null
	else
		break
	fi
	rm -f $tar > /dev/null 2>&1
done

if [ -n "$cl" ]; then
	pf=$BUILD_ROOT/$ver/$bld/$plt/extract/${cl}_list_essbase_${plt}.txt
	# Delete the files not in the list.
	ls -d * | while read onedir; do
		crrdir=$onedir
		ls -Rp $onedir | grep -v "^$" | while read one; do
			if [ "${one%:}" = "$one" ]; then	
				if [ "${one%/}" = "$one" ]; then
					rmv=false
					if [ "$cmdgq" = "false" ]; then
						rmv=true
					else
						[ "${one#ESSCMDQ}" = "$one" -a "${one#ESSCMDG}" = "$one" ] && rmv=true
					fi
					if [ "$rmv" = "true" ]; then
						grep "${crrdir}/${one}" $pf > /dev/null
						if [ $? -ne 0 ]; then
							rm -f ${crrdir}/${one} 2> /dev/null
					#		echo "rm -f ${crrdir}/${one}"
						fi
					fi
				fi
			else
				crrdir=${one%:}
			fi
		done
	done
	# Clean up empty directory
	ls -d * | while read onedir; do
		ls -R $onedir | grep ":$" | sort | while read one; do
			cnt=`ls ${one%:} | wc -l`
			let cnt=cnt
			if [ $cnt -eq 0 ]; then
				rm -rf ${one%:}
		#		echo "rm -rf ${one%:}"
			fi
		done
	done
fi

if [ -f "$BUILD_ROOT/$ver/$bld/java/essbase.jar" ]; then
	echo "Copying essbase.jar..."
	if [ ! -d "ARBORPATH/java" ]; then
		mkdir ARBORPATH/java > /dev/null 2>&1
		chmod 777 ARBORPATH/java > /dev/null 2>&1
	fi
	cp $BUILD_ROOT/$ver/$bld/java/essbase.jar ARBORPATH/java > /dev/null 2>&1
fi

# if [ -d "ARBOPATH/JavaAPI" -a ! -d "HYPERION_HOME/common/EssbaseJavaAPI" ]; then
# 	echo "Copying JavaAPI contents..."
# 	mkdir HYPEIRON_HOME/common/EssbaseJavaAPI > /dev/null 2>&1
# 	chmod 777 HYPERION_HOME/common/EssbaseJavaAPI > /dev/null 2>&1
# 	cp -rp ARBORPATH/JavaAPI/* HYPERION_HOME/common/EssbaseJavaAPI > /dev/null 2>&1
# fi
exit 0
