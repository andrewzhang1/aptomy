-- Script Name: query_nasa_temp.sql
-- Command line: pig -f 4-query_nasa_temp-loadData.pig.sql

data = LOAD '/data/nasa'
    USING PigStorage(' ')
    AS (address:chararray,
        host:chararray,
        dummy_2:chararray,
        raw_date:chararray,
        raw_time:chararray,
        dummy_3:chararray,
        html_page:chararray,
        http_code:chararray,
        size:int);
SPLIT data INTO
    large_page IF size>20000,
    medium_page IF size<=20000 AND size>5000,
    small_page IF size<5000; 
page_reqs = FOREACH small_page GENERATE address as site;
sites_pages = GROUP page_reqs BY(site);
results = FOREACH sites_pages GENERATE FLATTEN(group), COUNT(page_reqs) AS count;
DUMP results;
