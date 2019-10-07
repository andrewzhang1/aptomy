#!/usr/bin/env python
"""lab02_2.py Displays the octal and hexadecimal
representation of a number"""

while True:
    try:
        number = int(raw_input("Number please: "))
        break
    except ValueError:
        print "Please try again."
        
print "Octal = %#o Hexadecimal = %#x" % (number, number)

"""
$ lab02_2.py
Number please: 17
Octal = 021 Hexadecimal = 0x11
$ 

"""
