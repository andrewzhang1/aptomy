#!/usr/bin/env python
"""lab10_4.py starting_dir

Count and report the popular words in all the files, walking from
the starting directory.
"""
import os 
import sys 
import lab10_3 as words  

def CountFiles(stats, directory, f_names):
    for f in f_names:
        whole_path = os.path.join(directory, f)
        if os.path.isdir(whole_path):
            continue
        stats[0], stats[1] = words.CountWords(
            words.GetText(whole_path), stats[0], stats[1])
    
def PopularWordWalk(starting_dir):
    total = 0
    counts_d = {}
    for (this_dir, dir_names, file_names) in os.walk(starting_dir):
        for f_name in file_names:
            text = open(os.path.join(this_dir, f_name)).read()
            total = words.CountWords(text, counts_d, total)
    return words.GenWordReport(starting_dir, counts_d, total)

def main():
    if len(sys.argv) != 2:
        print __doc__
        sys.exit(1)
    print PopularWordWalk(sys.argv[1])

if __name__ == '__main__':
    main()
"""$ lab10_4.py ..

..: 139044 total words
count  %    word
 3316 2.4 : the
 2450 1.8 : a
[rest deleted]
"""
