-- Script Name: create_nasa_daily-Partition.sql
-- This needs to be run before run the python script 

CREATE TABLE nasa_daily(
  ip_address STRING,
  request_time STRING,
  page_url  STRING COMMENT "the page",
  http_code STRING,
  page_size INT
)
PARTITIONED BY(dt_date STRING);
