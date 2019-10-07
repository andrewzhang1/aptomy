

"""
Function for callback from os.path.walk:
    TotalTree: itself calls TotalFile to sum numeric strings in the file
"""


import os
import lab11_exer1


def TotalTree (arg, dname, fnames):
    """
    for each file name fname in fnames:
    build file spec fpath = dir name + file name;
    if not directory, apply TotalFile
    """

    for fname in fnames:
        fpath = os.path.join (dname, fname)
        if not os.path.isdir (fpath):
            arg[0] += 1
            arg[1] += lab11_exer1.TotalFile (fpath)


def test ():
    # stats = [number of files, total in files]
    stats = [0, 0]
    
    # walk directory tree from current directory, apply TotalFile to each file
    os.path.walk (
        '.',
        TotalTree,
        stats
        )

    print "%d files with total %f" %(stats[0], stats[1])


if __name__ == '__main__':
    test ()


"""
>>> 
=========== RESTART: C:\Users\E1HL\Python\exercises\lab11_exer2.py ===========
76 files with total 4350826808.940302
>>> 
"""
