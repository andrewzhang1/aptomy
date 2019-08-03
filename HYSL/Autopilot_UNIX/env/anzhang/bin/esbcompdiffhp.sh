#! /usr/bin/sh

export _NULL=$HOME/null.err

DIR1="$1"
DIR2="$2"

echo "XXXXXX" > missing
cat $DIR1 | while read type path; do
	
	dirpath=$(cat missing)

	echo $path | if ! grep -i "$dirpath" > ${_NULL} ; then
		
		if ! fgrep -x "$type $path" $DIR2 > ${_NULL} ; then
			if [ "$type" = "DIR" ]; then 	
				echo $path > missing
			fi
			echo "DIFF: $type $path"
		fi
	fi
done

rm -rf missing
