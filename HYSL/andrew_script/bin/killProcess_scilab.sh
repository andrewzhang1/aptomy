#  ps -fu $LOGNAME  | grep -i essbase > processID
# Commandline: killProcess_scailab.sh scilab

ps -ef $LOGNAME  | grep -i $1 > processID
#ps -ef  | grep -i sh >> processID 
cat processID  |
        while read line
        do
                set $line
                echo $2
                sleep 1
                kill -9 $2
        done

