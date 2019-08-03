# 06/04/2008 YK - Add log and xcp file location to $HYPRION_HOME/logs/essbase/
# 09/23/2008 YK - Add installer kind 
# 11/14/2008 YK - Add SXR_HOME information.
# 02/05/2009 YK Put analyzed dif record into .rtf file.

cd $SXR_WORK
echo "CHECKING REGRESSION RESULTS FROM `uname -n`:"
date 
echo "CURRENT WORKING DIRECTORY IS: "$(pwd) 

# MAKE SNAPSHOT TS
[ `uname` = "Windows_NT" ] && updext="UPD" || updext="updt"
updt_ts=`ls $SXR_HOME/../../../*.${updext} 2> /dev/null`
if [ -z "$updt_ts" ]; then
	updt_ts="Dynamic View"
else
	updt_ts=`cat $SXR_HOME/../../../*.${updext} | grep ^StartTime | \
	sed -e s/Jan/01/g -e s/Feb/02/g -e s/Mar/03/g -e s/Apr/04/g \
		-e s/May/05/g -e s/Jun/06/g -e s/Jul/07/g -e s/Aug/08/g \
		-e s/Sep/09/g -e s/Oct/10/g -e s/Nov/11/g -e s/Dec/12/g \
		-e "s/\-/ /g" -e "s/\./ /g" -e "s/\:/ /g" -e "s/^StartTime. *//g" | \
	awk '{printf("%s/%s/%s %s:%s:%s\n", $3, $2, $1, $4, $5, $6)}' | sort | tail -1`
fi
[ "$updt_ts" = "" ] && updt_ts="No date record" || update_ts="$update_ts"
echo "\$SXR_HOME=$SXR_HOME($updt_ts)"

if [ -f "$HYPERION_HOME/refresh_version.txt" ]; then
	tmp=`cat $HYPERION_HOME/refresh_version.txt`
	echo "USE REFRESH COMMAND $tmp"
elif [ -f "$HYPERION_HOME/hit_version.txt" ]; then
	tmp=`cat $HYPERION_HOME/hit_version.txt`
	echo "USE HIT INSTALLER $tmp"
else
	tmp=`get_ess_ver.sh`
	echo "USE CD INSTALLER $tmp"
fi

echo "======================================================================================="

if [ -d "$HYPERION_HOME/logs/essbase" ]; then
	LOGLOC="$HYPERION_HOME/logs/essbase"
else
	LOGLOC="$ARBORPATH"
fi
BOX=$(uname)
 
if [ $BOX = Windows_NT ]
then
        cd $SXR_WORK

	echo "Number of Success: `ls *.suc 2> /dev/null |wc -l`"
	echo "Number of Fails:	`ls *.dif 2> /dev/null |wc -l`"
	echo "Number of total sog files:`ls *.sog 2> /dev/null |wc -l`"
	echo "======================================================================================="
	echo "Executing find $LOGLOC -name *.xcp:"
	echo "*************************************************************************"
		find $LOGLOC -name "*.xcp"
	echo ""
	echo ""
	echo "Executing grep -i respond *.sog:"
	echo "*************************************************************************"
		grep -i respond *.sog
	echo ""
	echo ""
	echo "Executing grep -i network *.sog:"
	echo "*************************************************************************"
		grep -i network *.sog
	echo "Executing grep -i file Handle *.sog:"
	echo "*************************************************************************"
        	grep -i "file handle" *.sog 
	echo ""
	echo ""
	echo "Executing grep -i segmentation *.sog:"
	echo "*************************************************************************"
        	grep -i segmentation *.sog 
	echo ""
	echo ""
	echo "Executing grep -i network error *.sog:"
	echo "*************************************************************************"
        	grep -i "network error: cannot send" *.sog   
	echo ""
	echo ""
	echo "Looking for fatal in Essbase.log:"
	echo "*************************************************************************"
		grep -i 'fatal ' $LOGLOC/ESSBASE.log
	echo ""
	echo ""
	echo "Listing all the diff files:"
	echo "*************************************************************************"
	if [ -f "difs.rec" ]; then
		cat difs.rec | while read dfile ddetail; do
			dts=`ls -l $dfile`
			echo "${dts}\t[${ddetail}]"
		done
	else
		ls -l *.dif
	fi
	echo ""
	echo ""
	echo "======================================================================================="

	checksog='respond network "file handle" segmentation "network error: cannot send"'
	checklog='"fatal "'
		find $LOGLOC -name "*.xcp" | while read xcp
		do
			cp $xcp .
			bn=`basename $xcp`
			bbn=${bn%.*}
			cp "$LOGLOC/app/${bbn}/*.log" .
		done
		cp $LOGLOC/ESSBASE.log .
		find $LOGLOC/app -name "*.txt" | while read txt
		do
			rm -f $txt 2> /dev/null
		done

elif [ $BOX = HP-UX -o $BOX = Linux -o $BOX = AIX -o $BOX = SunOS ]
        then

	if [ $BOX = AIX -o $BOX = Linux ];then
		echo "Number of Success: `perl -e 'print scalar(@files = <*.suc>)'`"
		echo "Number of fails: `perl -e 'print scalar(@files = <*.dif>)'`"
		echo "Number of total sog files: `perl -e 'print scalar(@files = <*.sog>)'`"
	else
		echo "Number of Success: `ls *.suc 2> /dev/null |wc -l`"
		echo "Number of fails: `ls *.dif 2> /dev/null |wc -l`"
		echo "Number of total sog files: `ls *.sog 2> /dev/null |wc -l`"
	fi
	

	echo "======================================================================================="
	echo "Executing find $LOGLOC -name *.xcp:"
	echo "*************************************************************************"
		find $LOGLOC -name "*.xcp"
	echo ""
	echo ""
	echo "Executing grep -i network *.sog:"
	echo "*************************************************************************"
		grep -i network *.sog
	echo ""
	echo ""
	echo "Executing grep -i coredump *.sog:"
	echo "*************************************************************************"
		grep -i coredump *.sog
	echo ""
	echo ""
	echo "Executing grep -i serious *.sog:"
	echo "*************************************************************************"
		grep -i serious *.sog
	echo ""
	echo ""
	echo "Executing grep -i respond *.sog:"
	echo "*************************************************************************"
		grep -i respond *.sog
	echo ""
	echo ""
	echo "Executing grep -i file handle *.sog:"
	echo "*************************************************************************"
        	grep -i "file handle" *.sog 
	echo ""
	echo ""
	echo "Executing grep -i segmentation *.sog:"
	echo "*************************************************************************"
        	grep -i segmentation *.sog 
	echo ""
	echo ""
	echo "Executing grep -i network error *.sog:"
	echo "*************************************************************************"
        	grep -i "network error: cannot send" *.sog   
	echo ""
	echo ""
	echo "Looking for fatal in Essbase.log:"
	echo "*************************************************************************"
		grep -i 'fatal ' $LOGLOC/Essbase.log
	echo ""
	echo ""
	echo "Listing all the diff files:"
	echo "*************************************************************************"
	if [ -f "difs.rec" ]; then
		cat difs.rec | while read dfile ddetail; do
			dts=`ls -l $dfile`
			echo "${dts}\t[${ddetail}]"
		done
	else
		ls -l *.dif
	fi
	checksog='network coredump serious respond "file handle" segmentation "network error: cannot send"'
	checklog='"fatal "'
		find $LOGLOC -name "*.xcp" | while read xcp
		do
			cp $xcp .
			bn=`basename $xcp`
			bbn=${bn%.*}
			cp "$LOGLOC/app/${bbn}/*.log" .
		done
		cp $LOGLOC/Essbase.log .
		find $LOGLOC/app -name "*.txt" | while read txt
		do
			rm -f $txt 2> /dev/null
		done

else
        echo "Unknown OS, Unable gather results"
fi
