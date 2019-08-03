#!/usr/bin/ksh
# 06/04/2008 YK - Add log and xcp file location to $HYPRION_HOME/logs/essbase/
# 09/23/2008 YK - Add installer kind 
# 11/14/2008 YK - Add SXR_HOME information.
# 02/05/2009 YK - Put analyzed dif record into .rtf file.
# 03/30/2012 YK - Check HSS mode
# 06/06/2012 YK - Add GTLF_testunit name.
# 01/17/2013 YK - Bug 16187011 - RTF FILE DISPLAY WRONG TIME STAMP FOR THE SNAPSHOT.
#                 Bug 16186568 - START AND END TIMES IN RESULT RTF FILE DOESN'T SHOWUP THE TIME ZONE
# 03/12/2013 YK - Support workaround.txt

cd $SXR_WORK
echo "CHECKING REGRESSION RESULTS FROM ${LOGNAME}@`uname -n`(`get_platform.sh`):"
date 
echo "CURRENT WORKING DIRECTORY IS: "$(pwd) 

# MAKE SNAPSHOT TS
updt_ts=`get_snapshot_ts.sh`
[ -z "$updt_ts" ] && updt_ts="No date record"
echo "\$SXR_HOME=$SXR_HOME($updt_ts)"

echo "USE `get_instkind.sh -l`"
#if [ -f "$HYPERION_HOME/refresh_version.txt" ]; then
#	tmp=`cat $HYPERION_HOME/refresh_version.txt`
#	echo "USE REFRESH COMMAND $tmp"
#elif [ -f "$HYPERION_HOME/opack_version.txt" ]; then
#	tmp=`cat $HYPERION_HOME/opack_version.txt`
#	echo "USE OPACK INSTALLER $tmp"
#elif [ -f "$HYPERION_HOME/hit_version.txt" ]; then
#	tmp=`cat $HYPERION_HOME/hit_version.txt`
#	echo "USE HIT INSTALLER $tmp"
#elif [ -f "$HYPERION_HOME/bi_version.txt" ]; then
#	tmp=`cat $HYPERION_HOME/bi_version.txt`
#	echo "USE BISHIPHOME INSTALLER $tmp"
#else
#	tmp=`get_ess_ver.sh`
#	echo "USE CD INSTALLER $tmp"
#fi
gtlfu=`get_gtlftu.sh ${1%% *}`
[ -n "$gtlfu" ] && echo "GTLF_testunit: $gtlfu"
if [ "$SXR_MODE" = "1" ]; then
	echo "RUNNING UNDER HSS MODE."
elif [ "$SXR_MODE" = "2" ]; then
	echo "RUNNING UNDER BI($AP_SECMODE) MODE."
else
	echo "RUNNING UNDER NATIVE MODE."
fi

echo "======================================================================================="

if [ -f "$HYPERION_HOME/workaround.txt" ]; then
	echo "USING FOLLOWING WORKAROUNDS:"
	(IFS=
		cat $HYPERION_HOME/workaround.txt | while read line; do
			echo "  $line"
		done
	)
	echo "======================================================================================="
fi
# /scratch/ykono/hyperion/11.1.2.2.500_BI_AMD64/instances/instance1/diagnostics/logs/Essbase/essbaseserver1/essbase
if [ "$AP_SECMODE" = "rep" ]; then
	LOGLOC="${ARBORPATH%/*/*}/diagnostics/logs${ARBORPATH#${ARBORPATH%/*/*}}/essbase"
	[ ! -d "$LOGLOC" ] && unset LOGLOC
fi
if [ -z "$LOGLOC" ]; then
	if [ -d "$HYPERION_HOME/logs/essbase" ]; then
		LOGLOC="$HYPERION_HOME/logs/essbase"
	else
		LOGLOC="$ARBORPATH"
	fi
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
	if [ -d "$LOGLOC" ]; then
		find $LOGLOC -name "*.xcp"
	else
		echo "Cannot access $LOGLOC folder."
	fi
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
	if [ -f "$LOGLOC/ESSBASE.log" ]; then
		grep -i 'fatal ' $LOGLOC/ESSBASE.log
	else
		echo "Cannot access $LOGLOC/ESSBASE.log"
	fi
	echo ""
	echo ""
	echo "Listing all the diff files:"
	echo "*************************************************************************"
	if [ -f "difs.rec" ]; then
		cat difs.rec | while read dfile ddetail; do
			# dts=`ls -l $dfile`
			echo "${dfile}	[${ddetail}]"
			#NEW# echo "${dfile} # [${ddetail}]"
		done
	else
		ls -l *.dif
	fi
	echo ""

	checksog='respond network "file handle" segmentation "network error: cannot send"'
	checklog='"fatal "'
		find $LOGLOC -name "*.xcp" | while read xcp
		do
			cp $xcp .
			bn=`basename $xcp`
			bbn=${bn%.*}
			[ -d "$LOGLOC/app/${bbn}" ] && cp "$LOGLOC/app/${bbn}/*.log" . 2> /dev/null
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
	if [ -d "$LOGLOC" ]; then
		find $LOGLOC -name "*.xcp"
	else
		echo "Cannot access $LOGLOC folder."
	fi
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
	if [ -f "$LOGLOC/Essbase.log" ]; then
		cat $LOGLOC/Essbase.log 2> /dev/null | grep -i 'fatal ' 
	else
		echo "Cannot access $LOGLOC/Essbase.log"
	fi
	echo ""
	echo ""
	echo "Listing all the diff files:"
	echo "*************************************************************************"
	if [ -f "difs.rec" ]; then
		cat difs.rec | while read dfile ddetail; do
			# dts=`ls -l $dfile`
			echo "${dfile}	[${ddetail}]"
			#NEW# echo "${dfile} # [${ddetail}]"
		done
	else
		ls -l *.dif
	fi
	echo ""
	checksog='network coredump serious respond "file handle" segmentation "network error: cannot send"'
	checklog='"fatal "'
		find $LOGLOC -name "*.xcp" | while read xcp
		do
			cp $xcp .
			bn=`basename $xcp`
			bbn=${bn%.*}
			cp "$LOGLOC/app/${bbn}/*.log" . 2> /dev/null
		done
		cp $LOGLOC/Essbase.log .
		find $LOGLOC/app -name "*.txt" | while read txt
		do
			rm -f $txt 2> /dev/null
		done

else
        echo "Unknown OS, Unable gather results"
fi

if [ -f "$AUTOPILOT/mon/${LOGNAME}@$(hostname).ap.vdef.txt" \
	-o -f "$AUTOPILOT/mon/${LOGNAME}@$(hostname).reg.vdef.txt" ]; then
	echo "Predefined variables:"
	echo "*************************************************************************"
	if [ -f "$AUTOPILOT/mon/${LOGNAME}@$(hostname).ap.vdef.txt" ]; then
		echo "### before autopilot.sh ###"
		cat "$AUTOPILOT/mon/${LOGNAME}@$(hostname).ap.vdef.txt" | while read line; do
			echo "  $line"
		done
		echo ""
	fi		
	if [ -f "$AUTOPILOT/mon/${LOGNAME}@$(hostname).reg.vdef.txt" ]; then
		echo "### before start regression ###"
		cat "$AUTOPILOT/mon/${LOGNAME}@$(hostname).reg.vdef.txt" | while read line; do
			echo "  $line"
		done
		echo ""
	fi		
	echo ""
fi

if [ -f anafile ]; then
	cat anafile
fi

echo ""
echo "======================================================================================="
