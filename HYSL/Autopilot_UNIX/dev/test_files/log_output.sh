#!/usr/bin/ksh

if [ -z "$1" ]; then
	echo "log_output.sh <lof-file> [ <lines> ]"
	exit 1
fi
outf=$1
if [ -n "$2" ]; then
	lines=$2
else
	lines=3000
fi
	
let tail_lines="$lines - 1"

while read line; do
	echo $line >> $outf
	lc=`cat "$outf" | wc -l`
	if [ $lc -gt $lines ]; then
		tail -$lines "$outf" > "$outf.tmp"
		rm -f "$outf"
		mv -f "$outf.tmp" "$outf"
	fi
done

