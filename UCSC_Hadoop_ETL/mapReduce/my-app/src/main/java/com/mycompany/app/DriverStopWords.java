/*
 * Project: UC Santa Cruz Extension
 * Program: Big Data / Hadoop in Java
 * Date: 01-10-2018
 * Creator: Marilson Campos
 */

package com.mycompany.app;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.apache.log4j.Logger;

import java.util.Arrays;

public class DriverStopWords extends Configured implements Tool {

  private static Logger logger = Logger.getLogger(DriverStopWords.class);

  public static void main(String[] args) throws Exception {
    int res = ToolRunner.run(new DriverStopWords(), args);
    System.exit(res);
  }

  public int run(String[] args) throws Exception {
    final String JOB_NAME = "Partitioned Wordcount Job.";
    //String STOP_WORD_FILE = "/shared/grid-mr/data/stop_words.txt";
    String STOP_WORD_FILE = "/data/wordcount/other_data/stop_words.txt";
    Configuration conf = new Configuration();
    Job job = Job.getInstance(conf, JOB_NAME);

    job.setJarByClass(DriverStopWords.class);

    if (args.length != 2) {
      logger.error("Invalid number of parameters");
      logger.info("Usage: hadoop jar <jar> <main-class> <input-dir> <output-dir");
      return 1;
    }
    // Capture the command line parameters.
    Path inputPath = new Path(args[0]);
    Path outputPath = new Path(args[1]);


    // Wire the classes and define data types.
    job.setMapperClass(WordCountStopWMapper.class);
    job.setReducerClass(WordcountReducer.class);
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(IntWritable.class);
    job.setInputFormatClass(TextInputFormat.class);
    job.setOutputFormatClass(TextOutputFormat.class);
    // Sets input and output paths.
    FileInputFormat.setInputPaths(job, inputPath);
    FileOutputFormat.setOutputPath(job, outputPath);
    // Adds the stop word file to the dist cache.
    job.addCacheFile(new Path(STOP_WORD_FILE).toUri());
    logger.info("Added file to the distributed cache: " + STOP_WORD_FILE);


    // Describe the current job properties.
    logger.info("Hadoop job " + job.getJobName());
    logger.info(" Jar file       : " + "[" + job.getJar() + "]");
    logger.info(" Job parameters : " + Arrays.toString(args));

    logger.info("Mapper");
    logger.info("  - mapper class : " + job.getMapperClass());
    logger.info("  - output key class   : " + job.getMapOutputKeyClass());
    logger.info("  - output value class : " + job.getMapOutputValueClass());

    logger.info("Reducer");
    logger.info("  - reducer class  : " + job.getReducerClass());

    logger.info("Partition");
    logger.info("  - partitioner class  : " + job.getPartitionerClass());

    logger.info("Input format class  : " + job.getInputFormatClass());

    logger.info("Output");
    logger.info("  - format class : " + job.getOutputFormatClass());
    logger.info("  - key class    : " + job.getOutputKeyClass());
    logger.info("  - value class  : " + job.getOutputValueClass());

    logger.info("HDFS locations");
    logger.info("  - Input  : " + inputPath);
    logger.info("  - Output : " + outputPath);

    return job.waitForCompletion(true) ? 0 : 1;
  }

}

