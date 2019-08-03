-- Scrip Name: 3-nasa_temp.sql
-- Command Line: hive -f 3-nasa_temp.sql

CREATE EXTERNAL TABLE nasa_temp2(
  address STRING,
  dummy_1 STRING,
  dummy_2 STRING,
  raw_date STRING,
  raw_time STRING,
  dummy_3 STRING,
  html_page STRING,
  http_version STRING,
  http_code STRING,
  isize STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY " "
LOCATION "/data/data_nasa/temp_load";
