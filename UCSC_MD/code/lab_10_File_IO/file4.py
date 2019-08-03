#!/usr/bin/env python2.5
"""The finally can be attached to the try/except since Python 2.5"""

def PrintFile(file_name, fail_on_read=False): 
    try:                                      
        file_obj = open(file_name)            
        for line in file_obj:
            print line,
            if fail_on_read:
                raise IOError, "Failed while reading."
    except IOError, msg:
        print msg
    finally:
        try:
            file_obj.close()
        except NameError:
            pass

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
$ file4.py > file4.out
$ file3.py > file3.out
$ diff file3.out file4.out
$
"""
