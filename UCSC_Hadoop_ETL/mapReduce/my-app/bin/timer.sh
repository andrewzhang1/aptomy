
# A untility to cala the total time required 
# Command Line: timer.sh  

t1=`date +%s`
echo "Now is t1: $t1"

if [ -z "$1" ]; then
    echo "You need an argument, such as script name"
    exit 1
fi

if [ -f ${1}.out ]; then
    rm ${1}.out
fi


echo "We are going to run $1..."
./$1 2>&1 | tee -a ${1}.out

wait

t2=`date +%s`

let deltatime=t2-t1
let hours=deltatime/3600
let minutes=(deltatime/60)%60
let seconds=deltatime%60

echo -e "\nTotal time in second for ${1}: $deltatime"
printf "Total time in hour:min:sec: %d:%02d:%02d \n" $hours $minutes $seconds

