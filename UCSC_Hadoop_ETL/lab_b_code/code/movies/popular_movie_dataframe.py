from pyspark.sql import SparkSession
from pyspark.sql import Row
from pyspark.sql import functions


def load_movie_names():
    movie_names = {}
    with open("/shared/data/data_movies/movies.csv") as mv:
        for idx, line in enumerate(mv):
            if idx == 0:
                continue
            fields = line.split(':')
            movie_names[int(fields[0])] = fields[1]
    return movie_names


spark = SparkSession.builder.appName("PopMovies v2").getOrCreate()

id_to_name_dict = load_movie_names()

data = spark.sparkContext.textFile("file:///shared/data/data_movies/ratings.csv")
header = data.first()
ratings = data.filter(lambda row: row != header)

movies = ratings.map(lambda x: Row(movieID=int(x.split(',')[1])))
movie_dataset = spark.createDataFrame(movies)

top_movie_ids = movie_dataset.groupBy("movieID").count().orderBy("count", ascending=False).cache()

top_movie_ids.show()

top10 = top_movie_ids.take(20)

with open('results.txt', 'w') as res:
    for record in top10:
        res.write('{0}\t{1}\n'.format(record[1], id_to_name_dict[record[0]]))


