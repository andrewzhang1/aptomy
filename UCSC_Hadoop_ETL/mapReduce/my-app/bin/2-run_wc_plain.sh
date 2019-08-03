#!/bin/bash -e

# Scrip Name: b-run_wc_plain.sh
# Command Line: nohup b-run_wc_plain.sh  2>&1 | tee -a b-run_wc_plain.sh.out &
###
##- This file runs the plain Hadoop job for wordcount.
##  It does not include any special configuration but allows the use of combiner.
###

# export CLASSPATH=/usr/lib/hadoop/client-0.20/\*

# Check classpath for horton works: "hdaoop classpath"

export CLASSPATH=/usr/hdp/2.6.4.0-91/hadoop/lib/*

#cd /shared/grid-mr/
# cd /home/azhang/workspace_mapR/my-app 
cd /mnt/AGZ1/Hortonworks_home/azhang/UCSC_Hadoop/mapReduce/my-app

echo " "
echo "----- Delete the target hdfs dir -----"
CMD="hdfs dfs -rm -R /data/wordcount/output"
echo "> $CMD"

eval ${CMD} || true
echo " " 

echo "----- Launching Hadoop Job ---- "
echo " "
echo "  - Ignore the warning: 'WARN hdfs.DFSClient: Caught exception'"
echo "    Its a Hadoop bug described at: https://issues.apache.org/jira/browse/HDFS-10429"
echo "  "


t1=`date +%s`
echo "Now is t1: $t1"

CMD="hadoop jar ./target/my-app-1.0.0-fat.jar com.mycompany.app.Driver  /data/wordcount/input  /data/wordcount/output"
echo "> $CMD"
eval ${CMD}

echo " "
echo "----- List output in HDFS ----"
echo " "
CMD="hdfs dfs -ls /data/wordcount/output/"
echo "> $CMD"
eval ${CMD}

echo " "
echo "----- Pull the results out cluster ----"
echo " "
CMD="hdfs dfs -getmerge /data/wordcount/output /tmp/job_results.txt"
echo "> $CMD"
eval ${CMD}

sleep 5s

echo " "
echo "----- List the local file ----"
echo " "
CMD='cat /tmp/job_results.txt'
echo "> $CMD"
eval ${CMD}

wait

echo "wait to check time spent.."

t2=`date +%s`
let deltatime=t2-t1
let hours=deltatime/3600
let minutes=(deltatime/60)%60
let seconds=deltatime%60

echo -e "\nTotal time in second: $deltatime"
printf "Total time in hour:min:sec: %d:%02d:%02d \n" $hours $minutes $seconds

wait

echo " "
echo "---- x x x ----"
