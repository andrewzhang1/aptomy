

"""
Functions for callback from os.path.walk:
1.  SwapTree:  itself calls SwapCatDog (which calls DoSwap) to swap 'cat' and 'dog' within each file in a tree
2.  PrintTree: prints each file in a tree
"""


import os
import lab10_exer1


def SwapTree (arg, dname, fnames):
    """
    for each file name fname in file list fnames:
    build file spec fpath = dir name + file name;
    if not directory, apply SwapCatDog
    """

    for fname in fnames:
        fpath = os.path.join (dname, fname)
        if not os.path.isdir (fpath):
            lab10_exer1.SwapCatDog (fpath)


def PrintTree (arg, dname, fnames):
    """
    for each file name fname in file list fnames:
    build file spec fpath = dir name + file name;
    if not directory, get file content as string fstr; print fstr
    """

    for fname in fnames:
        fpath = os.path.join (dname, fname)
        if not os.path.isdir (fpath):
            try:
                fobj = file (fpath, 'r')
                fstr = fobj.read()                               # whole file as a string
                print fstr                                       # print fobj.read()
            except IOError:
                print "Error opening or reading %s" %(fpath)
            finally:
                fobj.close()


def test ():
    # walk directory tree, apply lab10_exer1.SwapCatDog to each file
    os.path.walk (
        'c:\Users\E1HL\Python\exercises\lab_10_File_IO\cats', 
        SwapTree, 
        None
        )

    # walk directory tree, print each resultant file for confirmation
    os.path.walk (
        'c:/Users/E1HL/Python/exercises/lab_10_File_IO/cats', 
        PrintTree, 
        None
        )


if __name__ == '__main__':
    test()


"""
# cats.txt

In my house we have 3 cats who love to tease our old dog.  The old dog
gets quite bewildered when they take turns running in front of him and
getting in his way.  He steps around one cat, then the next cat, then
the next cat, just to find the first cat again in his way.  However,
at nap time, they all curl up together, 3 cats and one old dog.

# cats.txt

In my house we have 3 dogs who love to tease our old cat.  The old cat
gets quite bewildered when they take turns running in front of him and
getting in his way.  He steps around one dog, then the next dog, then
the next dog, just to find the first dog again in his way.  However,
at nap time, they all curl up together, 3 dogs and one old cat.
"""
