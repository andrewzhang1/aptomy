#!/usr/bin/ksh
# rendir.sh : Rename entire direcotry name to short name.
# When the directory structure become deep and an abusolute path name become bigger than same specific
# number, Windows may fail to remove a directory or file in that deep locatoin like below:
# > rm: cannot remove directory "_dummy6/instances/instance4/bifoundation
# > /OracleBIPresentationServicesComponent/coreapplication_obips1
# > /catalog/SampleAppLite/root/shared/sample+lite/published+reporting
# > /data+models/sfo+passenger+count+data+model%2exdm": The director y is not empty.
# This command is made each folder names shorten and avoid above problem.
# History:
# 2012/09/05	YKono	First Edition

me=$0
targs=
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			echo "${me##*/} : Rename directory names to short."
			echo "Description:"
			echo "  This program rename entire directories under <dir> to short format."
			echo "  When target directory, target_folder, has following structure:"
			echo "  <target_folder> -+- <long_dir_name> - abc.txt"
			echo "                   +- <folder_A> -+- <sub-folder-X> - xyz.txt"
			echo "                   |              +- <sub-folder-Y>"
			echo "                   |              +- <sub-folder-Z> -+- <A>"
			echo "                   |                                 +- <B> - BBBB.txt"
			echo "                   |                                 +- <long_folder_name>"
			echo "                   +- <folder_B> -+- <folder_A_in_B> - a_in_b.txt"
			echo "                   +- <C>"
			echo "                   +- <folder_Z> - zzz.tct"
			echo "  \"${me##/} target_folder\" command change it like below:"
			echo "  <a> -+- <a> - abc.txt"
			echo "       +- <b> -+- <a> - xyz.txt"
			echo "       |       +- <b>"
			echo "       |       +- <c> -+- <A>"
			echo "       |               +- <B> - BBBB.txt"
			echo "       |               +- <a>"
			echo "       +- <c> -+- <a> - a_in_b.txt"
			echo "       +- <C>"
			echo "       +- <d> - zzz.tct"
			echo "Syntax: ${me##*/} <dir>"
			exit 0
			;;
		*)
			targs="$targs $1"
			;;
	esac
	shift
done

chk_one()
{
	crr=`pwd`
	cd $1
	cd ..
	dn=
	for n1 in a b c d e f g h i j k l m n o p q r s t u v w x y z; do
		if [ ! -d "$n1" ]; then
			dn=$n1
			break
		fi
	done
	if [ -z "$dn" ]; then
		for n1 in a b c d e f g h i j k l m n o p q r s t u v w x y z; do
			for n2 in 0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z; do
				if [ ! -d "$n1$n2" ]; then
					dn="$n1$n2"
				fi
				[ -n "$dn" ] && break
			done
			[ -n "$dn" ] && break
		done
	fi
	cd $crr
	echo $dn
}

lvl=0
stk=
rename_dirs()
{
	let lvl=lvl+1
	stk[$lvl]=`pwd`
	if [ -d "$1" ]; then
		cd $1
		cd ..
		td=${1##*/}
		if [ ${#td} -ne 1 -a $lvl -ne 1 ]; then
			nm=`chk_one $td`
			if [ -n "$nm" ]; then
				mv $td $nm
				echo "$lvl:Rename $td $nm"
			else
				nm=$td
				echo "$lvl:Failed to mv $td $nm"
			fi
		else
			nm=$td
			echo "$lvl:keep $td because 1 char."
		fi
		if [ -n "$nm" ]; then
			cd $nm
			ls -la | while read attr d1 d2 d3 d4 d5 d6 d7 fl; do
				[ "$fl" != "." -a "$fl" != ".." -a "$attr" != "${attr#d}" ] \
					&& rename_dirs $fl
			done
		fi
	else
		echo "$lvl:Missing $1 directory."
	fi
	cd ${stk[$lvl]}
	let lvl=lvl-1
}

crrdir=`pwd`
echo "targs=$targs"
for one in $targs; do
	rename_dirs $one
done
cd $crrdir

