#!/usr/bin/env python
"""The argument you give to your raise can be anything, a string is
most common, but a tuple is possible."""
     
import except1

def GetPositiveNumber(prompt):
    said = raw_input(prompt)
    number = float(said)
    if number < 0:
        raise ValueError, ("Number given must be positive.", number)
    return number
try:
    number = GetPositiveNumber("Positive number please: ")
except ValueError, msg:
    print "msg[0] =", msg[0]
    print "msg[1] =", msg[1]

"""
$ raise3.py
Positive number please: -1
msg[0] = Number given must be positive.
msg[1] = -1.0
$ """

    
