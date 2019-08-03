# Andrew Feb. 2017

# Purpose: Automate the part of the analysis and visualization for the h5 files.
# Command line:
# python test.annotation.py /home/genia/rigdata/wobbuffet/170109_ENG-SYS_02_wobbuffet_WAV13R07C12_cycle1/chunked_raw_data/bank08/raw

import sys, string, os
from os.path import abspath, dirname, join
import h5py
import numpy as np
import matplotlib.pyplot as plt
from os.path import abspath, dirname, join

import ac_analysis
#DATA_PATH = join(dirname(abspath(ac_analysis.__file__)), 'tests', 'data')

def main():
    print "Hi, there!\n"    
    path_name = '/home/genia/rigdata/wobbuffet/170109_ENG-SYS_02_wobbuffet_WAV13R07C12_cycle1/P_00_170110023618_ggc3-keeper_ac-analysis_v11.19.1'

    f = h5py.File(path_name + '/annotations.h5')
    print "the sub-dir of annotaions.h5 is: ", f .keys()
    
    
if __name__ == '__main__':
    main()

