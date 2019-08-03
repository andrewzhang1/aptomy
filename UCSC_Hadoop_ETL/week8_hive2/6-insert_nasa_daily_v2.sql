-- Script Name: 6-insert_nasa_daily_v2.sql 

INSERT OVERWRITE TABLE nasa_daily_v2
PARTITION(dt_date="1995-07-01")
SELECT address, html_page, http_code, isize
FROM nasa_temp;
