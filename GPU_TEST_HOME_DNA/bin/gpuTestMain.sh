# Main script to combine all: gpuTestMain.sh
# Group all the scirpts:
# 1. Command: "gpuTestMain.sh 160803
#    (Or we can use "nohup" to run it in the background and get a log file:
#    nohup gpuTestMain.sh 160810 > $GPU_TEST_HOME/log/gpuTestMain_160810.log &

# This script will generate a output: TodayAnnotaions_${1}.txt

if [ $# != 1 ]; then
    echo "You need one argument of date in format like: 160803"
    exit
fi

gpuTest1_getTodayAnnotations.sh ${1} gpu_list.txt
wait

# Remove "/" inside the TodayAnnotaions_${1}.txt. 
sed -i 's/\// /g'  $GPU_TEST_HOME/log/TodayAnnotaions_${1}.txt

# 3. run sed command
echo "sed step is done"
wait

echo "The TodayAnnotaions_${1}.txt is created:"
cat TodayAnnotaions_${1}.txt

# 4. Run the comaprison

gpuTest2_runCommandLine.sh ${1}

