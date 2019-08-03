#/bin/bash
###############################################################################
#: Author: Andrew Zhang
#: Script name: findMaxMinHighLowMain.sh   
#: Reviewers:
#: Date: 2/16/2017
#: Purpose:   This is the main script to call a temp script in which contains the daily run.
#: Note: Need a few  parameters on the command line 
#: Command line: gpuTest2_runCommandLine.sh TodayAnnotaions_160727.txt 
#: Input parameters: ./findMaxMinHighLowMain.sh 170216
#:
# #############################################################################

#: History:
# 10/13/2016: Andrew
# Added one log to track this run

#export log=gpuTest_compare_${1}.log
export log=anno_stat_result_${1}.csv

if [ $# != 1 ]; then
    echo "You need one (and only one) argument: the input file for the collection of the annotations.h5 file!"
    echo "The file looks like: "TodayAnnotaions_*.txt""
   exit
fi

cat $GPU_TEST_HOME/log/TodayAnnotaions_$1.txt | 
while read line 
do
    echo -e "\nStarts Aa new run now:"
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

    echo "--- Start to run to comparison ---"
    echo "==================================== "
    echo "Command Line: python ....."
    #echo "python $GPU_TEST_HOME/notebook/findMaxMin.py /home/genia/rigdata/$MACH_NAME/$RUN_NAME/$P_NUM_DIR" # >> $GPU_TEST_HOME/log/$log
    ### # gpuTest2-1_compare.sh  $DATA $MACH_NAME $RUN_NAME $P_NUM_DIR >> $GPU_TEST_HOME/log/$log
    python $GPU_TEST_HOME/notebook/findMaxMin.py /home/genia/rigdata/$MACH_NAME/$RUN_NAME/$P_NUM_DIR >> $GPU_TEST_HOME/result/$log 

    wait 
done

## At the end, we need to clean the data by a few steps:
# 1) Remove all the line started with anno_path by:
# sed -e '/anno_path/d' anno_stat_result_170216.csv  > anno_stat_result_170216.csv_new; mv anno_stat_result_170216.csv_new anno_stat_result_170216.csv

# 2) remove the line that the line that its first column is appeared in the another column 
# awk -F' ' 'seen[$1]++' anno_stat_result_170216.csv  > anno_stat_result_170216.csv_new ;\
#     mv anno_stat_result_170216.csv_new anno_stat_result_170216.csv
