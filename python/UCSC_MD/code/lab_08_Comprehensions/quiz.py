#!/usr/bin/env python
"""  Quiz 2 (Lab 08) answers 
>>> x = 3
>>> y = x
>>> x = 8
>>> print y
3

>>> x = [1, 2, 3]
>>> y = x
>>> x[1] = 8
>>> print y
[1, 8, 3]

>>> x = (8, 88)
>>> y
[1, 8, 3]

>>> x = "123"
>>> y = x
>>> x = "abc"
>>> y
'123'
"""

print "\n2. Program \n"

for n in range(6):
    for m in range(6):
        print "%4d" % (n*m),
    print
"""
$ quiz.py

2. Program 

   0    0    0    0    0    0
   0    1    2    3    4    5
   0    2    4    6    8   10
   0    3    6    9   12   15
   0    4    8   12   16   20
   0    5   10   15   20   25
$ """
