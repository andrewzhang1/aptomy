# Script Name: test.annotation.py
# Andrew Zhang
# Feb. 2017

# Purpose: Automate the part of the analysis and visualization for the h5 files.
# Command line:
# python test.annotation.py /home/genia/rigdata/wobbuffet/170109_ENG-SYS_02_wobbuffet_WAV13R07C12_cycle1/chunked_raw_data/bank08/raw

import sys, string, os
import h5py
import numpy as np
import matplotlib.pyplot as plt

def main():
    #path_name=sys.argv[1]
    path_name = '/home/genia/rigdata/wobbuffet/170109_ENG-SYS_02_wobbuffet_WAV13R07C12_cycle1/chunked_raw_data/bank00/raw'

# path_name=/home/genia/rigdata/wobbuffet/170109_ENG-SYS_02_wobbuffet_WAV13R07C12_cycle1/chunked_raw_data/bank00/raw

#'''
#path1=/home/genia/rigdata/wobbuffet/170109_ENG-SYS_02_wobbuffet_WAV13R07C12_cycle1/chunked_raw_data
    f = h5py.File(path_name + '/oc_calibration.h5')
    cnames = f['cells'].keys()

    print "We are looking at: ", path_name
    print "\n==================="

    print "\n==================="
    print "1) The sub-dir for oc_calibration.h5 is: ", f.keys() 

#    print "2) The oc_calibration.h5.cells.keys() is: ", f['cells'].keys() # Why it starts at b00c0006?
    cell_b00c4619=f['cells/b00c4619'].value
    
    print "\n==================="
    print "3) cell_b00c4619 is: ", cell_b00c4619 # The meaning for 0, 113..., 77?
#    cell_b00c4619_size=f['cells/b00c4619'].size  
    #print "4) cell_b00c4619_size is: ", cell_b00c4619_size # size is 29018; why it's the same as f['cells/b00c4619'].value.size?

    print "\n==================="
    #Check oc_calibration.h5/other_traces:
    #f['other_traces'].keys()
    print "other_traces is: \n ", f['other_traces'].keys()
    ts=f['other_traces/timestamp'].value

    print "\n==================="
    print "5) other_traces/timestamp'].value is: ", ts
    print "6) The size of the \"other_traces/timestamp'].value\" is: ", ts.size

    print "7) f['other_traces/liq'].value[100:] is: ", f['other_traces/liq'].value[100:]

    print "8) Start to plot the scatter for cells/b00c4619:"
    print "\n==================="
    data=f['cells/b00c4619'].value
#    print "The value for cells/b00c4619 is: ", data

    ts=f['other_traces/timestamp'].value
    plt.scatter(ts,data)
#   plt.show()

#dirname+bank = '/home/genia/rigdata/wobbuffet/170109_ENG-SYS_02_wobbuffet_WAV13R07C12_cycle1/chunked_raw_data/bank00'

    #exit

#'''# 
# cnames = f['cells'].keys()
#cell_b00c4619
    print "Check mulit_ubf.h5\n"
    print "cnames[0:10] is: ", cnames[0:4]
    k = 0
    for cellname in cnames[0:2]:
        bank = 'bank' + cellname
        k += 1
        print k, cellname, bank
        #h5name = dirname+bank+'/raw/multi_ubf.h5'
        h5name = path_name + '/multi_ubf.h5' 
        crd=h5py.File(h5name,'r')
        adc=np.asarray(crd['cells/{}'.format(cellname)],dtype=int)
        vap=np.asarray(crd['other_traces/half_cycle_flag'],dtype=int)
        tym=np.asarray(crd['other_traces/timestamp'],dtype=int)
        print "adc is: ", adc
        print "vap is: ", vap
        print "adc is: ", adc
        print "tym is: ", tym


# '''
#    plt.show()
if __name__ == '__main__':
    main()

