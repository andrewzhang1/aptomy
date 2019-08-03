#!/bin/bash

# Bash script to submit commands to hive and save results to a file.

hive <<EOF> create_tab_movies.sql.out

DROP TABLE movies;

show databases;

CREATE EXTERNAL TABLE movies (
    movie_id INT,
    title STRING,
    genres ARRAY<STRING>)
  ROW FORMAT DELIMITED
  FIELDS TERMINATED BY ':'
  COLLECTION ITEMS TERMINATED BY '|'
  LINES TERMINATED BY '\n'
  STORED AS TEXTFILE
  LOCATION "/data/movies_v1/movies";
                              
  SHOW TABLES;
  DESC movies;
  show databases;

quit;
EOF

