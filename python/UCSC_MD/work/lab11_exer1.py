

"""
Module lab11_exer1.py
"""


# OS level preparation to import modules in below directory tree search
#   current directory is location of this script (in __file__)
#       C:/Users/E1HL/Python/exercises
#   create a file __init__.py in subdirectories
#       C:/Users/E1HL/Python/exercises/lab_11_Packages
#       C:/Users/E1HL/Python/exercises/lab_11_Packages.apple
#       C:/Users/E1HL/Python/exercises/lab_11_Packages.apple.banana


#import sys


#if __name__ == '__main__':
#    sys.path.insert( 0, '..')
#else:
#    sys.path.insert(0, os.path.join( os.path.split( __file__)[0], '..'))

#try:
#    sys.path.insert(0, os.path.join( os.path.split( __file__)[0], '..'))
#except NameError:
#    sys.path.insert( 0, '..')


import lab_11_Packages.apple.banana.total_text as tt


def GetFile ():
    """
    Input:   interactively, a file path
    Returns: file path
    """

    while True:
        try:
            fpath = raw_input ("Enter file path (or null to quit): ")
            if fpath:
                return fpath
            else:
                break
        except (KeyboardInterrupt, EOFError):
            break


def TotalFile (fpath):
    """
    Input:   a file path
    Returns: sum of numeric strings in the file
    """

    if fpath:
        try:
            fobj = file (fpath, 'r')
            return tt.TotalText (fobj.read())      # whole file as a string, as expected by TotalText
        except (NameError, IOError):
            print "Error opening or reading file %s" %(fpath)
        except:
            print "Unexpected error:", sys.exc_info()[0]
            raise
        finally:
            fobj.close()
    else:
        return None


if __name__ == '__main__':
    fpath = GetFile()
    if fpath:
        total = TotalFile (fpath)
        print "File %s has total %f" %(fpath, total)
    else:
        print "No file path"


"""
>>> 
=========== RESTART: C:\Users\E1HL\Python\exercises\lab11_exer1.py ===========
Enter file path (or null to quit): C:\Users\E1HL\Python\exercises\lab_11_Packages\numbers.txt
File C:\Users\E1HL\Python\exercises\lab_11_Packages\numbers.txt has total 205.800000
>>> 
"""
