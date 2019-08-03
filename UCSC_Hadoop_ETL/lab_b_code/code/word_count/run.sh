#!/bin/bash

# command line: nohup run.sh > run.sh.out &

spark-submit ./word_count.py

cat ./results.txt

