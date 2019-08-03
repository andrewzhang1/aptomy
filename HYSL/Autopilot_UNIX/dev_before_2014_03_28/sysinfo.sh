crr=`pwd`

if [ $# -ne 1 ]; then
	echo "Usage: sysinfo.sh <filename>"
	exit 1
fi

[ -n "$SXR_INVIEW" ] && . `sxr which -sh esscmd.func`


OUTFILE=$1
echo "" >> $OUTFILE
echo "Environment:" >> $OUTFILE
echo "*************************************************************************" >> $OUTFILE
echo "which java    : `which java` " >> $OUTFILE 2>&1
echo "which perl    : `which perl` " >> $OUTFILE 2>&1
echo "java -version : " >> $OUTFILE 2>&1
java -version >> $OUTFILE 2>&1
echo "" >> $OUTFILE
env >> $OUTFILE
if [ -n "$SXR_INVIEW" ]; then
	get_os $OUTFILE
	get_sys_cfg system.cfg
	cat $SXR_WORK/system.cfg >> $OUTFILE
else
	echo "" >> $OUTFILE
	echo "##################################" >> $OUTFILE
	echo "### YOU ARE NOT IN A SXR VIEW. ###" >> $OUTFILE
	echo "### AND SKIP TO CORRECT OS AND ###" >> $OUTFILE
	echo "### SYSTEM CONFIG INFORMATIONS.###" >> $OUTFILE
	echo "##################################" >> $OUTFILE
	echo "" >> $OUTFILE
fi