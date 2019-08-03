#/bin/bash
###############################################################################
#: Author: Andrew Zhang
#: Script name: gpuTest2_runCommandLine.sh  
#: Reviewers:
#: Date: 8/02/2016
#: Purpose:   This is the main script to call a temp script in which contains the daily run.
#: Note: Need a few  parameters on the command line 
#: Command line: gpuTest2_runCommandLine.sh TodayAnnotaions_160727.txt 
#: Note: This "TodayAnnotaions_*.txt" needes to be already cleaned up by sed command.
#: Input parameters: 
# #############################################################################

#: History:
# 10/13/2016: Andrew
# Added one log to track this run

export log=gpuTest_compare_${1}.log

if [ $# != 1 ]; then
    echo "You need one (and only one) argument: the input file for the collection of the annotations.h5 file!"
    echo "The file looks like: "TodayAnnotaions_*.txt""
   exit
fi

#if [ -f $GPU_TEST_HOME/log/$log ]; then
 #   rm $GPU_TEST_HOME/log/$log
#fi


cat $GPU_TEST_HOME/log/TodayAnnotaions_$1.txt | 
while read line 
do
    echo -e "\nStarts a new run now:"
    echo -e "\n=====================\n"
    echo "$line"
    set $line
    echo "Run name is: $2" 
    echo "The P_* folder name is: $3 "

    # Define these two evn at this stage:
    export RUN_NAME=$2
    export P_NUM_DIR=$3

    #Find a way to get the machine name from "160726_SIG-A_01_drowzee_WAG25R07C09"
    
    #Station_Name=`echo "160728_ENG-SYS_04_sunkern_WAQ22R07C04" | cut -d"_" -f4`
    #Station_Name=`echo $2 | cut  -d"_" -f4`
   
    # Cut and define the date and station name from the run name of $2:
    set $2
    DATA=`echo $1 | cut  -d"_" -f1`
    MACH_NAME=`echo $1 | cut  -d"_" -f4` 
   
    echo ""
    echo "==== Summary of the 4 arguments required for the next process: ===="
    echo "1. Date is: $DATA" 
    echo "2. Machine name is: $MACH_NAME"
    echo "3. Run Name is: $RUN_NAME" 
    echo "4. P_*_foler is: $P_NUM_DIR"
    echo "" 
   # call gpuTestMain.sh after defined four parameters:
   # $1: Date,
   # $2: machine_name,
   # $3: Run_name,
   # $4: number of the run, such as: P_00_160802173759_s16-master_ac-analysis_v11.12.0
  
   # gpuTestMain.sh $1 $2 $3 $4
   # Note: The squence of the $1, $2, $3, $4 is different due to above steps. 
   # Sample: gpuTestMain.sh 160727 drowzee 160727_SIG-A_01_drowzee_WAG25R07C09 P_*

#   if [ -f $GPU_TEST_HOME/log/$log ]; then
#       rm $GPU_TEST_HOME/log/$log
#   fi

# Start 
    echo "--- Start to run to comparison ---"
    echo "==================================== "
    echo "Command Line: "
    echo "gpuTest2-1_compare.sh  $DATA $MACH_NAME $RUN_NAME $P_NUM_DIR" >> $GPU_TEST_HOME/log/$log
    gpuTest2-1_compare.sh  $DATA $MACH_NAME $RUN_NAME $P_NUM_DIR >> $GPU_TEST_HOME/log/$log 
    wait 
done
