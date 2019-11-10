import xlrd

import os
import openpyxl


# print out currrent directory
mypwd = os.getcwd()
print("current dir 1= ", mypwd)

# change directory
os.chdir("C:/AGZ1/aptomy/python/CACC_2019")

mypwd = os.getcwd()
print("current dir 2= ", mypwd)