#  ps -fu $LOGNAME  | grep -i essbase > processID
ps -fu $LOGNAME  | grep -i esscmd > processID
ps -fu $LOGNAME  | grep -i ESSSVR >> processID 
ps -fu $LOGNAME	 | grep -i ESSBASE >> processID
#ps -ef  | grep -i sh >> processID 
cat processID  |
        while read line
        do
                set $line
                echo $2
                sleep 1
                kill -9 $2
        done
