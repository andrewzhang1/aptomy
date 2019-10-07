#!/usr/bin/env python
"""lab11_3.py tree command in python"""
import os


def GatherTree(start_at):
    """Returns a dictionary of all the paths to files and
    directories in the directory structure starting at
    start_at.  The keys are the paths, the values are either
    "directory" or "file".
    """
    node_d = {}
    for (this_dir, dir_names, file_names) in os.walk(start_at):
        node_d[this_dir] = 'directory'
        for f_name in file_names:
            node_d[os.path.join(this_dir, f_name)] = 'file'
    return node_d

def Tree(start_at):
    """Prints the directory/file  structure starting at start_at."""

    node_d = GatherTree(start_at)
    directories = 0
    files = 0
    for node in sorted(node_d):
        path, name = os.path.split(node)
        slashes = path.count(os.sep)
        print "  | " * slashes,
        if path:
            print " |--",
        if node_d[node] == 'directory':
            print os.sep + name 
            directories += 1
        else:
            print name
            files += 1
    print
    print "%d directores, %d files" % (directories, files)

def main():
    start_at = raw_input("Tree to start at which directory? ")
    Tree(start_at)

if __name__ == '__main__':
    main()

"""$ ./lab11_3.py
Tree to start at which directory? ../lab_10_File_IO/cats
  |   |-- /cats
  |   |   |-- cats.txt
  |   |   |-- /deep_cats
  |   |   |   |-- cats.txt
  |   |   |   |-- /deeper_cats
  |   |   |   |   |-- cats.txt
  |   |   |   |   |-- more_cats.txt
  |   |   |   |-- more_cats.txt
  |   |   |-- more_cats.txt

3 directores, 6 files
$ """
  
