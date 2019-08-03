#!/bin/bash -e
# Script Name: 4-run_wc_partitioned.sh

###
##- This file runs the Hadoop job for wordcount using partitions.
###

#export CLASSPATH=/usr/lib/hadoop/client-0.20/\*
#cd /home/cloudera/workspace/grid-mr/

#export CLASSPATH=/usr/hdp/2.6.4.0-91/hadoop/lib/*

#cd /shared/grid-mr/
#cd /home/cloudera/workspace/my-app/
cd /home/azhang/workspace_mapR/my-app


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

CMD="hadoop jar ./target/mycompany.app-1.0.0-fat.jar com.mycompany.app.DriverPartitioned  /data/wordcount/input  /data/wordcount/output"
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

echo " "
echo "---- x x x ----"
