#!/usr/bin/ksh
maxl=0
for var in $@; do
	[ ${#var} -gt $maxl ] && maxl=${#var}
done
repstr=
spcpad=
while [ $maxl -ne 0 ]; do
	repstr="${repstr}?"
	spcpad="${spcpad} "
	let maxl="$maxl - 1"
done
for var in $@; do
        _str="${var}${spcpad}"
        _str=${_str%${_str#${repstr}}}
        _val=`eval "echo \\$${var}"`
        print -r "\$$_str=$_val"
done

