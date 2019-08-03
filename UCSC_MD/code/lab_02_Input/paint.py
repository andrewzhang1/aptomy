#!/usr/bin/env python
"""Demonstrates formatted output, and both uses of '%'
1.  string replacement
2.  modulo
"""   
PER_GALLON = 200      # A can of paint covers 200 square feet
sq_ft = 0 
while sq_ft == 0:
    input = raw_input("Number of square feet to paint: ")
    if not input:   # or if input == '':
        print "Thank you anyway." 
        break
    try:
        sq_ft = int(input)
    except ValueError:
        print "Please give a whole number."
else:
    cans = sq_ft/PER_GALLON
    if sq_ft % PER_GALLON > 0:
        cans += 1
        print "You need %.1f cans so you'd better buy %d %s."\
              % (float(sq_ft)/PER_GALLON, cans, 
                 "can" if cans==1 else "cans")
    else:
        print "You need exactly %d %s." % (cans, 
                                           "can" if cans==1 else "cans")
"""
$ paint.py
Number of square feet to paint: 250
You need 1.2 cans so you'd better buy 2 cans.
$ paint.py
Number of square feet to paint: 201
You need 1.0 cans so you'd better buy 2 cans.
$ paint.py
Number of square feet to paint: 400
You need exactly 2 cans.
$ paint.py
Number of square feet to paint: 
Thank you anyway.
$"""
