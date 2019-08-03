# UCSC_Hadoop_ETL

### Setup:
hortonworks sandbox on VMWare 

This project shows how to run hive in a batch mode, for example:

```
/mnt/AGZ1/Hortonworks_home/azhang/UCSC_Hadoop/week8_hive_partition
(azhang@sandbox-hdp.hortonworks.com)\>ls -l
total 29
-rwxr-xr-x 1 azhang root   187 Mar 25 21:57 1-nasa_daily_v1-No_Partition.sql
-rwxr-xr-x 1 azhang root   197 Mar 25 21:58 2-nasa_daily_v2-Partition.sql
-rwxr-xr-x 1 azhang root   370 Mar 27 09:38 3-nasa_temp.sql
-rwxr-xr-x 1 azhang root   381 Mar 27 10:18 3-nasa_temp-temp.sql
-rwxr-xr-x 1 azhang root   700 Mar 27 09:38 4-1-query_nasa_temp-loadData.pig.sql
-rwxr-xr-x 1 azhang root   317 Mar 27 09:53 4-2-query_nasa_temp-loadData.pig.sql
-rwxr-xr-x 1 azhang root     0 Mar 26 06:00 4-query_nasa_temp-loadData.pig.sql.out
-rwxr-xr-x 1 azhang root   167 Mar 27 10:20 5-1_insert_nasa_daily_v1.sql
-rwxr-xr-x 1 azhang root   166 Mar 26 06:04 5-insert_nasa_daily_v1.sql
-rwxr-xr-x 1 azhang root   174 Mar 26 06:08 6-insert_nasa_daily_v2.sql
-rwxr-xr-x 1 azhang root    35 Mar 26 16:50 7-Query_data_from_nasa_temp.sql
-rwxr-xr-x 1 azhang root  1009 Mar 29 07:36 7-Query_data_from_nasa_temp.sql.out
-rwxr-xr-x 1 azhang root 10454 Mar 26 05:51 pig_1522043473536.log
-rwxr-xr-x 1 azhang root  2829 Mar 28 18:49 pig_1522144437761.log

```

## Run in batch mode:
```
Run each sql with an outout for verification of the result:

hive -f 7-Query_data_from_nasa_temp.sql > 7-Query_data_from_nasa_temp.sql.out

```
### Check result:
```
Or:

head -2 7-Query_data_from_nasa_temp.sql.out
199.72.81.55    -       -       [01/Jul/1995:00:00:01   -0400]  "GET    /history/apollo/        HTTP/1.0"    200     6245
unicomp6.unicomp.net    -       -       [01/Jul/1995:00:00:06   -0400]  "GET    /shuttle/countdown/     HTTP/1.0"    200     3985

hive -e "select * from nasa_temp limit 10;" > 7-Query_data_from_nasa_temp.sql.out2
log4j:WARN No such property [maxFileSize] in org.apache.log4j.DailyRollingFileAppender.

Logging initialized using configuration in file:/etc/hive/2.6.4.0-91/0/hive-log4j.properties
OK
Time taken: 23.152 seconds, Fetched: 10 row(s)

```

### How to create dynamic parition

