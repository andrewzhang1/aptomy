#!/bin/bash

# script name: createDB.sh

# Bash script to submit commands to hive and save results to a file.

hive <<EOF | tee createDB.sh.out 

show databases;
DROP DATABASE IF EXISTS UCSC_hive_test;
CREATE DATABASE UCSC_hive_test;

show databases;

EOF

