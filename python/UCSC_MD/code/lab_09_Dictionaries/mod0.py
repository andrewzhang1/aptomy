#!/usr/bin/env python
"""mod0.py You can use the 'from' keyword to import a module so
that you can bring the specified attributes of the module into 
your local namespace.
""" 

from math import pi

def CalculateArea(radius):
    return pi * radius * radius

print CalculateArea(3)

"""
$ mod0.py
28.2743338823
$
"""
