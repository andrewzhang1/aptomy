# Script to find a few statistics values

import sys
from os.path import abspath, dirname, join
import numpy as np
#import matplotlib.pyplot as plt

import ac_analysis
from ac_analysis.model.annotations import load_from_h5

anno_path = sys.argv[1]
#anno_path = "/Volumes/AGZ_Home/workspace_pOD/genia/Andrew/170124_SIG-A_03_blastoise_WAV06R05C15"
#anno_path = "/home/genia/rigdata/arbok/170215_PEG-PORE_01_arbok_WAB16R10C17/P_00_170215205922_ggc3-keeper_ac-analysis_v11.22.1"
#anno_path = "/home/genia/rigdata/blastoise/170124_SIG-A_03_blastoise_WAV06R05C15/P_00_170124230837_ggc3-keeper_ac-analysis_v11.19.1"

annos = load_from_h5(anno_path + '/annotations.h5')
#print "annos ==> ", annos

print anno_path
#print sys.argv[1] 
neg_low, units = annos.get_rep_annotation('neg_low') # Enthough enable us to grab neg_low matrix shape = (cells, reps)
neg_high, units = annos.get_rep_annotation('neg_high')

pos_high, units = annos.get_rep_annotation('pos_high')
pos_low, units = annos.get_rep_annotation('pos_low')

# Filter the nan:
neg_high_new = neg_high[~np.isnan(neg_high)]
neg_low_new = neg_low[~np.isnan(neg_low)]

pos_high_new = pos_high[~np.isnan(pos_high)]
pos_low_new = pos_low[~np.isnan(pos_low)]

# 1) Get num_functional_seq_pores:
#annos_data = annos.get_run_annotation('num_functional_seq_pores')
#num_functional_seq_pores, unit = annos_data['num_functional_seq_pores']

# From the text_report_format.py:
#================================ 
#num functional seq pores:       {num_functional_seq_pores}
#avg homopolymer edit accuracy:  {align_average_percent_identical_weighted_edit}
#avg procession length:          {avg_procession_length}
#N50 procession length:          {n50_statistic}
#total procession length:        {aggregate_base_count}


annos_data = annos.get_run_annotations(['align_average_percent_identical_weighted_edit',\
                                        'num_functional_seq_pores',\
                                        'avg_procession_length',\
                                        'n50_statistic',\
                                        'aggregate_base_count'])

num_functional_seq_pores, unit = annos_data['num_functional_seq_pores']
avg_homopolymer_edit_accuracy, unit = annos_data['align_average_percent_identical_weighted_edit'] 
avg_procession_length, unit = annos_data['avg_procession_length']
N50_procession_length, unit = annos_data['n50_statistic']
total_procession_length, unit = annos_data['aggregate_base_count']

print "anno_path","1-neg_high_max", "2-neg_high_min", "3-neg_low_max", "4-neg_low_min", "5-pos_high_max", "6-pos_high_min", "7-pos_low_max", "8-pos_low_min", "9-num_functional_seq_pores", "10-avg_homopolymer_edit_accuracy", "11-avg_procession_length", "12-N50_procession_length", "13-total_procession_length", "14-neg_low_mean", "15-neg_low_std","16-neg_low_var"

# This command seems getting different values:
print anno_path, neg_high_new.max(), neg_high_new.min(), neg_low_new.max(), neg_low_new.min(), pos_high_new.max(), pos_high_new.min(), pos_low_new.max(), pos_low_new.min(), num_functional_seq_pores, avg_homopolymer_edit_accuracy, avg_procession_length, N50_procession_length, total_procession_length, neg_low_new.mean(), neg_low_new.std(), neg_low_new.var()

print "\nDone with anno_path: ", anno_path

