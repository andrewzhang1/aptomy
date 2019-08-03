from pyspark import SparkConf, SparkContext

conf = SparkConf().setMaster("local").setAppName("PopM")
sc = SparkContext(conf = conf)

data = sc.textFile("file:///shared/data/data_movies/ratings.csv")
header = data.first()
lines = data.filter(lambda row: row != header)
movies = lines.map(lambda x: (int(x.split(',')[1]), 1))
movieCounts = movies.reduceByKey(lambda x, y: x + y)

flipped = movieCounts.map( lambda (x, y) : (y, x) )
sortedMovies = flipped.sortByKey(ascending=False)

results = sortedMovies.take(10)

with open('results.txt', 'w') as res:
    for record in results:
    	res.write('{0},{1}\n'.format(record[0], record[1]))
