from pyspark import SparkConf, SparkContext

conf = SparkConf().setMaster("local").setAppName("WordCount")
sc = SparkContext(conf=conf)

'''
dataset = sc.textFile("file:///shared/data/data_wordcount/text.txt")
'''
'''
dataset = sc.textFile("text.txt")
'''

dataset = sc.textFile("file:///mnt/AGZ1/Hortonworks_home/azhang/UCSC_Hadoop/lab_b_code/data/data_wordcount/text.txt")

words = dataset.flatMap(lambda x: x.split())
wordCounts = words.countByValue()

with open('results.txt', 'w') as res:
    for word, count in wordCounts.items():
        cleanWord = word.encode('ascii', 'ignore')
        if cleanWord:
            res.write(cleanWord.decode() + " " + str(count) + '\n')
