#!/usr/bin/env python
"""Demonstrates the 'finally' clause -- and making it happen.
"""    

def PrintFile(file_name, fail_on_read=False):
    try:
        open_file = file(file_name)  # file is an alias for open
        try:                 
            for line in open_file:
                print line,
                if fail_on_read:
                    raise IOError, "Failed while reading."
        finally:
            open_file.close()
    except IOError, msg:
        print msg
        
def main(file_name="ram.tzu"):
    print """\n    PrintFile("%s")""" % (file_name)
    PrintFile(file_name)
    print """\n    PrintFile("%s", fail_on_read=True)""" % (file_name)
    PrintFile(file_name, fail_on_read=True)
    print """\n    PrintFile("absent_file")"""
    PrintFile("absent_file")

if __name__ == '__main__':
    main()

"""  
$ file3.py

    PrintFile("ram.tzu")
Ram Tzu knows this:
When God wants you to do something,
you think it's your idea.

    PrintFile("ram.tzu", fail_on_read=True)
Ram Tzu knows this:
Failed while reading.

    PrintFile("absent_file")
[Errno 2] No such file or directory: 'absent_file'
$


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
Notes on raising exceptions.  Usually you want to use a
built-in exception.

To see all the built-in exceptions:

>>> import exceptions
>>> help(exceptions)

or   

>>> help('exceptions')

"""
