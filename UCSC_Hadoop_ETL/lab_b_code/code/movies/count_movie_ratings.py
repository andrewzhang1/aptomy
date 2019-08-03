from pyspark import SparkConf, SparkContext
import collections

conf = SparkConf().setMaster("local").setAppName("CountMovieRatings")
sc = SparkContext(conf=conf)

#lines = sc.textFile("file:///shared/data/data_movies/ratings.csv")
line = sc.textFile("file:///mnt/AGZ1/Hortonworks_home/azhang/UCSC_Hadoop/lab_b_code/data/data_movies/ratings.csv")
ratings = lines.map(lambda x: x.split(',')[2])
result = ratings.countByValue()

with open('results.txt', 'w') as res:
    sortedResults = collections.OrderedDict(sorted(result.items()))
    for key, value in sortedResults.items():
        res.write('{0} {1}\n'.format(key, value))
