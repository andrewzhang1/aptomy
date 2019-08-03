#!/usr/bin/env python
"""Making a context manager as a class from scratch."""

import sys     

class OpenClose:

    def __init__(self, file_name, mode="r"):
        self.file_name = file_name
        self.mode = mode

    def __enter__(self):
        self.obj = open(self.file_name, self.mode)
        return self.obj

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.obj.close()

def PrintFile(file_name, fail_on_read=False):
    try:
        with OpenClose(file_name) as file_object:
            for line in file_object:
                print line,
                if fail_on_read:
                    raise IOError, "Failed while reading."
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
$ ./context.py > context.out
$ diff context.out ../lab_10_File_IO_and_Packages/file2.out
$ """
