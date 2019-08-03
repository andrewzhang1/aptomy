#!/usr/bin/ksh
# liblist.sh : Library list for specified command.
#

. apinc.sh

display_help()
{
	echo "liblist.sh [-h] <module> <module>"
}

tmpfile=$HOME/liblist.$$.tmp

win_liblist()
{
	imgname=`which $1`
	if [ $? -ne 0 ]; then
		echo "$1: <not found in the PATH>"
	else
		imgname=`basename $imgname`
		rm -rf $tmpfile > /dev/null 2>&1
		tasklist /m /fo list /fi "imagename eq $imgname" > $tmpfile 2>&1
		lcnt=`wc -l $tmpfile`
		lcnt=${lcnt#* }
		lcnt=${lcnt%% *}
		if [ $lcnt -lt 4 ]; then
			echo "$imgname: <not executing>" 
			cat $tmpfile | while read line; do
				echo "> $line"
			done
			rm -rf $tmpfile > /dev/null 2>&1
		else
			echo "$imgname:"
			tail +4 $tmpfile | while read line; do
				$line=${line##*\ }
				a=`which $line 2> /dev/null`
				if [ $? -ne 0 ]; then
					pathpart="-"
				else
					pathpart=`echo $a | sed -e "s!$HYPERION_HOME!HYPERION_HOME!g" \
							-e "s!$ARBORPATH!ARBORPATH!g"`
				fi
				echo "  ${pathpart}/$line"
			done
		fi
	fi
}

unix_liblist()
{
	imgname=`which $1`
	if [ $? -ne 0 -o "${imgname#no}" != "$imgname" ]; then
		echo "$1: <Not found in the PATH>."
	else
		imgbase=`basename $imgname`
		echo "$imgbase:"
		ldd $imgname | grep -v "needs:" | while read line; do
			line=`echo "${line#*=\>}" | sed -e "s/^[ 	]*//g"`
			echo "  $line" | \
				sed -e "s!$HYPERION_HOME!HYPERION_HOME!g" -e "s!$ARBORPATH!ARBORPATH!g"
		done
	fi
}

while [ $# -ne 0 ]; do
	if [ "$1" = "-h" ]; then
		display_help
		exit 1
	else
		if [ `uname` = "Windows_NT" ]; then
			win_liblist $1
		else
			unix_liblist $1
		fi
	fi
	shift
done

exit 0



