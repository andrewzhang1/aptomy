
echo 'select a task'
select TASK in 'check mounts' 'check disk space' 'check Memoru usage'
do 
    case $REPLY in
        1) TASK=mount;;
        2) TASK="df -h";;
        3) TASK="free -m";;
        *) echo ERROR && exit2;;
    esac
    if [ -n "$TASK" ]
    then
        clear
        $TASK
        break
    else
        echo Invalid CHOICE && exit 3
    fi
done
