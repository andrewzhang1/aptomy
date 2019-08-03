#!/bin/bash
#: Author: Andrew Zhang
#: Script name: gpuTest2-1_compare.sh 
#: Reviewers:
#: Date: 7/20/2016
#: Purpose:   Test the comparison: annotations.snail vs annotationsh5.
#: Command line sample:



#: Note: need to set a few system env:
# For examples:
# export TOOL_HOME=/home/genia/azhang/GPU_TEST_HOME/snail-tools/snail_tools
# export RUN_PATH_misty=/home/genia/rigdata/misty/160720_SIG-A_02_misty_WAQ20R03C15/P_00_160721010727_s16-master_ac-analysis_v11.10.0.dev.siga_3.2


# gpuTestMain.sh 160722 flareon  160722_SIG-A_02_flareon_WAG23R08C11

# 1. Need to set .set under $HOME by: ". .set"

# Modification History
# 07/21/2016: Define a few variabls for the run name:
# 07/26/2016: Added $4 as the P_* for various ac analysis for the same run (as per Chuck, more 
#             results is better.
# 08/02/2016: Modified the $4 from P_* into the full name as I created a new script that will require a full nane of the P_* 
#             as a directory name.

export RUN_LOC=/home/genia/rigdata 
export DATE=$1          # Specify the date to run.
export STATION_NAME=$2  # Specify the reader station's name.
export RUN_NAME=$3      # Specify the runame for the reader station.
export P_NUM=$4         # Specify the folder name for the annoations.h5 where ac analysis is run
                        # (must be in the format of two digits: 00, 02, etc.

#set -x

# for RUN in RUN1 RUN2 RUN3

echo "Check a few env settings now:"
echo "SNAIL_PATH is: `echo $SNAIL_HOME`"
echo " "
echo "Runing the GPU test now for `echo $3`..."

# IF no folder, create:
cd $GPU_TEST_HOME/result
if [ ! -d "$1" ]; then
    # Create a folder of as the date to store the gpu test results:
    mkdir $1
    echo "Folder $1 was created."
fi

cd  $GPU_TEST_HOME/result/$1
if [ ! -d "$3" ]; then
    # Create a folder of as the date to store the gpu test results:
    mkdir $3
    echo "Folder $3 was created."
fi

# Start the comparison test:
python $SNAIL_HOME/compare_snail_vs_ac_analysis.py \
    --snail $RUN_LOC/$STATION_NAME/$RUN_NAME/upload_to_s3/annotations.snail \
    --ref $RUN_LOC/$STATION_NAME/$RUN_NAME/$4/annotations.h5 \
    --output $GPU_TEST_HOME/result/$1/$3 \
    --summary-file $GPU_TEST_HOME/result/summary.csv \
    --write-plots 
#    --sptol 0.2


echo ""
echo "The summary file is  at: `echo $GPU_TEST_HOME/result`" 
echo "=================================================================="
#cd $GPU_TEST_HOME/result
#ls -l

echo ""
echo -e "And the png + csv files are at: `echo $GPU_TEST_HOME/result/$1/$3` \n"
echo "============================================================================================="

echo "=== Test is done for $3 ==="

