#!/usr/bin/env python
"""lab10_1_2.py -- lab10_1 again.  This time using the builtin file
iterator, so that all the file isn't in memory at one time, and
tempfile."""
import os
import shutil
import tempfile   
import do_swap

def Swapper(file_name, apple, orange):
    """ Changes the text in the file, replacing apples with
    oranges and oranges with apples."""
    try:
        open_file = open(file_name)
    except IOError, msg:
        print "Cannot open", file_name, 'because', msg
        return
    t_fd, t_name = tempfile.mkstemp()
    try:
        for line in open_file:
            swapped_line = do_swap.DoSwap(line, apple, orange)
            os.write(t_fd, swapped_line)
    finally:
        open_file.close()
        os.close(t_fd)
    os.rename(t_name, file_name)
        
def main():
    shutil.copy('cats.txt', 'cats2.txt')
    Swapper('cats2.txt', 'cat', 'dog')
    Swapper('www.txt', 'www', 'yyy')

if __name__ == '__main__':
    main()
"""
$ lab10_1_2.py
Can't open www.txt because [Errno 2] No such file or directory: 'www.txt'
$ cat cats2.txt

In my house we have 3 dogs who love to tease our old cat.  The old cat
gets quite bewildered when they take turns running in front of him and
getting in his way.  He steps around one dog, then the next dog, then
[The rest of the output is deleted.]"""
