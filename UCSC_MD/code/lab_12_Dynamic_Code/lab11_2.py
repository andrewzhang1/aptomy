#!/usr/bin/env python
"""lab11_2.py
Using os.walk to accumulate total through the files walked."""

import os

import apple.work_here_.lab11_1 as totaler

def TotalDeep(starting_dir):
    """Returns (no_of_files, total) where no_of_files is the
    number of files founds in the directory structure starting at
    starting_dir, and total is the sum of all the numbers found in
    those files.
    """
    total = no_of_files = 0
    for this_dir, dir_names, file_names in os.walk(starting_dir):
        for this_file in file_names:
            path_name = os.path.join(this_dir, this_file)
            try:
                total += totaler.TotalFile(path_name)
                no_of_files += 1
                # print path_name, "so far: %d files, adding to %d" % (no_of_files, total)
            except IOError, msg:
                print path_name, msg
    return (no_of_files, total)

def main():
    stats = TotalDeep('..')
    print "That's %d files, totaling to %d." % stats

if __name__ == '__main__':
    main()

"""
$ lab11_2.py
That's 1013 files, totaling to 21572143372.
$ """

