/*
 * Project: UC Santa Cruz Extension
 * Program: Big Data / Hadoop in Java
 * Date: 01-10-2018
 * Creator: Marilson Campos
 */

package com.mycompany.app;

import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class WordcountMapper extends Mapper<LongWritable, Text, Text, IntWritable> {

  private static final IntWritable ONE = new IntWritable(1);

  @Override
  protected void map(LongWritable offset, Text line, Context context)
      throws IOException, InterruptedException {
    for (String word : line.toString().split(" ")) {
      context.write(new Text(word), ONE);
    }
  }
}
