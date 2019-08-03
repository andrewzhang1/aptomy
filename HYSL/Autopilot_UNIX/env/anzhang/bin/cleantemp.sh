#!/bin/ksh

echo "Cleaning Temp Directories..."

CURRENT_DIRECTORY=`pwd`
LOGINNAME=`logname`

cd /var/tmp
ls -l | grep $LOGINNAME | while read line ; do
	MYTMP=`echo $line | awk '{print $9}'`
	chmod -R u+rwx $MYTMP
	rm -fR $MYTMP
done

cd /tmp
ls -l | grep $LOGINNAME | while read line ; do
	MYTMP=`echo $line | awk '{print $9}'`
	chmod -R u+rwx $MYTMP
	rm -fR $MYTMP
done

cd $CURRENT_DIRECTORY
echo "Cleaning Temp Directories COMPLETED."
