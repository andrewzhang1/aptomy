from pyspark import SparkConf, SparkContext


def load_movie_names():
    movie_names = {}
    with open("/shared/data/data_movies/movies.csv") as mv:
        for idx, line in enumerate(mv):
            if idx == 0:
                continue
            fields = line.split(':')
            movie_names[int(fields[0])] = fields[1]
    return movie_names


conf = SparkConf().setMaster("local").setAppName("PopMovies v1")
sc = SparkContext(conf=conf)

id_to_name_dict = sc.broadcast(load_movie_names())

data = sc.textFile("file:///shared/data/data_movies/ratings.csv")
header = data.first()
ratings = data.filter(lambda row: row != header)

movies = ratings.map(lambda x: (int(x.split(',')[1]), 1))
movie_counts = movies.reduceByKey(lambda x, y: x + y)

count_id_records = movie_counts.map(lambda (x, y): (y, x))
sorted_movies = count_id_records.sortByKey(ascending=False)

sorted_movie_names = sorted_movies.map(
    lambda (count, movie_id): (id_to_name_dict.value[movie_id], count))

results = sorted_movie_names.take(20)

with open('results.txt', 'w') as res:
    for record in results:
        res.write('{0}\t{1}\n'.format(record[1], record[0]))
