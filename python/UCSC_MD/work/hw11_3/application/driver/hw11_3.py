

"""
Example of finding word palindromes in all files in a directory tree
Uses: module packaging, directory walking, file I/O, exception handling, string manipulation
"""


# OS level preparation to import modules in directory tree search
#   current directory is location of this script
#       C:/Users/E1HL/Python/exercises/hw11_3/application/driver
#   search root will be
#       C:/Users/E1HL/Python/exercises/hw11_3/application
#   create a file __init__.py in subdirectories from search root
#   to directories containing modules to be imported
#       C:/Users/E1HL/Python/exercises/hw11_3/application/utils

import os
import sys

# set search root in sys.path
#       C:/Users/E1HL/Python/exercises/hw11_3/application
# which is '..' relative to current directory '.'
#       sys.path = ['..', 'C:\\Users\\E1HL\\Python\\exercises\\hw11_3\\application\\driver', ...]
if __name__ == '__main__':
    sys.path.insert( 0, '..')
else:
    sys.path.insert( 0, os.path.join( os.path.split( __file__)[0], '..'))

import utils.hw11_2 as pallib


def StartDir():
    """
    Input:   interactively, get starting directory
    Returns: directory path entered or, exit if null or user escapes
    """

    while True:
        try:
            dpath = raw_input( "Enter directory path (or null to quit): ")
            if dpath:
                if not os.path.isdir( dpath):
                    print "%s is not a valid directory path" % (dpath)
                else:
                    return dpath
            else:
                sys.exit()
        except (KeyboardInterrupt, EOFError):
            sys.exit()


def ShowPalindromesInFile( fpath):
    """
    Input:   file path
    Returns: palindrome words in the file
    """

    # function to filter words for palindrome testing, for example:
    #   disallow uninteresting words like: docstring quotes, '<<<', '==='
    #   allow alphanumeric words and periods: 'abba', 123.321
    def Filtered( word):
        good_chars = "."
        for char in word:
            if not char.isalnum() and char not in good_chars:
                return None
        return word

    try:
        fobj = file( fpath, 'r')
        for line in fobj:
            for word in line.split():
                if Filtered( word):
                    if pallib.Palindromize( word):
                        print "File %s has palindrome word '%s'" % (fpath, word)
    except (NameError, IOError):
        print "Error opening or reading file %s" % (fpath)
    except:
        print "Unexpected error: ", sys.exc_info()
        raise
    finally:
        fobj.close()


def ShowPalindromesInTree( dpath):
    """
    Input:   directory path
    Returns: palindrome words in files in the directory tree
    """

    # callback function for os.path.walk()
    def GetPalindromesInFiles( arg, dname, fnames):
        for fname in fnames:
            fpath = os.path.join( dname, fname)
            if os.path.isfile( fpath):
                ShowPalindromesInFile( fpath)

    os.path.walk( dpath, GetPalindromesInFiles, None)


def main():
    try:
        dpath = sys.argv[1]
    except IndexError:
        dpath = StartDir()

    ShowPalindromesInTree( dpath)


if __name__ == '__main__':
    main()


"""
>>> 
 RESTART: C:\Users\E1HL\Python\exercises\hw11_3\application\driver\hw11_3.py 
Enter directory path (or null to quit): C:\Users\E1HL\Python\exercises\hw11_3\application
File C:\Users\E1HL\Python\exercises\hw11_3\application\driver\hw11_3.py has palindrome word 'level' 
File C:\Users\E1HL\Python\exercises\hw11_3\application\driver\hw11_3.py has palindrome word 'sys' 
File C:\Users\E1HL\Python\exercises\hw11_3\application\driver\hw11_3.py has palindrome word '123.321'
>>> 
"""
