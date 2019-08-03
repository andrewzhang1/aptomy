#!/usr/bin/ksh

if [ $# -ne 1 ]; then
  echo "mkddir.sh <dirname for creating>"
  exit 1
fi

make_directory()
{
	crr_dir=`pwd`

	path_str=${1#?:}	# If windows, remove drive letter
	if [ "$path_str" != "$1" ]; then
		cd "${1%:*}:" 2> /dev/null
		if [ $? -ne 0 ]; then
			echo "Can not change directory to ${1%:*}: drive."
		fi
	fi
	dir=
	while [ -n "$path_str" ]; do
		tmp=${path_str%%/*}
		path_str=${path_str#${tmp}/}
		dir="${dir}$tmp/"
		if [ ! -d "$dir" ]; then
			mkdir "$dir" 2> /dev/null
			[ $? -ne 0 ] && echo "Failed to create $ret."
			chmod 0777 "$dir" 2> /dev/null
		fi
		[ "$tmp" = "$path_str" ] && break
	done
	cd "$crr_dir"
}

make_directory $1
