#!/usr/bin/ksh
#
#######################################################################
change_file()
{
	echo "\$TTL 3600" > $1.$$
	cat $1 >> $1.$$
	mv $1.$$ $1

	return
}

#######################################################################
MYNAME=`basename $0`
usage="Usage : $MYNAME [file [file ...]]"

if [ $# -lt 1 ]
then
	print $usage
	exit 1
fi

for file in $*
do
	if [[ ! -f $file ]]
	then
		print "error :$file is not a file"
		print "Skipping this file:- $file"
		continue
	fi
	change_file $file
done


#######################################################################
