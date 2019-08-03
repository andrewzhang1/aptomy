#!/bin/bash
###############################################################################
#: Author: Andrew Zhang
#: Script name: gpuTest1_getTodayAnnotations.sh 
#: Reviewers:
#: Date: 7/27/2016
#: Purpose:   This is temp script trying to get the Test GPU's comparison for the annotations files.
#: Note: Need a few  parameters on the command line 
#: Command line
# 
#: Note: need to set a few system env:
# Input parameters: 
# $1 = Date,  a parameter as date format, such 160727
# $2 = A machine list for the gpu in text format.

date=$1
gpu_machine_list=$2

if [ $# != 2 ]; then
    echo "You need two arguments: date and gpu_list, in order to run this script!"
   exit
fi

if [ $date -eq 0 ] ; then
    echo "Error: Please specify the date, such as: 160725"
    exit -1
fi

if [ $gpu_machine_list -eq 0 ] ; then
    echo "Error: Please specify gpu machine list."
    exit -1
fi

export RUN_LOC=/home/genia/rigdata

if [ -f $GPU_TEST_HOME/log/TodayAnnotaions_$1.txt ]; then
    rm $GPU_TEST_HOME/log/TodayAnnotaions_$1.txt
fi

cat $2 |
while read station_name
  do
    cd $RUN_LOC/$station_name
    #if ($? -eg 1); then
    echo ""
    echo "We are at: `pwd` now."   
    echo "`find . -name annotations.h5 |grep $_ `"
	find -L . -name  annotations.h5 |grep $1_  >> $GPU_TEST_HOME/log/TodayAnnotaions_$1.txt
    echo ""
    echo "Done with seaching annotations.h5 from  machine: `echo $station_name`!"
    echo "##############################################################"
    #fi
    #sleep 1
done

