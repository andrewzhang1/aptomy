#!/usr/bin/env python
"""
find_.py starting_dir pattern

(be sure to escape the pattern: \*.py.  Or put it in quotes: '*.py')

finds the files in the directories starting at starting_dir that match
the pattern.  Demonstrates the glob module.

The glob module provides a way to find files that match a given
pattern with simple shell-style wildcards.

Here we use glob and os.walk to find all the files in a directory
structure that match the pattern, just like the 'find' command in unix.

"""
import glob   
import os
import sys

def FindDeep(starting_dir, pattern):
    """Prints all the files that match the pattern in all the
    directories in the directory structure rooted at starting_dir.
    """
    for this_dir, dir_names, file_names in os.walk(starting_dir):
        result = glob.glob(os.path.join(this_dir, pattern))
        if result:
            print this_dir  + ':'
            dlen = len(this_dir)
            for each in result:
                print '   ' + each[dlen:]
def main():
    if len(sys.argv) == 3:
        FindDeep(sys.argv[1], sys.argv[2])
    else:
        print __doc__

if __name__ == '__main__':
    main()
"""
$ find_.py .. "*.py"
../lab_06_Sequences:
   /key_sort.py    [much deleted]"""
