#!/usr/bin/ksh
# logto.sh : log stdin to the target location
# Syntax: logto.sh <file>...
#   <file> : Output file name
#            If the name is console, display to stdout.
# HISTORY ############################################################################
# 11/09/2011 YK - First Edition

umask 000
orgp=$@
me=$0
outfs=
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			exit 1
			;;
		*)
			[ -z "$outfs" ] && outfs=$1 || outfs="$outfs $1"
			;;
	esac
	shift
done

if [ -z "$outfs" ]; then
	echo "No ouput file."
	display_help.sh $me
	exit 1
fi

for one in $outfs; do
	[ "$one" != "console" -a "$one" != "stdout" ] && rm -f $one > /dev/null 2>&1
done
sts=0
while read -r line; do
	if [ "${line#logto.sh return status=}" = "$line" ]; then
		for one in $outfs; do
			[ "$one" = "console" -o "$one" = "stdout" ] \
				&& print -r "$line" 2> /dev/null \
				|| print -r "$line" >> $one 2> /dev/null
			[ $? -ne 0 ] && sts=$?
		done
	else
		sts=${line#logto.sh return status=}
		break
	fi
done
exit $sts
