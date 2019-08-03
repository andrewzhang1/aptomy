# aptomy control script for scilab to process data
# V0.51
# Andrew 2015/05/14
# Notice: Still harded coded for all the pathes

while true 
do cd

    cd /home/azhang/aptomy_v0.51/inputfolder

    VAR=`(ls -t *.txt | tail -1)`
    echo $VAR
    
    if [ ! -z "$VAR" ]; then
        echo "Call scilab "
        echo "The file to be processed is: $VAR"

        while true
            do
            VAR2=`(ls -t *.txt  | tail -1)`
            if [ "VAR2" != "$VAR" ]; then
            cd   /home/azhang/aptomy_v0.51
            scilab -nw -args /home/azhang/aptomy_v0.51 $VAR PrintModulev4.py \
            -f /home/azhang/aptomy_v0.51/Import_Kin_Data_v10sh.sce

           echo "File processed; move to next file"
           sleep 1
           break 
      fi
      done
 fi
      sleep 1
 done



