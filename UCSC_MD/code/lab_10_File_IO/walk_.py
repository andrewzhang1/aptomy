#!/usr/bin/env python
"""walk_.py -- Demonstrates the os.walk function, one of many
very useful things given to us in the os module"""

import time  
import os 
        
def Process(this_dir, dir_names, file_names):
    print "In", os.path.abspath(this_dir)
    for file_name in sorted(dir_names + file_names):
        whole_name = os.path.join(this_dir, file_name)
        if os.path.isdir(whole_name):
            print '    directory:', file_name
        else:
            print '    %s:\n        %s' % (file_name, time.ctime( 
                os.path.getmtime(whole_name)))
            
if __name__ == '__main__':
    for (this_dir, dir_names, file_names) in os.walk('cats'):
        Process(this_dir, dir_names, file_names)


"""$ walk_.py
In /home/marilyn/python/mm/labs/lab_10_File_IO/cats
    cats.txt:
        Thu Jun 18 16:21:33 2009
    directory: deep_cats
    more_cats.txt:
        Thu Jun 18 16:21:33 2009
In /home/marilyn/python/mm/labs/lab_10_File_IO/cats/deep_cats
    cats.txt:
        Thu Jun 18 16:21:33 2009
    directory: deeper_cats
    more_cats.txt:
        Thu Jun 18 16:21:33 2009
In /home/marilyn/python/mm/labs/lab_10_File_IO/cats/deep_cats/deeper_cats
    cats.txt:
        Thu Jun 18 16:21:33 2009
    more_cats.txt:
        Thu Jun 18 16:21:33 2009
$
"""
