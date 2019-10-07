

"""
Run shell command 'dir', with example output:

 Volume in drive C is OSDISK 
 Volume Serial Number is 882E-57E1  

 Directory of C:\Users\E1HL\Python\exercises 

07/24/2016  08:10 AM    <DIR>          .
07/24/2016  08:10 AM    <DIR>          .. 
  . . .
07/02/2016  02:42 PM            27,807 3064_Davis_quiz6.pdf
03/08/2016  11:48 AM               347 cats.txt 
  . . . 
07/19/2016  10:37 PM    <DIR>          hw11_3 
  . . . 
07/03/2016  09:26 PM               510 lab04_exer1.py 
07/03/2016  09:26 PM             1,198 lab04_exer3.py 

              48 File(s)        316,320 bytes
               6 Dir(s)  126,411,931,648 bytes free 

Collect stdout and pipe into a file object to be read.
Parse the file sizes and sum; alternatively, parse the file names and apply os.path.getsize().
Profile both methods.
"""


import os
import sys

#if __name__ == '__main__':
#    sys.path.insert( 0, '..')
#else:
#    sys.path.insert(0, os.path.join( os.path.split( __file__)[0], '..'))
#
#import lab_11_Packages.apple.banana.total_text as total_text

import subprocess


def SumByShellDir():
    """
    """

    open_pipe = subprocess.Popen( ['cmd', '/c', 'dir'], stdout=subprocess.PIPE).stdout
    try:
        sum = 0
        for line in open_pipe.readlines():
            words = line.split()
            if len(words) >= 4 and (words[3].isdigit() or ',' in words[3]):
                size = words[3].replace( ',', '')
                sum += int( size)
        return sum
    finally:
        open_pipe.close()


def SumByOsPathGetsize():
    """
    """

    open_pipe = subprocess.Popen( ['cmd', '/c', 'dir'], stdout=subprocess.PIPE).stdout
    try:
        sum = 0
        for line in open_pipe.readlines():
            words = line.split()
            if len(words) >= 4 and (words[3].isdigit() or ',' in words[3]):
                fname = words[4]
                sum += os.path.getsize( fname)
        return sum
    finally:
        open_pipe.close()


def ProfileMethods( n):
    for i in range( n):
        SumByShellDir()
        SumByOsPathGetsize()


if __name__ == '__main__':
    import profile                          # import when testing, not when module used in Production
    profile.run( 'ProfileMethods( 10)')


"""
>>> 
=========== RESTART: C:/Users/E1HL/Python/exercises/lab12_exer2.py ===========
         6359 function calls in 2.440 seconds

   Ordered by: standard name

   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
       80    0.000    0.000    0.000    0.000 :0(Close)
       60    0.002    0.000    0.002    0.000 :0(CreatePipe)
       20    0.986    0.049    0.986    0.049 :0(CreateProcess)
       20    0.000    0.000    0.000    0.000 :0(Detach)
       60    0.000    0.000    0.000    0.000 :0(DuplicateHandle)
      120    0.000    0.000    0.000    0.000 :0(GetCurrentProcess)
       19    0.000    0.000    0.000    0.000 :0(GetExitCodeProcess)
       40    0.000    0.000    0.000    0.000 :0(GetStdHandle)
       39    0.000    0.000    0.000    0.000 :0(WaitForSingleObject)
       80    0.000    0.000    0.000    0.000 :0(add)
      220    0.000    0.000    0.000    0.000 :0(append)
       20    0.000    0.000    0.000    0.000 :0(close)
       20    0.000    0.000    0.000    0.000 :0(fdopen)
     1160    0.001    0.000    0.001    0.000 :0(isdigit)
       40    0.000    0.000    0.000    0.000 :0(isinstance)
       20    0.000    0.000    0.000    0.000 :0(join)
     1220    0.001    0.000    0.001    0.000 :0(len)
       20    0.000    0.000    0.000    0.000 :0(open_osfhandle)
        1    0.000    0.000    0.000    0.000 :0(range)
       20    1.346    0.067    1.346    0.067 :0(readlines)
       79    0.000    0.000    0.000    0.000 :0(remove)
      480    0.001    0.000    0.001    0.000 :0(replace)
        1    0.010    0.010    0.010    0.010 :0(setprofile)
     1220    0.004    0.000    0.004    0.000 :0(split)
      480    0.068    0.000    0.068    0.000 :0(stat)
        1    0.000    0.000    2.430    2.430 <string>:1(<module>)
      480    0.002    0.000    0.070    0.000 genericpath.py:55(getsize)
       10    0.005    0.001    1.176    0.118 lab12_exer2.py:23(SumByShellDir)
       10    0.005    0.000    1.254    0.125 lab12_exer2.py:59(SumByOsPathGetsize)
        1    0.000    0.000    2.430    2.430 lab12_exer2.py:76(ProfileMethods)
        1    0.000    0.000    2.440    2.440 profile:0(ProfileMethods( 10))
        0    0.000             0.000          profile:0(profiler)
       20    0.000    0.000    0.001    0.000 subprocess.py:458(_cleanup)
       20    0.001    0.000    0.001    0.000 subprocess.py:578(list2cmdline)
       20    0.001    0.000    0.996    0.050 subprocess.py:651(__init__)
       39    0.000    0.000    0.000    0.000 subprocess.py:755(__del__)
       20    0.001    0.000    0.004    0.000 subprocess.py:811(_get_handles)
       60    0.000    0.000    0.001    0.000 subprocess.py:881(_make_inheritable)
       20    0.001    0.000    0.989    0.049 subprocess.py:905(_execute_child)
       60    0.000    0.000    0.001    0.000 subprocess.py:946(_close_in_parent)
       58    0.000    0.000    0.001    0.000 subprocess.py:986(_internal_poll)
       
>>> 
"""
