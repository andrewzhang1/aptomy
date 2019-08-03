##
## This is a maven project with the wordcount code.
##

## A. To compile the project using maven
    mvn clean package


## B. To Run the program use
   ./list_commands.sh
            
                
## C. How to run a map/reduce job.

## Step 1. Delete
#   hdfs dfs -rmdir /data/wordcount/output

## Step 2. 
#   hadoop jar ./target/grid.util-1.0.0-fat.jar edu.ucsc.grid.util.Driver  /data/wordcount/input  /data/wordcount/output

