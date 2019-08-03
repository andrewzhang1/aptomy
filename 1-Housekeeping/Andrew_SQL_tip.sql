select lower(word), count(*) as count
from book1
where lower(substring(word, 1,1)) = 'a'
group by word
having count > 50
order by count desc;


-- Create DB
CREATE DATABASE site_test;

-- create use and assing to db:
grant all privileges on site_test to 'admin'@'localhost' identified by 'ADMIN';

--
# Test Create use, grant, etc server: vmlxu1

show tables;

show grants;