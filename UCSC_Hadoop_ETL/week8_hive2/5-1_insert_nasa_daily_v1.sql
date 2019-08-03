-- Scrip Name: 5-insert_nasa_daily_v1.sql 

INSERT OVERWRITE TABLE nasa_daily_v1
SELECT address, html_page, http_code, isize, "1995-07-01" as dt_date
FROM nasa_temp2;
