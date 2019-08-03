/*
 * Project: UC Santa Cruz Extension
 * Program: Big Data / Hadoop in Java
 * Date: 01-10-2018
 * Creator: Marilson Campos
 */

package com.mycompany.app;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.net.URI;
import java.util.HashSet;
import java.util.Set;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.util.StringUtils;

public class WordCountStopWMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
  private static final IntWritable ONE = new IntWritable(1);
  private Set<String> stopWords = new HashSet<String>();

  protected void setup(Mapper.Context context) throws IOException {
    // Since we are only adding one file to the cache, just pick the first one.
    URI[] cachedFiles = context.getCacheFiles();
    loadStopWords(cachedFiles[0]);
  }

  private void loadStopWords(URI anURI) {
    try {
      BufferedReader stopWordsFile = new BufferedReader(
          new FileReader(new File(anURI.getPath()).getName()));
      String stopWord;
      while ((stopWord = stopWordsFile.readLine()) != null) {
        stopWords.add(stopWord);
      }
    } catch (IOException error) {
      System.err.println("Error loading Stop Words '"
          + anURI + "' : " + StringUtils.stringifyException(error));
    }
  }

  @Override
  protected void map(LongWritable offset, Text line, Context context)
      throws IOException, InterruptedException {
    for (String word : line.toString().split(" ")) {
      if (word.isEmpty() || stopWords.contains(word)) {
        continue;
      }
      context.write(new Text(word), ONE);
    }
  }
}
