#!/usr/bin/env python
"""Palindrom searcher.  Call with:

hw11_3.py starting_dir
"""

import os
import sys

if __name__ == '__main__':
    sys.path.insert(0, "..") 
else:                        
    sys.path.insert(0, os.path.join(os.path.split(__file__)[0], '..'))

import utils.hw11_2 as palindromizer

STARTING_DIR = '/home/marilyn/python/mm/labs/lab_11_Packages'

def FindDeepPalindromes(starting_dir):
    """Find all the palindromes in the starting_dir directory
    structure and return a dictionary of
    {palindrome:no_of_times_found} pairs.
    """
    found_d = {}
    for this_dir, dir_names, file_names in os.walk(starting_dir):
        for file_name in file_names:
            FindPalindromes(os.path.join(this_dir, file_name), found_d)
    return found_d

def FindPalindromes(whole_path, found_d):
    """Find the palindromes in this file and add them to found_d."""
    try:
        file_obj = open(whole_path)
        for line in file_obj:
            for word in line.split():
                answer = palindromizer.Palindromize(word)
                if not answer:
                    continue
                if answer in found_d:
                    found_d[answer] += [whole_path]
                else:
                    found_d[answer] = [whole_path]
    except OSError:
        pass
    finally:
        try:
            file_obj.close()
        except:
            pass

def ReportPalindromes(found_d):
    """
    Reports the one-word palindromes in all the files in the
    directory structure starting at starting_dir.
    """
    for each in found_d:
        print "%s in %d files" % (each, len(found_d[each]))

def main():
    try:
        starting_dir = sys.argv[1]
    except IndexError:
        starting_dir = STARTING_DIR
    ReportPalindromes(FindDeepPalindromes(starting_dir))

if __name__ == '__main__':
    main()

"""
$ hw11_3.py
abcba in 13 files
stats in 21 files
murderforajarofredrum in 1 files
3443 in 13 files
12321 in 13 files
neveroddoreven in 1 files
ratsliveonnoevilstar in 1 files
$ """
