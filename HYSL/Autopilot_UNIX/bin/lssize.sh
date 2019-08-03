#!/usr/bin/ksh

ls -l $@ 2> /dev/null | grep -v "^total" |  while read att id usr grp sz d1 d2 d3 fn
do
	t=$sz
	d=
	while [ "${#t}" -gt 3 ]; do
		[ -n "$d" ] && d=",${d}"
		d="${t#${t%???}}${d}"
		t=${t%???}
	done
	if [ -n "$t" ]; then
		[ -n "$d" ] && d="$t,$d" || d=$t
	fi
	
	sz="                    ${d}"
	sz=${sz#${sz%???????????????}}
	echo "$sz ${fn##*/}"
done | sort


