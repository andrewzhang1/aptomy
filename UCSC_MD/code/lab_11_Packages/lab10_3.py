#!/usr/bin/env python
"""lab10_3.py  Write a function that takes a file name and 
counts how many times each word appears in the file."""

from __future__ import division
import sys
import string

def CountWords(text, counts_d, total=0):
    """Counts the number of each word in the text.  Returns the 
    total number of words.
    counts_d is a dictionary of {"word":count, "word2":count, ...}
    which can be empty when called.
    """
    text = text.lower().split()
    for word in text:
        word = word.strip(string.punctuation)
        if not word:
            continue
        total += 1
        if word in counts_d:
            counts_d[word] += 1
        else:
            counts_d[word] = 1
    return total

def FindPopularWords(counts_d):
    """Returns a list of (word, count) pairs from the dictionary
    counts_d -- but only the 10 most popular words and all words that
    are as popular."""
    
    def ValueKey(this):
        """Sort by the value."""
        return counts_d[this]

    counts_l = []
    words = sorted(counts_d, key=ValueKey)
    # taking the first 10 and any more that tie for 10th
    # but maybe there are only 10 or fewer
    number_of_words = len(words)
    for word in reversed(words):
        if number_of_words > 10 and \
               counts_d[word] < counts_d[words[-10]]:
            break
        counts_l += [(word, counts_d[word])]
    return counts_l

def GenWordReport(file_name, counts_d, total):
    """Returns a string containing the report of the words in the
    counts_d dictionary, and total words given."""
    if not total:
        return "No words found."
    counts_l = FindPopularWords(counts_d)
    ret_str = "\n%s: %d total words" % (file_name, total)
    ret_str += "\ncount  %    word\n"
    for word, hits in counts_l:
        ret_str += "%5d %.1f : %s\n" % (hits, hits * 100/total, word)
    return ret_str

def GetText(file_name):
    try:
        file_obj = open(file_name)
        try:
            text = file_obj.read()
        finally:
            file_obj.close()
    except IOError, msg:
        print >> sys.stderr, "Can't read", file_name, ':', msg
        sys.exit(1)
    return text

def PopularWordReport(file_name):
    """Driver for the program.  Returns a the popular word report for
    the file_name."""
    text = GetText(file_name)
    counts_d = {}
    total = CountWords(text, counts_d)
    print total, counts_d
    return GenWordReport(file_name, counts_d, total)

def main():
    try:
        file_name = sys.argv[1]
    except IndexError:
        file_name = 'zen.story'
    print PopularWordReport(file_name)

if __name__ == '__main__':
    main()

"""
$ lab10_3.py

zen.story: 76 total words

count  %    word
    4 5.3 : the
    4 5.3 : a
    3 3.9 : you
    3 3.9 : and
    2 2.6 : zen
    2 2.6 : without
    2 2.6 : who
    2 2.6 : to
    2 2.6 : through
    2 2.6 : that
    2 2.6 : zen
    2 2.6 : without
    2 2.6 : who
    2 2.6 : to
    2 2.6 : through
    2 2.6 : that
    2 2.6 : sword
  [more deleted]
$ cat zen.story
A general in ancient China came to see a Zen master.

He drew his sword and pointed it at the teacher, and 
announced: "Don't you know that I am a man who can 
run you through without blinking an eye?"

To which the Zen master responded instantly: "Don't 
you know that I am a man who can be run through 
without blinking an eye?"

Deeply impressed, the general sheathed his sword and 
remained for the teaching.
"""
