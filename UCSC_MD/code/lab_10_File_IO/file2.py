#!/usr/bin/env python
"""Demonstrates the 'finally' clause.  It happens whether or
not there's an exception and it passes the exception up to the
surrounding try/except.

*  You cannot put an except and finally with the same try ...
   unless you are running Python 2.5+.
+  The finally clause happens, no matter what, even if there is
   a return in the try clause.
"""

def PrintFile(f_name):  
    file_obj = open(f_name)
    try:
        for line in file_obj:
            print line,
    finally:
        file_obj.close()

def main(file_name="ram.tzu"):
    try:
        PrintFile(file_name)
    except IOError, msg:
        print msg

if __name__ == '__main__':
    import sys
    try:
        main(sys.argv[1])
    except IndexError:
        main()

"""
$ file2.py
Ram Tzu know this:
When God wants you to do something,
you think it's your idea.
$ file2.py xy
[Errno 2] No such file or directory: 'xy'

$"""
