CREATE EXTERNAL TABLE ratings (
      user_id INT,
      movieId INT,
      rating float,
      timestamp bigint)
ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ','
   LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION "/data/movies_v1/ratings";

