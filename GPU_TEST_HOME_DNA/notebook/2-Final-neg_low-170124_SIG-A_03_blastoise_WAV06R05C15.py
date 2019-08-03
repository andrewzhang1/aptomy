
# coding: utf-8

# #### Find one cell that its neg_low is above vmzoro and one cell that its neg_low is above 0; look at the trace data for both on dvt.
# Use data set: 
# 1. 170109_ENG-SYS_02_wobbuffet_WAV13R07C12_cycle1 (check is existed: /experiments/vmzero_end/cell_anno/vmzero_end Dataset {131072) 
# 2. 170124_SIG-A_03_blastoise_WAV06R05C15  (check is existed: /experiments/vmzero_end/cell_anno/vmzero_end Dataset {131072) 
# 3. 170206_TAG_01_caterpie_WAV07R10C15 (CVC mode ==> vmzero_end is NOT existed, why?)

from os.path import abspath, dirname, join
import numpy as np
import matplotlib.pyplot as plt

import ac_analysis
from ac_analysis.model.annotations import load_from_h5


# ### 1) Load the annotation files and show the interested annotations

# 1) 170109_ENG-SYS_02_wobbuffet_WAV13R07C12_cycle1
#anno_path="/mnt/AGZ_Home_vmwin10/workspace_pOD/genia/Andrew/170109_ENG-SYS_02_wobbuffet_WAV13R07C12_cycle1/P_00_170110023618_ggc3-keeper_ac-analysis_v11.19.1/annotations.h5"

# 2) 170124_SIG-A_03_blastoise_WAV06R05C15
#anno_path="/mnt/AGZ_Home_vmwin10/workspace_pOD/genia/Andrew/170124_SIG-A_03_blastoise_WAV06R05C15/annotations.h5"
anno_path="/home/genia/rigdata/blastoise/170124_SIG-A_03_blastoise_WAV06R05C15/P_00_170124230837_ggc3-keeper_ac-analysis_v11.19.1/annotations.h5"
annos = load_from_h5(anno_path)
print "annos ==> ", annos

neg_low, units = annos.get_rep_annotation('neg_low') # Enthough enable us to grab neg_low matrix shape = (cells, reps)
print "neg_low ==> ",  neg_low, units
print "\nneg_low.shape ==> ", neg_low.shape
print "\nneg_low.size ==> ", neg_low.size # rows * columns

cells = annos.cells  #grab all cells
print "cells ==> ", cells
print "\ncells.shape ==> ", cells.shape
print "\ncells.size ==> ", cells.size 

# ### 2. Filter for neg_low

# Remove rows with only nan and zero 
#(probably dont want to just remove zeros, why?)
#mask = np.all(np.isnan(neg_low) | np.equal(neg_low, 0), axis=1) 
print "This mask only removes cells that have no reps of data. If a cell has even one rep of neg_low value recorded we keep the cell"
# Filter cells that don't complete sequencing waveform 
mask = np.all(np.isnan(neg_low), axis=1)
print "mask is ==> ", mask

filt_neg_low = neg_low[~mask]   #only get cells where neg_low is not all nan or all zero
print "\nfilt_neg_low is: ", filt_neg_low

filt_cells = cells[~mask]  #get cell names based on neg_low mask 
print "\nfilt_cells is: ", filt_cells

# Test one cell trace:
print "\n==============================\nMISC: Test a cess for'b15c7996 \n============================== "
neg_low_cell = neg_low[cells == 'b15c7996']
print "Below we can see that cell was deactivated after 3 reps, so only 3 neg_low values were recorded."
print "In order to keep numpy matrix structure, the remaining values were recorded as nan???"
print "\nneg_low_cell is: ", neg_low_cell  # What does these 3 values?


# ### 3. Get oc_calibration_vmzero

# 1) Read oc_calibration_vmzero
vmzeros, unit = annos.get_cell_annotation('oc_calibration_vmzero')
print "1) vmzeros ==> ", vmzeros, unit

# 2) Filted vmzero that elimited the nan, etc??
filt_vmzeros = vmzeros[~mask]
#plt.hist(filt_vmzeros, bins=100); plt.show()  #plot to show vmzeoro distribution
print "\n2) filt_vmzeros ==> ",  filt_vmzeros 

# 3 what you have is neg_low minus vmzero:
#    Get flatten matrix (numpy.matrix.flatten), 
#    See: https://docs.scipy.org/doc/numpy/reference/generated/numpy.matrix.flatten.html
#       https://plot.ly/numpy/ravel/

# now what you have is neg_low minus vmzero
flat_filt_neg_low = np.ravel(filt_neg_low)  #flatten matrix to array to do subtraction of vmzero 
print "3-1) flat_filt_neg_low ==> ", flat_filt_neg_low

#print flat_filt_neg_low.shape
neg_low_minus_vmzero = (filt_neg_low - filt_vmzeros[:, np.newaxis])
#print "ACTUAL FIRST ROW", neg_low_minus_vmzero[0]
#print "EXPECTED FIRST ROW" , filt_neg_low[0] - filt_vmzeros[0]

#sanity check for sign 
# plt.hist(filt_vmzeros, bins = 20); plt.show()

#confirm proper shape
print "3-3) neg_low_minus_vmzero.shape ==> ", neg_low_minus_vmzero.shape
print "3-4) flat_filt_neg_low.shape ==> ",  flat_filt_neg_low.shape

# Finally, give a value, such as : > 0, > 4, or > 5:
# How to decide? Actually we want to look for a positive number. For example, if vmzero is 120 and neg low goes to 130"
#"above" vmzero, then neg_low - vmzero will be positive e.g. 10. 

print '====== Final ======='
final_mask = np.any(neg_low_minus_vmzero > 0, axis=1)
print "FINAL mask", final_mask.shape
print "Filt cells", filt_cells.shape

final_filt_cells = filt_cells[final_mask]
print "Final Targeted Filted Cells ==> ", final_filt_cells

print "\nMISC Confirmation"
print "-------------------"
print "final_mask ==> ", final_mask
print "length of final_mask ==> ", len(final_mask)
print "filt_cells.shape    ==>  ",filt_cells.shape


# ### 4. Finally, calculate the rep(s) 

# Here is the logic

cells = [['a'], ['b']] #This would be your array of cells 
x = np.array([[1,2,3], [1,4,5]])  #this would be your neg low 
x = x[cells != 'b'] 
np.where(x > 3)

# -End

