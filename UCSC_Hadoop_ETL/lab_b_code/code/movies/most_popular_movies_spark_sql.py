from pyspark.sql import SparkSession
from pyspark.sql import Row

import collections

# Create a SparkSession (Note, the config section is only for Windows!)
spark = SparkSession.builder.appName("PopMovieSparkSQL").getOrCreate()


# userId,movieId,rating,timestamp
def make_row(line):
    fields = line.split(',')
    return Row(
        userId=int(fields[0]),
        movieId=int(fields[1]),
        rating=str(fields[2].encode("utf-8")),
        timestamp=int(fields[3])
    )


data = spark.sparkContext.textFile(
    "file:///mnt/AGZ1/Hortonworks_home/azhang/UCSC_Hadoop/lab_b_code/data/data_movies/ratings.csv")
header = data.first()
lines = data.filter(lambda row: row != header)

ratings = lines.map(make_row)

schemaRatings = spark.createDataFrame(ratings).cache()
schemaRatings.createOrReplaceTempView("ratings")

# Calculate using query string
query = (
    "SELECT q1.movieId, q1.counted FROM "
    " (SELECT movieId, count(*) as counted "
    "  FROM ratings GROUP BY movieId) q1 "
    " ORDER BY q1.counted DESC"
)
movie_counts = spark.sql(query).take(20)

# calculate using sql like functions.
movie_counts2 = schemaRatings.groupBy("movieId").count().orderBy("count",
                                                                 ascending=False).take(
    20)

header = '- ' * 30

print("Method 1")
print(header)
for record in movie_counts:
    print('count={0}, \t id={1}'.format(record.movieId, record.counted))

print(' ')
print("Method 2")
print(header)
for record in movie_counts2:
    print('count={0}, \t id={1}'.format(record[0], record[1]))

spark.stop()
