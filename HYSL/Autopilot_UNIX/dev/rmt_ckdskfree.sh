#!/usr/bin/ksh

targs=
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			echo "${me##*/} <targ-node>|<plat>|all... [!<node>]"
			exit 0
			;;
		all)
			targs="all"
			;;
		*)
			[ -z "$targs" ] && targs=$1 || targs="$targs $1"
			;;
	esac
	shift
done

if [ -z "$targs" ]; then
	echo "No target defined."
	exit 1
fi

list=
for one in $targs; do
	if [ "$one" != "${one#!}" ]; then
		if [ -n "`echo $list | grep ${one#!}`" ]; then
			echo "Remove ${one#!}"
			list="${list%%${one#!}*}${list#*${one#!}}"
		fi
	else
		apctl.sh -c $one | grep -v tasks | while read pl nd d1 st d2 alive; do
			if [ "$alive" = "ALIVE" ]; then
				if [ -n "`echo list | grep $nd`" ]; then
					echo "Duplicate $nd."
				else
					[ -n "$list" ] && list="$list $nd" || list=$nd
					echo "Add $pl $nd."
				fi
			else
				echo "Skip $pl $nd $alive."
			fi
		done
	fi
done

for one in $list; do
	echo "Create apmon.sh restart cmd file for $one"
	cp $AUTOPILOT/dev/rmtscr_ckdskfree.cmd $AUTOPILOT/mon/${one}.cmd
done

