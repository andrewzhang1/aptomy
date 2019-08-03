/*
 * Project: UC Santa Cruz Extension
 * Program: Big Data / Hadoop in Java
 * Date: 01-10-2018
 * Creator: Marilson Campos
 */

package com.mycompany.app;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.IntWritable;


public final class WordCountPartitioner extends org.apache.hadoop.mapreduce.Partitioner<Text,IntWritable > {
  @Override
  public int getPartition(Text key, IntWritable value, int numPartitions) {
    String keyStr = key.toString().toLowerCase();
    if (keyStr.startsWith("a")) return 0;
    else return 1;
  }
}



