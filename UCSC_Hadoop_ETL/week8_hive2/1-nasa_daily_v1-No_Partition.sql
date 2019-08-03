-- Script Name: 1-nasa_daily_v1-No_Partition.sql

CREATE TABLE nasa_daily_v1(
  address STRING,
  html_page STRING COMMENT "the page",
  http_code STRING,
  size INT,
  dt_date STRING
);
