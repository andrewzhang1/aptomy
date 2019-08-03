#!/usr/bin/env python
"""lab02_1.py Inputs two integers and determines whether
the first is a multiple of the second. """

while True:  # True/False are keywords.   
    try:    
        number1 = int(raw_input("Number please: "))
        break
    except ValueError:
        print "Please try again."
    
while True:
    try:
        number2 = int(raw_input("Number please: "))
        break
    except ValueError:
        print "Please try again."
    
if number1 % number2 == 0:
    print '%d is a multiple of %d' % (number1, number2)
else:
    print '%d is not a multiple of %d' % (number1, number2)

"""
$ lab02_1.py
Number please: 8
Number please: 2
8 is a multiple of 2
$ lab02_1.py
Number please: 18
Number please: 17
18 is not a multiple of 17
$ """
