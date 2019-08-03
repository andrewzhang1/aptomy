-- Script Name: 2-nasa_daily_v2-Partition.sql

CREATE TABLE nasa_daily_v2(
  address STRING,
  html_page STRING COMMENT "the page",
  http_code STRING,
  size INT
)
PARTITIONED BY(dt_date STRING);
