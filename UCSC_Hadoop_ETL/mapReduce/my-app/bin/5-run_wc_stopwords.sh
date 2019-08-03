#!/bin/bash -e

###
##- This file runs the Hadoop job for wordcount using a stop words file.
###

export CLASSPATH=/usr/lib/hadoop/client-0.20/\*

#cd /shared/grid-mr/
cd /home/cloudera/workspace/grid-mr/

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

CMD="hadoop jar ./target/grid.mr-1.0.0-fat.jar edu.ucsc.grid.mr.DriverStopWords  /data/wordcount/input  /data/wordcount/output"
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
