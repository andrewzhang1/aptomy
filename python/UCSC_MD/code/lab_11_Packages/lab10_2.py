#!/usr/bin/env python
"""lab10_2.py  Uses os.walk() and the previous exercise
to change all the cats to dogs and dogs to cats through
a directory structure."""

import os
import sys
import shutil
import lab10_1 as swapper   # was the previous exercise

def SwapTextFiles(starting_dir, swappers):
    """ Changes the text in a files in the starting_dir 
    directory structure. swappers is a tuple of strings
    to swap.
    """
    try:
        apple, orange = swappers
    except ValueError:  # or maybe let the error raise
        print >> sys.stderr, 'swappers must be a 2-tuple of words to swap'
        sys.exit(1)

    for (this_dir, dir_names, file_names) in os.walk(starting_dir):
        for file_name in file_names:
            file_name = os.path.join(this_dir, file_name)
            swapper.Swapper(file_name, apple, orange)
            
def PrintDeepFiles(starting_dir):
    for (this_dir, dir_names, file_names) in os.walk(starting_dir):
        for file_name in file_names:
            file_name = os.path.join(this_dir, file_name)
            if not os.path.isfile(file_name):
                continue
            print file_name + ':'
            file_object = open(file_name)
            for line in file_object:
                print line,
            file_object.close()
            print "---"

def main():
    if len(sys.argv) > 1:
        starting_dir = sys.argv[1]
    else:
        try:
            shutil.rmtree("cats2")
        except OSError: # not there
            pass
        shutil.copytree("./cats", "./cats2")
        starting_dir = 'cats2'
    PrintDeepFiles(starting_dir)
    SwapTextFiles(starting_dir, ('cat', 'dog'))
    PrintDeepFiles(starting_dir)

if __name__ == '__main__':
    main()
"""
$ lab10_2.py
cats2/cats.txt:

In my house we have 3 cats who love to tease our old dog.  The old dog
gets quite bewildered when they take turns running in front of him and
getting in his way.  He steps around one cat, then the next cat, then
the next cat, just to find the first cat again in his way.  However,
at nap time, they all curl up together, 3 cats and one old dog.

---
cats2/more_cats.txt:

In my house we have 3 cats who love to tease our old dog.  The old dog

[much skipped]

---
cats2/deep_cats/deeper_cats/more_cats.txt:

In my house we have 3 dogs who love to tease our old cat.  The old cat
gets quite bewildered when they take turns running in front of him and
getting in his way.  He steps around one dog, then the next dog, then
the next dog, just to find the first dog again in his way.  However,
at nap time, they all curl up together, 3 dogs and one old cat.

---
$"""
