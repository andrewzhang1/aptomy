#!/bin/bash -e
#Scrit Name: a-load_data.sh
# Command Line:  nohup a-load_data.sh > a-load_data.sh.out &

###
##- This file generates and loads the wordcount data into HDFS.
###

#cd /shared/grid-mr/
# cd /home/azhang/workspace_mapR/my-app
cd /mnt/AGZ1/Hortonworks_home/azhang/UCSC_Hadoop/mapReduce/my-app

echo " "
echo "----- Delete the input hdfs dir -----"
CMD="hdfs dfs -rm -R /data/wordcount/input"
echo "> $CMD"
eval $CMD || true
echo " " 


echo "----- Re-create the input hdfs dir -----"
CMD="hdfs dfs -mkdir -p /data/wordcount/input"
echo "> $CMD"
eval $CMD || true
echo " " 


echo "----- Generating the data  -----"

echo -e "Hadoop is the elephant king \\nA yellow and elegant thing\\nHe never forgets\\nUseful data or lets\\nAn extraneous element cling " > /tmp/HadoopPoem0.txt
echo -e "A wonderful king is Hadoop \\nThe elephant plays well with Sqoop \\nBut what helps him to thrive\\nAre Impala and Hive \\nAnd HDFS in the group" > /tmp/HadoopPoem1.txt
echo -e "Hadoop is an elegant fellow\\nAn elephant gentle and mellow\\nHe never gets mad\\nOr does anything bad\\nBecause he is yellow" > /tmp/HadoopPoem2.txt


echo "----- Loading in HDFS  ---- "
echo " "

hdfs dfs -put /tmp/HadoopPoem* /data/wordcount/input 

sleep 5s

echo " "
echo "----- List the local file ----"
echo " "

CMD='hdfs dfs -ls /data/wordcount/input'
echo "> $CMD"
eval $CMD

echo ' '
echo '---- x x x ----'


