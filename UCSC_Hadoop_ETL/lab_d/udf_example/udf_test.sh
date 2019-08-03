#!/bin/bash

hive <<EOF

ADD JAR /mnt/AGZ1/Hortonworks_home/azhang/UCSC_Hadoop_ETL/lab_d/jars/grid.udf-1.0.0-fat.jar;  

CREATE TEMPORARY FUNCTION year_date AS 'edu.ucsc.grid.udf.DateYear';

select year_date("2018-01-02 00:00:00");

EOF
