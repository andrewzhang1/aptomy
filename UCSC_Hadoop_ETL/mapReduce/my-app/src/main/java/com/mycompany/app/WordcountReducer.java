/*
 * Project: UC Santa Cruz Extension
 * Program: Big Data / Hadoop in Java
 * Date: 01-10-2018
 * Creator: Marilson Campos
 */


package com.mycompany.app;

import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

public class WordcountReducer extends Reducer<Text, IntWritable, Text, IntWritable> {

  @Override
  protected void reduce(Text key, Iterable<IntWritable> values, Context context)
      throws IOException, InterruptedException {

    int finalCount = 0;
    for (IntWritable partialCount : values) {
      finalCount += partialCount.get();
    }
    context.write(key, new IntWritable(finalCount));
  }

}
