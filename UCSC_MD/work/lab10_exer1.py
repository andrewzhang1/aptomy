

"""
Function to swap 'cat' and 'dog', itself calling DoSwap
"""


import shutil
import do_swap


def SwapCatDog (fname):
    """
    in file named fname, swap 'cat' and 'dog'
    """

    try:
        fobj  = file (fname, 'r')                           # fobj = open (fname, 'r')
        lines = fobj.readlines()                            # all lines in a list
    except IOError:
        print "Error opening or reading %s" %(fname)
    finally:
        fobj.close()

    try:
        fobj = file (fname, 'w')                            # fobj = open (fname, 'w')
        for line in lines:
            new_line = do_swap.DoSwap (line, 'cat', 'dog')
            fobj.write (new_line)
    except IOError:
        print "Error opening or writing %s" %(fname)
    finally:
        fobj.close()


def test ():
    """
    alternatively, / or, mixed \ and /, also understood by Python:
        'c:/Users/E1HL/Python/exercises/lab_10_File_IO/cats/cats.txt'
        'c:/Users/E1HL/Python/exercises/lab_10_File_IO/cats\cats.txt'
    """

    shutil.copy (
        'c:\Users\E1HL\Python\exercises\lab_10_File_IO\cats\cats.txt',
        'c:\Users\E1HL\Python\exercises\lab_10_File_IO\cats2.txt'
                 )
    SwapCatDog ('c:\Users\E1HL\Python\exercises\lab_10_File_IO\cats2.txt')


if __name__ == '__main__':
    test()


"""
# cats.txt

In my house we have 3 cats who love to tease our old dog.  The old dog
gets quite bewildered when they take turns running in front of him and
getting in his way.  He steps around one cat, then the next cat, then
the next cat, just to find the first cat again in his way.  However,
at nap time, they all curl up together, 3 cats and one old dog.

# cats2.txt

In my house we have 3 dogs who love to tease our old cat.  The old cat
gets quite bewildered when they take turns running in front of him and
getting in his way.  He steps around one dog, then the next dog, then
the next dog, just to find the first dog again in his way.  However,
at nap time, they all curl up together, 3 dogs and one old cat.
"""
