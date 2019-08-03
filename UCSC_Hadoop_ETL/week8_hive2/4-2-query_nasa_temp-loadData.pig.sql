-- Script Name: 4-2-query_nasa_temp-loadData.pig.sql

-- Purpose: Looking at the data using pig – part 2

page_reqs = FOREACH small_page
  GENERATE
address as site;
  sites_pages = GROUP page_reqs
  BY(site);
results = FOREACH sites_pages
  GENERATE
    FLATTEN(group),
    COUNT(page_reqs) AS count;
DUMP results;
