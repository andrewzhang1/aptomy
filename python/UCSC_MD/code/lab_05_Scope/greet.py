#!/usr/bin/env python
"""Demonstrates keyword arguments"""

def Greet(first, last): 
    print 'Hello', first, last

Greet('Rocky','The Squirrel')
Greet(last='Moose', first='Bullwinkle')

"""
$ greet.py
Hello Rocky The Squirrel
Hello Bullwinkle Moose
$ 
"""
