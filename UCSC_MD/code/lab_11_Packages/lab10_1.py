#!/usr/bin/env python
"""lab10_1.py Copy the cats.txt into your area.  Change the file so
that all the cats become dogs and dogs become cats."""

import do_swap
import shutil  

def Swapper(file_name, apple, orange):
    """ Changes the text in the file, replacing apples with
    oranges and oranges with apples."""
    try:
        open_file = open(file_name, "r+")
    except IOError, msg:
        print "Can't open", file_name, 'because', msg
        return
    try:  # Putting the whole file in memory!
        text = open_file.read()  
        text = do_swap.DoSwap(text, apple, orange)
        open_file.seek(0, 0)
        open_file.truncate() 
        open_file.write(text)
    finally:
        open_file.close()

def main():
    shutil.copy('cats.txt', 'cats2.txt')
    Swapper('cats2.txt', 'cat', 'dog')
    Swapper('www.txt', 'www', 'yyy')

if __name__ == '__main__':
    main()
"""
$ lab10_1.py
Can't open www.txt because [Errno 2] No such file or directory: 'www.txt'
$ cat cats2.txt

In my house we have 3 dogs who love to tease our old cat.  The old cat
gets quite bewildered when they take turns running in front of him and
getting in his way.  He steps around one dog, then the next dog, then
the next dog, just to find the first dog again in his way.  However,
at nap time, they all curl up together, 3 dogs and one old cat.
"""
