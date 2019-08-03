# Python module to print scilab generated data
# shell command structure: python /Users/Shawn/Desktop/kinematics_data/printmodulev3.py  /Users/Shawn/Desktop/kinematics_data testjsonoutput_Result.json
# this code is executed from import_kin_data_v6sh.sce
# first result file is assumed to be _Result.txt all other figure files follow: _Result_p1.csv

import matplotlib
matplotlib.use('Agg')
import numpy as np
import matplotlib.pyplot as plt
import os
import sys
import json
import datetime
import pylab

#print 'Number of arguments:', len(sys.argv), 'arguments.'
print 'Data file to be processed by python:', str(sys.argv)

path = sys.argv[1] #'/users/shawn/desktop/kinematics_data'
filenames_fig_data = sys.argv[2]
os.chdir(path + '/resultfolder_interim')
#list_files = os.listdir(path)
#print 'Files in dir: ', list_files[0]


with open(filenames_fig_data) as data_file:
    data = json.load(data_file)

from pprint import pprint
#pprint(data)
#pprint(data["kneelat_plot"]["xlabel"])


## writing out a multipage pdf report
str = filenames_fig_data
output_filename = str.replace('.json','.pdf')
from matplotlib.backends.backend_pdf import PdfPages
pp = PdfPages(path +'/resultfolder/' +output_filename)

### Summary Results
plt.plot([0, 10],[2, 12], '.', color='gray')
font = {'family' : 'serif',
        'color'  : 'white',
        'weight' : 'normal',
        'size'   : 18,
        }
plt.text(-1, 10, data["summary"]["message"] , fontdict=font, fontsize = 18)
if len(data) < 2: #exception handling for the data is short and scilab did not process it
    plt.axis('off')
    plt.savefig(pp, format='pdf' , facecolor='gray', edgecolor='none', transparent=True)
    pp.close()
    quit()
plt.text(-1, 8, datetime.date.today(), fontdict=font)
plt.text(-1, 7, "cycling duration analyzed(min): " +data["summary"]["recording_duration_sec"], fontdict=font)
plt.text(-1, 6, "average cadence(pedal strokes/min): " +data["summary"]["ave_cadence"], fontdict=font)
plt.text(-1, 3, "sensor sample rate: " +data["summary"]["sensordata_sampling_rate"], fontdict=font)
plt.text(-1, 5, "# of pedal strokes analyzed: " +data["summary"]["num_pedal_strokes"], fontdict=font)
plt.text(-1, 4, "% of cycling data analyzed: " +data["summary"]["perc_duration_analyzed"], fontdict=font)
plt.axis('off')
plt.savefig(pp, format='pdf' , facecolor='gray', edgecolor='none', transparent=True)
plt.clf()

#### Ploting saddle height
fig, axes = plt.subplots(nrows=3, ncols=2) #fig = plt.gcf()
fig.set_size_inches(8,12) # great for setting overall page size in inches

plt.subplot2grid((3,3),(0, 0), colspan=3) # text recommendation
plt.plot([0, 5],[0, 5], 'r.', color='gray')
plt.text(-.2, 1.5, data["saddleheight_plot"]["result_print"] +"\n" , fontsize = 18, color='white')
plt.axis('off')
plt.title("Saddle height analysis", fontsize=18, color='white')

plt.subplot2grid((3,3),(1, 2), rowspan=2) # plt.subplot(2, 2, 4) # sensor path
plt.plot(data["saddleheight_plot"]["path_x"], data["saddleheight_plot"]["path_y"], '--', linewidth=2)
plt.xlabel(data["saddleheight_plot"]["xlabel_path"], fontsize=14, color='black')
plt.ylabel(data["saddleheight_plot"]["ylabel_path"], fontsize=14, color='black')
plt.grid(True)
plt.axis('equal')
plt.xticks(color = 'gray')


plt.subplot2grid((3,3),(1, 0), rowspan=2)   # knee angle
plot_rng = data["saddleheight_plot"]["rec_range"]
plt.plot(.45,data["saddleheight_plot"]["seat_height"], 'o', color='blue', markersize=25)
plt.axhspan(plot_rng[0], plot_rng[1], facecolor='g', alpha=0.5)
plt.text(0.55, data["saddleheight_plot"]["seat_height"] - 1, "saddle\nheight", fontsize=12, color='black')
#plt.annotate('local max', xy=(2, 1), xytext=(3, 1.5),arrowprops=dict(facecolor='black', shrink=0.05),)
plt.axis([0, 1, 50, 10]) #plt.ylim(0,50)
#plt.axis('equal')
plt.yticks([15, 30, 45],['too high','optimal\nrange\nin green','too low'], color='black')
plt.xticks(color = 'gray')
#plt.tight_layout()
plt.xlabel(data["saddleheight_plot"]["xlabel_bend"], fontsize=14, color='black')
plt.ylabel(data["saddleheight_plot"]["ylabel_bend"], fontsize=14, color='black')
plt.savefig(pp, format='pdf', facecolor='gray', edgecolor='none', transparent=False)
plt.clf()

### Plotting Lateral Knee Movement
fig, axes = plt.subplots()
fig.set_size_inches(8,12) # great for setting overall page size in inches

#plt.subplot2grid((3,3),(0, 0), rowspan=3) # text recommendation
plt.subplot2grid((3,3),(0, 0), colspan=3)
plt.plot([0, 5],[0, 5], 'r.', color='gray')
plt.text(-.2, 1.5, data["kneelat_plot"]["result_print"] +"\n",  fontsize = 18, color='white')
plt.axis('off')
plt.title("Side-to-side knee motion analysis", fontsize=18, color='white')

plt.subplot2grid((3,3),(1, 1), rowspan=2)
line, = plt.plot(data["kneelat_plot"]["path_z"], data["kneelat_plot"]["path_y"], '--', linewidth=2)
#line.set_dashes([10, 5, 100, 5])   # 10 points on, 5 off, 100 on, 5 off
plot_rng = data["kneelat_plot"]["rec_range"]
plt.axvspan(plot_rng[0], plot_rng[1], facecolor='g', alpha=0.5)
plt.axis('equal')
plt.xlim(-25,25)
plt.xticks(plot_rng, color='black')
plt.xlabel(data["kneelat_plot"]["xlabel"], fontsize=14, color='black')
plt.ylabel(data["kneelat_plot"]["ylabel"], fontsize=14, color='black')
#plt.title(data["kneelat_plot"]["result_print"] +"\n", fontsize=14, color='black')
#plt.tight_layout()

plt.savefig(pp, format='pdf', facecolor='gray', edgecolor='none', transparent=False)
#plt.show()
plt.clf()


pp.close()
print("successful executing of python code to export pdf report (python)")


